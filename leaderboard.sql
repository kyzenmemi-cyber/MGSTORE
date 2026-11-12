-- Run once in Supabase: SQL Editor -> New query -> paste -> Run.
-- Leaderboard: 1 point for every order that is Shipped or Delivered. Top 10 customers.
create or replace function public.leaderboard()
returns table(user_id uuid, name text, avatar text, score bigint)
language sql
security definer
set search_path = public, auth
as $$
  select o.user_id,
         coalesce(nullif(u.raw_user_meta_data->>'full_name',''), split_part(u.email,'@',1)) as name,
         nullif(u.raw_user_meta_data->>'avatar','') as avatar,
         count(*) as score
  from public.orders o
  join auth.users u on u.id = o.user_id
  where o.status in ('Shipped','Delivered') and o.user_id is not null
  group by o.user_id, u.email, u.raw_user_meta_data
  order by count(*) desc, min(o.created_at) asc
  limit 10;
$$;
revoke all on function public.leaderboard() from public;
grant execute on function public.leaderboard() to anon, authenticated;
