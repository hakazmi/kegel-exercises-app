-- Per-goal plan snapshots on profiles (level + calendar cursors).
-- Session rows stay track-tagged; the app filters Today by active track.

alter table public.profiles
  add column if not exists goal_plans jsonb not null default '{}'::jsonb;

create or replace function public.kegel_upsert_profile(p_profile jsonb)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_millis bigint;
begin
  if v_uid is null then
    raise exception 'not authenticated';
  end if;

  v_millis := public._kegel_millis(p_profile, 'updated_at_millis');

  insert into public.profiles as t (
    user_id, display_name, goal, experience, sessions_per_day, track,
    level, level_started_on, plan_started_on, rest_weekday,
    onboarding_done, tutorial_done, paywall_seen, level_unlock_snoozed,
    goal_plans, guide_seen_at, time_zone, updated_at_millis
  )
  values (
    v_uid,
    p_profile->>'display_name',
    p_profile->>'goal',
    p_profile->>'experience',
    nullif(p_profile->>'sessions_per_day', '')::int,
    p_profile->>'track',
    coalesce(nullif(p_profile->>'level', '')::int, 1),
    public._kegel_date(p_profile->>'level_started_on'),
    public._kegel_date(p_profile->>'plan_started_on'),
    nullif(p_profile->>'rest_weekday', '')::int,
    coalesce((p_profile->>'onboarding_done')::boolean, false),
    coalesce((p_profile->>'tutorial_done')::boolean, false),
    coalesce((p_profile->>'paywall_seen')::boolean, false),
    coalesce((p_profile->>'level_unlock_snoozed')::boolean, false),
    coalesce(p_profile->'goal_plans', '{}'::jsonb),
    public._kegel_timestamptz(p_profile->>'guide_seen_at'),
    p_profile->>'time_zone',
    v_millis
  )
  on conflict (user_id) do update
  set
    display_name = excluded.display_name,
    goal = excluded.goal,
    experience = excluded.experience,
    sessions_per_day = excluded.sessions_per_day,
    track = excluded.track,
    level = case when t.updated_at_millis < excluded.updated_at_millis then excluded.level else t.level end,
    level_started_on = case when t.updated_at_millis < excluded.updated_at_millis then excluded.level_started_on else t.level_started_on end,
    plan_started_on = case when t.updated_at_millis < excluded.updated_at_millis then excluded.plan_started_on else t.plan_started_on end,
    rest_weekday = case when t.updated_at_millis < excluded.updated_at_millis then excluded.rest_weekday else t.rest_weekday end,
    onboarding_done = t.onboarding_done or excluded.onboarding_done,
    tutorial_done = t.tutorial_done or excluded.tutorial_done,
    paywall_seen = t.paywall_seen or excluded.paywall_seen,
    level_unlock_snoozed = case when t.updated_at_millis < excluded.updated_at_millis then excluded.level_unlock_snoozed else t.level_unlock_snoozed end,
    goal_plans = case when t.updated_at_millis < excluded.updated_at_millis then excluded.goal_plans else t.goal_plans end,
    guide_seen_at = coalesce(greatest(t.guide_seen_at, excluded.guide_seen_at), t.guide_seen_at, excluded.guide_seen_at),
    time_zone = coalesce(excluded.time_zone, t.time_zone),
    updated_at_millis = greatest(t.updated_at_millis, excluded.updated_at_millis)
  where t.updated_at_millis <= excluded.updated_at_millis
     or (not t.onboarding_done and excluded.onboarding_done)
     or (not t.tutorial_done and excluded.tutorial_done)
     or (not t.paywall_seen and excluded.paywall_seen);
end;
$$;

revoke all on function public.kegel_upsert_profile(jsonb) from public;
grant execute on function public.kegel_upsert_profile(jsonb) to authenticated;
