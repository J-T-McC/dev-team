# Design Standards

> Owned by the Designer (proposes) and Project Owner (approves). A section marked _open_ is set by the first design spec that needs it, which proposes it for the Owner's yes.

## Requirements (active)
- Every UI-bearing user story maps to a flow in the design spec (plugin `templates/design-spec.md`); states (empty, loading, error, success) are designed wherever they occur.
- Each spec leads with a committed Concept and links mockups of its key screens.
- Stay consistent with documented components and patterns; a new component or pattern is welcome when it serves the story better, flagged as new in the spec.
- Accessible by construction: semantic elements, visible text as the accessible name, focus order, contrast — explicit labels only where nothing visible names a control.

## Craft bar (active)
- A clear point of view beats a safe default: the design should stand out next to a generic version of itself.
- No copy that explains what the design already makes obvious — no labels restating button text, no helper text for self-evident fields.
- Empty, loading, and error states get the same care as the happy path.
- Brand voice, and references the team admires: _open_.

## Design tool (active)
Where mockups live. `none` → self-contained HTML in `<feature>/mockups/`.
- **Tool:** none *(e.g. `figma`, `penpot` — reached through its MCP server)*
- **MCP server:** — *(set with the tool)*
- **File / project / page for mockups:** — *(set with the tool)*
- **Snapshot in the workspace:** yes *(a PNG or HTML copy of each key screen beside the frame links, so roles without the tool — and cheaper reads — can check UI against it)*

## Design system
_Open — component library, tokens, spacing/typography scales._

## Interaction patterns
_Open — validation feedback, confirmation dialogs, loading and error conventions._

## Accessibility baseline
- WCAG 2.2 AA; everything works with a keyboard alone and reads correctly in a screen reader.

## Responsive targets
_Open — the screen sizes and devices it supports, from where the product runs._
