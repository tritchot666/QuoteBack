# Independent Living Canada — development environment and local testing

Status: a dedicated Supabase development project exists and the first working web app is deployed. This is still a test-only pilot, not a public service launch.

## Project separation

- Supabase project: `Independent Living Canada`
- Project ref: `zrrmqrmedgfgbejhagcc`
- Region: Canada Central (`ca-central-1`)
- Preview: https://zrrmqrmedgfgbejhagcc.supabase.co/functions/v1/independent-living-site
- Source branch: `independent-living-mvp`
- Do not point QuoteBack production, Stripe webhooks, customer data or production auth at this project.
- Do not merge this branch to `main` without explicit approval.

## Working app

The application is in `independent-living/web/`. It currently supports email/password account creation and sign-in, authenticated customer requests, requester-only request history, and provider applications with pending/inactive defaults.

The static website is served by the `independent-living-site` Edge Function. It reads the browser-safe publishable key from the Supabase-provided `SUPABASE_PUBLISHABLE_KEYS` environment variable. The function performs no privileged database operations and does not expose a service-role key. JWT verification is disabled only because this function serves public static assets; all data operations happen through Supabase Auth and RLS.

For local preview from the repository root:

```bash
python3 -m http.server 8080 --directory independent-living/web
```

Open http://localhost:8080 and enter the project URL and publishable key in the connection panel. Never enter a service-role or secret key. The Supabase JS client is pinned to `@supabase/supabase-js@2.57.0`.

## Auth redirect configuration still required

In Supabase Dashboard for project `zrrmqrmedgfgbejhagcc`, open Authentication → URL Configuration:
- Set the Site URL to `https://zrrmqrmedgfgbejhagcc.supabase.co/functions/v1/independent-living-site`.
- Add that exact URL to the allowed Redirect URLs.
- Save changes.

This allows confirmation emails to return users to the live preview. Verify the confirmation link using a synthetic test account.

## Database

All Independent Living migrations are isolated under `independent-living/supabase/migrations/`. The repository-root `supabase/migrations/` directory belongs to QuoteBack and must not be used for this product.

The current database contains seven RLS-enabled `il_*` tables. The `il_submit_service_request` RPC runs as SECURITY INVOKER and is executable by authenticated users only. It creates the request and private contact record atomically.

## Required synthetic-account tests

Use separate synthetic requester and provider accounts. Do not use real customer/provider details.

- Sign up, verify email and sign in.
- Submit a service request and confirm it appears only in the requester's history.
- Confirm the request's private contact row is not visible to another account.
- Apply as a provider and confirm onboarding status is `pending`.
- Confirm all new provider service rows are inactive.
- Confirm an unapproved provider cannot activate a service.
- Confirm a provider cannot change its own onboarding status.
- Confirm a provider cannot read another provider's profile, services or invites.

A successful migration or static CI check is not proof that all RLS paths are secure. Record the results of the account-isolation tests before any real data is accepted.

## Not yet implemented

- Operator/admin role and secure operator-only request triage.
- Provider screening evidence, approval workflow, service matching and invitations.
- Provider responses, booking confirmation and notifications.
- Family/supporter access and formal consent revocation workflow.
- Payments, refunds, disputes, complaints and incident handling.
- Privacy policy, terms, support contact, retention schedule and legal/insurance review.
- Accessibility audit and Manitoba/provincial operating approvals.

## Launch restriction

The hosted page is clearly labelled **development pilot — test accounts only**. Do not advertise public availability, collect real customer data, confirm provider availability, accept payment, or provide emergency/clinical/personal care through this MVP. Complete the launch gates and independent review first.
