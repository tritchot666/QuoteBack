-- Harden provider approval: only trusted server-side/operator actions may change verification state.
create or replace function public.il_prevent_self_approval()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is not null
     and new.onboarding_status is distinct from old.onboarding_status then
    raise exception 'Provider onboarding status is operator-controlled';
  end if;
  return new;
end;
$$;

drop trigger if exists il_provider_status_operator_only on public.il_provider_profiles;
create trigger il_provider_status_operator_only
before update of onboarding_status on public.il_provider_profiles
for each row execute function public.il_prevent_self_approval();

drop policy if exists "il provider owns profile" on public.il_provider_profiles;
create policy "il provider reads own profile" on public.il_provider_profiles
  for select using (auth.uid() = owner_user_id);
create policy "il provider creates pending profile" on public.il_provider_profiles
  for insert with check (
    auth.uid() = owner_user_id and onboarding_status = 'pending'
  );
create policy "il provider updates own profile" on public.il_provider_profiles
  for update using (auth.uid() = owner_user_id)
  with check (auth.uid() = owner_user_id);

-- Operator approval must be performed by a trusted server-side process using service-role credentials.
-- Never expose service-role credentials to the browser.
