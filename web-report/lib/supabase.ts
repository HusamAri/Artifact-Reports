import { createClient } from "@supabase/supabase-js";

const url = process.env.NEXT_PUBLIC_SUPABASE_URL ?? "";
const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ?? "";

/// Anonymous Supabase client used for public-report pages. RLS policies
/// from migration 0002 cover the visibility='public' + non-expired
/// SELECT path; nothing here ever sees a JWT.
export const supabasePublic = createClient(url, anonKey, {
  auth: { persistSession: false, autoRefreshToken: false },
});

export const isConfigured = url.length > 0 && anonKey.length > 0;
