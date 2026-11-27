-- Independent Living Canada: isolated MVP foundation.
-- This migration is additive and does not alter QuoteBack tables or Stripe flows.
-- Apply only to the intended Supabase project after confirming the project ref and backup.

create extension if not exists pgcrypto;

create table if not exists public.il_provider_profiles (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null unique references auth.users(id) on delete cascade,
  display_name text not null,
  business_name text,
  contact_email text not null,
  contact_phone text,
  service_description text not null default '',
  onboarding_status text not null default 'pending'
    check (onboarding_status in ('pending','under_review','approved','rejected','suspended')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.il_provider_services (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid not null references public.il_provider_profiles(id) on delete cascade,
  category text not null check (category in (
    'non_emergency_transport','companionship','errands_groceries',
    'light_household_help','home_accessibility'
  )),
  service_area text not null,
  active boolean not null default false,
  created_at timestamptz not null default now(),
  unique(provider_id, category, service_area)
);

create table if not exists public.il_service_requests (
  id uuid primary key default gen_random_uuid(),
  requester_user_id uuid not null references auth.users(id) on delete restrict,
  recipient_name text,
  category text not null check (category in (
    'non_emergency_transport','companionship','errands_groceries',
    'light_household_help','home_accessibility'
  )),
  city text not null,
  service_area text,
  description text not null,
  preferred_date date,
  preferred_time_window text,
  accessibility_logistics text not null default '',
  status text not null default 'received'
    check (status in ('received','reviewing','matching','options_shared','booked','closed','cancelled')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Contact details are separated from the provider-visible request summary.
create table if not exists public.il_request_private_contacts (
  request_id uuid primary key references public.il_service_requests(id) on delete cascade,
  contact_name text not null,
  contact_email text,
  contact_phone text,
  preferred_contact_method text not null check (preferred_contact_method in ('email','phone')),
  created_at timestamptz not null default now(),
  check (contact_email is not null or contact_phone is not null)
);

create table if not exists public.il_consent_grants (
  id uuid primary key default gen_random_uuid(),
  recipient_user_id uuid not null references auth.users(id) on delete cascade,
  supporter_user_id uuid not null references auth.users(id) on delete cascade,
  scope text[] not null check (cardinality(scope) > 0),
  granted_at timestamptz not null default now(),
  expires_at timestamptz,
  revoked_at timestamptz,
  check (recipient_user_id <> supporter_user_id)
);

create table if not exists public.il_request_provider_invites (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references public.il_service_requests(id) on delete cascade,
  provider_id uuid not null references public.il_provider_profiles(id) on delete cascade,
  invited_at timestamptz not null default now(),
  response_deadline timestamptz,
  unique(request_id, provider_id)
);

create table if not exists public.il_provider_responses (
  id uuid primary key default gen_random_uuid(),
  invite_id uuid not null unique references public.il_request_provider_invites(id) on delete cascade,
  provider_id uuid not null references public.il_provider_profiles(id) on delete cascade,
  availability text not null,
  price_cad numeric(10,2) check (price_cad is null or price_cad >= 0),
  scope_and_limits text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists il_requests_owner_created_idx
  on public.il_service_requests(requester_user_id, created_at desc);
create index if not exists il_requests_city_category_idx
  on public.il_service_requests(city, category, status);
create index if not exists il_invites_provider_idx
  on public.il_request_provider_invites(provider_id, invited_at desc);
create index if not exists il_services_area_category_idx
  on public.il_provider_services(service_area, category) where active = true;

alter table public.il_provider_profiles enable row level security;
alter table public.il_provider_services enable row level security;
alter table public.il_service_requests enable row level security;
alter table public.il_request_private_contacts enable row level security;
alter table public.il_consent_grants enable row level security;
alter table public.il_request_provider_invites enable row level security;
alter table public.il_provider_responses enable row level security;

-- Providers can manage their own onboarding profile; public directory access is intentionally absent.
create policy "il provider owns profile" on public.il_provider_profiles
  for all using (auth.uid() = owner_user_id) with check (auth.uid() = owner_user_id);

create policy "il provider manages own services" on public.il_provider_services
  for all using (
    exists (select 1 from public.il_provider_profiles p
      where p.id = provider_id and p.owner_user_id = auth.uid())
  ) with check (
    exists (select 1 from public.il_provider_profiles p
      where p.id = provider_id and p.owner_user_id = auth.uid())
  );

-- Customers may create and read only their own requests. Status changes are operator-only via trusted backend.
create policy "il requester reads own requests" on public.il_service_requests
  for select using (auth.uid() = requester_user_id);
create policy "il requester creates own requests" on public.il_service_requests
  for insert with check (auth.uid() = requester_user_id);

-- Invited providers see only the non-contact request summary they have been invited to.
create policy "il invited provider reads request summary" on public.il_service_requests
  for select using (
    exists (
      select 1
      from public.il_request_provider_invites i
      join public.il_provider_profiles p on p.id = i.provider_id
      where i.request_id = il_service_requests.id
        and p.owner_user_id = auth.uid()
        and p.onboarding_status = 'approved'
    )
  );

-- Private customer contact details are not available to providers through client-side access.
create policy "il requester reads private contact" on public.il_request_private_contacts
  for select using (
    exists (select 1 from public.il_service_requests r
      where r.id = request_id and r.requester_user_id = auth.uid())
  );
create policy "il requester creates private contact" on public.il_request_private_contacts
  for insert with check (
    exists (select 1 from public.il_service_requests r
      where r.id = request_id and r.requester_user_id = auth.uid())
  );

create policy "il recipient manages consent" on public.il_consent_grants
  for all using (auth.uid() = recipient_user_id)
  with check (auth.uid() = recipient_user_id);

create policy "il provider reads own invites" on public.il_request_provider_invites
  for select using (
    exists (select 1 from public.il_provider_profiles p
      where p.id = provider_id and p.owner_user_id = auth.uid())
  );

create policy "il provider reads and manages own responses" on public.il_provider_responses
  for all using (
    exists (select 1 from public.il_provider_profiles p
      where p.id = provider_id and p.owner_user_id = auth.uid())
  ) with check (
    exists (
      select 1
      from public.il_provider_profiles p
      join public.il_request_provider_invites i on i.provider_id = p.id
      where p.id = provider_id
        and p.owner_user_id = auth.uid()
        and i.id = invite_id
    )
  );

-- Requesters can compare responses only for their own requests.
create policy "il requester reads responses to own requests" on public.il_provider_responses
  for select using (
    exists (
      select 1
      from public.il_request_provider_invites i
      join public.il_service_requests r on r.id = i.request_id
      where i.id = invite_id and r.requester_user_id = auth.uid()
    )
  );

-- No client policy is provided for operator actions, verification evidence, incidents, or booking/payment.
-- Those capabilities must be added behind authenticated server-side authorization after role design.
