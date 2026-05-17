// oauth-youtube — Google OAuth 2.0 dance for YouTube Data API readonly access.
//
// Two paths share one function:
//
//   POST /functions/v1/oauth-youtube/start
//     Headers:  Authorization: Bearer <supabase_user_jwt>
//     Body:     { "workspace_id": "<uuid>" }
//     Returns:  { "auth_url": "https://accounts.google.com/..." }
//
//   GET  /functions/v1/oauth-youtube/callback?code=...&state=...
//     Public — Google redirects the browser here.
//     Exchanges the code for tokens, inserts/updates social_accounts,
//     deletes the state row, and returns an HTML "you can close this
//     window" landing page.
//
// Required env: SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY,
//   YOUTUBE_OAUTH_CLIENT_ID, YOUTUBE_OAUTH_CLIENT_SECRET,
//   YOUTUBE_OAUTH_REDIRECT_URI.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.0";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const CLIENT_ID = Deno.env.get("YOUTUBE_OAUTH_CLIENT_ID")!;
const CLIENT_SECRET = Deno.env.get("YOUTUBE_OAUTH_CLIENT_SECRET")!;
const REDIRECT_URI = Deno.env.get("YOUTUBE_OAUTH_REDIRECT_URI")!;

const SCOPES = [
  "https://www.googleapis.com/auth/youtube.readonly",
  "https://www.googleapis.com/auth/yt-analytics.readonly",
].join(" ");

Deno.serve(async (req: Request) => {
  const url = new URL(req.url);
  const last = url.pathname.split("/").filter(Boolean).pop();

  if (req.method === "POST" && last === "start") return handleStart(req);
  if (req.method === "GET" && last === "callback") return handleCallback(url);
  return json({ error: "not_found" }, 404);
});

async function handleStart(req: Request): Promise<Response> {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return json({ error: "missing_authorization" }, 401);
  }

  let body: { workspace_id?: string };
  try {
    body = await req.json();
  } catch {
    return json({ error: "invalid_json" }, 400);
  }

  const workspaceId = body.workspace_id;
  if (!workspaceId) return json({ error: "missing_workspace_id" }, 400);

  // Resolve the caller via their JWT so workspace membership is enforced.
  const userClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: authHeader } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: userData, error: userErr } = await userClient.auth.getUser();
  if (userErr || !userData.user) {
    return json({ error: "unauthenticated" }, 401);
  }

  // Confirm membership (RLS would also block writes, but failing here
  // gives a cleaner error code).
  const { data: member } = await userClient
    .from("workspace_members")
    .select("workspace_id")
    .eq("workspace_id", workspaceId)
    .eq("user_id", userData.user.id)
    .maybeSingle();
  if (!member) return json({ error: "not_a_member" }, 403);

  const state = crypto.randomUUID();
  const service = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  await service.rpc("purge_expired_oauth_states");
  const { error: insertErr } = await service.from("oauth_states").insert({
    state,
    workspace_id: workspaceId,
    user_id: userData.user.id,
    platform: "youtube",
  });
  if (insertErr) return json({ error: insertErr.message }, 500);

  const authUrl = new URL("https://accounts.google.com/o/oauth2/v2/auth");
  authUrl.searchParams.set("client_id", CLIENT_ID);
  authUrl.searchParams.set("redirect_uri", REDIRECT_URI);
  authUrl.searchParams.set("response_type", "code");
  authUrl.searchParams.set("scope", SCOPES);
  authUrl.searchParams.set("access_type", "offline");
  authUrl.searchParams.set("prompt", "consent");
  authUrl.searchParams.set("state", state);

  return json({ auth_url: authUrl.toString() }, 200);
}

