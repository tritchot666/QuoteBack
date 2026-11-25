# QuoteBack backend setup (GitHub-only codebase)

This repository remains the source of truth. The backend is a separate Supabase project, not Lovable.

## What this adds
- Tenant-owned profiles, estimates, subscriptions, consent evidence, suppression entries and message audit events.
- Row-level security on customer data.
- Automatic profile creation when a user signs up.
- A Stripe webhook with signature verification, event idempotency, subscription status updates and failed-payment handling.

## Required external project setup
Create a Supabase project on the free tier and run `supabase/migrations/202611250001_quoteback_core.sql` in its SQL editor. Deploy the Edge Function:

```sh
supabase functions deploy stripe-webhook --no-verify-jwt
supabase secrets set STRIPE_SECRET_KEY=... STRIPE_WEBHOOK_SECRET=... STRIPE_STARTER_PRICE_ID=... STRIPE_GROWTH_PRICE_ID=... SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=...
```

Never put the service-role key, Stripe secret key, or webhook secret in browser code or GitHub.

Configure Stripe to send these events to `https://YOUR_PROJECT_REF.supabase.co/functions/v1/stripe-webhook`:
- `checkout.session.completed`
- `customer.subscription.updated`
- `customer.subscription.deleted`
- `invoice.payment_failed`

## Important Stripe limitation
The two existing Stripe Payment Links are preserved on the marketing page. They are not sufficient by themselves for secure account provisioning: checkout must carry the authenticated QuoteBack user's UUID as `client_reference_id`, and the webhook needs the actual recurring Price IDs. Do not enable paid self-serve onboarding until checkout is created from an authenticated session or the payment links are replaced with authenticated Checkout Sessions. The existing links must not be treated as proof of an active subscription entitlement.

## Messaging
No SMS/email provider is configured. Do not send marketing messages until recipient consent is documented and provider compliance (including Canadian sender identification, unsubscribe/STOP handling, suppression and delivery webhooks) is implemented. This schema stores consent and suppression evidence but does not send messages.

## Frontend integration remaining
Set the public Supabase project URL and anon key in the browser app only after project creation. Use Supabase Auth for sign-in, then read/write estimates under the signed-in user's ID. RLS is the security boundary; never rely on client-side filtering alone.
