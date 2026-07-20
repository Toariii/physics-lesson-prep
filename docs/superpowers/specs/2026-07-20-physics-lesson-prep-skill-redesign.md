# Physics Lesson Prep Skill Redesign

**Date:** 2026-07-20
**Status:** Approved design, pending implementation plan
**Target:** `C:/Users/admin/.codex/skills/physics-lesson-prep`

## 1. Purpose

Rebuild `physics-lesson-prep` from a one-shot lesson generator into a gated, evidence-based teaching workflow for domestic and international physics education.

The skill must establish the learner and course context, collect learning evidence, plan a realistic course cycle, research and validate curriculum sources, obtain teacher confirmation, prepare only the next two to four lessons, and use post-lesson evidence to update later planning.

The skill supports:

- one-to-one tutoring, small groups, and regular school classes;
- domestic middle school, high school, and university courses;
- AP, IB, Cambridge International, Pearson Edexcel, and other identifiable international systems;
- score improvement, synchronized consolidation, advance preparation, and competition or enrichment goals;
- concept-focused, practice-focused, mixed, and competition-focused instruction.

## 2. Core Principles

1. Do not generate formal teaching materials until the required learner, course, evidence, and source gates are complete.
2. Ask only questions that affect a teaching decision; do not repeat information already supplied.
3. Require one primary learning goal even when several goals are combined.
4. Prefer authentic student evidence. If none exists, create a diagnostic process before planning the course.
5. Separate official course boundaries from disciplinary knowledge sources.
6. Treat university or school websites as evidence of course identity and local requirements, not automatically as complete teaching content.
7. Prefer the assigned textbook for the knowledge sequence. If none is assigned, recommend two or three suitable authoritative books and wait for teacher confirmation.
8. Preserve teacher control at curriculum, textbook, course-cycle, safety, privacy, and adjustment decisions.
9. Plan the full course at framework level but prepare only the next two to four lessons in detail.
10. Require post-lesson evidence before generating the next formal lesson batch.

## 3. State Machine

### S0: Create or Identify an Anonymous Course Record

Determine whether the request concerns a new learner or class, an existing record, or a temporary consultation. Ask permission before creating local files.

Use anonymous identifiers such as:

```text
CN-NC-G10-PHY-IND-001
UK-CAIE-AS-PHY-SMALL-001
CN-UNIV-ENG-MECH-CLASS-001
```

Do not store real names, contact information, home addresses, account credentials, medical documents, or unrelated family information.

**Completion gate:** The teaching context and anonymous record choice are confirmed.

### S1: Confirm Learner and Course Identity

Required information:

- country or region;
- school or program type;
- grade, academic year, or university stage;
- full course name;
- curriculum system, examination board, university program, or course code;
- current chapter or module;
- one-to-one, small-group, or regular-class context;
- teaching and examination language.

For university courses, also collect the institution or anonymized course link, department, program stage, credits or hours, prerequisites, syllabus, assigned textbook, assessment model, and whether the course is theoretical, tutorial, laboratory, or mixed.

For school courses, also collect textbook publisher and edition, local examination region, school progress, required or elective module, and any school-specific ordering.

Answers such as `high school physics`, `IB physics`, `university mechanics`, or `rigid-body motion` are insufficient. When identity cannot be resolved, provide a collection checklist and stop.

**Completion gate:** There is enough information to locate the actual curriculum or course boundary.

### S2: Confirm Learning Goals

Support four goal types:

- score improvement and examination preparation;
- synchronized consolidation;
- advance preparation;
- competition or enrichment.

Allow combinations but require one primary goal, no more than two secondary goals, a target date, and observable success criteria.

Goal-specific intake:

- **Score improvement:** examination, date, current and target score, item types, timing, loss patterns, and official marking evidence.
- **Synchronized consolidation:** school progress, upcoming assessments, homework needs, and the gap between classroom understanding and independent performance.
- **Advance preparation:** lead time, desired readiness level, future textbook sequence, and mathematical limits.
- **Competition/enrichment:** competition and stage, prior experience, mathematical tools, available time, target outcome, and permission to exceed the school curriculum.

If goals conflict with available time, show the conflict and require prioritization.

**Completion gate:** A primary goal, target date, and measurable outcome are confirmed.

### S3: Collect Learning Evidence or Run Diagnosis

Evidence priority:

1. recent tests, assignments, and error work;
2. school feedback, grade reports, or rubrics;
3. teacher observation;
4. completed-course and textbook progress;
5. a skill-generated diagnostic completed by the learner;
6. learner self-assessment.

Do not use self-reported confidence as the sole basis for planning.

Analyze evidence across:

- conceptual knowledge;
- method and model selection;
- representation conversion;
- mathematics;
- experimental and data skills;
- notation and assessed communication;
- learning behavior.

