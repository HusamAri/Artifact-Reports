# Database Schema

See `supabase/migrations/0001_init.sql` for authoritative DDL.

## Tables

### `profiles`
1:1 with `auth.users`. Display name, avatar, locale.

### `workspaces`
Tenant boundary. Owner is a profile; plan tier mirrors current subscription.

### `workspace_members`
Composite PK `(workspace_id, user_id)`. Role: `owner | editor | viewer`.

### `workspace_invites`
Email invites with token + expiry; accepted via `invite-accept` edge fn.

### `social_accounts`
Per-workspace connections. Holds encrypted OAuth tokens (encryption added
in 0003) and last sync time. Unique on `(workspace_id, platform, external_id)`.

### `metrics_snapshots`
Time-series table. Source enum distinguishes API / CSV / manual / OCR.
`metrics jsonb` is flexible by design — normalization lookup ships later.

### `posts`
Per-post breakdown. Optional; primarily for top-content reports.

### `reports`
Saved dashboards. `public_id` is the URL slug used by `web-report/`.
Visibility: `private | link | public`. Optional password + expiry.

### `report_snapshots`
Frozen data + PDF storage path. Snapshot is taken when a link is generated
so the public viewer doesn't drift if the underlying metrics change.

### `subscriptions`
StoreKit-driven. `apple_original_transaction_id` is the stable key. Status
mirrors App Store Server Notifications v2 states. A `provider` enum keeps
the door open for Google Play later.

### `audit_logs`
Append-only. Workspace-scoped actor + action + metadata. Required for
KVKK/GDPR data-export endpoint (M9).

## RLS strategy (0002)

Helper function:
```sql
create or replace function is_workspace_member(ws uuid, roles workspace_role[])
returns boolean language sql security definer as $$
  select exists (
    select 1 from workspace_members
    where workspace_id = ws
      and user_id = auth.uid()
      and role = any(roles)
  );
$$;
```

Then every workspace-scoped table gets:
- `select`: `is_workspace_member(workspace_id, ARRAY['owner','editor','viewer']::workspace_role[])`
- `insert/update`: `is_workspace_member(workspace_id, ARRAY['owner','editor']::workspace_role[])`
- `delete`: `is_workspace_member(workspace_id, ARRAY['owner']::workspace_role[])`

Special: `reports` adds an `anon` select policy where
`visibility='public' AND (expires_at IS NULL OR expires_at > now())`.

## Encryption (0003)

`pgsodium` column-level encryption on
`social_accounts.access_token_encrypted` and `.refresh_token_encrypted`,
with a per-workspace key in the keyring.
