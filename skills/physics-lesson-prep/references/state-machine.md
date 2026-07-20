# State Machine

Use this contract to select the earliest incomplete state, constrain the current response, and identify the evidence needed to advance. A later state never overrides an unmet earlier gate.

| State | Entry condition | Allowed output | Forbidden output | Completion evidence | Teacher confirmation | Rollback target |
|---|---|---|---|---|---|---|
| S0 | No record decision for the current request | Record options and privacy summary; extract and display confirmed facts; non-advancing preview or collection of up to the next gate's most important questions | Formal lesson, cycle, or question-pack output; source research; file saving without separate permission | Explicit new anonymous/existing/temporary consultation choice | Record choice required even for temporary or no-write work; save permission is separate | None |
| S1 | Course identity incomplete | 1-5 identity questions and collection checklist | Curriculum assumptions and lessons | Identifiable course boundary | Confirm conflicts | S0 |
| S2 | Goal incomplete | Goal questions and conflict analysis | Course plan | Primary goal, date, success criteria | Confirm priority | S1 |
| S3 | Evidence absent or weak | Evidence request; diagnostic blueprint, confirmed diagnostic, result collection, learner profile | Formal cycle plan before a credible artifact or completed diagnostic | Credible artifact or completed diagnostic results supporting a learner profile | Confirm blueprint before diagnostic creation or administration | S1/S2 |
| S4 | Teaching conditions incomplete | Questions and Course Requirements Confirmation Sheet | Formal cycle plan | Confirmed duration, frequency, weeks, mode, setting, load, outputs | Required | S1-S3 |
| S5 | Sources unverified | Research task card, source research, book comparison | Formal plan | Traceable course boundary and knowledge mainline | Required in S6 | S1-S4 |
| S6 | Evidence package unconfirmed | Course Evidence Package and revisions allowed by the decision | Course-cycle plan | Explicit A decision | Required; B-D do not advance | S5 |
| S7 | Framework unconfirmed | Three capacity options, cycle framework, and requested revisions | Detailed future course | Explicit A decision | Required; B-D do not advance and E rolls back | S2-S6 |
| S8 | Framework confirmed; current batch not yet reported taught | Next 2-4 lessons, teacher-review revisions, delivery clarifications | Entire future course in detail; another batch while current batch awaits teaching | Teacher-approved batch and later teacher report that it was taught | Approve batch; taught report triggers S9 | S3-S7 |
| S9 | Prior batch taught | Reflection structuring, mastery update, adjustment proposal | Next formal batch before evidence and approval | Reflection evidence plus approved adjustment | Required | S1-S8 by change type |

## State Guidance

- Enter the earliest state whose completion evidence is missing, contradicted, weak, or no longer current.
- Produce only the allowed output for that state. Treat forbidden output as blocked even when the teacher requests speed or asks to skip intake.
- Record teacher decisions explicitly. Silence, ambiguity, and an unreviewed draft do not count as confirmation.
- Keep evidence traceable to the supplied artifact, completed diagnostic, validated source, or recorded teacher decision.
- Advance one gate at a time unless the current turn contains complete, non-conflicting evidence for multiple consecutive states.
- At S0, every new request requires an explicit new anonymous record, named existing record, or temporary consultation choice before advancing. Permission to save a file is a separate decision.
- At S0, do not waste facts already supplied: extract and display every confirmed fact and, within the turn's one-to-five-question total, allow a non-advancing preview or collection of the next gate's most important questions. Clearly say the answers are held pending the S0 choice, the current stage stays S0, and no later state is completed or advanced. This preview may describe evidence or a later research route, but it must not perform source research or produce formal lesson, cycle, worksheet, or question-pack output.
- At S3, use this subflow when evidence is absent: draft a diagnostic blueprint -> obtain teacher confirmation -> create or administer the diagnostic -> collect results -> derive the learner profile. Do not advance to S4 until a credible artifact or completed diagnostic supports that profile.
- At S6, only A advances to S7. B stays S6 for revised-order confirmation unless the revision changes research, then return to S5; C returns to S5; D stays or returns to S5 while awaiting material.
- At S7, only A advances to S8. B-D stay S7 for revision; E rolls back to the earliest affected state from S1 through S6.
- At S8, prepare only the next two to four lessons and label the batch for teacher review. Revise until approved, then wait for delivery and the teacher's report that the batch was taught; while waiting, allow only revisions or clarifications, never regenerate or start a new batch.
- At S9, structure reflection evidence, update mastery judgments provisionally, and propose adjustments before returning to lesson preparation.

## Rollback Rules

- course or version change -> S1 then S5-S6;
- goal change -> S2;
- invalid learner profile -> S3;
- schedule or delivery change -> S4;
- source or textbook change -> S5-S6;
- minor adjustment -> stay S9 then S8;
- moderate adjustment -> S7 then S8;
- major adjustment -> earliest affected state.

After rollback, preserve still-valid evidence but re-confirm every decision invalidated by the change. Do not continue formal generation from a superseded boundary, source set, framework, or learner profile.
