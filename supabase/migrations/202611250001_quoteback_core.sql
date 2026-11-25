-- QuoteBack multi-tenant foundation (Supabase Postgres)
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  company_name text not null default '',
  contact_email text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  stripe_customer_id text unique,
  stripe_subscription_id text unique,
  plan text not null default 'starter' check (plan in ('starter','growth')),
  status text not null default 'inactive',
  current_period_end timestamptz,
  cancel_at_period_end boolean not null default false,
  updated_at timestamptz not null default now()
);

create table if not exists public.estimates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  customer_name text not null,
  customer_email text,
  customer_phone text,
  job_description text not null,
  amount_cad numeric(12,2) not null default 0 check (amount_cad >= 0),
  sent_on date,
  follow_up_on date,
  status text not null default 'sent' check (status in ('sent','follow_up','won','lost')),
  notes text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.recipient_consents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  estimate_id uuid references public.estimates(id) on delete set null,
  recipient text not null,
  channel text not null check (channel in ('email','sms')),
  consent_basis text not null,
  consent_source text not null,
  consented_at timestamptz not null,
  revoked_at timestamptz,
  evidence_notes text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.suppression_list (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  recipient text not null,
  channel text not null check (channel in ('email','sms')),
  reason text not null default 'unsubscribe',
  created_at timestamptz not null default now(),
  unique(user_id, recipient, channel)
);

create table if not exists public.message_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  estimate_id uuid references public.estimates(id) on delete set null,
  channel text not null check (channel in ('email','sms')),
  direction text not null check (direction in ('outbound','inbound')),
  recipient text not null,
  provider_message_id text,
  status text not null default 'queued',
  body text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.stripe_events (
  id text primary key,
  event_type text not null,
  processed_at timestamptz not null default now()
);

create index if not exists estimates_user_followup_idx on public.estimates(user_id, follow_up_on);
create index if not exists estimates_user_status_idx on public.estimates(user_id, status);
create index if not exists consent_user_recipient_idx on public.recipient_consents(user_id, recipient, channel);
create index if not exists message_events_user_created_idx on public.message_events(user_id, created_at desc);

alter table public.profiles enable row level security;
alter table public.subscriptions enable row level security;
alter table public.estimates enable row level security;
alter table public.recipient_consents enable row level security;
alter table public.suppression_list enable row level security;
alter table public.message_events enable row level security;
alter table public.stripe_events enable row level security;

create policy "profiles own row" on public.profiles for all using (auth.uid() = id) with check (auth.uid() = id);
create policy "subscriptions own read" on public.subscriptions for select using (auth.uid() = user_id);
create policy "estimates own rows" on public.estimates for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "consents own rows" on public.recipient_consents for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "suppression own rows" on public.suppression_list for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "messages own read" on public.message_events for select using (auth.uid() = user_id);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  insert into public.profiles(id, contact_email)
  values (new.id, new.email)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Internal service-role webhook writes only. The service role bypasses RLS.
