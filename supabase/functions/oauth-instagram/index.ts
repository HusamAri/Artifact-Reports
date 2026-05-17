// oauth-instagram — Meta Facebook Login → Instagram Graph API access.
//
// POST /functions/v1/oauth-instagram/start
//   Body: { workspace_id }
//   Returns: { auth_url }
//
// GET /functions/v1/oauth-instagram/callback?code=&state=
//   Public — Meta redirects here. Exchanges code → long-lived user
//   token, walks Pages → instagram_business_account, upserts
//   social_accounts.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.0";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const APP_ID = Deno.env.get("META_APP_ID")!;
const APP_SECRET = Deno.env.get("META_APP_SECRET")!;
const REDIRECT_URI = Deno.env.get("INSTAGRAM_OAUTH_REDIRECT_URI")!;

const SCOPES = [
  "instagram_basic",
  "instagram_manage_insights",
  "pages_show_list",
  "pages_read_engagement",
  "business_management",
].join(",");

const GRAPH = "https://graph.facebook.com/v21.0";

Deno.serve(async (req: Request) => {
  const url = new URL(req.url);
  const last = url.pathname.split("/").filter(Boolean).pop();
  if (req.method === "POST" && last === "start") return handleStart(req);
  if (req.method === "GET" && last === "callback") return handleCallback(url);
  return json({ error: "not_found" }, 404);
});

async function handleStart(req: Request): Promise<Response> {
  const auth = req.headers.get("Authorization");
  if (!auth?.startsWith("Bearer ")) {
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

  const userClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: auth } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: userData } = await userClient.auth.getUser();
  if (!userData.user) return json({ error: "unauthenticated" }, 401);
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
    platform: "instagram",
  });
  if (insertErr) return json({ error: insertErr.message }, 500);

  const authUrl = new URL(`${GRAPH.replace("graph", "www")}/dialog/oauth`);
  authUrl.searchParams.set("client_id", APP_ID);
  authUrl.searchParams.set("redirect_uri", REDIRECT_URI);
  authUrl.searchParams.set("response_type", "code");
  authUrl.searchParams.set("scope", SCOPES);
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
  const { data: stateRow } = await service
    .from("oauth_states")
    .select("workspace_id, user_id, expires_at")
    .eq("state", state)
    .maybeSingle();
  if (!stateRow) return htmlError("Invalid or expired state.");
  if (new Date(stateRow.expires_at) < new Date()) {
    await service.from("oauth_states").delete().eq("state", state);
    return htmlError("State expired.");
  }

  // 1. Code → short-lived user token.
  const tokenUrl = new URL(`${GRAPH}/oauth/access_token`);
  tokenUrl.searchParams.set("client_id", APP_ID);
  tokenUrl.searchParams.set("client_secret", APP_SECRET);
  tokenUrl.searchParams.set("redirect_uri", REDIRECT_URI);
  tokenUrl.searchParams.set("code", code);
  const tokenRes = await fetch(tokenUrl);
  if (!tokenRes.ok) return htmlError(`Token exchange failed: ${await tokenRes.text()}`);
  const shortToken = (await tokenRes.json() as { access_token: string })
    .access_token;

  // 2. Exchange for long-lived (~60 day) token.
  const longUrl = new URL(`${GRAPH}/oauth/access_token`);
  longUrl.searchParams.set("grant_type", "fb_exchange_token");
  longUrl.searchParams.set("client_id", APP_ID);
  longUrl.searchParams.set("client_secret", APP_SECRET);
  longUrl.searchParams.set("fb_exchange_token", shortToken);
  const longRes = await fetch(longUrl);
  if (!longRes.ok) return htmlError(`Long-lived exchange failed: ${await longRes.text()}`);
  const longJson = await longRes.json() as {
    access_token: string;
    expires_in?: number;
  };
  const userToken = longJson.access_token;
  const expiresAt = longJson.expires_in
    ? new Date(Date.now() + longJson.expires_in * 1000).toISOString()
    : null;

  // 3. Find the Page → ig_business_account.
  const pagesRes = await fetch(
    `${GRAPH}/me/accounts?fields=id,name,instagram_business_account&access_token=${userToken}`,
  );
  if (!pagesRes.ok) return htmlError(`Pages lookup failed: ${await pagesRes.text()}`);
  const pagesJson = await pagesRes.json() as {
    data?: Array<{
      id: string;
      name: string;
      instagram_business_account?: { id: string };
    }>;
  };
  const page = pagesJson.data?.find((p) => p.instagram_business_account);
  if (!page) return htmlError("No Page with an Instagram Business account.");
  const igId = page.instagram_business_account!.id;

  // 4. Channel display fields.
  const igRes = await fetch(
    `${GRAPH}/${igId}?fields=id,username,name,profile_picture_url&access_token=${userToken}`,
  );
  if (!igRes.ok) return htmlError(`IG account lookup failed: ${await igRes.text()}`);
  const ig = await igRes.json() as {
    id: string;
    username?: string;
    name?: string;
    profile_picture_url?: string;
  };

  const { error: upsertErr } = await service.from("social_accounts").upsert({
    workspace_id: stateRow.workspace_id,
    platform: "instagram",
    external_id: ig.id,
    display_name: ig.name ?? ig.username ?? "Instagram",
    handle: ig.username ?? null,
    avatar_url: ig.profile_picture_url ?? null,
    access_token_encrypted: userToken,
    refresh_token_encrypted: null, // Meta long-lived tokens don't refresh
    expires_at: expiresAt,
    scopes: SCOPES.split(","),
    deleted_at: null,
  }, { onConflict: "workspace_id,platform,external_id" });
  if (upsertErr) return htmlError(upsertErr.message);

  await service.from("oauth_states").delete().eq("state", state);

  return htmlSuccess(ig.username ?? ig.name ?? "Instagram");
}

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json" },
  });
}

function htmlSuccess(name: string): Response {
  return new Response(landingPage(true, name), {
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
  const escaped = detail.replace(/[&<>]/g, (c) =>
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
  <p>${escaped}</p>
  <p class="hint">You can close this window and return to the app.</p>
</div></body></html>`;
}
