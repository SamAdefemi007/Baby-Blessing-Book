-- Run once in Supabase SQL Editor.
create table if not exists public.blessings (
  id uuid primary key default gen_random_uuid(),
  guest_name text not null check (char_length(trim(guest_name)) between 1 and 100),
  relationship text check (relationship is null or char_length(relationship) <= 100),
  message text not null check (char_length(trim(message)) between 10 and 3000),
  bible_verse text check (bible_verse is null or char_length(bible_verse) <= 250),
  created_at timestamptz not null default now()
);
create table if not exists public.blessing_admins (
  user_id uuid primary key references auth.users(id) on delete cascade
);
alter table public.blessings enable row level security;
alter table public.blessing_admins enable row level security;

-- Public guests may INSERT only; they cannot read any rows.
revoke all on public.blessings from anon, authenticated;
grant usage on schema public to anon, authenticated;
grant insert (guest_name, relationship, message, bible_verse) on public.blessings to anon, authenticated;
grant select on public.blessings to authenticated;

-- Admin roster is readable only by the authenticated user whose ID matches.
revoke all on public.blessing_admins from anon, authenticated;
grant select on public.blessing_admins to authenticated;

drop policy if exists "guests can submit blessings" on public.blessings;
create policy "guests can submit blessings" on public.blessings
for insert to anon, authenticated with check (true);

drop policy if exists "admins can read blessings" on public.blessings;
create policy "admins can read blessings" on public.blessings
for select to authenticated using (
  exists (select 1 from public.blessing_admins a where a.user_id = (select auth.uid()))
);

drop policy if exists "admins can verify own membership" on public.blessing_admins;
create policy "admins can verify own membership" on public.blessing_admins
for select to authenticated using (user_id = (select auth.uid()));

-- AFTER each parent signs in for the first time, find their UUID in
-- Supabase > Authentication > Users, then run (replace UUID values):
-- insert into public.blessing_admins(user_id) values
--   ('PARENT_ONE_AUTH_USER_UUID'), ('PARENT_TWO_AUTH_USER_UUID')
-- on conflict do nothing;
