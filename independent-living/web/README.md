# Independent Living Canada — working web app

**Development pilot only.** The app is connected to a separate Supabase development project. It is not open for public bookings. Use synthetic test accounts and fictional details only; do not submit real personal, financial, health, or accessibility-sensitive information.

## Website hosting

The primary website is being moved to GitHub Pages because the Supabase Edge Function preview was returning raw HTML in some browsers instead of rendering it.

- Source: `independent-living/web/`
- Deployment workflow: `.github/workflows/independent-living-pages.yml`
- Expected project site: https://tritchot666.github.io/QuoteBack/
- The authoritative published URL will be the `page_url` reported by the successful GitHub Pages deployment run.

The workflow copies the contents of this directory to the Pages artifact root. Asset paths in the HTML are relative so CSS and JavaScript resolve on the project site. If the first deployment reports that Pages is not enabled, enable GitHub Pages in repository Settings → Pages and choose **GitHub Actions** as the build and deployment source, then rerun the workflow.

The old Supabase Edge Function preview is retained temporarily for diagnosis:
https://zrrmqrmedgfgbejhagcc.supabase.co/functions/v1/independent-living-site

## Supabase development connection

- Project ref: `zrrmqrmedgfgbejhagcc` (Canada Central)
- Project URL: `https://zrrmqrmedgfgbejhagcc.supabase.co`
- Browser configuration: `config.js` contains only the Supabase publishable key, which is designed for browser exposure. Never put a service-role or secret key in this directory, GitHub, or any browser bundle.
- Supabase JS is pinned to `@supabase/supabase-js@2.57.0`.

All database access is subject to Supabase Auth and row-level security. The static website does not perform privileged database operations.

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

Open http://localhost:8080. The app reads its Supabase URL and publishable key from `config.js`.

## Project separation

- Source files: `independent-living/web/`
- Supabase config and migrations: `independent-living/supabase/`
- Keep all changes on `independent-living-mvp` until reviewed.
- Do not use the repository-root `supabase/migrations/` directory; it belongs to QuoteBack.
- Do not merge this work into QuoteBack production.

## Required next steps

1. Verify GitHub Pages deployment and published homepage rendering on desktop and mobile.
2. Configure Supabase Auth Site URL and allowed redirect URL to the final GitHub Pages URL.
3. Run signup, email confirmation, sign-in, request submission, private-contact isolation and provider onboarding tests with separate synthetic accounts.
4. Build an operator-only workflow using server-side authorization and least-privilege access.
5. Complete provider screening, privacy/legal/insurance and Manitoba transportation/service reviews.
6. Add consent-aware family access, accessibility testing, incident handling and a retention/deletion process.
7. Complete the launch acceptance checklist before accepting real requests.