Do not use `carelessness` as a final category. Resolve it into a repeatable cause such as transcription, sign tracking, unit checking, reading speed, computational load, or a missing checking routine.

If evidence is absent, first produce a diagnostic blueprint containing purpose, scope, duration, item count, knowledge and ability dimensions, scoring method, and the evidence needed to continue. Generate the actual diagnostic only after the teacher confirms the blueprint.

**Completion gate:** At least one credible evidence source or completed diagnostic supports a learner profile.

### S4: Confirm Teaching Conditions

Required information:

- lesson duration;
- lessons per week;
- sustainable number of weeks;
- deadlines;
- concept-focused, practice-focused, mixed, or competition-focused mode;
- teaching setting, class size, and online or offline delivery;
- homework capacity;
- required outputs.

Also collect equipment, quantity, visibility, blackboard or projection access, calculators, simulations, printing, online writing, website access, assistants, grouping, accommodations, and whether school homework and progress must be integrated.

For mixed teaching, confirm proportions or stage-based changes rather than recording only `mixed`.

Produce a Course Requirements Confirmation Sheet and wait for confirmation.

**Completion gate:** The teacher confirms the operational requirements.

### S5: Research and Validate Curriculum Evidence

Create a research task card before browsing. Research only specific unresolved questions.

Use original sources, record versions and access dates, and do not treat search-result snippets as evidence. Do not bypass logins or paywalls and do not copy unauthorized full textbooks or question banks.

#### School and International Systems

Use this order where available:

1. government, curriculum authority, or official examination board;
2. current curriculum standard, specification, syllabus, or subject guide;
3. official updates, specimen papers, marking guidance, and examiner reports;
4. current textbook and teacher materials;
5. school progress and internal examination requirements;
6. professional bodies and authoritative education organizations;
7. credible teaching resources.

Confirm the exact system, qualification, course code, level, version, first examination year, examination series, local region, and assessment model. Do not generalize a regional examination rule to another region.

#### University Double-Track Research

Use two evidence tracks.

**Track A: Actual course boundary**

- teacher-provided syllabus and schedule;
- department or university course page;
- course code and catalog;
- assigned chapters;
- lectures, assignments, laboratories, and examination scope.

This track establishes what the target course actually teaches and assesses.

**Track B: Disciplinary knowledge line**

- the assigned textbook;
- teacher-recommended reference books;
- authoritative textbooks and monographs at the same level;
- reputable publisher materials;
- professional organizations and university open courses.

This track establishes definitions, notation, assumptions, derivation depth, sequence, model boundaries, and exercise progression.

If no assigned textbook is known, identify two or three appropriate authoritative books. Record title, author, publisher, ISBN, edition and year, relevant chapters, level, strengths, limitations, notation differences, and evidence of adoption. Wait for the teacher to choose a primary textbook.

Do not use another university's course as proof of the target university's formal requirements.

**Failure behavior:** If the network is unavailable, official material is inaccessible, the version cannot be verified, or only low-quality sources exist, provide a source collection checklist and optional diagnostic tools. Do not generate a formal course plan.

**Completion gate:** Course boundaries and the knowledge mainline are supported by traceable evidence.

### S6: Teacher Confirms the Course Evidence Package

The confirmation package must include:

- course identity, code, version, examination period, textbook, and school progress;
- official required, recommended, excluded, and prerequisite content;
- knowledge, mathematics, experimental, modeling, communication, timing, item, and marking requirements;
- official order, school order, and recommended order with reasons;
- learner evidence compared with course requirements;
- source list with title, institution or author, URL or bibliographic record, date or edition, access date, evidence level, purpose, and verification status;
- unresolved issues and source conflicts.

For university courses, separate `School Course Boundary` and `Textbook Knowledge Mainline`.

Teacher options:

```text
A. Confirm and enter course-cycle planning
B. Confirm identity but modify the teaching order
C. Source or version is wrong; research again
D. School requirements differ; I will provide material
```

**Completion gate:** The teacher explicitly confirms the evidence package.

### S7: Generate and Confirm the Course-Cycle Framework

Calculate realistic capacity from weeks, frequency, duration, holidays, diagnosis, assessments, revision, and a 5-10% contingency allowance.

If the goal exceeds capacity, present:

1. a minimum viable route;
2. a recommended route;
3. an enhanced route requiring more time, homework, or lessons.

The framework must contain:

- final outcomes;
- phases and module sequence;
- prerequisite graph and minimum remediation;
- concept-to-practice proportions;
- module exit criteria;
- formative, module, stage, and final assessments;
- review and contingency lessons;
- risks, triggers, and alternative routes.

Plan the complete cycle at framework level only. Wait for teacher confirmation before detailed preparation.

Teacher options:

```text
A. Confirm and prepare the next lessons
B. Change concept/practice proportions
C. Change module order or lesson allocation
D. Change stage objectives
E. Add school-progress or learner information
```

