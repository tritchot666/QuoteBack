# MVP Scope — Independent Living Canada

## Target users
- Older adults arranging support for themselves
- People with disabilities arranging practical daily-living support
- Adult children and other authorized family supporters coordinating services
- Independent local service providers and community organizations

## Core MVP journey
1. Visitor selects a service category and enters a city/postal-code area.
2. Visitor describes the practical task, preferred date/time, mobility/access requirements relevant to the service, and contact method.
3. Platform routes the request to suitable providers or an operator for manual matching.
4. Providers respond with availability, price/estimate, service boundaries, and relevant credentials.
5. Customer or authorized family contact reviews options and chooses a provider.
6. Booking confirmation, cancellation rules, and service status are recorded.
7. Customer can request recurring service or coordinate additional family support with explicit permission.

## First launch categories
- Non-emergency accessible/assisted transportation
- Companionship and social visits
- Errands and grocery support
- Light housekeeping and household assistance
- Home accessibility modifications

## Explicitly out of scope for first release
- Emergency dispatch or 911 replacement
- Ambulance, stretcher, or medical transportation
- Clinical care, diagnosis, nursing, medication administration, or personal care
- Automated eligibility decisions for government funding
- Handling medical records or detailed health profiles
- Nationwide launch before province-specific service, insurance, and regulatory checks
- Provider payment escrow or guarantees of service quality

## MVP screens
- Public home page and service category pages
- Request-support form
- Provider interest / onboarding form
- Operator dashboard for requests and provider matching
- Customer request status and quote comparison
- Family-authorized contact workflow (explicit consent)
- Privacy, safety, accessibility, cancellation, and complaint information

## Commercial tests
- Interview 15 families/caregivers and 15 providers in one launch area.
- Obtain at least 5 providers willing to accept pilot referrals across 2–3 service categories.
- Secure at least 5 genuine service requests and 3 paid pilot transactions before investing in automation.
- Track response time, match rate, completed service rate, repeat request rate, customer satisfaction, provider acquisition cost, and gross margin per booking.

## Launch acceptance criteria
- Keyboard-accessible, mobile-first, screen-reader-friendly forms.
- Clear distinction between emergency and non-emergency services.
- Explicit consent before a family member can arrange or receive updates about another adult.
- Provider credentials and insurance fields with expiry/review dates where applicable.
- Documented complaint, incident, cancellation, and safeguarding procedures.
- Privacy-minimizing collection and role-based access enforced by database RLS.
- No live payment collection until provider terms, refunds, disputes, and tax treatment are defined.
- All advertised service areas and availability are real and verified.
