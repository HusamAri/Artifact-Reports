// invite-accept — redeems a workspace invite token for the authenticated user.
//
// POST /functions/v1/invite-accept
//   Headers:  Authorization: Bearer <supabase_user_jwt>
//   Body:     { "token": "<invite-token>" }
//
// Response:   { "workspace_id": "<uuid>" }  (200)
//             { "error": "<message>" }       (4xx/5xx)
//
// The heavy lifting (token lookup, expiry check, member insert, invite
// delete) happens inside the SQL function `accept_workspace_invite()`
// added in migration 0004. Edge function is the thin auth wrapper.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.0";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;

interface InviteAcceptRequest {
  token?: string;
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return json({ error: "method_not_allowed" }, 405);
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return json({ error: "missing_authorization" }, 401);
  }

  let body: InviteAcceptRequest;
  try {
    body = await req.json();
  } catch {
    return json({ error: "invalid_json" }, 400);
  }

  const token = body.token?.trim();
  if (!token) {
    return json({ error: "missing_token" }, 400);
  }

  // Forward the caller's JWT so RLS + auth.uid() resolve to them.
  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: authHeader } },
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { data, error } = await supabase.rpc("accept_workspace_invite", {
    invite_token: token,
  });

  if (error) {
    const status = error.code === "42501"
      ? 401
      : error.code === "02000"
      ? 404
      : error.code === "22023"
      ? 410
      : 500;
    return json({ error: error.message, code: error.code }, status);
  }

  return json({ workspace_id: data }, 200);
});

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json" },
  });
}
