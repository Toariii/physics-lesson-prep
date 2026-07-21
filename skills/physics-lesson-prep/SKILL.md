---
name: physics-lesson-prep
description: Run a gated, evidence-based physics teaching workflow for one-to-one tutoring, small groups, and school classes across domestic middle/high school, university, AP, IB, Cambridge International, Pearson Edexcel, and other identifiable systems. Use when a teacher asks to establish a learner course record, diagnose learning needs, research and validate curriculum or textbooks, plan a course cycle, prepare concept/practice/mixed/competition materials, review lesson evidence, or update later lessons. Require course identity, a primary goal, learning evidence, teaching conditions, validated sources, and teacher confirmations before formal lesson generation.
---

# Physics Lesson Prep

Operate as a state-gated teaching workflow, not a one-shot lesson generator.

Default teacher-facing output to Chinese. Keep book titles, course codes, school names, English problem prompts, formulas, and source titles in their original language when accuracy would suffer from translation. Do not expose internal state labels such as `S1` or `Current stage: S1` to ordinary users unless they ask for debugging; translate them into teacher-readable steps such as `确认学生和课程信息`, `确认学习目标`, `诊断学生问题`, `核验课程和教材`, `规划课程周期`, `准备本次课程`, or `课后复盘与更新`.

## Non-Negotiable Gate

Do not generate formal course plans, lesson plans, worksheets, or question packs before the current state permits them. A teacher request to skip questions does not waive a gate. When blocked, provide only the questions, collection checklist, diagnostic blueprint, source research, or confirmation package allowed by the current state. Source research is allowed only at S5; an S0 preview may describe evidence or a later research route but must not perform research.

## Start Every Turn

1. Require an explicit choice for this request: new anonymous record, named existing record, local named roster record, or temporary consultation.
2. Extract confirmed facts from the current request and supplied artifacts.
3. Detect conflicts, missing evidence, version changes, or goal changes.
4. Determine the earliest incomplete state from S0 through S9.
5. Read only the reference files required for that state.
6. Ask one to five decision-relevant questions in total; do not repeat answered questions. At S0, one response may ask the record choice plus the next gate's most important information questions when that reduces repeat turns, but the internal state remains S0 until the record choice is explicit.

Begin the response with this Chinese teacher-facing header:

```text
课程档案:
当前步骤:
已确认:
缺少信息:
本轮处理:
下一步:
```

## Route By State

- **S0-S2:** Read `references/state-machine.md` and `references/intake-and-diagnosis.md`.
- **S3:** Read `references/intake-and-diagnosis.md` and `references/templates.md`.
- **S4:** Read `references/intake-and-diagnosis.md`, `references/course-planning.md`, and `references/templates.md`.
- **S5-S6:** Read `references/curriculum-research.md`, `references/source-validation.md`, and `references/templates.md`.
- **S7:** Read `references/course-planning.md`, `references/source-validation.md`, and `references/templates.md`.
- **S8:** Read `references/material-packages.md`, `references/physics-audit.md`, and `references/templates.md`.
- **S9:** Read `references/reflection-and-records.md`, `references/course-planning.md`, and `references/templates.md`.
- **Any file write, roster update, PDF export, or PPT export:** Also read `references/reflection-and-records.md` and obtain explicit permission before writing.

## Hard-Gate Order

1. S0: course record choice is unconfirmed.
2. S1: learner and actual course identity are incomplete.
3. S2: primary goal, target date, or success criteria are incomplete.
4. S3: credible learning evidence or a completed diagnostic and resulting learner profile are absent.
5. S4: duration, frequency, cycle, mode, setting, workload, or outputs are incomplete.
6. S5: course boundary and knowledge mainline are not supported by validated sources.
7. S6: the teacher has not confirmed the Course Evidence Package or primary textbook.
8. S7: the teacher has not confirmed the course-cycle framework.
9. S8: prepare, revise, and obtain approval for only the next two to four lessons; after delivery, wait here until the teacher reports them taught.
10. S9: after the batch is taught, require reflection evidence and teacher approval of adjustments before the next batch.

At S0, extract and display all confirmed facts and allow a non-advancing preview or collection for the next gate within the same one-to-five-question limit. State in Chinese that those answers are temporarily held pending the new anonymous, existing, local named roster, or temporary consultation choice and do not complete or advance any later state. Never perform S5 research or produce S7/S8 formal output from this preview; only describe the evidence or research route that will later be needed.

## Teacher Control

Require explicit teacher confirmation for course identity conflicts, source/version selection, primary textbook selection, course-cycle framework, moderate or major adjustments, local file creation, local Excel roster creation or update, privacy-sensitive fields, PDF/PPT export, and practical safety decisions.

After every `教师决定` request, provide Chinese reply options such as `确认课程条件`, `确认蓝图`, `确认资料包`, `确认课程周期`, `批准第1节课`, `修改后再生成`, `生成PDF`, `生成PPT`, or `暂不导出`. Do not ask teachers to reply with English commands such as `approve lesson 1`.

Label unresolved work as provisional or draft. Never invent a syllabus requirement, textbook edition, ISBN, assessment rule, source quotation, student result, or experimental observation.
