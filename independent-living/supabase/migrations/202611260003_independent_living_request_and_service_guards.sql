-- Tighten requester-created status and provider service activation.
-- Additive hardening for the isolated Independent Living MVP.

drop policy if exists "il requester creates own requests" on public.il_service_requests;
create policy "il requester creates received requests only" on public.il_service_requests
  for insert
  with check (
    auth.uid() = requester_user_id
    and status = 'received'
  );

create or replace function public.il_require_approved_provider_for_active_service()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  provider_status text;
begin
  if new.active then
    select p.onboarding_status
      into provider_status
      from public.il_provider_profiles p
      where p.id = new.provider_id;

    if provider_status is distinct from 'approved' then
      raise exception 'Provider must be approved before activating a service';
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists il_active_service_requires_approval on public.il_provider_services;
create trigger il_active_service_requires_approval
before insert or update of active, provider_id on public.il_provider_services
for each row execute function public.il_require_approved_provider_for_active_service();

comment on function public.il_require_approved_provider_for_active_service() is
  'Prevents unapproved providers from activating services; operator approval remains server-side.';
