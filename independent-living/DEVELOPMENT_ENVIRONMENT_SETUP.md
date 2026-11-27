# Independent Living MVP — Safe Development Environment Setup

Status: preparation guide only. No Supabase project has been linked or changed by this document.

## Non-negotiable separation

- Create a **new Supabase project dedicated to Independent Living development**.
- Do not link this branch to QuoteBack's existing Supabase project.
- Do not copy QuoteBack customer records, authentication users, Stripe data, or secrets.
- Use synthetic test accounts and fictional requests only.
- Keep this work on `independent-living-mvp`; do not merge it into `main` as part of setup.

## 1. Create and identify the project

1. In the Supabase dashboard, create a new project with a clear name such as `independent-living-dev`.
2. Record the project reference shown in the project URL.
3. Confirm the project name and reference in the dashboard before any CLI command.
4. Use a strong, unique database password and store it in a password manager.
5. Enable multi-factor authentication on the account that administers the project.

## 2. Configure local development

Install the Supabase CLI using the official instructions for your operating system. From a clean checkout of this repository:

```bash
git checkout independent-living-mvp
supabase login
supabase link --project-ref YOUR_INDEPENDENT_LIVING_DEV_PROJECT_REF
supabase projects list
```

Before linking, compare the project reference character-for-character with the new development project's reference. If it is not an exact match, stop.

Do not paste access tokens, database passwords, or service-role keys into chat, GitHub files, screenshots, or client-side code.

## 3. Review and apply migrations

The Independent Living migrations currently prepared are:

- `supabase/migrations/202611260001_independent_living_core.sql`
- `supabase/migrations/202611260002_independent_living_provider_approval_guard.sql`
- `supabase/migrations/202611260003_independent_living_request_and_service_guards.sql`

Read all three files before applying them. Confirm that the linked project is the dedicated development project, then apply:

```bash
supabase db push
supabase migration list
```

If the CLI reports unexpected remote migrations, schema drift, or a project mismatch, stop. Do not use a reset command on a project containing data.

## 4. Required security checks before any real data

Use synthetic accounts only. Follow `DATABASE_SECURITY_TEST_PLAN.md` and verify at minimum:

- A requester cannot insert a request with a status other than `received`.
- A requester cannot read another request or its private contact record.
- An unapproved provider cannot activate a service.
- A provider cannot change its own onboarding status to approved.
- An invited approved provider sees only the request summary, not private contact details.
- A provider cannot respond to another provider's invitation.
- A supporter has no access merely because a consent row exists; supporter access is not implemented yet.

Inspect the resulting policies and triggers in the Supabase dashboard. Passing SQL migration alone is not proof that the application is secure.

## 5. Environment variables and key handling

When application integration is implemented, use environment variables rather than hard-coded credentials. The browser may receive only the project URL and publishable/anon key, protected by correctly tested RLS. A service-role/secret key must remain exclusively in a trusted server environment and must never use a `VITE_`, `NEXT_PUBLIC_`, or other browser-exposed prefix.

No application environment file is committed by this guide. Do not create a production environment until the separate development project and deployment target are confirmed.

## 6. Current limitations

This repository currently contains prototype HTML screens and database design/migrations. The forms do not submit to Supabase. The operator dashboard is fictional demo data. There is no implemented operator role, secure notification pipeline, family-supporter access, booking workflow, payment flow, provider verification evidence store, or production hosting configuration.

Do not collect real customer details, advertise confirmed provider availability, accept payment, or describe the service as launched until the relevant technical, legal, insurance, safeguarding, accessibility, and operational launch gates have been completed.
