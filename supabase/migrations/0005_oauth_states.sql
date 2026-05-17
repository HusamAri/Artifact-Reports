-- =========================================================================
-- 0005_oauth_states.sql — Short-lived OAuth state tokens for CSRF
-- protection across the redirect dance.
-- =========================================================================

create table if not exists public.oauth_states (
  state text primary key,
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  user_id uuid not null,
  platform social_platform not null,
  redirect_to text,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default now() + interval '10 minutes'
);

create index if not exists oauth_states_workspace_idx
  on public.oauth_states (workspace_id);

alter table public.oauth_states enable row level security;

-- No SELECT/INSERT/UPDATE/DELETE policies: the table is exclusively
-- service-role (edge functions). Authenticated callers never touch it
-- directly.

-- Helper: purge expired rows. Edge functions can call this from
-- /start to keep the table small. Idempotent.
create or replace function public.purge_expired_oauth_states()
returns void
language sql
security definer
set search_path = public
as $$
  delete from public.oauth_states where expires_at < now();
$$;

revoke all on function public.purge_expired_oauth_states() from public;
