-- =========================================================================
-- 0006_oauth_states_pkce.sql — extends oauth_states with PKCE support
-- for platforms that require it (X, LinkedIn, etc.).
-- =========================================================================

alter table public.oauth_states
  add column if not exists code_verifier text;
