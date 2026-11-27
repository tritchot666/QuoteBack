# Independent Living Canada — live development environment

Last updated: 2026-11-27

## Supabase development project

- Project: Independent Living Canada
- Project ref: `zrrmqrmedgfgbejhagcc`
- Region: Canada Central (`ca-central-1`)
- API URL: `https://zrrmqrmedgfgbejhagcc.supabase.co`
- Status at verification: `ACTIVE_HEALTHY`
- The project was created with a $0/month quoted base cost; future usage, plan limits and billing can change.

This is a dedicated project in the QuoteBack organization. It is separate from QuoteBack production. Do not point QuoteBack's production app, Stripe webhook, or customer records at this project.

## Database deployment

The core schema, provider approval guards, service/request guards, provider suspension safeguards and security hardening have been applied. A further migration, `atomic_request_submission`, adds the authenticated `il_submit_service_request` RPC.

Seven `il_*` tables exist and RLS is enabled on all seven. The new request RPC was verified as SECURITY INVOKER; `anon` cannot execute it and `authenticated` can. The RPC creates the service request and its separate private contact record in one transaction.

Latest advisor check:
- Security: zero findings.
- Health: zero findings.
- Performance: seven unused-index notices (expected on a low-volume/empty development database) and two multiple-permissive-SELECT policy warnings. The latter are the intended requester/invited-provider read paths and should be revisited after integration and load testing.

## Working web app

- Source files: `independent-living/web/`
- Public development preview: https://zrrmqrmedgfgbejhagcc.supabase.co/functions/v1/independent-living-site
- Supabase Edge Function: `independent-living-site`, status ACTIVE, version 2, JWT verification disabled because it serves static public assets only.
- The page loads the browser-safe publishable key dynamically from Supabase's `SUPABASE_PUBLISHABLE_KEYS` environment variable. No key or service-role secret is committed to GitHub.
- Supabase JS is pinned to `@supabase/supabase-js@2.57.0`.

Implemented in the app:
- Email/password sign-up and sign-in.
- Customer request submission through the atomic RPC.
- Request history restricted by requester RLS.
- Provider application and service-category registration.
- Provider profiles start as `pending`; service listings start inactive.
- The existing database trigger prevents unapproved providers from activating services.
- Responsive layout, keyboard focus states, labelled forms and non-emergency/non-clinical boundaries.
- CI workflow checks browser JavaScript syntax, required files and HTML parsing.

## Important limitations

This is a **development pilot, not a public service launch**. The live site is visibly labelled test-only. Use synthetic accounts and fictional information only. Do not enter real customer, provider, financial, health or accessibility-sensitive information.

Not yet implemented or approved:
- Authenticated end-to-end tests with separate synthetic requester/provider accounts.
- Operator-only admin workflows and role management.
- Provider screening, credential/insurance/licence review and provider directory.
- Request routing, provider invitations, matching, booking confirmations or notifications.
- Family/supporter access and formal consent management.
- Payment processing, refunds, disputes, incident handling or complaint workflows.
- Reviewed privacy policy, terms, support contact, retention/deletion schedule and provincial operating approvals.
- Formal accessibility audit and legal/insurance review.

The Edge Function deployment reports ACTIVE. A separate external HTTP smoke test and full browser end-to-end test are still outstanding.

## Next engineering gates

1. Configure Supabase Auth Site URL and allowed redirect URL to the live preview URL.
2. Run signup, confirmation, sign-in, request submission, private-contact isolation and provider onboarding tests with synthetic accounts.
3. Build an operator-only workflow using server-side authorization and least-privilege access; never expose service-role credentials in the browser.
4. Complete Manitoba pilot legal, insurance, safeguarding, privacy, accessibility and transportation checks before accepting real requests.
5. Add consent-aware family access, accessibility testing, incident handling and a retention/deletion process.
6. Keep PR #3 in draft; do not merge to QuoteBack production until reviewed and approved.

## Credential handling

The project URL and publishable key may be exposed to the browser. The service-role/secret key must remain exclusively in trusted server-side environments and must never appear in browser code, a public repository, or a `NEXT_PUBLIC_*` variable.
