# Independent Living Canada — MVP acceptance and launch gates

**Status:** planning checklist for the Winnipeg pilot. This is not evidence that any gate has passed.

## Gate 1 — Service definition
- [ ] Confirm the legal operating entity and cleared business/brand name.
- [ ] Confirm exact launch geography and hours; publish only areas with verified provider coverage.
- [ ] Publish a plain-language service boundary: coordination of non-emergency, non-clinical supports only.
- [ ] State clearly that the service is not an emergency response, ambulance, medical transport, home-care agency, or guarantee of provider availability.
- [ ] Define who answers calls/messages, escalation coverage, cancellations, refunds (if applicable), complaints and incident reports.

## Gate 2 — Legal, insurance and safeguarding review
- [ ] Obtain Manitoba legal advice on privacy, consumer protection, marketplace/platform liability, contracts, accessibility, employment classification and payment/tax obligations.
- [ ] Confirm applicable transportation rules for each ride category, including vehicle/driver requirements, commercial use, insurance and municipal rules.
- [ ] Obtain insurance advice for the platform and each service category; document minimum provider coverage.
- [ ] Define identity, reference, background-check and vulnerable-sector screening requirements where lawful and appropriate.
- [ ] Establish safeguarding rules for visits in private homes, lone-worker safety, boundaries, suspected abuse/neglect and incident escalation.
- [ ] Do not advertise regulated, clinical or personal-care services until the relevant licensing and compliance requirements are independently verified.

## Gate 3 — Consent and privacy
- [ ] Obtain informed agreement from the adult receiving support before creating or sharing a request.
- [ ] Treat family members as supporters only where the adult has explicitly authorized their role; make consent specific, recorded, time-limited where appropriate and revocable.
- [ ] Collect only contact, location and practical service details needed to coordinate the request.
- [ ] Do not collect diagnoses, medication lists, health-card numbers or medical records in the MVP.
- [ ] Provide a privacy notice covering purpose, disclosures, retention, access/correction, deletion requests and contact for privacy concerns.
- [ ] Confirm secure authentication, role-based access, row-level security, audit events, backups and retention/deletion procedures.
- [ ] Test that customers cannot read other customers' requests or private contact details, and providers see only requests specifically shared with them.

## Gate 4 — Provider onboarding
- [ ] Verify legal/business identity and named contact.
- [ ] Verify references, relevant experience, insurance and required licences/permits.
- [ ] Verify accessible-vehicle features and safe boarding/transfer boundaries for transportation providers.
- [ ] Agree written scope, prices, cancellation terms, service standards and complaint process.
- [ ] Record credential expiry dates and suspend referrals when required documents expire.
- [ ] Obtain provider agreement and privacy/confidentiality commitments.
- [ ] Complete a manual test referral before allowing live referrals.

## Gate 5 — Technical and operational testing
- [ ] Deploy database migrations only to a confirmed, dedicated development project—not QuoteBack production.
- [ ] Review migrations and policies with a qualified developer/security reviewer before production use.
- [ ] Run the full database security test plan using separate customer, provider and operator identities.
- [ ] Confirm unauthenticated users cannot read or write private records.
- [ ] Confirm provider accounts cannot approve themselves or view uninvited requests.
- [ ] Confirm consent revocation stops future family/provider disclosures as designed.
- [ ] Test keyboard-only navigation, screen-reader labels, mobile layouts, contrast and zoom.
- [ ] Test duplicate submissions, invalid input, outages, notification failures and recovery.
- [ ] Do not activate payments until provider contracts, customer terms, taxes, refunds, disputes and payout controls are approved.

## Gate 6 — Controlled pilot
- [ ] Interview at least 15 families/caregivers and 15 potential providers in the target area.
- [ ] Recruit and verify at least 5 providers across a deliberately narrow service mix.
- [ ] Process 5 genuine requests manually with documented consent and secure handling.
- [ ] Complete at least 3 paid pilot transactions only after legal, insurance, pricing and payment gates pass.
- [ ] Track time to first response, match rate, completed service rate, cancellations, complaints, incidents and customer/provider feedback.
- [ ] Review every incident and complaint before expanding geography or categories.

## Current honest status
The repository contains planning documents, SQL migration drafts and static demonstration pages. The HTML demos do not submit or save information. The SQL migrations have not been confirmed as deployed to a dedicated development database. No live provider network, customer bookings or revenue are established by these artifacts.

**Release rule:** A checkbox is complete only when there is dated evidence and an accountable reviewer. Do not treat a prototype screen or a successful local demo as proof of production readiness.
