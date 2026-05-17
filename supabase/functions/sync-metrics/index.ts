// sync-metrics — refreshes metrics for a single social account.
//
// POST /functions/v1/sync-metrics
//   Headers:  Authorization: Bearer <supabase_user_jwt>
//   Body:     { "account_id": "<uuid>" }
//   Returns:  { "captured_at": "<iso>", "snapshot": { ... } }
//
// Only YouTube is wired in this PR (M3c). Other platforms return 501
// and will be filled in by their own M3d+ PRs.

import { createClient, SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.45.0";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const YT_CLIENT_ID = Deno.env.get("YOUTUBE_OAUTH_CLIENT_ID")!;
const YT_CLIENT_SECRET = Deno.env.get("YOUTUBE_OAUTH_CLIENT_SECRET")!;

interface SyncRequest {
  account_id?: string;
}

interface SocialAccountRow {
  id: string;
  workspace_id: string;
  platform: string;
  external_id: string;
  access_token_encrypted: string | null;
  refresh_token_encrypted: string | null;
  expires_at: string | null;
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return json({ error: "missing_authorization" }, 401);
  }

  let body: SyncRequest;
  try {
    body = await req.json();
  } catch {
    return json({ error: "invalid_json" }, 400);
  }
  const accountId = body.account_id?.trim();
  if (!accountId) return json({ error: "missing_account_id" }, 400);

  // Membership check via the caller's JWT.
  const userClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: authHeader } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: visible } = await userClient
    .from("social_accounts")
    .select("id")
    .eq("id", accountId)
    .maybeSingle();
  if (!visible) return json({ error: "not_a_member_or_missing" }, 403);

  // Token reads + writes require service role (decrypted view).
  const service = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: account, error } = await service
    .from("social_accounts_decrypted")
    .select(
      "id, workspace_id, platform, external_id, access_token_encrypted, "
        + "refresh_token_encrypted, expires_at",
    )
    .eq("id", accountId)
    .maybeSingle();
  if (error || !account) return json({ error: "account_not_found" }, 404);

  switch ((account as SocialAccountRow).platform) {
    case "youtube":
      return syncYouTube(service, account as SocialAccountRow);
    case "instagram":
      return syncInstagram(service, account as SocialAccountRow);
    default:
      return json({ error: "platform_not_implemented" }, 501);
  }
});

async function syncYouTube(
  service: SupabaseClient,
  account: SocialAccountRow,
): Promise<Response> {
  const accessToken = await ensureFreshAccessToken(service, account);
  if (!accessToken) return json({ error: "token_refresh_failed" }, 401);

  const statsRes = await fetch(
    `https://www.googleapis.com/youtube/v3/channels?part=statistics&id=${account.external_id}`,
    { headers: { Authorization: `Bearer ${accessToken}` } },
  );
  if (!statsRes.ok) {
    const detail = await statsRes.text();
    return json({ error: "youtube_api_error", detail }, 502);
  }
  const statsJson = await statsRes.json() as {
    items?: Array<{
      statistics?: {
        viewCount?: string;
        subscriberCount?: string;
        videoCount?: string;
      };
    }>;
  };
  const stats = statsJson.items?.[0]?.statistics;
  if (!stats) return json({ error: "no_statistics" }, 404);

  const followers = parseInt(stats.subscriberCount ?? "0", 10);
  const posts = parseInt(stats.videoCount ?? "0", 10);
  const impressions = parseInt(stats.viewCount ?? "0", 10);
  const capturedAt = new Date().toISOString();

  const snapshot = {
    social_account_id: account.id,
    captured_at: capturedAt,
    followers,
    posts,
    impressions,
    raw: stats,
  };

  const { error: insertErr } = await service
    .from("metrics_snapshots")
    .insert(snapshot);
  if (insertErr) return json({ error: insertErr.message }, 500);

  await service
    .from("social_accounts")
    .update({ last_synced_at: capturedAt })
    .eq("id", account.id);

  return json({ captured_at: capturedAt, snapshot }, 200);
}

async function syncInstagram(
  service: SupabaseClient,
  account: SocialAccountRow,
): Promise<Response> {
  const token = account.access_token_encrypted;
  if (!token) return json({ error: "no_token" }, 401);

  // Account-level fields: followers_count + media_count + name.
  const userRes = await fetch(
    `https://graph.facebook.com/v21.0/${account.external_id}?fields=followers_count,media_count&access_token=${token}`,
  );
  if (!userRes.ok) {
    return json({ error: "instagram_api_error", detail: await userRes.text() }, 502);
  }
  const user = await userRes.json() as {
    followers_count?: number;
    media_count?: number;
  };

  // 7-day rolling insights for engagement signal.
  let reach: number | null = null;
  let impressions: number | null = null;
  const since = Math.floor(Date.now() / 1000) - 7 * 24 * 60 * 60;
  const until = Math.floor(Date.now() / 1000);
  const insightsRes = await fetch(
    `https://graph.facebook.com/v21.0/${account.external_id}/insights?metric=reach,impressions&period=day&since=${since}&until=${until}&access_token=${token}`,
  );
  if (insightsRes.ok) {
    const ins = await insightsRes.json() as {
      data?: Array<{
        name: string;
        values: Array<{ value: number }>;
      }>;
    };
    for (const m of ins.data ?? []) {
      const total = m.values.reduce((a, v) => a + (v.value ?? 0), 0);
      if (m.name === "reach") reach = total;
      if (m.name === "impressions") impressions = total;
    }
  }

  const capturedAt = new Date().toISOString();
  const snapshot = {
    social_account_id: account.id,
    captured_at: capturedAt,
    followers: user.followers_count ?? null,
    posts: user.media_count ?? null,
    reach,
    impressions,
    raw: { user },
  };

  const { error: insertErr } = await service
    .from("metrics_snapshots")
    .insert(snapshot);
  if (insertErr) return json({ error: insertErr.message }, 500);

  await service
    .from("social_accounts")
    .update({ last_synced_at: capturedAt })
    .eq("id", account.id);

  return json({ captured_at: capturedAt, snapshot }, 200);
}

/// Returns a valid access token. If the stored token is expired,
/// refreshes it using refresh_token_encrypted and persists the new
/// access token + expiry.
async function ensureFreshAccessToken(
  service: SupabaseClient,
  account: SocialAccountRow,
): Promise<string | null> {
  const expiresAt = account.expires_at ? new Date(account.expires_at) : null;
  const skewMs = 60_000; // refresh 1 min before nominal expiry
  if (
    account.access_token_encrypted
    && expiresAt
    && expiresAt.getTime() - Date.now() > skewMs
  ) {
    return account.access_token_encrypted;
  }
  if (!account.refresh_token_encrypted) return null;

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "content-type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: YT_CLIENT_ID,
      client_secret: YT_CLIENT_SECRET,
      refresh_token: account.refresh_token_encrypted,
      grant_type: "refresh_token",
    }),
  });
  if (!res.ok) return null;
  const tokens = await res.json() as {
    access_token: string;
    expires_in: number;
  };
  const newExpiresAt = new Date(Date.now() + tokens.expires_in * 1000)
    .toISOString();

  await service
    .from("social_accounts")
    .update({
      access_token_encrypted: tokens.access_token,
      expires_at: newExpiresAt,
    })
    .eq("id", account.id);

  return tokens.access_token;
}

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json" },
  });
}