**Completion gate:** The teacher confirms the course-cycle framework.

### S8: Prepare the Next Two to Four Lessons

Match the selected mode.

#### Concept-Focused Package

Include objectives, prerequisites, a central question, phenomenon or context, precise concept explanation, model assumptions and boundaries, derivation, multiple representations, defensible daily-life or engineering examples, counterexamples, teacher question chains, concept checks, guided examples, independent foundation practice, answers, and diagnostic interpretations.

Each real-world example must state the real system, idealization, what the model explains, and what it does not explain.

#### Practice-Focused Package

Include a question-type map, selection rationale, source and adaptation status, difficulty and cognitive demand, expected time, student version, teacher solution, marking points, common errors and causes, variants, second-attempt practice, and error-record fields.

Classify cognitive demand by concept identification, model selection, equation construction, representation conversion, multistep reasoning, evaluation, and non-standard transfer.

#### Mixed Package

Use diagnosis, targeted explanation, teacher modeling, scaffolded practice, independent practice, error discussion, variant transfer, and an exit check. Explanation must address the diagnosed obstacle rather than repeat an entire chapter.

#### Competition or Enrichment Package

Include problem context, minimal necessary information, model construction, mathematics, graded hints, multiple solutions, method comparison, breakthrough points, common dead ends, generalization, strategy reflection, and a complete solution.

For every lesson include its position in the cycle, learner evidence, outcomes and exit criteria, preparation, timeline, teacher questions, learner actions, anticipated errors, assessment, homework, reflection fields, and branches for faster or slower progress.

Prepare the first lesson fully. Keep lessons two to four adjustable.

**Completion gate:** Formal materials are delivered with a teacher-review label and traceable sources.

### S9: Collect Reflection and Roll the Plan Forward

For one-to-one and small groups, require a short reflection before generating the next formal batch. Accept natural language and structure it for confirmation.

Required evidence includes actual content completed, learner independence, representative successes and errors, sticking points, timing variance, homework evidence, learner feedback, and teacher judgment.

For regular classes, accept at least two of the following:

- class accuracy;
- representative errors;
- sampled work;
- performance by learner tier;
- teacher observation;
- stage-test statistics.

If the only feedback is `students did not understand`, provide a rapid diagnostic or data-collection template and stop.

Classify adjustments:

- **Minor:** change the next lesson without changing stage outcomes.
- **Moderate:** change the next two to four lessons and show the cycle effect.
- **Major:** change goals, course identity, evidence assumptions, conditions, or sources and return to the corresponding earlier state.

Wait for teacher confirmation before applying adjustments.

**Completion gate:** Reflection evidence and the adjustment decision are confirmed.

## 4. Mastery and Evidence Model

Track each concept with evidence:

```text
0 Not encountered
1 Encountered but cannot explain
2 Completes foundation tasks with prompts
3 Independently completes standard tasks
4 Transfers to varied contexts
5 Explains, compares methods, and handles non-standard problems
```

Record the evidence, limitations, and date. Teacher impressions may be recorded but must be labeled when direct evidence is absent.

## 5. Source Model

Use four evidence levels while preserving the university double-track distinction.

- **A: Decisive official or assigned source.** Government curriculum, examination board, university or department requirement, official syllabus, assigned textbook, official assessment material.
- **B: Authoritative disciplinary or professional source.** Major textbooks, reputable publishers, professional societies, authoritative education organizations, university open courses, peer-reviewed education research.
- **C: Screened teaching practice.** Credible teacher resources, school department materials, established platforms, teaching demonstrations, and licensed question banks.
- **D: Lead only.** Forums, general search results, unknown question sites, personal notes, short videos, and AI-generated material.

Do not allow a lower-level source to override a higher-level course requirement. Independently audit physics and pedagogy in C-level materials. Use D-level materials only to find better sources.

For key claims, verify publisher or institution, document identity, version, date, originality, completeness, replacement status, regional applicability, and relevance. Cross-check course versions, assessment changes, required experiments, prerequisites, and weighting with at least one decisive source and a second supporting source when available.

## 6. Course Records and Privacy

Suggested record structure:

```text
physics-courses/<anonymous-id>/
├── profile.md
├── curriculum-evidence.md
├── course-plan.md
├── progress-log.md
├── assessments/
├── lesson-plans/
└── resources/
```

Do not create or update files before the teacher approves the directory, anonymous identifier, saved fields, and whether original materials may be copied or only referenced. Preview writes before execution and report changed files afterward.

Preserve adjustment history rather than silently overwriting decisions.

## 7. Response Protocol

Begin every response with:

```text
Course record:
Current stage:
Confirmed:
Missing:
This turn:
Next gate:
```

