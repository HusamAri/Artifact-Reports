-- =========================================================================
-- 0001_init.sql — Artifact Reports initial schema (M1)
--
-- Scope: Table DDL only. RLS is ENABLED on every table but NO policies are
-- defined here — policies land in 0002_rls.sql. Token encryption (pgsodium)
-- lands in 0003_encryption.sql.
-- =========================================================================

create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- ---------- Enums --------------------------------------------------------

create type social_platform as enum (
  'instagram',
  'tiktok',
  'youtube',
  'x',
  'linkedin',
  'google_my_business',
  'uberall'
);

create type workspace_role as enum ('owner', 'editor', 'viewer');

create type metric_source as enum ('api', 'csv', 'manual', 'ocr');

create type report_visibility as enum ('private', 'link', 'public');

create type subscription_status as enum (
  'trialing',
  'active',
  'in_grace_period',
  'in_billing_retry',
  'expired',
  'revoked'
);

create type subscription_provider as enum ('apple', 'google');

-- ---------- Profiles -----------------------------------------------------

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  avatar_url text,
  locale text not null default 'en',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

alter table public.profiles enable row level security;

-- ---------- Workspaces ---------------------------------------------------

create table public.workspaces (
  id uuid primary key default uuid_generate_v4(),
  owner_id uuid not null references public.profiles(id) on delete restrict,
  name text not null,
  slug text not null unique,
  plan_tier text not null default 'free',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

alter table public.workspaces enable row level security;

create table public.workspace_members (
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role workspace_role not null default 'viewer',
  created_at timestamptz not null default now(),
  primary key (workspace_id, user_id)
);

alter table public.workspace_members enable row level security;

create table public.workspace_invites (
  id uuid primary key default uuid_generate_v4(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  email text not null,
  role workspace_role not null default 'viewer',
  token text not null unique,
  invited_by uuid not null references public.profiles(id) on delete restrict,
  expires_at timestamptz not null,
  accepted_at timestamptz,
  created_at timestamptz not null default now()
);

alter table public.workspace_invites enable row level security;

-- ---------- Social accounts ---------------------------------------------

create table public.social_accounts (
  id uuid primary key default uuid_generate_v4(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  platform social_platform not null,
  external_id text not null,
  display_name text,
  handle text,
  avatar_url text,
  -- TODO(0003): encrypt these with pgsodium per-workspace key
  access_token_encrypted bytea,
  refresh_token_encrypted bytea,
  expires_at timestamptz,
  scopes text[] not null default '{}',
  last_synced_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (workspace_id, platform, external_id)
);

alter table public.social_accounts enable row level security;

create index social_accounts_workspace_idx
  on public.social_accounts (workspace_id, platform);

-- ---------- Metrics (time-series) ---------------------------------------

create table public.metrics_snapshots (
  id bigserial primary key,
  social_account_id uuid not null references public.social_accounts(id) on delete cascade,
  captured_at timestamptz not null default now(),
  source metric_source not null,
  metrics jsonb not null,
  raw_payload jsonb
);

alter table public.metrics_snapshots enable row level security;

create index metrics_snapshots_account_time_idx
  on public.metrics_snapshots (social_account_id, captured_at desc);

-- ---------- Posts -------------------------------------------------------

create table public.posts (
  id uuid primary key default uuid_generate_v4(),
  social_account_id uuid not null references public.social_accounts(id) on delete cascade,
  external_post_id text not null,
  posted_at timestamptz,
  content text,
  media_urls text[] not null default '{}',
  metrics jsonb not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (social_account_id, external_post_id)
);

alter table public.posts enable row level security;

-- ---------- Reports -----------------------------------------------------

create table public.reports (
  id uuid primary key default uuid_generate_v4(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  title text not null,
  config jsonb not null default '{}',
  public_id uuid not null unique default uuid_generate_v4(),
  visibility report_visibility not null default 'private',
  password_hash text,
  expires_at timestamptz,
  created_by uuid not null references public.profiles(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

alter table public.reports enable row level security;

create index reports_public_id_idx on public.reports (public_id);

-- Frozen snapshot: once a link is shared, data shouldn't drift.
create table public.report_snapshots (
  id uuid primary key default uuid_generate_v4(),
  report_id uuid not null references public.reports(id) on delete cascade,
  data jsonb not null,
  pdf_storage_path text,
  created_at timestamptz not null default now()
);

alter table public.report_snapshots enable row level security;

-- ---------- Subscriptions -----------------------------------------------

create table public.subscriptions (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  workspace_id uuid references public.workspaces(id) on delete set null,
  provider subscription_provider not null default 'apple',
  product_id text not null,
  tier text not null,
  status subscription_status not null,
  -- Apple-specific (Google fields can co-exist or move to separate table)
  apple_original_transaction_id text,
  apple_latest_transaction_id text,
  latest_receipt jsonb,
  current_period_end timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (provider, apple_original_transaction_id)
);

alter table public.subscriptions enable row level security;

create index subscriptions_user_idx on public.subscriptions (user_id);
create index subscriptions_workspace_idx on public.subscriptions (workspace_id);

-- ---------- Audit log ---------------------------------------------------

create table public.audit_logs (
  id bigserial primary key,
  workspace_id uuid references public.workspaces(id) on delete cascade,
  actor_id uuid references public.profiles(id) on delete set null,
  action text not null,
  target text,
  metadata jsonb not null default '{}',
  created_at timestamptz not null default now()
);

alter table public.audit_logs enable row level security;

create index audit_logs_workspace_time_idx
  on public.audit_logs (workspace_id, created_at desc);

-- ---------- updated_at trigger ------------------------------------------

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

create trigger workspaces_set_updated_at
  before update on public.workspaces
  for each row execute function public.set_updated_at();

create trigger social_accounts_set_updated_at
  before update on public.social_accounts
  for each row execute function public.set_updated_at();

create trigger posts_set_updated_at
  before update on public.posts
  for each row execute function public.set_updated_at();

create trigger reports_set_updated_at
  before update on public.reports
  for each row execute function public.set_updated_at();

create trigger subscriptions_set_updated_at
  before update on public.subscriptions
  for each row execute function public.set_updated_at();
