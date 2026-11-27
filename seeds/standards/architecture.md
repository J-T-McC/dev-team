# Architecture Standards

> Owned by the Principal Engineer (proposes) and the approver dev-team `workflow/handoffs.md` § Autonomy names (the Owner, below autonomous). Setup fills what it can from the code; a section marked _open_ is set by the first plan that needs it, which proposes it.

## Requirements (active)
- Significant, hard-to-reverse decisions require an ADR (plugin `templates/adr.md`).
- Designs stay within `<ws>/stack/stack.md`; deviations require an Owner-approved ADR.
- Every technical plan section must trace to a PRD acceptance criterion.

## Module boundaries
_Open — layering rules, allowed dependencies between modules._

## API design
_Open — REST/GraphQL/RPC conventions, versioning, error format._

## Data
_Open — migration policy, naming, soft-delete policy._

## Security baseline
- Secrets never in code, logs, or the repository; they come from the environment or a secret manager.
- Validate input where it enters the system; deny by default.
- _Open — sign-in and permission patterns._
