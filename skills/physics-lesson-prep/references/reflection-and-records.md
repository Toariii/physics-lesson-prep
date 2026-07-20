# Reflection And Records

## File-Write Consent Gate

Before any write, obtain explicit permission for the save directory, pseudonymous or anonymous-minimized identifier, exact fields and files, retention choice, access scope, and whether originals may be copied or must remain reference only. Preview changes before writing and report every changed file afterward. Temporary consultation means no save. Never auto write a learner or course record, and never store passwords, tokens, credentials, authentication codes, or other secrets.

Permission applies only to the previewed write. If the directory, identifier, fields, files, or source-artifact treatment changes, preview again and renew permission.

## Suggested Anonymous Record Structure

Use this structure when the teacher approves persistent records. Treat it as pseudonymous unless a data minimization review supports a stronger classification: an anonymous identifier alone does not guarantee anonymity, and combinations of quasi-identifiers can re-identify a learner.

```text
physics-courses/<anonymous-id>/
  profile.md
  curriculum-evidence.md
  course-plan.md
  progress-log.md
  assessments/
  lesson-plans/
  resources/
```

- `profile.md` stores the pseudonymous, minimized learning context, goals, constraints, and accommodations.
- `curriculum-evidence.md` stores verified course boundaries, source references, and conflicts.
- `course-plan.md` stores confirmed routes, cycles, dependencies, capacity, and approved revisions.
- `progress-log.md` stores dated reflection, mastery evidence, adjustment decisions, and change history.
- `assessments/` stores minimized or anonymized assessment evidence and summaries.
- `lesson-plans/` stores released batches and preserves superseded versions.
- `resources/` stores approved teaching resources or references to them.

Preserve histories. Append or version changes rather than overwriting prior evidence, plans, judgments, or released materials.

## Allowed And Prohibited Fields

Allowed fields are teaching-relevant and pseudonymous or anonymous-minimized: region, learner stage, education system, course identity, goals, evidence summaries, representative errors, mastery, progress, workload, and accommodations needed for teaching. Before saving, conduct a data minimization review of quasi-identifiers including region, stage, course, school, accommodations, and distinctive error patterns; omit, coarsen, or generalize them where possible. Store a school name only when essential, specifically consented, and permitted by institution policy.

Prohibited fields include real names in filenames or records; phone numbers, email addresses, social accounts, government or school identifiers, addresses, credentials or authentication data, secrets, original medical records, financial details, unrelated family information, identifiable information about other students, and full raw school-system screenshots. A school name may be used temporarily for research but is not saved by default; remove it from external examples and cases.

Set a retention period and review date, with a teacher-controlled deletion or read-only archive decision when the period ends, subject to institutional requirements. Limit access to the authorized teacher or institution, and use device or workspace encryption and access controls where available. The teacher must confirm the applicable local law, institution policy, lawful basis, and guardian or learner consent where required. This is operational skill guidance, not legal advice or a claim of compliance.

Before export, strip direct identifiers and unnecessary quasi-identifiers, preview the export, and obtain teacher approval. Record the export recipient, purpose, fields, and decision.

## Source-Artifact Handling

Redact and minimize each artifact before upload. Ask whether each approved artifact should be copied or reference only, and extract only teaching-relevant evidence. Do not reproduce incidental personally identifiable information. If an artifact cannot be safely minimized, request an anonymized replacement before save.

Do not delete an original or source artifact without authority. Preserve copyright, attribution, provenance, license, and source references for copied, adapted, or referenced material.

## One-To-One And Small-Group Reflection

Before the next formal batch, collect completed and uncompleted content, independence, representative success, error or exact sticking point where present, timing, homework evidence only when homework was assigned, otherwise class or assessment evidence, learner feedback, and teacher judgment. Natural language is accepted: structure it into these fields, show the structured reflection, and wait for the teacher to confirm it. This confirmation is a hard gate.

## Regular-Class Evidence

