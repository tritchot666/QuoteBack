# QuoteBack

QuoteBack is a browser-based estimate tracking workspace for Canadian residential trade contractors.

## Current application
- Marketing site: `index.html`
- Estimate workspace: `app.html` (local browser storage; CSV import/export; editable email/SMS drafts)
- Backend foundation: `supabase/` (database migration and Stripe webhook)

## Status
The static workspace can be used locally in a browser. The Supabase backend foundation is not live until a project is created, the migration is applied, and secrets are configured. There is currently no live authentication/cloud sync or automatic messaging provider. Existing Stripe payment links do not activate accounts by themselves.

See [BACKEND_SETUP.md](BACKEND_SETUP.md) before configuring a backend. Never commit secrets.
