-- =========================================================================
-- 0002_rls.sql — Row-Level Security policies for Artifact Reports (M2)
--
-- Every table gets workspace-membership-based policies via the
-- is_workspace_member() helper. Reports have an additional anon SELECT
-- policy for public shareable links.
-- =========================================================================

-- ---------- Helper: workspace membership check ---------------------------

create or replace function public.is_workspace_member(
  ws uuid,
  roles workspace_role[]
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.workspace_members
    where workspace_id = ws
      and user_id = auth.uid()
      and role = any(roles)
  );
$$;

revoke all on function public.is_workspace_member(uuid, workspace_role[]) from public;
grant execute on function public.is_workspace_member(uuid, workspace_role[]) to authenticated;

-- ---------- profiles -----------------------------------------------------

create policy "profiles: self can select"
  on public.profiles for select
  to authenticated
  using (id = auth.uid());

create policy "profiles: self can insert"
  on public.profiles for insert
  to authenticated
  with check (id = auth.uid());

create policy "profiles: self can update"
  on public.profiles for update
  to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

-- ---------- workspaces ---------------------------------------------------

create policy "workspaces: members can select"
  on public.workspaces for select
  to authenticated
  using (
    public.is_workspace_member(
      id,
      array['owner','editor','viewer']::workspace_role[]
    )
  );

create policy "workspaces: any authenticated user can create"
  on public.workspaces for insert
  to authenticated
  with check (owner_id = auth.uid());

create policy "workspaces: owners can update"
  on public.workspaces for update
  to authenticated
  using (
    public.is_workspace_member(id, array['owner']::workspace_role[])
  )
  with check (
    public.is_workspace_member(id, array['owner']::workspace_role[])
  );

create policy "workspaces: owners can delete"
  on public.workspaces for delete
  to authenticated
  using (
    public.is_workspace_member(id, array['owner']::workspace_role[])
  );

-- ---------- workspace_members -------------------------------------------

create policy "workspace_members: members can select rows in their workspace"
  on public.workspace_members for select
  to authenticated
  using (
    public.is_workspace_member(
      workspace_id,
      array['owner','editor','viewer']::workspace_role[]
    )
  );

-- A user inserts themselves when accepting an invite (token-gated through an
-- edge function). Owners can add others; everyone else is denied.
create policy "workspace_members: self-add or owner-add"
  on public.workspace_members for insert
  to authenticated
  with check (
    user_id = auth.uid()
    or public.is_workspace_member(workspace_id, array['owner']::workspace_role[])
  );

create policy "workspace_members: owners can update roles"
  on public.workspace_members for update
  to authenticated
  using (
    public.is_workspace_member(workspace_id, array['owner']::workspace_role[])
  )
  with check (
    public.is_workspace_member(workspace_id, array['owner']::workspace_role[])
  );

-- Owners remove anyone; members can remove themselves (leave).
create policy "workspace_members: owners or self can delete"
  on public.workspace_members for delete
  to authenticated
  using (
    user_id = auth.uid()
    or public.is_workspace_member(workspace_id, array['owner']::workspace_role[])
  );

-- ---------- workspace_invites -------------------------------------------

create policy "workspace_invites: members can select"
  on public.workspace_invites for select
  to authenticated
  using (
    public.is_workspace_member(
      workspace_id,
      array['owner','editor','viewer']::workspace_role[]
    )
  );

create policy "workspace_invites: owners/editors can insert"
  on public.workspace_invites for insert
  to authenticated
  with check (
    public.is_workspace_member(
      workspace_id,
      array['owner','editor']::workspace_role[]
    )
  );

create policy "workspace_invites: owners can delete"
  on public.workspace_invites for delete
  to authenticated
  using (
    public.is_workspace_member(workspace_id, array['owner']::workspace_role[])
  );

-- ---------- social_accounts ---------------------------------------------

create policy "social_accounts: members can select"
  on public.social_accounts for select
  to authenticated
  using (
    public.is_workspace_member(
      workspace_id,
      array['owner','editor','viewer']::workspace_role[]
    )
  );

create policy "social_accounts: owners/editors can insert"
  on public.social_accounts for insert
  to authenticated
  with check (
    public.is_workspace_member(
      workspace_id,
      array['owner','editor']::workspace_role[]
    )
  );

create policy "social_accounts: owners/editors can update"
  on public.social_accounts for update
  to authenticated
  using (
    public.is_workspace_member(
      workspace_id,
      array['owner','editor']::workspace_role[]
    )
  )
  with check (
    public.is_workspace_member(
      workspace_id,
      array['owner','editor']::workspace_role[]
    )
  );

