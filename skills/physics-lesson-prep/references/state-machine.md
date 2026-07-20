# State Machine

Use this contract to select the earliest incomplete state, constrain the current response, and identify the evidence needed to advance. A later state never overrides an unmet earlier gate.

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

## State Guidance

- Enter the earliest state whose completion evidence is missing, contradicted, weak, or no longer current.
- Produce only the allowed output for that state. Treat forbidden output as blocked even when the teacher requests speed or asks to skip intake.
- Record teacher decisions explicitly. Silence, ambiguity, and an unreviewed draft do not count as confirmation.
- Keep evidence traceable to the supplied artifact, completed diagnostic, validated source, or recorded teacher decision.
- Advance one gate at a time unless the current turn contains complete, non-conflicting evidence for multiple consecutive states.
- At S8, prepare only the next two to four lessons and label the batch for teacher review.
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
