-- =========================================================================
-- 0007_report_snapshot_trigger.sql — auto-capture a frozen
-- report_snapshots row when a report is created (M5c).
-- =========================================================================

-- Captures the workspace's current metrics into report_snapshots.data
-- as a JSON blob. SECURITY DEFINER so it can read service-role data;
-- search_path pinned to public to keep things deterministic.
create or replace function public.capture_report_snapshot()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_period_days int := coalesce((new.config->>'period_days')::int, 30);
  v_accounts jsonb;
  v_totals jsonb;
begin
  -- Newest snapshot per account in the workspace, projected to a
  -- jsonb array. Uses DISTINCT ON because Postgres has no
  -- "latest row per group" agg built-in.
  with latest as (
    select distinct on (sa.id)
      sa.id as account_id,
      sa.platform,
      sa.display_name,
      sa.handle,
      sa.avatar_url,
      ms.followers,
      ms.impressions,
      ms.reach,
      ms.posts,
      ms.captured_at
    from public.social_accounts sa
    left join public.metrics_snapshots ms
      on ms.social_account_id = sa.id
    where sa.workspace_id = new.workspace_id
      and sa.deleted_at is null
    order by sa.id, ms.captured_at desc nulls last
  )
  select
    coalesce(jsonb_agg(to_jsonb(l)), '[]'::jsonb),
    jsonb_build_object(
      'followers',   coalesce(sum(l.followers), null),
      'impressions', coalesce(sum(l.impressions), null),
      'reach',       coalesce(sum(l.reach), null),
      'posts',       coalesce(sum(l.posts), null)
    )
  into v_accounts, v_totals
  from latest l;

  insert into public.report_snapshots (report_id, data)
    values (
      new.id,
      jsonb_build_object(
        'captured_at', now(),
        'period_days', v_period_days,
        'accounts',    v_accounts,
        'totals',      coalesce(v_totals, '{}'::jsonb)
      )
    );

  return new;
end;
$$;

drop trigger if exists trg_capture_report_snapshot on public.reports;
create trigger trg_capture_report_snapshot
  after insert on public.reports
  for each row execute function public.capture_report_snapshot();
