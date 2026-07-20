# Physics Lesson Prep Skill Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild `physics-lesson-prep` as a versioned, state-gated, evidence-based teaching workflow that refuses premature lesson generation, validates curriculum and textbook sources, plans realistic course cycles, prepares only the next two to four lessons, and rolls forward from post-lesson evidence.

**Architecture:** Keep a canonical, Git-tracked skill at `skills/physics-lesson-prep/` and install an exact copy to `C:/Users/admin/.codex/skills/physics-lesson-prep/` only after validation. Make `SKILL.md` a concise S0-S9 controller and move detailed intake, research, source, planning, material, reflection, physics-audit, and template rules into focused reference files. Use a dependency-free PowerShell structural validator plus ten fresh-agent forward tests to verify behavior.

**Tech Stack:** Agent Skills Markdown/YAML, PowerShell 7, Git, Codex multi-agent forward testing, Codex global skills directory.

---

## File Map

Create or replace these canonical source files:

```text
skills/physics-lesson-prep/
├── SKILL.md                              # Trigger metadata, state routing, hard gates, response protocol
├── agents/
│   └── openai.yaml                       # UI name, description, and gated default prompt
└── references/
    ├── state-machine.md                  # S0-S9 entry, allowed action, completion, confirmation, rollback
    ├── intake-and-diagnosis.md           # Course identity, four goals, evidence, diagnosis, smart questioning
    ├── curriculum-research.md            # Domestic, international, university double-track, textbook selection
    ├── source-validation.md              # A-D evidence levels, edition checks, conflicts, citations, failure modes
    ├── course-planning.md                # Capacity, phases, dependencies, exit criteria, rolling 2-4 lessons
    ├── material-packages.md              # Concept, practice, mixed, competition packages and answer requirements
    ├── reflection-and-records.md          # Anonymous records, privacy, reflection, mastery, adjustments, archive
    ├── physics-audit.md                  # Physics, diagram, experiment, question, solution, and source consistency
    └── templates.md                      # Exact response and teacher-confirmation templates
```

Create these implementation support files:

```text
scripts/
└── install-physics-lesson-prep.ps1        # Safe, exact canonical-to-global installation
tests/physics-lesson-prep/
├── validate-skill.ps1                    # Dependency-free structural and content validation
├── acceptance-cases.md                   # Ten forward-test prompts and pass criteria
└── expected-files.txt                    # Exact installed file inventory
```

Remove these obsolete canonical/global references after the replacement is complete:

```text
references/lesson-modes.md
```

Do not modify the approved specification at `docs/superpowers/specs/2026-07-20-physics-lesson-prep-skill-redesign.md` except to correct a discovered contradiction.

---

### Task 1: Create the Canonical Skill Skeleton and Failing Structural Test

**Files:**
- Create: `skills/physics-lesson-prep/SKILL.md`
- Create: `skills/physics-lesson-prep/agents/openai.yaml`
- Create: `skills/physics-lesson-prep/references/.gitkeep`
- Create: `tests/physics-lesson-prep/expected-files.txt`
- Create: `tests/physics-lesson-prep/validate-skill.ps1`

- [ ] **Step 1: Create the exact expected-file inventory**

Use `apply_patch` to create `tests/physics-lesson-prep/expected-files.txt` with:

```text
SKILL.md
agents/openai.yaml
references/state-machine.md
references/intake-and-diagnosis.md
references/curriculum-research.md
references/source-validation.md
references/course-planning.md
references/material-packages.md
references/reflection-and-records.md
references/physics-audit.md
references/templates.md
```

- [ ] **Step 2: Create a dependency-free validator that initially fails**

Use `apply_patch` to create `tests/physics-lesson-prep/validate-skill.ps1` with this complete logic:

```powershell
param(
  [string]$SkillPath = "skills/physics-lesson-prep"
)

$ErrorActionPreference = "Stop"
$resolved = Resolve-Path -LiteralPath $SkillPath
$skillRoot = $resolved.Path
$failures = [System.Collections.Generic.List[string]]::new()

function Require([bool]$Condition, [string]$Message) {
  if (-not $Condition) { $script:failures.Add($Message) }
}

$expected = Get-Content -LiteralPath "tests/physics-lesson-prep/expected-files.txt" |
  Where-Object { $_.Trim() -ne "" }

foreach ($relative in $expected) {
  $native = $relative.Replace("/", [IO.Path]::DirectorySeparatorChar)
  Require (Test-Path -LiteralPath (Join-Path $skillRoot $native)) "Missing file: $relative"
}

if (Test-Path -LiteralPath (Join-Path $skillRoot "SKILL.md")) {
  $skill = Get-Content -LiteralPath (Join-Path $skillRoot "SKILL.md") -Raw
  Require ($skill -match "(?ms)^---\r?\nname: physics-lesson-prep\r?\ndescription: .+?\r?\n---") "Invalid SKILL.md frontmatter"
  Require (($skill -split "`n").Count -le 300) "SKILL.md must remain a concise controller under 300 lines"
  Require ($skill -match "S0") "State S0 is not routed"
  Require ($skill -match "S9") "State S9 is not routed"
  Require ($skill -match "Do not generate formal") "Formal-material hard gate is missing"
  Require ($skill -match "Current stage") "Response status protocol is missing"
  Require ($skill -notmatch "TODO|TBD|FIXME|\[TODO") "Placeholder text remains in SKILL.md"
}

$allMarkdown = Get-ChildItem -LiteralPath $skillRoot -Recurse -File -Filter "*.md"
foreach ($file in $allMarkdown) {
  $text = Get-Content -LiteralPath $file.FullName -Raw
  Require ($text -notmatch "TODO|TBD|FIXME|\[TODO") "Placeholder text remains in $($file.FullName)"
}

$joined = ($allMarkdown | ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw }) -join "`n"
$requiredPhrases = @(
  "primary goal",
  "diagnostic blueprint",
  "two or three",
  "primary textbook",
  "double-track",
  "teacher confirmation",
  "next two to four lessons",
  "anonymous",
  "representative errors",
  "search-result snippets"
)
foreach ($phrase in $requiredPhrases) {
  Require ($joined -match [regex]::Escape($phrase)) "Missing required behavior: $phrase"
}

$uiPath = Join-Path $skillRoot "agents/openai.yaml"
if (Test-Path -LiteralPath $uiPath) {
  $ui = Get-Content -LiteralPath $uiPath -Raw
  Require ($ui -match '\$physics-lesson-prep') "Default prompt must mention `$physics-lesson-prep"
  Require ($ui -match "intake") "UI metadata must describe the gated intake workflow"
}

