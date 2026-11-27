# Independent Living Canada — working web app

**Development pilot only.** The app is connected to a separate Supabase development project. It is not open for public bookings. Use synthetic test accounts and fictional details only; do not submit real personal, financial, health, or accessibility-sensitive information.

## Live development preview

https://zrrmqrmedgfgbejhagcc.supabase.co/functions/v1/independent-living-site

The public Edge Function serves the static site only. It exposes the project's browser-safe publishable key at runtime; all database access is still subject to Supabase Auth and row-level security. The function does not use a service-role key and performs no privileged database operations.

## Implemented

- Email/password account creation and sign-in through Supabase Auth.
- Authenticated customer request submission.
- Atomic database operation that creates the request and private contact record together.
- Request history limited by RLS to the signed-in requester.
- Provider application and service-interest submission.
- Provider profiles default to `pending`; service listings default to `active = false`.
- Database trigger prevents an unapproved provider from activating a service.
- Responsive, keyboard-friendly layouts and explicit non-emergency/non-clinical scope.

## Not implemented / not enabled

- Public provider directory, automatic matching, provider invitations or provider responses.
- Operator/admin dashboard and role management.
- Family/supporter access and consent workflows.
- Booking confirmations, payment collection, refunds or dispute handling.
- Email notifications, incident management, provider credential document storage.
- A reviewed privacy policy, terms, support contact, retention schedule or provincial operating approvals.

Do not advertise service availability or accept real customers until those items and the launch gates have been reviewed and approved.

## Local preview

From the repository root:

```bash
python3 -m http.server 8080 --directory independent-living/web
```

Open http://localhost:8080. The local page asks for the project URL and publishable key. Use only the publishable key. Never enter a service-role or secret key.

The browser loads the Supabase JS client from the pinned CDN version `@supabase/supabase-js@2.57.0`.

## Project separation

- Source: `independent-living/web/`
- Supabase config and migrations: `independent-living/supabase/`
- Project ref: `zrrmqrmedgfgbejhagcc` (Canada Central)
- Keep all changes on `independent-living-mvp` until reviewed.
- Do not use the repository-root `supabase/migrations/` directory; it belongs to QuoteBack.
- Do not merge this work into QuoteBack production.

## Required next steps

1. Test signup, email confirmation, login, request submission, private-contact isolation and provider onboarding with separate synthetic accounts.
2. Build an operator-only workflow using server-side authorization and least-privilege access.
3. Complete provider screening, privacy/legal/insurance and Manitoba transportation/service reviews.
4. Add consent-aware family access, accessibility testing, incident handling and a retention/deletion process.
5. Complete the launch acceptance checklist before accepting real requests.
