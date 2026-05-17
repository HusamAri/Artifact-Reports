// oauth-linkedin — LinkedIn OAuth 2.0 (OpenID Connect + optional
// Pages API scope when granted).
//
// POST /start  { workspace_id } → { auth_url }
// GET  /callback?code=&state=  → HTML landing; upserts social_accounts.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.0";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const CLIENT_ID = Deno.env.get("LINKEDIN_CLIENT_ID")!;
const CLIENT_SECRET = Deno.env.get("LINKEDIN_CLIENT_SECRET")!;
const REDIRECT_URI = Deno.env.get("LINKEDIN_OAUTH_REDIRECT_URI")!;

const SCOPES = "openid profile email w_member_social";

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
    platform: "linkedin",
  });
  if (insertErr) return json({ error: insertErr.message }, 500);

  const authUrl = new URL("https://www.linkedin.com/oauth/v2/authorization");
  authUrl.searchParams.set("response_type", "code");
  authUrl.searchParams.set("client_id", CLIENT_ID);
  authUrl.searchParams.set("redirect_uri", REDIRECT_URI);
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
    .select("workspace_id, expires_at")
    .eq("state", state)
    .maybeSingle();
  if (!stateRow) return htmlError("Invalid or expired state.");
  if (new Date(stateRow.expires_at) < new Date()) {
    await service.from("oauth_states").delete().eq("state", state);
    return htmlError("State expired.");
  }

  const tokenRes = await fetch(
    "https://www.linkedin.com/oauth/v2/accessToken",
    {
      method: "POST",
      headers: { "content-type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({
        grant_type: "authorization_code",
        code,
        redirect_uri: REDIRECT_URI,
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
      }),
    },
  );
  if (!tokenRes.ok) {
    return htmlError(`Token exchange failed: ${await tokenRes.text()}`);
  }
  const tokens = await tokenRes.json() as {
    access_token: string;
    refresh_token?: string;
    expires_in: number;
    scope?: string;
  };

  // /v2/userinfo (OIDC) returns sub, name, picture, email.
  const meRes = await fetch("https://api.linkedin.com/v2/userinfo", {
    headers: { Authorization: `Bearer ${tokens.access_token}` },
  });
  if (!meRes.ok) {
    return htmlError(`/v2/userinfo failed: ${await meRes.text()}`);
  }
  const me = await meRes.json() as {
    sub: string;
    name?: string;
    given_name?: string;
    family_name?: string;
    picture?: string;
    email?: string;
  };

  const expiresAt = new Date(Date.now() + tokens.expires_in * 1000)
    .toISOString();

  const { error: upsertErr } = await service.from("social_accounts").upsert({
    workspace_id: stateRow.workspace_id,
    platform: "linkedin",
    external_id: me.sub,
    display_name: me.name
      ?? [me.given_name, me.family_name].filter(Boolean).join(" ")
      || "LinkedIn",
    handle: me.email ?? null,
    avatar_url: me.picture ?? null,
    access_token_encrypted: tokens.access_token,
    refresh_token_encrypted: tokens.refresh_token ?? null,
    expires_at: expiresAt,
    scopes: (tokens.scope ?? SCOPES).split(/[ ,]+/),
    deleted_at: null,
  }, { onConflict: "workspace_id,platform,external_id" });
  if (upsertErr) return htmlError(upsertErr.message);

  await service.from("oauth_states").delete().eq("state", state);
  return htmlSuccess(me.name ?? "LinkedIn");
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
