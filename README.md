# physics-lesson-prep

`physics-lesson-prep` is a Codex Skill for evidence-gated physics lesson preparation.

It is designed for teachers who need a structured workflow rather than a one-shot lesson generator. The Skill asks for learner/course identity, goals, evidence, teaching conditions, curriculum or textbook sources, and teacher confirmations before producing formal lesson materials.

## What it supports

- One-to-one tutoring, small groups, and regular classes.
- Domestic middle/high school, university, AP, IB, Cambridge International, Pearson Edexcel, and other identifiable systems.
- Score improvement, synchronized consolidation, advance preparation, and competition or enrichment routes.
- Official-source and textbook-led curriculum research.
- Rolling preparation of only the next 2-4 lessons.
- Chinese teacher-facing workflow by default, while preserving course codes, textbook titles, formulas, and English student prompts when needed.
- Optional local Excel roster guidance and optional PDF/PPT export gates.

## Install locally

Copy `skills/physics-lesson-prep` into your Codex skills directory:

```powershell
Copy-Item -Recurse -Force .\skills\physics-lesson-prep "$env:USERPROFILE\.codex\skills\physics-lesson-prep"
```

This repository also includes a Windows installer used during development:

```powershell
pwsh -NoProfile -File .\scripts\install-physics-lesson-prep.ps1 -ValidateOnly
pwsh -NoProfile -File .\scripts\install-physics-lesson-prep.ps1
```

## Validate

```powershell
pwsh -NoProfile -File .\tests\physics-lesson-prep\validate-skill.ps1
pwsh -NoProfile -File .\tests\physics-lesson-prep\validate-acceptance.ps1
```

The acceptance validator expects local forward-test artifacts under `output/physics-lesson-prep-validation`, which are not committed.

## Privacy note

The Skill is a workflow guide, not a compliance tool. It requires teacher confirmation before saving records, local roster files, PDFs, PPTs, or other exports. Do not publish student names, contacts, IDs, credentials, school-system screenshots, or raw private learning records.

## License

No open-source license has been selected yet. Choose and add a license before encouraging third-party reuse.
