-- Automatically deactivate provider service listings when approval is withdrawn.
-- This is a safety backstop; the operator must still investigate and document the reason.

create or replace function public.il_deactivate_services_when_provider_not_approved()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.onboarding_status is distinct from 'approved' then
    update public.il_provider_services
      set active = false
      where provider_id = new.id and active = true;
  end if;
  return new;
end;
$$;

drop trigger if exists il_deactivate_services_on_status_change on public.il_provider_profiles;
create trigger il_deactivate_services_on_status_change
after update of onboarding_status on public.il_provider_profiles
for each row
when (old.onboarding_status is distinct from new.onboarding_status)
execute function public.il_deactivate_services_when_provider_not_approved();

comment on function public.il_deactivate_services_when_provider_not_approved() is
  'Automatically deactivates all service listings when provider approval is withdrawn.';
