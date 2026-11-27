-- Security and performance hardening applied to the isolated Independent Living project.
-- Trigger-only SECURITY DEFINER routines must not be exposed as public RPCs.
revoke all on function public.il_prevent_self_approval() from public, anon, authenticated;
revoke all on function public.il_require_approved_provider_for_active_service() from public, anon, authenticated;
revoke all on function public.il_deactivate_services_when_provider_not_approved() from public, anon, authenticated;

create index if not exists il_consent_grants_recipient_idx on public.il_consent_grants(recipient_user_id);
create index if not exists il_consent_grants_supporter_idx on public.il_consent_grants(supporter_user_id);
create index if not exists il_provider_responses_provider_idx on public.il_provider_responses(provider_id);

drop policy if exists "il provider reads own profile" on public.il_provider_profiles;
create policy "il provider reads own profile" on public.il_provider_profiles
  for select to authenticated using ((select auth.uid()) = owner_user_id);
drop policy if exists "il provider creates pending profile" on public.il_provider_profiles;
create policy "il provider creates pending profile" on public.il_provider_profiles
  for insert to authenticated with check ((select auth.uid()) = owner_user_id and onboarding_status = 'pending');
drop policy if exists "il provider updates own profile" on public.il_provider_profiles;
create policy "il provider updates own profile" on public.il_provider_profiles
  for update to authenticated using ((select auth.uid()) = owner_user_id)
  with check ((select auth.uid()) = owner_user_id);

drop policy if exists "il provider manages own services" on public.il_provider_services;
create policy "il provider manages own services" on public.il_provider_services
  for all to authenticated
  using (exists (select 1 from public.il_provider_profiles p where p.id = provider_id and p.owner_user_id = (select auth.uid())))
  with check (exists (select 1 from public.il_provider_profiles p where p.id = provider_id and p.owner_user_id = (select auth.uid())));

drop policy if exists "il requester reads own requests" on public.il_service_requests;
create policy "il requester reads own requests" on public.il_service_requests
  for select to authenticated using ((select auth.uid()) = requester_user_id);
drop policy if exists "il invited provider reads request summary" on public.il_service_requests;
create policy "il invited provider reads request summary" on public.il_service_requests
  for select to authenticated using (
    exists (select 1 from public.il_request_provider_invites i
      join public.il_provider_profiles p on p.id = i.provider_id
      where i.request_id = il_service_requests.id
        and p.owner_user_id = (select auth.uid())
        and p.onboarding_status = 'approved')
  );
drop policy if exists "il requester creates received requests only" on public.il_service_requests;
create policy "il requester creates received requests only" on public.il_service_requests
  for insert to authenticated with check ((select auth.uid()) = requester_user_id and status = 'received');

drop policy if exists "il requester reads private contact" on public.il_request_private_contacts;
create policy "il requester reads private contact" on public.il_request_private_contacts
  for select to authenticated using (exists (select 1 from public.il_service_requests r
    where r.id = request_id and r.requester_user_id = (select auth.uid())));
drop policy if exists "il requester creates private contact" on public.il_request_private_contacts;
create policy "il requester creates private contact" on public.il_request_private_contacts
  for insert to authenticated with check (exists (select 1 from public.il_service_requests r
    where r.id = request_id and r.requester_user_id = (select auth.uid())));

drop policy if exists "il recipient manages consent" on public.il_consent_grants;
create policy "il recipient manages consent" on public.il_consent_grants
  for all to authenticated using ((select auth.uid()) = recipient_user_id)
  with check ((select auth.uid()) = recipient_user_id);

drop policy if exists "il provider reads own invites" on public.il_request_provider_invites;
create policy "il provider reads own invites" on public.il_request_provider_invites
  for select to authenticated using (exists (select 1 from public.il_provider_profiles p
    where p.id = provider_id and p.owner_user_id = (select auth.uid())));

drop policy if exists "il provider reads and manages own responses" on public.il_provider_responses;
create policy "il provider reads and manages own responses" on public.il_provider_responses
  for all to authenticated
  using (exists (select 1 from public.il_provider_profiles p where p.id = provider_id and p.owner_user_id = (select auth.uid())))
  with check (exists (select 1 from public.il_provider_profiles p
    join public.il_request_provider_invites i on i.provider_id = p.id
    where p.id = provider_id and p.owner_user_id = (select auth.uid()) and i.id = invite_id));

drop policy if exists "il requester reads responses to own requests" on public.il_provider_responses;
create policy "il requester reads responses to own requests" on public.il_provider_responses
  for select to authenticated using (exists (select 1
    from public.il_request_provider_invites i
    join public.il_service_requests r on r.id = i.request_id
    where i.id = invite_id and r.requester_user_id = (select auth.uid())));
