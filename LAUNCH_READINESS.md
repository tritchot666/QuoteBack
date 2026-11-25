# QuoteBack launch readiness

Last reviewed: 2026-11-25

## Current verified state

- The repository default branch is `main`.
- The repository currently exposes a single root file, `index.html`.
- The repository language is reported as HTML.
- The landing page describes an automated SMS/email estimate-follow-up SaaS for Canadian HVAC, plumbing, and electrical contractors.
- The landing page advertises CAD $199 and $349 monthly plans and links to Stripe Checkout.
- The page states that account credentials and dedicated Canadian SMS number provisioning are delivered within one business hour.
- The page describes CSV upload, email forwarding, integrations, scheduled follow-ups, reply handling, and revenue recovery.
- No application backend, database, authentication, customer dashboard, messaging provider integration, payment webhook, or deployment workflow has been verified in this repository.
- No end-to-end customer workflow or payment fulfilment has been tested.

## Launch gate: do not advertise unverified fulfilment

Before accepting recurring subscriptions, implement and test:

1. Customer authentication, tenant isolation, and secure account provisioning.
2. Persistent storage for companies, customers, estimates, consent evidence, messages, and status history.
3. A messaging provider integration with Canadian number provisioning, delivery status, inbound replies, STOP/HELP handling, and suppression lists.
4. Email delivery with sender authentication, bounce handling, unsubscribe processing, and suppression lists.
5. A consent/eligibility record for each recipient, including source, timestamp, purpose, and applicable consent basis.
6. Import validation and duplicate prevention for uploaded CSV data.
7. Job/estimate workflow, pause-on-reply behavior, retry controls, audit logs, and revenue reporting.
8. Stripe subscription checkout configuration, signed webhook verification, entitlement provisioning, cancellation, failed-payment handling, and refund workflow.
9. Privacy, security, retention, deletion, incident response, and customer support procedures.
10. End-to-end tests covering signup, import, follow-up, opt-out, inbound reply, approval, cancellation, and payment lifecycle.

## Canadian messaging safeguards

- Do not treat a publicly visible email address as blanket permission for bulk marketing.
- For commercial electronic messages, document a valid CASL consent basis before sending; include sender identification and a working unsubscribe mechanism.
- For SMS, obtain and record appropriate consent before sending commercial messages, identify the sender, and support required opt-out handling.
- Keep customer consent and suppression records. Never re-message a recipient who has opted out unless a valid legal basis permits it.
- Have Canadian counsel review the actual customer messaging flows and privacy terms before launch.

## Safe go-to-market sequence

1. Keep the current landing page available for discovery, but do not drive paid traffic or promise immediate automated fulfilment until the product and checkout lifecycle are verified.
2. Offer a clearly disclosed, manually delivered pilot only if the operator can actually provide the promised service.
3. Recruit a small number of contractors through referrals, opt-in enquiries, trade communities that permit promotion, and properly qualified one-to-one outreach.
4. Measure quote recovery, response rate, opt-outs, delivery failures, and customer retention before scaling.
5. Turn on recurring paid plans only after the launch gates above pass.

## Release evidence

Record test date, environment, test account, expected result, actual result, and evidence for each launch gate. A successful static-page render is not an end-to-end SaaS test.
