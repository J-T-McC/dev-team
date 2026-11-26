---
type: llm
---
Before writing anything, the reply asks the user to choose:
1. Whose project this is, with three answers: their own project shared with the repository (dev-team's rules and documents committed with the code), their own project just for them for now (kept out of the repository's history), or someone else's project (guest: nothing of dev-team shows up in their work). Each answer has a one-line meaning.
2. How involved they want to be: supervised, standard or autonomous, each with a one-line meaning, standard marked as recommended.
3. The commit message style, with dev-team's ticket style shown as an example (for instance `feat(auth): ENG-123 add login timeout`).
Every question marks a recommended answer. It may also ask what they are building. Fail if it asks about the workspace folder, the features folder or folder naming as questions of their own, or asks more than four questions.