create policy "social_accounts: owners can delete"
  on public.social_accounts for delete
  to authenticated
  using (
    public.is_workspace_member(workspace_id, array['owner']::workspace_role[])
  );

-- ---------- metrics_snapshots -------------------------------------------

create policy "metrics_snapshots: members can select via account"
  on public.metrics_snapshots for select
  to authenticated
  using (
    exists (
      select 1
      from public.social_accounts sa
      where sa.id = social_account_id
        and public.is_workspace_member(
          sa.workspace_id,
          array['owner','editor','viewer']::workspace_role[]
        )
    )
  );

create policy "metrics_snapshots: owners/editors can insert via account"
  on public.metrics_snapshots for insert
  to authenticated
  with check (
    exists (
      select 1
      from public.social_accounts sa
      where sa.id = social_account_id
        and public.is_workspace_member(
          sa.workspace_id,
          array['owner','editor']::workspace_role[]
        )
    )
  );

-- ---------- posts -------------------------------------------------------

create policy "posts: members can select via account"
  on public.posts for select
  to authenticated
  using (
    exists (
      select 1
      from public.social_accounts sa
      where sa.id = social_account_id
        and public.is_workspace_member(
          sa.workspace_id,
          array['owner','editor','viewer']::workspace_role[]
        )
    )
  );

create policy "posts: owners/editors can write via account"
  on public.posts for insert
  to authenticated
  with check (
    exists (
      select 1
      from public.social_accounts sa
      where sa.id = social_account_id
        and public.is_workspace_member(
          sa.workspace_id,
          array['owner','editor']::workspace_role[]
        )
    )
  );

create policy "posts: owners/editors can update via account"
  on public.posts for update
  to authenticated
  using (
    exists (
      select 1
      from public.social_accounts sa
      where sa.id = social_account_id
        and public.is_workspace_member(
          sa.workspace_id,
          array['owner','editor']::workspace_role[]
        )
    )
  )
  with check (
    exists (
      select 1
      from public.social_accounts sa
      where sa.id = social_account_id
        and public.is_workspace_member(
          sa.workspace_id,
          array['owner','editor']::workspace_role[]
        )
    )
  );

-- ---------- reports -----------------------------------------------------

create policy "reports: members can select"
  on public.reports for select
  to authenticated
  using (
    public.is_workspace_member(
      workspace_id,
      array['owner','editor','viewer']::workspace_role[]
    )
  );

-- Public shareable links: anon role can read reports flagged public and
-- still within their TTL.
create policy "reports: public links readable by anon"
  on public.reports for select
  to anon
  using (
    visibility = 'public'
    and (expires_at is null or expires_at > now())
  );

create policy "reports: owners/editors can insert"
  on public.reports for insert
  to authenticated
  with check (
    public.is_workspace_member(
      workspace_id,
      array['owner','editor']::workspace_role[]
    )
  );

create policy "reports: owners/editors can update"
  on public.reports for update
  to authenticated
  using (
    public.is_workspace_member(
      workspace_id,
      array['owner','editor']::workspace_role[]
    )
  )
  with check (
    public.is_workspace_member(
      workspace_id,
      array['owner','editor']::workspace_role[]
    )
  );

create policy "reports: owners can delete"
  on public.reports for delete
  to authenticated
  using (
    public.is_workspace_member(workspace_id, array['owner']::workspace_role[])
  );

-- ---------- report_snapshots -------------------------------------------

create policy "report_snapshots: members can select via report"
  on public.report_snapshots for select
  to authenticated
  using (
    exists (
      select 1
      from public.reports r
      where r.id = report_id
        and public.is_workspace_member(
          r.workspace_id,
          array['owner','editor','viewer']::workspace_role[]
        )
    )
  );

create policy "report_snapshots: public links readable by anon"
  on public.report_snapshots for select
  to anon
  using (
    exists (
      select 1
      from public.reports r
      where r.id = report_id
        and r.visibility = 'public'
        and (r.expires_at is null or r.expires_at > now())
    )
  );

-- Snapshot writes happen server-side (edge fn with service role); no
-- authenticated INSERT policy.

-- ---------- subscriptions ----------------------------------------------

-- Read-only for the owning user. Inserts/updates go through StoreKit
-- edge functions using the service role key (RLS bypassed there).
create policy "subscriptions: owner can select"
  on public.subscriptions for select
  to authenticated
  using (user_id = auth.uid());

-- ---------- audit_logs ------------------------------------------------

-- Members can read their workspace's audit trail. Writes are
-- service-role-only (no INSERT policy here).
create policy "audit_logs: members can select"
  on public.audit_logs for select
  to authenticated
  using (
    workspace_id is not null
    and public.is_workspace_member(
      workspace_id,
      array['owner','editor','viewer']::workspace_role[]
    )
  );