For a regular class, require at least two of the following: class accuracy, representative errors, sampled work, performance by high/middle/foundation tier, teacher observation, or stage-test statistics. If the report is only vague language such as "they did not understand," offer a rapid diagnostic or data template and do not rewrite the formal next batch.

## Five-Dimension Reflection Analysis

Analyze evidence across five dimensions: knowledge; method; representation; notation and assessed communication; and learning behavior. Experiment, data interpretation, and mathematics may be evidence subdimensions where useful.

For each error, distinguish first occurrence, repeated occurrence, correct after a prompt, persistent after support, complex-task failure, prerequisite gap, and language or communication barrier. Treat "carelessness" as unresolved until evidence identifies the knowledge, method, representation, notation, attention, or checking-process cause.

## Mastery Scale 0-5

```text
0 Not encountered
1 Encountered but cannot explain
2 Foundation tasks with prompts
3 Independent standard tasks
4 Transfer to varied contexts
5 Explanation, method comparison, and non-standard problems
```

Every mastery update records its evidence, limitations, date, and confidence. A teacher impression may be recorded as a labeled judgment, but it is not direct evidence and must not silently replace assessed or observed evidence.

## Minor, Moderate, And Major Adjustments

- A minor adjustment changes the next lesson without changing the stage outcome.
- A moderate adjustment affects the next two to four lessons or the current cycle while preserving course identity and goals.
- A major adjustment changes course identity, goal, learner profile, teaching conditions, or decisive source evidence and names the rollback state.

Present the evidence, adjustment level, proposed before-and-after state, downstream impact, and rollback. Wait for teacher confirmation before applying any adjustment. No silent change is allowed.

## Rollback And Change History

Rollback mappings are exact: changed course identity or version returns to S1; changed goals return to S2; changed learner evidence or profile returns to S3; changed teaching conditions return to S4; changed or conflicting source evidence returns to S5-S6; changed cycle design returns to S7; changed lesson-batch evidence returns to S9 before S8 resumes.

Every change-history entry records timestamp, before, after, reason, teacher confirmation, and impact. Preserve prior records and released versions so rollback restores a known state rather than reconstructing one from memory.

## Next-Batch Gate

For one-to-one or small-group teaching, the next batch requires prior batch reflection, representative learning evidence consisting of a success, error, sticking point, or completed assessment or observation, an approved adjustment or confirmed decision to continue unchanged, and no unresolved proposed changes. Require homework evidence only when homework was assigned; otherwise use class or assessment evidence. An error-free batch may advance when the available evidence supports the mastery judgment. Never fabricate an error, homework result, observation, assessment, or mastery claim to satisfy the gate. For a regular class, require at least two evidence items from the regular-class list.

If evidence is insufficient, provide only a diagnostic, a data-collection template, or a clearly labeled provisional outline; do not produce a formal batch. Apply this gate at batch level, normally after each two-to-four-lesson batch rather than after every isolated lesson.

## Course Completion And Archive

The completion summary records initial goals, actual teaching delivered, changes and supporting evidence, remaining gaps, effective and low-value methods, recommended next chapters or books, achievement against goals, and teacher judgment. After teacher confirmation, archive the completed cycle as read-only. Start a new cycle for renewed work rather than overwrite the archive.

## Damaged Or Conflicting Record Handling

If a record is damaged, incomplete, or internally conflicting, stop writes. Preserve the damaged original read-only and compute or capture a hash if possible. Show the conflict and offer backup or recovery paths. Restore a backup to a new path; never overwrite the damaged original. Validate the backup structure and inventory before use, and record its source, provenance, hash where available, and recovered fields.

Preview recovery changes and renew teacher consent before recovery writes. Compare and resolve conflicts between the damaged record, backup, and other verified sources. Only replace the active record after validation and teacher confirmation, while retaining the original, recovered version, decisions, and full audit trail. If a cited source artifact is missing, stop citing it as verified. Course or assessment version changes roll back to S5-S6 for renewed validation.

When an error may have affected released material, quarantine impacted materials, re-audit them, notify the teacher, and record the result and rollback decision. Privacy and learner safety take priority over continuity or convenience.
