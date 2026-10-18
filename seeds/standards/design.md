# Design Standards

> **Placeholder** — customize per project. Owned by the Designer (proposes) and Project Owner (approves).

## Requirements (active)
- Every UI-bearing user story maps to a flow in the design spec (plugin `templates/design-spec.md`); states (empty, loading, error, success) are designed wherever they occur.
- Each spec leads with a committed Concept and links mockups of its key screens.
- Stay consistent with documented components and patterns; a new component or pattern is welcome when it serves the story better, flagged as new in the spec.
- Accessible by construction: semantic elements, visible text as the accessible name, focus order, contrast — explicit labels only where nothing visible names a control.

## Craft bar (active)
- A clear point of view beats a safe default: the design should stand out next to a generic version of itself.
- No copy that explains what the design already makes obvious — no labels restating button text, no helper text for self-evident fields.
- Empty, loading, and error states get the same care as the happy path.
- _Customize: brand voice, references the team admires, how far to push._

## Design tool (active)
Where mockups live. `none` → self-contained HTML in `docs/design/<feature-slug>/`.
- **Tool:** none *(e.g. `figma`, `penpot` — reached through its MCP server)*
- **MCP server:** _TBD_
- **File / project / page for mockups:** _TBD_
- **Snapshot in `docs/`:** yes *(a PNG or HTML copy of each key screen beside the frame links, so roles without the tool — and cheaper reads — can check UI against it)*

## Design system
_TBD — component library, tokens, spacing/typography scales._

## Interaction patterns
_TBD — validation feedback, confirmation dialogs, loading and error conventions._

## Accessibility baseline
_TBD — target WCAG level, keyboard support, screen-reader requirements._

## Responsive targets
_TBD — supported breakpoints/form factors._
