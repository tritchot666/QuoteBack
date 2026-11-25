# QuoteBack launch readiness

Last reviewed: 2026-11-25

## Verified repository state

- GitHub Pages hosts the static marketing site and browser workspace.
- `app.html` supports local estimate records, status tracking, follow-up queue, dashboard totals, editable email/SMS drafts, CSV import/export and business profile settings.
- Local records are stored in the current browser using localStorage. They do not sync between devices or users.
- The marketing page contains the two Stripe Payment Links supplied and confirmed by the owner. Their external checkout and charge flow have not been independently tested here.
- The website explicitly warns that paid fulfilment is not available until onboarding and deliverables are confirmed.
- A Supabase migration now defines tenant-owned profiles, subscriptions, estimates, consent evidence, suppression records and message audit events with row-level security.
- A Stripe webhook Edge Function now verifies Stripe signatures, handles checkout/subscription/payment-failure events and records processed event IDs.
- The Supabase backend is scaffolding only. No Supabase project, credentials, migration execution, function deployment or Stripe webhook endpoint has been configured or verified.

## Remaining launch gates

1. Create a separate Supabase project, apply the migration and configure secrets. Do not use Lovable's backend.
2. Add and test frontend Supabase Auth, account recovery, authenticated session handling and cloud CRUD. Keep local mode clearly identified until connected.
3. Replace static Payment Link-only onboarding with authenticated Checkout Sessions carrying the signed-in user's UUID as `client_reference_id`. Configure actual Stripe Price IDs and webhook events. Verify subscription activation, renewal, cancellation, failed payment and refunds.
4. Build a customer consent capture workflow with source, timestamp, purpose and applicable CASL consent basis; enforce suppression before any send.
5. Integrate a Canadian-capable SMS provider and email provider, including sender verification, delivery/inbound webhooks, STOP/HELP/unsubscribe, retries and suppression.
6. Implement scheduled follow-up jobs, pause-on-reply, audit history, duplicate-safe CSV import and tenant-isolation tests.
7. Finalize privacy, retention, deletion, incident response, customer support and terms with qualified Canadian legal review.
8. Run end-to-end tests against deployed services, including signup, cross-tenant access denial, estimate CRUD, CSV import, consent, opt-out, inbound reply, approval, payment lifecycle and account cancellation.

## Canadian messaging safeguards

- A publicly visible email address is not blanket permission for bulk marketing.
- Record a valid CASL consent basis before sending commercial electronic messages; include sender identification and a working unsubscribe mechanism.
- For SMS, obtain and record appropriate consent before sending commercial messages, identify the sender and support opt-out handling.
- Maintain suppression records and never re-message opted-out recipients unless a valid legal basis permits it.

## Release decision

**Not production-ready for paid self-serve subscriptions or automatic messaging.** The local browser workspace is usable for manual estimate tracking. Backend schema and webhook code are committed but not deployed. Do not represent subscriptions, cloud storage, automated messaging or customer provisioning as operational until the gates above are tested and signed off.
