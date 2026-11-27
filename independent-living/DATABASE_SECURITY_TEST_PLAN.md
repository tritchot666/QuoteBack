# Independent Living MVP — Database Security Test Plan

Status: written for the isolated MVP migrations; **not yet executed against Supabase**.

## Before applying
- Confirm the exact Supabase project ref belongs to the intended Independent Living environment.
- Confirm a current backup exists.
- Review the SQL in both `202611260001_independent_living_core.sql` and `202611260002_independent_living_provider_approval_guard.sql`.
- Apply to a development project first. Do not run against QuoteBack production.
- Confirm the migrations are recorded and inspect the resulting policies and triggers.

## Required test identities
Create separate authenticated test users for:
1. Requester A
2. Requester B
3. Provider A (pending)
4. Provider B (approved by trusted operator/server process)
5. Supporter A

Use synthetic data only. Never use real client details for security tests.

## Required checks

| Test | Expected result |
|---|---|
| Requester A inserts a service request with their own auth UID | Allowed |
| Requester A attempts to insert a request with Requester B's UID | Denied |
| Requester A reads their own request | Allowed |
| Requester A reads Requester B's request | No rows |
| Provider A attempts to set onboarding status to approved | Denied |
| Provider A reads a request without an invite | No rows |
| Approved Provider B reads a request after an invite | Allowed; only the non-contact request summary |
| Provider reads private contact table | No rows |
| Requester A reads their own private contact record | Allowed |
| Requester A reads Requester B's private contact record | No rows |
| Provider submits a response to its own valid invite | Allowed |
| Provider submits a response against another provider's invite | Denied |
| Requester A compares responses for their own request | Allowed |
| Requester A reads responses to Requester B's request | No rows |
| Supporter A tries to use a consent grant they do not own | Denied |

## Important implementation gaps (intentionally not enabled)
- Consent rows are stored, but family/supporter access is **not** implemented. A consent record alone must never be treated as authorization.
- Operator dashboard and operator role/permissions are not implemented. Trusted server-side operations need explicit authentication and authorization.
- Provider verification evidence, incident/complaint handling, bookings, notifications, and payments are not implemented.
- The provider approval guard assumes trusted service-role actions run server-side where `auth.uid()` is null. Verify this behavior in the target Supabase environment before relying on it.
- The current request schema is a starting point, not a substitute for a privacy impact assessment, legal review, or operational safeguarding process.

## Release gate
Do not collect real personal information or publish booking availability until the migrations have been applied and tested in the correct project, provider approval is controlled by an authorized operator, privacy and consent notices are reviewed, and the end-to-end workflow has been tested with synthetic accounts.