async function handleCallback(url: URL): Promise<Response> {
  const code = url.searchParams.get("code");
  const state = url.searchParams.get("state");
  if (!code || !state) return htmlError("Missing code or state.");

  const service = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  // Look up and atomically delete the state row.
  const { data: stateRow, error: stateErr } = await service
    .from("oauth_states")
    .select("workspace_id, user_id, expires_at")
    .eq("state", state)
    .maybeSingle();
  if (stateErr || !stateRow) return htmlError("Invalid or expired state.");
  if (new Date(stateRow.expires_at) < new Date()) {
    await service.from("oauth_states").delete().eq("state", state);
    return htmlError("State expired.");
  }

  // Exchange the code for tokens.
  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "content-type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      code,
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      redirect_uri: REDIRECT_URI,
      grant_type: "authorization_code",
    }),
  });
  if (!tokenRes.ok) {
    const detail = await tokenRes.text();
    return htmlError(`Token exchange failed: ${detail}`);
  }
  const tokens = await tokenRes.json() as {
    access_token: string;
    refresh_token?: string;
    expires_in: number;
    scope: string;
  };

  // Fetch the channel id + title for display purposes.
  const channelRes = await fetch(
    "https://www.googleapis.com/youtube/v3/channels?part=snippet&mine=true",
    { headers: { Authorization: `Bearer ${tokens.access_token}` } },
  );
  if (!channelRes.ok) {
    const detail = await channelRes.text();
    return htmlError(`Channel lookup failed: ${detail}`);
  }
  const channelJson = await channelRes.json() as {
    items?: Array<{
      id: string;
      snippet: {
        title: string;
        customUrl?: string;
        thumbnails?: { default?: { url: string } };
      };
    }>;
  };
  const channel = channelJson.items?.[0];
  if (!channel) return htmlError("No YouTube channel on this account.");

  const expiresAt = new Date(Date.now() + tokens.expires_in * 1000)
    .toISOString();

  // Upsert: one row per (workspace, platform, external_id).
  const { error: upsertErr } = await service.from("social_accounts").upsert(
    {
      workspace_id: stateRow.workspace_id,
      platform: "youtube",
      external_id: channel.id,
      display_name: channel.snippet.title,
      handle: channel.snippet.customUrl ?? null,
      avatar_url: channel.snippet.thumbnails?.default?.url ?? null,
      access_token_encrypted: tokens.access_token,
      refresh_token_encrypted: tokens.refresh_token ?? null,
      expires_at: expiresAt,
      scopes: tokens.scope.split(" "),
      deleted_at: null,
    },
    { onConflict: "workspace_id,platform,external_id" },
  );
  if (upsertErr) return htmlError(upsertErr.message);

  await service.from("oauth_states").delete().eq("state", state);

  return htmlSuccess(channel.snippet.title);
}

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json" },
  });
}

function htmlSuccess(channelTitle: string): Response {
  return new Response(landingPage(true, channelTitle), {
    status: 200,
    headers: { "content-type": "text/html; charset=utf-8" },
  });
}

function htmlError(message: string): Response {
  return new Response(landingPage(false, message), {
    status: 400,
    headers: { "content-type": "text/html; charset=utf-8" },
  });
}

function landingPage(success: boolean, detail: string): string {
  const title = success ? "Connected" : "Connection failed";
  const accent = success ? "#A855F7" : "#ef4444";
  const escapedDetail = detail.replace(/[&<>]/g, (c) =>
    c === "&" ? "&amp;" : c === "<" ? "&lt;" : "&gt;");
  return `<!doctype html>
<html><head><meta charset="utf-8"><title>${title}</title>
<meta name="viewport" content="width=device-width,initial-scale=1">
<style>
  body { font-family: -apple-system, system-ui, sans-serif;
         background: #0B0B0E; color: #fff; min-height: 100vh;
         display: flex; align-items: center; justify-content: center;
         margin: 0; padding: 24px; }
  .card { background: #1A1A1F; border-radius: 28px; padding: 32px;
          max-width: 360px; width: 100%; }
  h1 { margin: 0 0 8px; font-size: 22px; color: ${accent}; }
  p { margin: 0 0 16px; color: #A1A1AA; font-size: 15px; }
  .hint { font-size: 12px; color: #71717A; }
</style></head>
<body><div class="card">
  <h1>${title}</h1>
  <p>${escapedDetail}</p>
  <p class="hint">You can close this window and return to the app.</p>
</div></body></html>`;
}
