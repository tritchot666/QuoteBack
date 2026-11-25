# QuoteBack backend setup (GitHub-only codebase)

The GitHub repository is the source of truth. Supabase provides authentication, database storage, and server-side functions. Lovable is not required.

## Current capabilities
- Supabase email/password sign-in in the workspace.
- Tenant-owned estimate storage protected by row-level security (RLS).
- Profile creation on signup.
- Stripe webhook foundation with signature verification and subscription event handling.
- Local CSV import/export and editable message drafts.

## Not yet active
- Paid self-serve checkout is disabled until secrets, recurring Stripe Price IDs, webhook delivery, and account provisioning are configured and tested.
- Automated email and SMS sending are not implemented. Do not advertise or promise automated delivery.
- Local-only records created while signed out do not automatically transfer into a cloud account. Export a CSV before switching accounts or clearing browser data.

## Supabase project configuration
Run `supabase/migrations/202611250001_quoteback_core.sql` in the Supabase SQL Editor.

In **Authentication → URL Configuration**, set:
- Site URL: `https://tritchot666.github.io`
- Redirect URL: `https://tritchot666.github.io/QuoteBack/app.html`

The browser app uses the public project URL and publishable key. Never put a secret/service-role key in browser code or GitHub.

## Edge Functions
Deploy both functions:
```sh
supabase functions deploy create-checkout-session
supabase functions deploy stripe-webhook --no-verify-jwt
```

Set server-side secrets using the Supabase CLI or dashboard Edge Function secrets:
- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`
- `STRIPE_STARTER_PRICE_ID` (recurring CAD price)
- `STRIPE_GROWTH_PRICE_ID` (recurring CAD price)
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY` (used to validate the signed-in customer)
- `SUPABASE_SERVICE_ROLE_KEY` (webhook only; never expose it)

The checkout function validates the caller's Supabase access token and accepts only the `starter` or `growth` plan. It returns a Stripe-hosted Checkout URL. The webhook verifies Stripe signatures and writes subscription status to the database.

In Stripe, create recurring CAD Prices and configure a webhook endpoint:
`https://idqalgwrxeecsdnuogyf.supabase.co/functions/v1/stripe-webhook`

Subscribe to:
- `checkout.session.completed`
- `customer.subscription.created`
- `customer.subscription.updated`
- `customer.subscription.deleted`
- `invoice.payment_failed`

Do not enable paid buttons until both functions are deployed, all server secrets are configured, test-mode checkout succeeds for a real authenticated test account, webhook events update the correct subscription row, and cancellation/payment-failure states are verified.

## Messaging and Canadian compliance
No sending provider is configured. The app only creates drafts. Before any commercial email or SMS automation, implement and test consent evidence, sender identification, unsubscribe/STOP handling, suppression checks, and provider delivery webhooks. Follow Canadian Anti-Spam Legislation and applicable carrier rules. Never send bulk unsolicited messages.
