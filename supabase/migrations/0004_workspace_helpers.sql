-- =========================================================================
-- 0004_workspace_helpers.sql — Convenience triggers and RPCs for workspace
-- creation and invite acceptance flows (M2d).
-- =========================================================================

-- Trigger: when a workspace row is inserted, automatically add the
-- inserting user as the workspace owner. Bypasses RLS because the
-- function runs as definer and uses NEW.owner_id directly.
create or replace function public.add_owner_on_workspace_create()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.workspace_members (workspace_id, user_id, role)
    values (new.id, new.owner_id, 'owner')
  on conflict do nothing;
  return new;
end;
$$;

drop trigger if exists trg_workspace_owner_membership on public.workspaces;
create trigger trg_workspace_owner_membership
  after insert on public.workspaces
  for each row execute function public.add_owner_on_workspace_create();

-- RPC: accept an invite by token. Called by the invite-accept edge
-- function with the caller's JWT, so auth.uid() resolves to the
-- redeeming user. Returns the workspace id on success.
create or replace function public.accept_workspace_invite(invite_token text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_invite public.workspace_invites%rowtype;
  v_user uuid := auth.uid();
begin
  if v_user is null then
    raise exception 'not authenticated' using errcode = '42501';
  end if;

  select * into v_invite
    from public.workspace_invites
    where token = invite_token
    limit 1;

  if not found then
    raise exception 'invite not found' using errcode = '02000';
  end if;

  if v_invite.expires_at is not null and v_invite.expires_at < now() then
    raise exception 'invite expired' using errcode = '22023';
  end if;

  insert into public.workspace_members (workspace_id, user_id, role)
    values (v_invite.workspace_id, v_user, v_invite.role)
  on conflict (workspace_id, user_id) do update
    set role = excluded.role;

  delete from public.workspace_invites where id = v_invite.id;

  return v_invite.workspace_id;
end;
$$;

revoke all on function public.accept_workspace_invite(text) from public;
grant execute on function public.accept_workspace_invite(text) to authenticated;