Ask one to five currently necessary questions. Explain in one sentence why missing information blocks the next decision. Do not repeat known information.

When information conflicts, display both pieces of evidence, the impact, and the required teacher decision. Do not silently choose the convenient interpretation.

## 8. Hard-Gate Logic

```text
if course identity is incomplete:
    enter S0 or S1 and ask only intake questions
else if primary goal is incomplete:
    enter S2 and confirm the goal
else if learning evidence is absent:
    enter S3 and request evidence or design diagnosis
else if teaching conditions are incomplete:
    enter S4 and produce the requirements confirmation
else if curriculum evidence is unverified:
    enter S5 and research or provide a collection checklist
else if teacher has not confirmed evidence:
    enter S6 and stop at the confirmation package
else if course-cycle framework is unconfirmed:
    enter S7 and stop after framework options
else if the next lesson batch is not prepared:
    enter S8 and prepare two to four lessons
else if reflection evidence is missing:
    enter S9 and collect evidence only
else:
    propose adjustments, wait for confirmation, then roll forward
```

A request to skip questions does not change the gates. The skill may provide a diagnostic, evidence collection tool, or explicitly labeled provisional outline, but not formal course materials.

## 9. Material Quality Gates

### Course Consistency

- match the confirmed system, version, primary textbook, level, and school progress;
- do not mix examination boards, editions, or university course levels;
- label unresolved local requirements.

### Educational Design

- connect every activity to an outcome and evidence;
- use progressive practice and formative checks;
- distinguish teaching completion from learner mastery;
- make later decisions depend on observed evidence.

### Physics Integrity

- verify formulas, dimensions, units, signs, vectors, diagrams, assumptions, and limiting cases;
- ensure question conditions, diagrams, solutions, answers, and marking points agree;
- distinguish real systems from idealized models;
- independently solve every original or adapted numerical problem;
- require local safety review for practical work.

### Use and Compliance

- separate student and teacher versions;
- label source, original/adapted status, and official/non-official status;
- do not misrepresent questions as official past papers;
- do not reproduce unauthorized complete books or question collections;
- label materials as draft when any quality gate remains unresolved.

## 10. Planned Skill Structure

```text
physics-lesson-prep/
├── SKILL.md
├── agents/
│   └── openai.yaml
└── references/
    ├── state-machine.md
    ├── intake-and-diagnosis.md
    ├── curriculum-research.md
    ├── source-validation.md
    ├── course-planning.md
    ├── material-packages.md
    ├── reflection-and-records.md
    ├── physics-audit.md
    └── templates.md
```

`SKILL.md` acts as the concise state controller. Detailed education, research, planning, material, reflection, audit, and template rules load only when needed.

## 11. Acceptance Tests

1. **Insufficient request:** `Prepare rigid-body motion.` The skill enters S1 and produces no lesson.
2. **Course known, evidence absent:** The skill requests authentic work or a diagnostic and produces no cycle plan.
3. **University page lacks detail:** The skill uses the site for course identity, recommends two or three verified books, and waits for a primary-textbook decision.
4. **International version conflict:** The skill exposes old/new version evidence and stops for confirmation.
5. **Teacher asks to skip gates:** The skill explains the missing evidence and refuses formal planning.
6. **Concept-focused request after confirmation:** The skill produces detailed concepts, model boundaries, representations, examples, and foundation practice aligned with the course.
7. **Practice-focused request after confirmation:** The skill produces traceable, graded questions, independently checked solutions, marking points, error causes, and second attempts.
8. **Post-lesson adjustment:** The skill updates mastery evidence, classifies the adjustment, waits for approval, and prepares only the next batch.
9. **Weak large-class feedback:** The skill requests statistics or representative evidence and offers a rapid diagnostic rather than rewriting the plan.
10. **Identifiable student information:** The skill requests anonymization and excludes unnecessary identifiers from saved records.

## 12. Release Criteria

Release only when:

- every state has explicit entry, completion, confirmation, and rollback rules;
- incomplete information never produces formal course materials;
- missing learner evidence routes to diagnosis;
- missing authoritative evidence blocks formal planning;
- university research uses the double-track, textbook-led model;
- textbook recommendation requires teacher selection;
- all four learning goals have distinct planning logic;
- all four material modes have distinct structures;
- reflection changes later planning;
- privacy and file-write consent are enforced;
- sources, editions, textbooks, and question origins remain traceable;
- physics calculations, diagrams, experiments, and solutions are audited;
- all ten acceptance tests pass in forward testing.

## 13. Out of Scope

- automatic collection or storage of identifiable student data;
- bypassing school, examination-board, publisher, or library access controls;
- replacing teacher risk assessment, safeguarding, accommodations, or professional judgment;
- generating a complete long-term course before evidence and confirmation gates;
- treating unofficial summaries or AI output as authoritative curriculum evidence.
