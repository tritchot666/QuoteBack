# Independent Living Canada — live development environment

Last updated: 2026-11-26

## Supabase development project

- Project: Independent Living Canada
- Project ref: `zrrmqrmedgfgbejhagcc`
- Region: Canada Central (`ca-central-1`)
- API URL: `https://zrrmqrmedgfgbejhagcc.supabase.co`
- Status at verification: `ACTIVE_HEALTHY`
- Quoted project creation cost: $0/month at time of creation (future usage, plan limits, and billing can change; check Supabase billing before production use).

This is a dedicated project in the QuoteBack organization. It is separate from QuoteBack production. Do not point QuoteBack's production app, Stripe webhook, or customer records at this project.

## Database deployment

The following migrations have been applied and verified:
1. `202611260001_independent_living_core`
2. `202611260002_independent_living_provider_approval_guard`
3. `202611260003_independent_living_request_and_service_guards`
4. `202611260004_independent_living_provider_suspension`
5. `20261127_security_hardening`

Seven `il_*` tables exist. Row-level security is enabled on all seven. There are 13 RLS policies. The three trigger-only SECURITY DEFINER functions have EXECUTE revoked from PUBLIC, anon, and authenticated. A database check returned zero public execute grants for those functions.

Supabase security advisors returned no findings at the last check. Health advisors returned no findings. Performance advisors still report unused indexes (expected on an empty database) and two multiple-permissive-SELECT policy warnings because a requester and an invited provider have different legitimate read paths. Revisit after integration and load testing.

## Important limitations

- No real customer or provider records have been inserted.
- No production users/authentication flow has been configured or tested.
- No client app is connected to this database yet.
- The HTML pages in `prototype/` are demonstrations only; their forms do not submit or store data.
- No provider screening, insurance/licence verification, legal review, privacy review, or accessibility audit has been completed.
- No payment processing is enabled.
- Do not accept emergency, ambulance, clinical, nursing, medication, or personal-care requests through this MVP.

## Next engineering gates

1. Implement authentication and connect a development-only client using the Supabase publishable key stored in local environment configuration (never commit keys or service-role secrets).
2. Add authenticated integration tests using separate synthetic requester and provider accounts; verify ownership isolation, provider invitation access, contact-detail privacy, provider approval/suspension, and consent revocation.
3. Add operator-only server-side workflows for provider verification, request routing, status transitions, and incident handling. Do not implement these with client-side service-role credentials.
4. Build and test the real request and provider onboarding flows; replace demo-only copy only after end-to-end tests pass.
5. Complete Manitoba pilot legal, insurance, safeguarding, privacy, accessibility, and transport checks before taking real requests.
6. Keep the GitHub pull request draft until independent review and launch gates are complete.

## Credential handling

The project API URL and publishable key may be configured in a local development environment. Never commit secrets. Never expose a Supabase service-role/secret key in browser code, a public repository, or a `NEXT_PUBLIC_*` variable.
