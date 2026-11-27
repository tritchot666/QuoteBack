# Data Model & Technical Build Plan

Status: design proposal only. Do not run migrations until the actual application schema, Supabase project, and deployment environment have been inspected.

## Product architecture

Keep this product isolated from QuoteBack production. Reuse only reviewed patterns (authentication, UI components, notification utilities, and Stripe integration where appropriate). Do not reuse QuoteBack's quote tables or payment flows without checking their assumptions.

Initial operating model: a manually assisted marketplace. A request is reviewed by an operator, matched with eligible providers, and sent for responses. Do not promise instant dispatch or guaranteed availability.

## Proposed entities

- `profiles`: authenticated user profile; minimal contact details and preferred communication method.
- `provider_profiles`: provider business/person, service description, operating status, contact details, onboarding state.
- `provider_services`: normalized service categories offered by a provider.
- `provider_service_areas`: cities/postal-prefixes served; avoid storing precise location until required.
- `provider_verification_checks`: check type, status, reviewer, checked-at, expiry-at, evidence reference; never display a check as passed until reviewed.
- `service_requests`: requester, service category, general location, description, preferred time window, accessibility logistics relevant to the request, status.
- `request_contacts`: contact person and relationship to recipient; separate from recipient identity.
- `consent_grants`: adult recipient's authorization for a named supporter to submit requests or receive specified updates; scope, granted-at, expires-at, revoked-at, evidence.
- `request_provider_invites`: provider invited to a request, invited-at, response deadline, response status.
- `provider_responses`: availability, price/estimate, service boundaries, qualifications relevant to the job, response timestamp.
- `bookings`: selected provider, agreed scope, scheduled window, agreed price, cancellation terms accepted, status.
- `booking_events`: append-only status/audit history; actor, event, timestamp, safe metadata.
- `incidents_and_complaints`: restricted access, triage status, owner, timestamps, resolution; collect only necessary details.
- `operator_notes`: internal operational notes with strict role-based access; never place sensitive health details here.
- `notification_preferences`: consent and channel preferences for email/SMS; unsubscribe/suppression state.

## Access-control rules

1. Enable RLS on every user-facing table.
2. A requester can read only their own requests and bookings.
3. A supporter can access only records covered by an active, scoped consent grant.
4. A provider can read only requests explicitly invited to that provider, and only the minimum details needed to respond.
5. Providers cannot see competing providers' bids or private customer contact details before selection unless operationally required and authorized.
6. Only designated operators can review provider checks, manage incidents, and change verification states.
7. Service-role credentials remain server-side. Never expose them to browser code.
8. Use audit events for consent changes, provider status changes, booking changes, and privileged access.

## Privacy and safety defaults

- Do not collect diagnoses, medication lists, health-card numbers, or detailed clinical history in the MVP.
- Ask only for practical access details needed to fulfil a service (for example, whether a wheelchair-accessible vehicle is required and whether the rider can transfer independently).
- Do not expose home addresses to providers until an appropriate stage of the booking and with clear notice.
- Consent must be revocable. Revocation prevents future supporter access; retain only records required for legitimate audit/legal purposes under a documented retention policy.
- No emergency, ambulance, clinical care, medication administration, or personal care services in the initial release.
- Every service category and province requires an operational checklist before activation.

## Build sequence

### Milestone 0 — Repository and environment audit
- Identify the actual frontend framework, routing, styling, test commands, and deployment workflow.
- Inspect Supabase project linkage, current migrations, auth settings, RLS conventions, and secrets without exposing secret values.
- Confirm the independent-living branch does not affect production.
- Record current baseline build/test results.

### Milestone 1 — Non-transactional lead capture
- Add accessible service request form with clear non-emergency scope.
- Add provider interest form.
- Initially send submissions to a secure operator workflow; do not publish a provider directory until providers are reviewed.
- Add privacy notice, consent wording, and contact preferences.
- Add abuse/spam controls and retention policy.

### Milestone 2 — Operator matching console
- Request queue, status, service category, service area, and timestamps.
- Invite eligible providers manually.
- Record provider responses and compare options.
- Keep an audit trail of status changes and customer communications.

### Milestone 3 — Accounts and consent
- Add authentication, profile management, RLS, scoped family-supporter grants, revocation, and audit events.
- Test cross-account access denial before any public launch.

### Milestone 4 — Booking and payment
- Only after provider terms, insurance, screening, cancellations, refunds, disputes, taxes, and province-specific rules are approved.
- Use server-side payment intents/checkout and verified webhooks.
- Do not hold funds or imply escrow unless a compliant marketplace payment design is implemented.

## Acceptance tests

- Unauthenticated users cannot access private requests or bookings.
- A user cannot read or modify another user's request by changing an ID.
- A supporter without an active grant cannot access the adult recipient's data.
- Revoked consent immediately blocks future supporter access.
- A provider cannot see a request unless invited.
- A provider cannot read another provider's response.
- A user can request deletion/correction through a documented process.
- All forms work by keyboard and screen reader and have clear error messages.
- No request flow implies emergency response or guaranteed service availability.