$unexpected = Get-ChildItem -LiteralPath $skillRoot -Recurse -File |
  ForEach-Object { [IO.Path]::GetRelativePath($skillRoot, $_.FullName).Replace("\", "/") } |
  Where-Object { $_ -notin $expected }
foreach ($file in $unexpected) {
  $failures.Add("Unexpected skill file: $file")
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Output "PASS: physics-lesson-prep structure and required behaviors validated"
```

- [ ] **Step 3: Create minimal invalid placeholders only for the red phase**

Use `apply_patch` to create `skills/physics-lesson-prep/SKILL.md`:

````markdown
---
name: physics-lesson-prep
description: Temporary red-phase controller for the physics lesson preparation redesign.
---

# Physics Lesson Prep

This file intentionally lacks the complete gated workflow until the failing test is recorded.
```

Create `skills/physics-lesson-prep/agents/openai.yaml`:

```yaml
interface:
  display_name: "Physics Lesson Prep"
  short_description: "Guided physics course intake and evidence-based planning"
  default_prompt: "Use $physics-lesson-prep to start a gated physics course intake before preparing lessons."
```

Create an empty `skills/physics-lesson-prep/references/.gitkeep`.

- [ ] **Step 4: Run the validator and verify the intended red result**

Run:

```powershell
pwsh -NoProfile -File tests/physics-lesson-prep/validate-skill.ps1
```

Expected: exit code `1` with missing-file errors for all nine reference files and missing-behavior errors. Do not proceed if it passes.

- [ ] **Step 5: Commit the red test and skeleton**

Run:

```powershell
git add -- skills/physics-lesson-prep tests/physics-lesson-prep
git commit -m "test: define physics lesson prep skill contract"
```

Expected: one commit containing only the canonical skeleton and validation contract.

---

### Task 2: Implement the S0-S9 Controller and State Contract

**Files:**
- Replace: `skills/physics-lesson-prep/SKILL.md`
- Create: `skills/physics-lesson-prep/references/state-machine.md`
- Modify: `skills/physics-lesson-prep/agents/openai.yaml`

- [ ] **Step 1: Replace `SKILL.md` with the concise controller**

Use `apply_patch` so the final file contains exactly these responsibilities and no lesson-generation shortcut:

```markdown
---
name: physics-lesson-prep
description: Run a gated, evidence-based physics teaching workflow for one-to-one tutoring, small groups, and school classes across domestic middle/high school, university, AP, IB, Cambridge International, Pearson Edexcel, and other identifiable systems. Use when a teacher asks to establish a learner course record, diagnose learning needs, research and validate curriculum or textbooks, plan a course cycle, prepare concept/practice/mixed/competition materials, review lesson evidence, or update later lessons. Require course identity, a primary goal, learning evidence, teaching conditions, validated sources, and teacher confirmations before formal lesson generation.
---

# Physics Lesson Prep

Operate as a state-gated teaching workflow, not a one-shot lesson generator.

## Non-Negotiable Gate

Do not generate formal course plans, lesson plans, worksheets, or question packs before the current state permits them. A teacher request to skip questions does not waive a gate. When blocked, provide only the questions, collection checklist, diagnostic blueprint, source research, or confirmation package allowed by the current state.

## Start Every Turn

1. Identify an explicitly named existing anonymous course record, if any.
2. Extract confirmed facts from the current request and supplied artifacts.
3. Detect conflicts, missing evidence, version changes, or goal changes.
4. Determine the earliest incomplete state from S0 through S9.
5. Read only the reference files required for that state.
6. Ask one to five decision-relevant questions; do not repeat answered questions.

Begin the response with:

```text
Course record:
Current stage:
Confirmed:
Missing:
This turn:
Next gate:
```

## Route By State

- **S0-S2:** Read `references/state-machine.md` and `references/intake-and-diagnosis.md`.
- **S3:** Read `references/intake-and-diagnosis.md` and `references/templates.md`.
- **S4:** Read `references/intake-and-diagnosis.md`, `references/course-planning.md`, and `references/templates.md`.
- **S5-S6:** Read `references/curriculum-research.md`, `references/source-validation.md`, and `references/templates.md`.
- **S7:** Read `references/course-planning.md`, `references/source-validation.md`, and `references/templates.md`.
- **S8:** Read `references/material-packages.md`, `references/physics-audit.md`, and `references/templates.md`.
- **S9:** Read `references/reflection-and-records.md`, `references/course-planning.md`, and `references/templates.md`.
- **Any file write:** Also read `references/reflection-and-records.md` and obtain explicit permission before writing.

## Hard-Gate Order

1. S0: anonymous course record choice is unconfirmed.
2. S1: learner and actual course identity are incomplete.
3. S2: primary goal, target date, or success criteria are incomplete.
4. S3: authentic learning evidence or a completed diagnostic is absent.
5. S4: duration, frequency, cycle, mode, setting, workload, or outputs are incomplete.
6. S5: course boundary and knowledge mainline are not supported by validated sources.
7. S6: the teacher has not confirmed the Course Evidence Package or primary textbook.
8. S7: the teacher has not confirmed the course-cycle framework.
9. S8: prepare only the next two to four lessons permitted by the confirmed framework.
10. S9: require reflection evidence and teacher approval of adjustments before the next batch.

## Teacher Control

Require explicit teacher confirmation for course identity conflicts, source/version selection, primary textbook selection, course-cycle framework, moderate or major adjustments, local file creation, privacy-sensitive fields, and practical safety decisions.

Label unresolved work as provisional or draft. Never invent a syllabus requirement, textbook edition, ISBN, assessment rule, source quotation, student result, or experimental observation.
````

- [ ] **Step 2: Create the complete state contract**

Create `references/state-machine.md` with a table for every S0-S9 state. Each row must contain `Entry condition`, `Allowed output`, `Forbidden output`, `Completion evidence`, `Teacher confirmation`, and `Rollback target`.

The exact contract must include:

```markdown
| State | Entry condition | Allowed output | Forbidden output | Completion evidence | Teacher confirmation | Rollback target |
|---|---|---|---|---|---|---|
| S0 | No record decision | Record options and privacy summary | File creation and lesson content | New/existing/temporary choice | Required before writing | None |
| S1 | Course identity incomplete | 1-5 identity questions and collection checklist | Curriculum assumptions and lessons | Identifiable course boundary | Confirm conflicts | S0 |
| S2 | Goal incomplete | Goal questions and conflict analysis | Course plan | Primary goal, date, success criteria | Confirm priority | S1 |
| S3 | Evidence absent or weak | Evidence request or diagnostic blueprint | Formal cycle plan | Credible artifact or completed diagnostic | Confirm blueprint before test creation | S1/S2 |
| S4 | Teaching conditions incomplete | Questions and Course Requirements Confirmation Sheet | Formal cycle plan | Confirmed duration, frequency, weeks, mode, setting, load, outputs | Required | S1-S3 |
| S5 | Sources unverified | Research task card, source research, book comparison | Formal plan | Traceable course boundary and knowledge mainline | Required in S6 | S1-S4 |
| S6 | Evidence package unconfirmed | Course Evidence Package | Course-cycle plan | Explicit A/B/C/D decision | Required | S5 |
| S7 | Framework unconfirmed | Three capacity options and cycle framework | Detailed future course | Explicit A/B/C/D/E decision | Required | S2-S6 |
| S8 | Framework confirmed | Next 2-4 lessons only | Entire future course in detail | Teacher-review-ready batch | Review label required | S3-S7 |
| S9 | Prior batch taught | Reflection structuring, mastery update, adjustment proposal | Next formal batch before evidence and approval | Reflection evidence plus approved adjustment | Required | S1-S8 by change type |
```

Also define exact rollback rules:

- course or version change -> S1 then S5-S6;
- goal change -> S2;
- invalid learner profile -> S3;
- schedule or delivery change -> S4;
- source or textbook change -> S5-S6;
- minor adjustment -> stay S9 then S8;
- moderate adjustment -> S7 then S8;
- major adjustment -> earliest affected state.

- [ ] **Step 3: Update the UI metadata to advertise intake rather than instant output**

Replace `agents/openai.yaml` with:

```yaml
interface:
  display_name: "Physics Lesson Prep"
  short_description: "Run gated intake, research, planning, and lesson preparation"
  default_prompt: "Use $physics-lesson-prep to start a gated intake for my learner or class, verify the course and evidence, and tell me the next required step before preparing lessons."
```

- [ ] **Step 4: Run focused controller checks**

Run:

```powershell
pwsh -NoProfile -File tests/physics-lesson-prep/validate-skill.ps1
```

Expected: still fails because the remaining reference files are missing, but no longer reports missing `S0`, `S9`, hard gate, status protocol, or UI intake behavior.

- [ ] **Step 5: Commit the controller**

```powershell
git add -- skills/physics-lesson-prep/SKILL.md skills/physics-lesson-prep/agents/openai.yaml skills/physics-lesson-prep/references/state-machine.md
git commit -m "feat: add gated physics lesson workflow controller"
```

---

### Task 3: Implement Intake, Goals, Evidence, Diagnosis, and Smart Questioning

**Files:**
- Create: `skills/physics-lesson-prep/references/intake-and-diagnosis.md`
- Create: `skills/physics-lesson-prep/references/templates.md`

- [ ] **Step 1: Write the intake and diagnosis reference**

Create `references/intake-and-diagnosis.md` with these exact top-level sections:

```markdown
# Intake And Diagnosis

## Questioning Rules
## S0 Anonymous Record Intake
## S1 Domestic School Intake
## S1 International Course Intake
## S1 University Course Intake
## S2 Four Goal Routes
## Multiple-Goal Priority And Conflict Rules
## S3 Evidence Priority
## Error Analysis Taxonomy
## Diagnostic Blueprint
## Diagnostic Result Profile
## S4 Teaching Conditions
## Smart Skip And Conflict Rules
```

Populate them with these enforceable requirements:

- ask one to five questions per turn;
- classify fields as required, important, or optional;
- do not ask a field already confirmed by request or artifact;
- require country/region, school/program type, stage, full course, system/code, current module, setting, and language;
- add university institution/link, department, course code, credits/hours, prerequisites, syllabus, textbook, assessment, and class type;
- add school textbook edition, local region, school progress, examination target, and module status;
- support score, synchronized, advance, and competition routes with the goal-specific fields in the approved spec;
- require one primary goal, target date, and observable success criteria;
- prioritize authentic tests, assignments, errors, feedback, teacher observation, progress, diagnostic, then self-assessment;
- prohibit `carelessness` as a terminal diagnosis;
- require diagnostic-blueprint confirmation before generating a diagnostic test;
- profile knowledge, method, representation, mathematics, experiment/data, assessed communication, and learning behavior;
- collect duration, weekly frequency, sustainable weeks, deadline, mode/proportion, setting, class size, delivery, homework capacity, output requirements, equipment, visibility, digital access, accommodations, and school integration.

Include this insufficient-information example:

```text
Course record: not created
Current stage: S1 learner and course identity
Confirmed: Topic is rigid-body motion
Missing: learner stage, actual course, curriculum or course code, current module, teaching context
This turn: collect the minimum course identity
Next gate: identify a traceable course boundary

Please provide:
1. The learner's country/region and grade or university stage.
2. The full course name, system/examination board, or university course code.
3. The current textbook, syllabus, course page, or table of contents.

I will not produce a lesson until the actual course can be identified.
```

- [ ] **Step 2: Create reusable intake and diagnosis templates**

Create `references/templates.md` initially with these exact templates:

````markdown
# Templates

## Turn Status Header

```text
Course record:
Current stage:
Confirmed:
Missing:
This turn:
Next gate:
```

## Course Requirements Confirmation Sheet

```text
Anonymous record:
Course identity:
Primary and secondary goals:
Target date and success criteria:
Learning evidence:
Lesson duration and weekly frequency:
Available weeks and deadlines:
Teaching mode and proportions:
Setting, class size, and delivery:
Homework capacity:
Equipment and access:
Required outputs:
Unresolved conditions:
Teacher decision: confirm / revise / provide missing information
```

## Diagnostic Blueprint

```text
Diagnostic purpose:
Course boundary:
Prerequisites covered:
Core content covered:
Ability dimensions:
Duration:
Item count and format:
Scoring and interpretation:
Evidence required to continue:
Teacher decision: confirm blueprint / revise blueprint
```

## Learner Evidence Profile

| Dimension | Status | Evidence | Repeated pattern | Teaching impact | Confidence |
|---|---|---|---|---|---|
````

Do not add research, planning, lesson, or reflection templates yet; later tasks extend this same file.

- [ ] **Step 3: Add focused validator assertions for intake**

Modify `validate-skill.ps1` by adding these required phrases:

```powershell
"one to five",
"carelessness",
"score improvement",
"synchronized consolidation",
"advance preparation",
"competition or enrichment",
"Course Requirements Confirmation Sheet"
```

Expected semantics: all phrases must exist somewhere in the canonical skill.

- [ ] **Step 4: Run the validator**

```powershell
pwsh -NoProfile -File tests/physics-lesson-prep/validate-skill.ps1
```

Expected: intake-related assertions pass; missing research, planning, materials, reflection, and audit files still fail.

- [ ] **Step 5: Commit intake and diagnosis**

```powershell
git add -- skills/physics-lesson-prep/references/intake-and-diagnosis.md skills/physics-lesson-prep/references/templates.md tests/physics-lesson-prep/validate-skill.ps1
git commit -m "feat: add learner intake and diagnostic gates"
```

---

### Task 4: Implement Curriculum Research, Textbook Selection, and Source Validation

**Files:**
- Create: `skills/physics-lesson-prep/references/curriculum-research.md`
- Create: `skills/physics-lesson-prep/references/source-validation.md`
- Modify: `skills/physics-lesson-prep/references/templates.md`
- Modify: `tests/physics-lesson-prep/validate-skill.ps1`

- [ ] **Step 1: Write the curriculum research routes**

Create `references/curriculum-research.md` with:

```markdown
# Curriculum Research

## Research Entry Gate
## Research Task Card
## Domestic Middle And High School Route
## AP Route
## IB Route
## Cambridge International Route
## Pearson Edexcel And Other Awarding Bodies
## University Double-Track Research
## Assigned Textbook Route
## No Assigned Textbook Route
## Secondary Teaching-Material Search
## Research Failure And Offline Degradation
```

The university section must explicitly use the phrase `double-track` and define:

```text
Track A - Actual course boundary:
teacher syllabus -> course/department page -> course code/catalog -> assigned chapters -> lectures/assignments/labs/examination scope

Track B - Disciplinary knowledge line:
assigned textbook -> teacher references -> authoritative same-level textbooks/monographs -> reputable publisher resources -> professional bodies/open courses
```

The no-assigned-textbook route must require exactly two or three candidates and teacher confirmation of one primary textbook. Record title, author, publisher, ISBN, edition/year, chapters, level, strengths, limitations, notation differences, and adoption evidence.

For domestic and international routes, encode the exact official-first orders in the approved specification. State that another university, region, or examination system may inform teaching but cannot prove the target course requirement.

The secondary search section must distinguish concept-focused, practice-focused, and competition research. The offline section must allow only a collection checklist, institution/file search suggestions, textbook information form, and diagnostic tools.

- [ ] **Step 2: Write source levels and authenticity checks**

Create `references/source-validation.md` with:

```markdown
# Source Validation

## Separate Three Claim Types
## A-D Evidence Levels
## Web Page Verification
## Official PDF Verification
## Book And Edition Verification
## Cross-Validation Rules
## Source Conflict Procedure
## Question Provenance And Copyright
## Research Record
## Course Evidence Package
```

Define claim types:

- course fact: what the target course requires;
- disciplinary fact: what physics and mathematics establish;
- teaching recommendation: a pedagogical choice for this learner.

Define A-D levels exactly as decisive official/assigned, authoritative professional, screened teaching practice, and lead only. Require original pages instead of search-result snippets. Verify publisher/institution, identity, version, date, originality, completeness, replacement status, locality, and relevance.

For books, require publisher catalog, library catalog such as WorldCat, course reading list, author/institution page, or lawful contents/sample. Reject retailer titles and unknown PDFs as sole edition evidence.

Require at least one decisive source plus a second supporting source when available for versions, assessment changes, mandatory experiments, prerequisites, and weighting. If only one official source exists, state that cross-validation remains incomplete.

- [ ] **Step 3: Extend templates with research and evidence packages**

Append these sections to `references/templates.md`:

````markdown
## Research Task Card

```text
Anonymous record:
Course and version:
Student stage and setting:
Primary goal and target date:
Current module:
Known textbook or syllabus:
Questions to verify:
Required official evidence:
Required book evidence:
```

## Source Record

```text
Claim type: course fact / disciplinary fact / teaching recommendation
Evidence level: A / B / C / D
Title:
Institution or author:
URL or bibliographic record:
Published/updated or edition year:
Access date:
Course/version applicability:
Exact information used:
Cross-validation:
Replacement or conflict risk:
Verification status:
```

## Textbook Comparison

| Candidate | Author | Publisher | ISBN | Edition | Chapters | Level | Strengths | Limitations | Notation differences | Adoption evidence |
|---|---|---|---|---|---|---|---|---|---|---|

Teacher decision: choose one primary textbook / request new candidates / provide assigned book

## Course Evidence Package

```text
Course identity and version:
School Course Boundary:
Textbook Knowledge Mainline:
Required / recommended / excluded content:
Prerequisite relationships:
Assessment and marking requirements:
Official, school, and recommended sequence:
Learner evidence gap:
Source list:
Source conflicts:
Unresolved items:
Teacher decision: A confirm / B modify order / C research again / D provide school material
```
````

- [ ] **Step 4: Add research assertions and run validation**

Add these phrases to the validator:

```powershell
"Track A",
"Track B",
"ISBN",
"WorldCat",
"course fact",
"disciplinary fact",
"teaching recommendation",
"Course Evidence Package"
```

Run:

```powershell
pwsh -NoProfile -File tests/physics-lesson-prep/validate-skill.ps1
```

Expected: research/source assertions pass; planning/material/reflection/audit files remain missing.

- [ ] **Step 5: Commit curriculum research**

```powershell
git add -- skills/physics-lesson-prep/references/curriculum-research.md skills/physics-lesson-prep/references/source-validation.md skills/physics-lesson-prep/references/templates.md tests/physics-lesson-prep/validate-skill.ps1
git commit -m "feat: add curriculum and textbook evidence workflow"
```

---

### Task 5: Implement Course-Cycle Planning and Rolling Lesson Scope

**Files:**
- Create: `skills/physics-lesson-prep/references/course-planning.md`
- Modify: `skills/physics-lesson-prep/references/templates.md`
- Modify: `tests/physics-lesson-prep/validate-skill.ps1`

- [ ] **Step 1: Write the complete planning reference**

Create `references/course-planning.md` with:

```markdown
# Course Planning

## Planning Entry Gate
## Teaching Capacity Calculation
## Goal-Capacity Conflict
## Course-Cycle Layers
## Module Dependencies And Minimum Remediation
## Module Exit Criteria
## Assessment Nodes
## Four Goal Strategies
## Concept-Practice Allocation
## Risks And Alternative Routes
## Rolling Two-To-Four-Lesson Rule
## Course-Cycle Confirmation
```

Require the capacity calculation to include planned weeks, weekly frequency, duration, holidays, diagnosis, stage assessment, revision, and 5-10% contingency. When capacity is insufficient, generate minimum viable, recommended, and enhanced routes.

Define the course-cycle layers as final outcomes, stages, dependency graph, minimum prerequisite repair, mode allocation, exit criteria, assessments, contingency, and risks.

Encode distinct strategies for all four goals:

- score: loss analysis, high-frequency repair, item/marking methods, timed mixed work, simulation and retraining;
- synchronized: pre-activation, concept repair, schoolwork correction, transfer, assessment preparation;
- advance: familiarity, understanding, readiness, cognitive-load reduction, mathematics preparation;
- competition: mathematical route, model library, multiple methods, approximation, proof, non-standard strategy, official problems.

Require only the first lesson to be fully fixed; lessons two to four remain adjustable. Prohibit detailed generation of all future lessons.

- [ ] **Step 2: Extend templates with capacity and cycle confirmation**

Append:

````markdown
## Capacity Calculation

```text
Calendar weeks:
Lessons per week:
Minutes per lesson:
Theoretical lessons:
Holidays/cancellations:
Diagnosis and assessments:
Revision and simulation:
5-10% contingency:
Usable teaching lessons:
Goal-capacity conflict:
```

## Course-Cycle Framework

```text
Final outcomes:
Minimum viable route:
Recommended route:
Enhanced route:
Stages and lesson allocation:
Dependency graph:
Minimum prerequisite remediation:
Concept/practice proportions:
Module exit criteria:
Assessment nodes:
Review and contingency:
Risks, triggers, and alternatives:
Next 2-4 lessons to prepare after confirmation:
Teacher decision: A confirm / B change proportions / C change order or allocation / D change objectives / E add evidence
```
````

- [ ] **Step 3: Add planning assertions and run validation**

Add:

```powershell
"5-10% contingency",
"minimum viable route",
"recommended route",
"enhanced route",
"Module Exit Criteria",
"first lesson"
```

Run the validator. Expected: only material, reflection, and audit files remain missing.

- [ ] **Step 4: Commit course planning**

```powershell
git add -- skills/physics-lesson-prep/references/course-planning.md skills/physics-lesson-prep/references/templates.md tests/physics-lesson-prep/validate-skill.ps1
git commit -m "feat: add evidence-based rolling course planning"
```

---

### Task 6: Implement Four Distinct Material Packages and Physics Release Audit

**Files:**
- Create: `skills/physics-lesson-prep/references/material-packages.md`
- Create: `skills/physics-lesson-prep/references/physics-audit.md`
- Modify: `skills/physics-lesson-prep/references/templates.md`
- Modify: `tests/physics-lesson-prep/validate-skill.ps1`

- [ ] **Step 1: Write distinct material-package contracts**

Create `references/material-packages.md` with:

```markdown
# Material Packages

## S8 Entry Gate And Common Header
## Concept-Focused Package
## Practice-Focused Package
## Mixed Package
## Competition Or Enrichment Package
## Student And Teacher Version Separation
## Question Provenance
## Standard Solution Contract
## Lesson One Versus Lessons Two To Four
## Teacher-Review Label
```

The concept package must require accurate concept statements, prerequisites, central question, phenomenon, models and boundaries, derivation, multiple representations, real-life/engineering example with idealization limits, counterexamples, teacher question chain, concept check, guided example, foundation practice, answers, and diagnostic interpretation.

The practice package must require question-type map, selection rationale, source, original/adapted status, difficulty, cognitive demand, estimated time, student version, teacher solution, marking points, error cause, variant, second-attempt problem, and error-record fields.

The mixed package must enforce diagnosis -> targeted explanation -> modeling -> scaffolded practice -> independent practice -> error discussion -> variant transfer -> exit evidence.

The competition package must require minimal information, modeling, mathematics, graded hints, multiple solutions, method comparison, breakthrough point, dead ends, generalization, strategy reflection, and complete solution.

Define the standard solution contract exactly:

```text
Model and known conditions
Symbols, frame, and sign convention
Physical principle
Derivation or calculation
Final answer
Units and significant figures
Physical interpretation
Independent check
Marking points
Accepted alternative methods
```

- [ ] **Step 2: Replace the physics audit with the expanded release gate**

Create `references/physics-audit.md` with:

```markdown
# Physics Audit

## Universal Model And Calculation Audit
## Mechanics And Rigid-Body Audit
## Circuits And Electromagnetism Audit
## Waves, Optics, And SHM Audit
## Thermal, Fluids, Nuclear, And Modern Physics Audit
## Graph And Data Audit
## Diagram Specification And Release Gate
## Experiment Safety And Feasibility
## Question-Solution-Marking Consistency
## Cross-Textbook Notation And Depth
## Release Labels
```

Preserve all valid checks from the installed skill, then add:

- verify reference frame, body/system, constraints, generalized coordinates, sign convention, rigid-body assumptions, angular velocity/acceleration directions, relative velocity/acceleration, instantaneous-center limits, rolling constraints, inertia definitions, parallel-axis use, and energy/angular-momentum boundaries;
- require every diagram to have purpose, system, topology/geometry, labels, directions, scale status, and correspondence with the problem and solution;
- audit every original or adapted numerical problem independently;
- reject a spring-balance reading as net force unless all other components are modeled;
- reject qualitative observation as quantitative verification;
- compare textbook notation and derivation depth with the confirmed primary book;
- label output `teacher-review-ready` only when all gates pass, otherwise `draft` with exact unresolved items.

- [ ] **Step 3: Add lesson and material templates**

Append to `templates.md`:

````markdown
## Lesson Batch Header

```text
Anonymous record:
Current state: S8
Course/version:
Primary textbook and chapters:
Course-cycle stage:
Learner evidence used:
Package mode:
Lessons in this batch:
Source status:
Release label: teacher-review-ready / draft
Teacher checks still required:
```

## Single-Lesson Plan

```text
Position in cycle:
Evidence addressed:
Objectives and exit criteria:
Prerequisites:
Preparation:
Timeline with teacher move, learner action, question, evidence, and branch:
Knowledge explanation or question route:
Anticipated errors and responses:
Formative assessment:
Homework:
Faster-progress branch:
Slower-progress branch:
Post-lesson reflection fields:
```

## Practice Question Record

```text
Source:
Year/series/edition and item:
Official / licensed / original / adapted:
Concept and cognitive demand:
Difficulty and expected time:
Student prompt:
Teacher solution:
Marking points:
Common error and cause:
Variant:
Second-attempt problem:
```
````

- [ ] **Step 4: Add package/audit assertions and run validation**

Add:

```powershell
"Concept-Focused Package",
"Practice-Focused Package",
"Mixed Package",
"Competition Or Enrichment Package",
"Accepted alternative methods",
"instantaneous-center",
"teacher-review-ready"
```

Run the validator. Expected: only `reflection-and-records.md` remains missing.

- [ ] **Step 5: Commit materials and physics audit**

```powershell
git add -- skills/physics-lesson-prep/references/material-packages.md skills/physics-lesson-prep/references/physics-audit.md skills/physics-lesson-prep/references/templates.md tests/physics-lesson-prep/validate-skill.ps1
git commit -m "feat: add differentiated lesson packages and physics audit"
```

---

### Task 7: Implement Anonymous Records, Reflection, Mastery, and Rollback

**Files:**
- Create: `skills/physics-lesson-prep/references/reflection-and-records.md`
- Modify: `skills/physics-lesson-prep/references/templates.md`
- Delete: `skills/physics-lesson-prep/references/.gitkeep`
- Modify: `tests/physics-lesson-prep/validate-skill.ps1`

- [ ] **Step 1: Write record and reflection rules**

Create `references/reflection-and-records.md` with:

```markdown
# Reflection And Records

## File-Write Consent Gate
## Suggested Anonymous Record Structure
## Allowed And Prohibited Fields
## Source-Artifact Handling
## One-To-One And Small-Group Reflection
## Regular-Class Evidence
## Five-Dimension Reflection Analysis
## Mastery Scale 0-5
## Minor, Moderate, And Major Adjustments
## Rollback And Change History
## Next-Batch Gate
## Course Completion And Archive
## Damaged Or Conflicting Record Handling
```

Require explicit permission for the save directory, anonymous identifier, fields, and whether original materials may be copied or only referenced. Preview changes before writing and list changed files afterward.

Allow teaching-relevant anonymous course, goal, evidence, progress, errors, workload, and accommodation fields. Prohibit real names in filenames, contact details, credentials, addresses, unneeded medical/family information, and identifiable third-party student data.

Require one-to-one/small-group reflection fields from the specification. For regular classes, require at least two of accuracy, representative errors, sampled work, tier performance, observation, and stage-test statistics.

Use this mastery scale exactly:

```text
0 Not encountered
1 Encountered but cannot explain
2 Foundation tasks with prompts
3 Independent standard tasks
4 Transfer to varied contexts
5 Explanation, method comparison, and non-standard problems
```

Every mastery change must record evidence, limitations, date, and confidence. Classify adjustments as minor, moderate, or major and wait for teacher confirmation before applying them.

- [ ] **Step 2: Extend templates with record, reflection, adjustment, and summary forms**

Append:

````markdown
## Anonymous Record Write Preview

```text
Proposed directory:
Anonymous identifier:
Files to create or modify:
Fields to store:
Original materials: reference only / copy allowed
Identifiable information excluded:
Teacher decision: approve / revise / do not save
```

## Post-Lesson Reflection

```text
Planned versus completed content:
Independent performance:
Representative success:
Representative errors:
Exact sticking point:
Timing variance:
Homework evidence:
Learner feedback:
Teacher judgment:
Evidence confidence:
```

## Regular-Class Evidence

```text
Class accuracy:
Representative errors:
Sampled work:
High/middle/foundation tier performance:
Teacher observation:
Stage-test statistics:
Evidence items supplied:
```

## Adjustment Proposal

```text
Adjustment level: minor / moderate / major
Evidence:
Current mastery state:
Proposed change:
Effect on next lessons:
Effect on course cycle:
Rollback state if required:
Teacher decision: confirm / revise / collect more evidence
```

## Course Summary

```text
Initial goals:
Actual teaching delivered:
Evidence of knowledge and skill change:
Goals achieved or not achieved:
Remaining gaps:
Effective methods:
Low-value methods:
Recommended next chapters/books:
Teacher professional judgment to add:
Archive decision:
```
````

- [ ] **Step 3: Complete validation rules**

Add:

```powershell
"explicit permission",
"real names",
"at least two",
"Adjustment level",
"Course Summary"
```

Delete `.gitkeep`, then run:

```powershell
pwsh -NoProfile -File tests/physics-lesson-prep/validate-skill.ps1
```

Expected: `PASS: physics-lesson-prep structure and required behaviors validated`.

- [ ] **Step 4: Run additional inventory and link checks**

Run:

```powershell
$root = Resolve-Path 'skills/physics-lesson-prep'
$skill = Get-Content -LiteralPath "$root/SKILL.md" -Raw
$links = [regex]::Matches($skill, 'references/[a-z0-9-]+\.md') | ForEach-Object Value | Sort-Object -Unique
$links | ForEach-Object {
  if (-not (Test-Path -LiteralPath (Join-Path $root $_))) { throw "Broken reference: $_" }
}
"PASS: all SKILL.md reference links resolve"
```

Expected: `PASS: all SKILL.md reference links resolve`.

- [ ] **Step 5: Commit records and reflection**

```powershell
git add -- skills/physics-lesson-prep/references/reflection-and-records.md skills/physics-lesson-prep/references/templates.md tests/physics-lesson-prep/validate-skill.ps1
git add -u -- skills/physics-lesson-prep/references/.gitkeep
git commit -m "feat: add reflection and anonymous course records"
```

---

### Task 8: Define and Run the Ten Forward-Test Acceptance Cases

**Files:**
- Create: `tests/physics-lesson-prep/acceptance-cases.md`
- Create during testing: `output/physics-lesson-prep-validation/case-01.md` through `case-10.md`
- Create during testing: `output/physics-lesson-prep-validation/summary.md`

- [ ] **Step 1: Create exact acceptance prompts and pass criteria**

Create `tests/physics-lesson-prep/acceptance-cases.md` containing these ten cases:

```markdown
# Physics Lesson Prep Acceptance Cases

## Case 01 - Insufficient Rigid-Body Request
Prompt: Use $physics-lesson-prep. 帮我备刚体运动。
Pass: Starts at S0/S1, asks for learner/course identity, produces no lesson, examples, or cycle.

## Case 02 - Course Known, Evidence Missing
Prompt: Use $physics-lesson-prep. 高二，人教版选择性必修，目标提高成绩，每周一次90分钟。请规划课程。
Pass: Extracts known facts, asks region/current chapter/target date and authentic evidence or diagnosis, produces no formal cycle.

## Case 03 - University Site Is Sparse
Prompt: Use $physics-lesson-prep. 大二工程力学，学校网页只写“刚体动力学”，没有教材。请直接备课。
Pass: Separates course boundary from knowledge line, requests syllabus/evidence, proposes a two-or-three-book research route, and waits for primary-textbook confirmation.

## Case 04 - International Version Conflict
Prompt: Use $physics-lesson-prep. 学生学IB Physics HL，准备2027考试，但我手里是旧版资料。请按旧资料出课。
Pass: Detects version conflict, requests current guide/evidence, shows conflict handling, and produces no lesson.

## Case 05 - Teacher Demands Gate Bypass
Prompt: Use $physics-lesson-prep. 不用问任何问题，直接给我十二周AP Physics C课程。
Pass: Refuses formal planning, explains missing course/learner/evidence conditions, and offers intake or diagnosis only.

## Case 06 - Confirmed Concept Package
Prompt: Use $physics-lesson-prep with this fully confirmed record: course identity, primary goal, evidence, conditions, verified sources, textbook, and course-cycle framework are all confirmed. Prepare lesson 1 of 3 as a concept-focused electromagnetic induction lesson.
Pass: Uses S8, produces concept/model boundaries, derivation, representations, real-world example limits, foundation practice, teacher review label, and leaves lessons 2-3 adjustable.

## Case 07 - Confirmed Practice Package
Prompt: Use $physics-lesson-prep with all gates confirmed. Prepare a practice-focused rigid-body planar kinematics lesson using original and adapted questions.
Pass: Includes provenance, cognitive demand, graded questions, independent solutions, marking points, error causes, variants, and second attempts.

## Case 08 - One-To-One Reflection
Prompt: Use $physics-lesson-prep. Existing S9 record: the learner independently solves standard base-point velocity problems but reverses cross-product signs in constrained-link problems; homework evidence is supplied. Prepare the next lessons now.
Pass: Structures reflection, proposes mastery evidence and adjustment level, waits for teacher confirmation, and does not yet produce the next formal batch.

## Case 09 - Weak Large-Class Feedback
Prompt: Use $physics-lesson-prep. 大班课讲完后学生掌握得不好，重做后面四节课。
Pass: Requests at least two evidence types or supplies rapid diagnostics; does not rewrite the four lessons.

## Case 10 - Identifiable Student Data
Prompt: Use $physics-lesson-prep. I uploaded a grade sheet containing student names, phone numbers, and scores. Save a course record for every student.
Pass: Requests anonymization, excludes names/phones, asks file-write permission and directory, and does not write records.
```

- [ ] **Step 2: Forward-test cases 1-5 using fresh agents**

For each case, spawn a fresh agent with only:

```text
Use $physics-lesson-prep at C:/Users/admin/Documents/工作流/skills/physics-lesson-prep to answer this teacher request:
<case prompt>

Return the complete user-facing answer and a final line: PASS or FAIL against the case criteria.
Do not modify files.
```

Save each complete response to `output/physics-lesson-prep-validation/case-0N.md` using `apply_patch`. Do not reveal the expected ideal answer beyond the case criteria.

- [ ] **Step 3: Forward-test cases 6-10 using fresh agents**

Use the same isolation and save pattern. For cases claiming confirmed state, the agent may treat the prompt's confirmation statement as an available record; it must still follow S8/S9 boundaries.

- [ ] **Step 4: Review failures and patch only transferable causes**

For every failed case, document:

```text
Observed behavior:
Violated gate or quality rule:
Root cause in skill instructions:
Minimal transferable change:
Cases rerun:
```

Patch the responsible canonical file, rerun the structural validator, and rerun the failed case plus one adjacent case. Do not add prompt-specific wording that merely memorizes a test.

- [ ] **Step 5: Create the acceptance summary**

Create `output/physics-lesson-prep-validation/summary.md` with:

```markdown
# Physics Lesson Prep Forward-Test Summary

| Case | Result | State chosen | Formal output correctly gated | Notes |
|---|---|---|---|---|

## Structural Validation

## Revisions Made From Failures

## Residual Risks

## Release Decision
```

Release decision must be `PASS` only if all ten cases pass after reruns.

- [ ] **Step 6: Commit acceptance fixtures and validated skill revisions**

Do not commit generated validation outputs unless the user explicitly wants them tracked. Commit the test specification and any skill fixes:

```powershell
git add -- tests/physics-lesson-prep/acceptance-cases.md skills/physics-lesson-prep
git commit -m "test: forward-test physics lesson prep gates"
```

---

### Task 9: Install the Validated Skill Safely

**Files:**
- Create: `scripts/install-physics-lesson-prep.ps1`
- Replace outside repository after approval: `C:/Users/admin/.codex/skills/physics-lesson-prep/**`

- [ ] **Step 1: Create a safe installation script**

Use `apply_patch` to create `scripts/install-physics-lesson-prep.ps1`:

```powershell
param(
  [string]$Source = "skills/physics-lesson-prep",
  [string]$Destination = "C:/Users/admin/.codex/skills/physics-lesson-prep"
)

$ErrorActionPreference = "Stop"
$sourcePath = (Resolve-Path -LiteralPath $Source).Path
$destinationParent = Split-Path -Parent $Destination
$destinationName = Split-Path -Leaf $Destination

if ($destinationName -ne "physics-lesson-prep") {
  throw "Refusing unexpected destination name: $destinationName"
}
if (-not (Test-Path -LiteralPath $destinationParent)) {
  throw "Destination parent does not exist: $destinationParent"
}

pwsh -NoProfile -File "tests/physics-lesson-prep/validate-skill.ps1" -SkillPath $sourcePath
if ($LASTEXITCODE -ne 0) { throw "Canonical skill validation failed" }

$backup = "$Destination.backup-$(Get-Date -Format yyyyMMdd-HHmmss)"
if (Test-Path -LiteralPath $Destination) {
  Copy-Item -LiteralPath $Destination -Destination $backup -Recurse -Force
}

if (Test-Path -LiteralPath $Destination) {
  Remove-Item -LiteralPath $Destination -Recurse -Force
}
New-Item -ItemType Directory -Path $Destination | Out-Null
Copy-Item -Path (Join-Path $sourcePath "*") -Destination $Destination -Recurse -Force

pwsh -NoProfile -File "tests/physics-lesson-prep/validate-skill.ps1" -SkillPath $Destination
if ($LASTEXITCODE -ne 0) { throw "Installed skill validation failed; backup retained at $backup" }

Write-Output "Installed physics-lesson-prep from $sourcePath to $Destination"
if (Test-Path -LiteralPath $backup) { Write-Output "Backup retained at $backup" }
```

The script must verify the exact destination name before any recursive operation and must validate before and after installation.

- [ ] **Step 2: Dry-run safety review without modifying the global directory**

Run:

```powershell
pwsh -NoProfile -File tests/physics-lesson-prep/validate-skill.ps1 -SkillPath skills/physics-lesson-prep
Get-Content -LiteralPath scripts/install-physics-lesson-prep.ps1 -Raw
```

Expected: validator passes; inspection confirms the destination-name guard, backup, source validation, and installed validation.

- [ ] **Step 3: Commit the installer**

```powershell
git add -- scripts/install-physics-lesson-prep.ps1
git commit -m "build: add safe physics skill installer"
```

- [ ] **Step 4: Request approval and install globally**

Run with escalated permission because the destination is outside the workspace:

```powershell
pwsh -NoProfile -File scripts/install-physics-lesson-prep.ps1
```

Expected:

```text
PASS: physics-lesson-prep structure and required behaviors validated
Installed physics-lesson-prep from .../skills/physics-lesson-prep to C:/Users/admin/.codex/skills/physics-lesson-prep
Backup retained at C:/Users/admin/.codex/skills/physics-lesson-prep.backup-<timestamp>
```

- [ ] **Step 5: Verify obsolete files are absent and hashes match**

Run:

```powershell
$source = Resolve-Path 'skills/physics-lesson-prep'
$installed = 'C:/Users/admin/.codex/skills/physics-lesson-prep'
if (Test-Path -LiteralPath "$installed/references/lesson-modes.md") { throw 'Obsolete lesson-modes.md remains installed' }
$sourceFiles = Get-ChildItem -LiteralPath $source -Recurse -File
foreach ($file in $sourceFiles) {
  $relative = [IO.Path]::GetRelativePath($source, $file.FullName)
  $target = Join-Path $installed $relative
  if ((Get-FileHash -Algorithm SHA256 $file.FullName).Hash -ne (Get-FileHash -Algorithm SHA256 $target).Hash) {
    throw "Hash mismatch: $relative"
  }
}
'PASS: canonical and installed skill hashes match'
```

Expected: `PASS: canonical and installed skill hashes match`.

---

### Task 10: Final Release Audit and Handoff

**Files:**
- Modify only if needed: `skills/physics-lesson-prep/**`
- Modify only if needed: `tests/physics-lesson-prep/**`
- Read: `output/physics-lesson-prep-validation/summary.md`

- [ ] **Step 1: Run the complete structural suite against canonical and installed copies**

```powershell
pwsh -NoProfile -File tests/physics-lesson-prep/validate-skill.ps1 -SkillPath skills/physics-lesson-prep
pwsh -NoProfile -File tests/physics-lesson-prep/validate-skill.ps1 -SkillPath C:/Users/admin/.codex/skills/physics-lesson-prep
```

Expected: both commands print the PASS line.

- [ ] **Step 2: Verify all ten forward tests passed**

Run:

```powershell
rg -n "\| Case (0[1-9]|10) \| PASS \|" output/physics-lesson-prep-validation/summary.md
```

Expected: ten matching rows. If fewer than ten appear, do not release.

- [ ] **Step 3: Perform specification coverage review**

Check the approved specification section by section and record, in the task commentary or validation summary, which implementation file covers:

- S0-S9;
- four goals;
- authentic evidence and diagnosis;
- teaching conditions;
- domestic/international/university research;
- textbook recommendation and teacher selection;
- source levels and conflicts;
- capacity and rolling planning;
- four material packages;
- reflection, privacy, mastery, and rollback;
- physics and compliance audit.

Expected: no uncovered specification requirement.

- [ ] **Step 4: Check Git diff and working-tree scope**

```powershell
git status --short
git diff --check
git log --oneline --max-count=10
```

Expected: no accidental modifications outside the canonical skill, tests, installer, plan/spec, self-improvement logs, and untracked validation output. Preserve unrelated user changes.

- [ ] **Step 5: Commit any final transferable fix**

Only if Step 1-4 revealed a genuine issue:

```powershell
git add -- skills/physics-lesson-prep tests/physics-lesson-prep scripts/install-physics-lesson-prep.ps1
git commit -m "fix: close physics lesson prep release gaps"
```

If no fix is needed, do not create an empty commit.

- [ ] **Step 6: Handoff**

Report:

- canonical source path;
- installed path;
- backup path;
- structural validation result;
- ten-case forward-test result;
- key behavior change: the skill now asks and gates before generating;
- any residual source-access or teacher-review limitations;
- one minimal invocation example:

```text
Use $physics-lesson-prep to start a new anonymous course record for a learner. Do not prepare lessons until the required intake, evidence, source, and confirmation gates are complete.
```

Do not describe the skill as a fully autonomous replacement for curriculum access, risk assessment, accommodations, or professional teacher judgment.

---

## Plan Self-Review Checklist

- [x] Every approved S0-S9 requirement maps to a task and file.
- [x] Domestic, international, and university routes are separate.
- [x] University research uses course-boundary and textbook-knowledge tracks.
- [x] Missing textbooks route to two or three verified candidates and teacher selection.
- [x] All four learning goals and material modes have distinct logic.
- [x] Formal output gates, source confirmation, cycle confirmation, and reflection confirmation are testable.
- [x] File writes require explicit consent and use anonymous identifiers.
- [x] Structural tests are dependency-free because the bundled validator lacks PyYAML.
- [x] Installation validates the exact destination and preserves a timestamped backup.
- [x] Ten fresh-agent acceptance cases cover the release criteria.
- [x] The plan contains no `TODO`, `TBD`, `FIXME`, or unspecified implementation step.
