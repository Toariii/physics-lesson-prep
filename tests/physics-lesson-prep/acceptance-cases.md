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
