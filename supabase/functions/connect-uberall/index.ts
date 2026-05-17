// connect-uberall — API key-based connection (Uberall has no OAuth).
//
// POST /functions/v1/connect-uberall
//   Headers:  Authorization: Bearer <supabase_user_jwt>
//   Body:     { "workspace_id": "<uuid>", "api_key": "<uberall-private-key>" }
//   Returns:  { "account_id": "<uuid>" }
//
// Validates the key by calling Uberall /api/locations, then upserts a
// social_accounts row with the key stored in access_token_encrypted.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.0";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const UBERALL_BASE = Deno.env.get("UBERALL_API_BASE")
  ?? "https://uberall.com/api";

interface ConnectRequest {
  workspace_id?: string;
  api_key?: string;
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const auth = req.headers.get("Authorization");
  if (!auth?.startsWith("Bearer ")) {
    return json({ error: "missing_authorization" }, 401);
  }

  let body: ConnectRequest;
  try {
    body = await req.json();
  } catch {
    return json({ error: "invalid_json" }, 400);
  }
  const workspaceId = body.workspace_id?.trim();
  const apiKey = body.api_key?.trim();
  if (!workspaceId) return json({ error: "missing_workspace_id" }, 400);
  if (!apiKey) return json({ error: "missing_api_key" }, 400);

  // Verify membership through the caller's JWT.
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

  // Validate the key by listing locations.
  const probeRes = await fetch(
    `${UBERALL_BASE}/locations?max=1`,
    { headers: { privatekey: apiKey } },
  );
  if (!probeRes.ok) {
    return json(
      { error: "invalid_api_key", detail: await probeRes.text() },
      401,
    );
  }
  const probe = await probeRes.json() as {
    response?: {
      count?: number;
      locations?: Array<{ id?: number | string; name?: string }>;
    };
  };
  const first = probe.response?.locations?.[0];
  const externalId = first?.id ? String(first.id) : `uberall:${workspaceId}`;
  const displayName = first?.name ?? "Uberall";

  const service = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: row, error: upsertErr } = await service
    .from("social_accounts")
    .upsert(
      {
        workspace_id: workspaceId,
        platform: "uberall",
        external_id: externalId,
        display_name: displayName,
        handle: null,
        avatar_url: null,
        access_token_encrypted: apiKey,
        refresh_token_encrypted: null,
        expires_at: null,
        scopes: ["locations.read"],
        deleted_at: null,
      },
      { onConflict: "workspace_id,platform,external_id" },
    )
    .select("id")
    .single();
  if (upsertErr || !row) {
    return json({ error: upsertErr?.message ?? "upsert_failed" }, 500);
  }

  return json({ account_id: row.id }, 200);
});

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json" },
  });
}
