# Independent Living Canada — Working Project

> Working title only. Brand/name is not cleared or finalized.

A Canada-wide service discovery and coordination platform helping older adults, people with disabilities, and families find practical support to live independently.

## Product promise
One place to find and coordinate trusted local help: accessible transportation, companionship, errands, home assistance, home modifications, and family coordination.

## Build strategy
- Keep QuoteBack intact. This work lives on the separate `independent-living-mvp` branch.
- Reuse patterns and proven components selectively; do not reuse QuoteBack's contractor-estimate schema as-is.
- Start with a lightweight discovery/booking marketplace, not a regulated care provider or transport operator.
- Begin validation in Manitoba, then expand province-by-province after local provider coverage and compliance checks.
- Brand remains provisional until corporate-name, trademark, and domain clearance.

## Initial launch categories
1. Accessible and assisted rides (non-emergency only)
2. Companionship and check-in visits
3. Errands, groceries, and prescription pickup/delivery
4. Light household help
5. Home accessibility and safety modifications
6. Family coordination and recurring schedules

## Important boundaries
- No emergency response, medical transport, clinical care, medication administration, or personal-care claims in the initial MVP.
- Providers remain independently responsible for their services, licensing, insurance, screening, and legal obligations; platform verification requirements must be designed and implemented before public launch.
- Never claim a provider is “vetted” until checks are actually completed and documented.
- Collect the minimum personal information necessary. Do not collect diagnoses or detailed health records in the initial request flow.
- Do not launch bookings or accept payments until provider onboarding, consent, cancellation/refund rules, privacy controls, safety escalation, and provincial requirements have been reviewed.

## Repository map
- `independent-living/README.md` — project overview
- `independent-living/MVP_SCOPE.md` — launch scope and acceptance criteria
- `independent-living/SAFETY_AND_COMPLIANCE.md` — operational safeguards
- `independent-living/prototype/index.html` — static, interactive concept prototype (no backend; does not submit or store requests)

## Next technical steps
1. Confirm brand after clearance.
2. Validate demand with families and local providers.
3. Design separate tables for service requests, providers, service areas, availability, bookings, and family-authorized contacts.
4. Implement Supabase Auth, RLS, consent/audit trails, and provider onboarding.
5. Add booking/payment only after the operating model and compliance review are complete.
