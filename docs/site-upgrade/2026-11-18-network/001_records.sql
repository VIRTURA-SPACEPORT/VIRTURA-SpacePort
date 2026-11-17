-- VIRTURA ID foundation. Apply ONCE to a reviewed Supabase development project.
-- Additive only: no existing table, auth configuration, domain or user is changed.
-- No production deployment or real-user validation is implied by this file.
begin;

create table public.vcn_resources (
  id text primary key check (length(id) between 1 and 128),
  kind text not null check (kind in ('work','reading','app','event','resource')),
  title text not null check (length(title) between 1 and 200),
  url text not null check (url ~ '^https://'),
  published boolean not null default false,
  created_at timestamptz not null default now()
);
create table public.vcn_bookmarks (
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  resource_id text not null references public.vcn_resources(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, resource_id)
);
create table public.vcn_progress (
  user_id uuid not null references auth.users(id) on delete cascade,
  resource_id text not null references public.vcn_resources(id) on delete cascade,
  percent integer not null check (percent between 0 and 100),
  version integer not null default 1 check (version > 0),
  updated_at timestamptz not null default now(),
  primary key (user_id, resource_id)
);
create index vcn_bookmarks_resource_idx on public.vcn_bookmarks(resource_id);
create index vcn_progress_resource_idx on public.vcn_progress(resource_id);

alter table public.vcn_resources enable row level security;
alter table public.vcn_bookmarks enable row level security;
alter table public.vcn_progress enable row level security;
revoke all on public.vcn_resources, public.vcn_bookmarks, public.vcn_progress from public, anon, authenticated;
grant select on public.vcn_resources to anon, authenticated;
grant select, delete on public.vcn_bookmarks to authenticated;
grant insert (user_id, resource_id) on public.vcn_bookmarks to authenticated;
grant select, delete on public.vcn_progress to authenticated;
grant all on public.vcn_resources, public.vcn_bookmarks, public.vcn_progress to service_role;

-- Verify identity on the server too; hiding buttons is never an access rule.
create function public.vcn_direct_verified_account()
returns boolean language sql stable security definer set search_path = '' as $$
  select auth.uid() is not null
    and auth.jwt()->>'client_id' is null
    and coalesce(auth.jwt()->>'is_anonymous','false') <> 'true'
    and exists (select 1 from auth.users u where u.id = auth.uid() and u.email_confirmed_at is not null);
$$;
revoke all on function public.vcn_direct_verified_account() from public, anon, authenticated;
grant execute on function public.vcn_direct_verified_account() to authenticated;

create policy vcn_public_resources on public.vcn_resources for select to anon, authenticated using (published);
create policy vcn_read_bookmarks on public.vcn_bookmarks for select to authenticated
  using (user_id = (select auth.uid()) and (select public.vcn_direct_verified_account()));
create policy vcn_add_bookmarks on public.vcn_bookmarks for insert to authenticated
  with check (user_id = (select auth.uid()) and (select public.vcn_direct_verified_account())
    and exists (select 1 from public.vcn_resources r where r.id = resource_id and r.published));
create policy vcn_delete_bookmarks on public.vcn_bookmarks for delete to authenticated
  using (user_id = (select auth.uid()) and (select public.vcn_direct_verified_account()));
create policy vcn_read_progress on public.vcn_progress for select to authenticated
  using (user_id = (select auth.uid()) and (select public.vcn_direct_verified_account()));
create policy vcn_delete_progress on public.vcn_progress for delete to authenticated
  using (user_id = (select auth.uid()) and (select public.vcn_direct_verified_account()));

-- Only this RPC may insert/update progress. It authenticates the caller itself,
-- uses a fixed search_path, checks resource visibility and detects stale writes.
create function public.vcn_set_progress(p_resource_id text, p_percent integer, p_expected_version integer)
returns public.vcn_progress language plpgsql security definer set search_path = '' as $$
declare
  v_uid uuid := auth.uid();
  v_row public.vcn_progress;
begin
  if not public.vcn_direct_verified_account() then
    raise exception 'Direct verified account session required' using errcode = '42501';
  end if;
  if p_percent is null or p_percent < 0 or p_percent > 100 or p_expected_version is null or p_expected_version < 0 then
    raise exception 'Invalid progress or version' using errcode = '22023';
  end if;
  if not exists (select 1 from public.vcn_resources r where r.id = p_resource_id and r.published) then
    raise exception 'Resource is not available' using errcode = '22023';
  end if;
  if p_expected_version = 0 then
    insert into public.vcn_progress(user_id, resource_id, percent)
    values (v_uid, p_resource_id, p_percent)
    on conflict (user_id, resource_id) do nothing returning * into v_row;
  else
    update public.vcn_progress set percent = p_percent, version = version + 1, updated_at = clock_timestamp()
    where user_id = v_uid and resource_id = p_resource_id and version = p_expected_version
    returning * into v_row;
  end if;
  if v_row.user_id is null then
    raise exception 'Progress changed: reload before saving' using errcode = '40001';
  end if;
  return v_row;
end;
$$;
revoke all on function public.vcn_set_progress(text,integer,integer) from public, anon, authenticated;
grant execute on function public.vcn_set_progress(text,integer,integer) to authenticated;

-- Public references only. No personal information, membership or payment data.
insert into public.vcn_resources(id,kind,title,url,published) values
('portfolio:reawakening','work','Reawakening','https://ewanqian.site/music/reawakening/',true),
('collective:programs','reading','分享与工作坊','https://github.com/ewanqian/VIRTURA-Collective/tree/main/programs',true),
('spaceport:network-roadmap','reading','SpacePort 的应用网络','https://github.com/ewanqian/VIRTURA-SpacePort/issues/10',true);
commit;
