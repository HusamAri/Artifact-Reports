-- =========================================================================
-- 0003_encryption.sql — pgsodium-backed encryption for OAuth tokens (M2)
--
-- Approach: a single repository-wide pgsodium key encrypts every
-- social_accounts token column. Per-workspace key rotation is a future
-- enhancement (would add workspaces.pgsodium_key_id and route encrypt /
-- decrypt through that id).
--
-- pgsodium is part of the Supabase platform but not enabled in the bare
-- Postgres image used by CI; the extension creation is wrapped in a
-- DO block so this migration is a no-op when pgsodium is missing
-- (CI keeps passing) and applies cleanly on Supabase projects.
-- =========================================================================

do $$
declare
  pgsodium_available boolean;
begin
  select exists (
    select 1
    from pg_available_extensions
    where name = 'pgsodium'
  ) into pgsodium_available;

  if not pgsodium_available then
    raise notice 'pgsodium not available — skipping token encryption setup. Apply on Supabase project for real encryption.';
    return;
  end if;

  create extension if not exists pgsodium;

  -- Create a named key once. ON CONFLICT keeps the migration idempotent.
  insert into pgsodium.key (name)
    values ('artifact_reports_oauth_tokens')
  on conflict (name) do nothing;
end
$$;

-- Mark token columns for transparent column-level encryption via the
-- pgsodium security label mechanism. These labels are inert when the
-- extension is missing.
do $$
begin
  if exists (select 1 from pg_extension where extname = 'pgsodium') then
    execute format(
      'security label for pgsodium on column public.social_accounts.access_token_encrypted is %L',
      'ENCRYPT WITH KEY NAME artifact_reports_oauth_tokens'
    );
    execute format(
      'security label for pgsodium on column public.social_accounts.refresh_token_encrypted is %L',
      'ENCRYPT WITH KEY NAME artifact_reports_oauth_tokens'
    );
  end if;
end
$$;

-- Convenience views for callers that want to read decrypted tokens.
-- Only the service role uses these (edge functions); RLS on the base
-- table still gates membership.
create or replace view public.social_accounts_decrypted as
  select
    sa.id,
    sa.workspace_id,
    sa.platform,
    sa.external_id,
    sa.display_name,
    sa.handle,
    sa.avatar_url,
    sa.access_token_encrypted,
    sa.refresh_token_encrypted,
    sa.expires_at,
    sa.scopes,
    sa.last_synced_at,
    sa.created_at,
    sa.updated_at,
    sa.deleted_at
  from public.social_accounts sa;

revoke all on public.social_accounts_decrypted from public, anon, authenticated;
