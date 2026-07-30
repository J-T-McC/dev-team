# Claude Development Organization Bootstrap

## Objective

Create a reusable multi-agent development organization for Claude Code.

This organization should mimic a real software engineering team where each agent has a clearly defined responsibility and communicates through documented artifacts rather than making assumptions.

The end goal is to allow future software projects to move from product requirements to production-ready code using specialized agents.

---

# Core Principles

## Single Responsibility

Every agent owns exactly one responsibility.

Agents must never perform work that belongs to another role.

---

## Documentation First

Agents communicate primarily through project documents.

Generated artifacts become the source of truth.

Agents should reference existing documentation before asking questions.

---

## No Assumptions

If required information is missing:

* Search existing project documentation.
* Ask the responsible agent.
* Ask the project owner.

Never invent requirements.

---

## Human Approval Gates

No phase automatically proceeds to the next.

Completion of each phase requires explicit user approval.

---

## Build Small

Favor many small documents over large documents.

Examples:

* One PRD per feature
* One technical plan per feature
* One task list per technical plan

---

# Phase 1

Create the project directory structure.

```
.claude/
    CLAUDE.md

    skills/
        orchestrator/
        product-manager/
        principal-engineer/
        task-planner/
        senior-developer/
        reviewer/

docs/
    product/
    architecture/
    plans/
    tasks/
    questions/
    stack/
    standards/

templates/

workflow/
```

---

# Phase 2

Generate a global CLAUDE.md.

Responsibilities:

* Overall project philosophy
* Coding standards
* Documentation rules
* Escalation rules
* Approval workflow
* Required reading order
* Communication expectations

This document should be shared by every agent.

---

# Phase 3

Generate every Skill.

Each skill must contain:

* Purpose
* Responsibilities
* Inputs
* Outputs
* Decision authority
* Escalation rules
* Deliverables
* Things this agent must never do
* Required documents
* Workflow
* Examples

Generate the following skills:

* Orchestrator
* Product Manager
* Principal Engineer
* Task Planner
* Senior Developer
* Reviewer

---

# Phase 4

Generate document templates.

Create reusable templates for:

Product Requirement Document

```
Feature

Problem

Goals

Users

User Stories

Acceptance Criteria

Out of Scope

Open Questions
```

Technical Plan

```
Overview

Architecture

Data Model

API

Services

Validation

Risks

Dependencies

Implementation Notes
```

Task Plan

```
Task

Description

Dependencies

Files

Acceptance Criteria

Testing
```

Architecture Decision Record

Question

Decision

Alternatives

Reasoning

Impact

Question Template

Requested By

Question

Context

Required By

Priority

Answer

Review Template

Summary

Findings

Recommendations

Approval

---

# Phase 5

Generate workflow documentation.

Create:

workflow/overview.md

Explain:

Product Owner

↓

Product Manager

↓

Principal Engineer

↓

Task Planner

↓

Senior Developer

↓

Reviewer

↓

Project Owner Approval

---

Also create:

workflow/handoffs.md

Define what information every handoff must contain.

Each artifact should include:

Inputs

Outputs

Dependencies

Outstanding Questions

Next Agent

---

# Phase 6

Generate communication rules.

Document how agents communicate.

Preferred order:

1. Existing documentation

2. Previous decisions

3. Responsible upstream agent

4. User

Never bypass the chain of responsibility.

---

# Phase 7

Generate project standards.

Create:

docs/standards/

Including:

coding.md

documentation.md

testing.md

architecture.md

planning.md

review.md

These documents initially contain placeholders and guidance for future customization.

---

# Phase 8

Generate stack configuration.

Create:

docs/stack/stack.md

Include sections for:

Languages

Frameworks

Infrastructure

Cloud

CI/CD

Database

Testing

Static Analysis

Formatting

Package Managers

Security

Performance

Deployment

Leave placeholder values where project-specific information is required.

---

# Phase 9

Generate orchestrator documentation.

The Orchestrator is responsible for:

Determining the next agent

Checking prerequisites

Tracking project progress

Ensuring approvals exist

Detecting blockers

Escalating missing information

Maintaining project status

The Orchestrator never writes code.

The Orchestrator never writes PRDs.

The Orchestrator never designs architecture.

The Orchestrator coordinates work only.

---

# Phase 10

Generate example workflow.

Create a fictional feature named:

User Authentication

Generate:

Product Requirement

↓

Technical Plan

↓

Task List

↓

Question

↓

Question Response

↓

Review

Demonstrate proper communication between every agent.

---

# Quality Requirements

Every generated markdown document should:

* be concise
* use consistent formatting
* avoid duplicated guidance
* avoid conflicting responsibilities
* clearly define ownership
* include practical examples
* remain reusable across projects

---

# Final Deliverable

When complete, the repository should contain a fully functional reusable development organization that can be copied into any future software project.

Do not begin implementing software.

Only generate the organization, documentation, templates, and skills required to support future development.
