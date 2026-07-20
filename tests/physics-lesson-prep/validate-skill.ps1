param(
    [string]$SkillPath = "skills/physics-lesson-prep"
)

$failures = [System.Collections.Generic.List[string]]::new()
$expectedFilesPath = Join-Path $PSScriptRoot "expected-files.txt"
$expectedFiles = @(Get-Content -LiteralPath $expectedFilesPath | Where-Object { $_.Trim() })

function Test-ExactHeadings {
    param([string[]]$Lines, [string[]]$ExpectedHeadings)

    $headings = @($Lines | Where-Object { $_ -match '^#{1,2}\s' })
    return ($headings -join "`n") -ceq ($ExpectedHeadings -join "`n")
}

function Test-OrderedPhrases {
    param([string]$Content, [string[]]$Phrases)

    $previousIndex = -1
    foreach ($phrase in $Phrases) {
        $index = $Content.IndexOf($phrase, [System.StringComparison]::OrdinalIgnoreCase)
        if ($index -lt 0 -or $index -le $previousIndex) {
            return $false
        }
        $previousIndex = $index
    }
    return $true
}

try {
    $resolvedSkillPath = (Resolve-Path -LiteralPath $SkillPath -ErrorAction Stop).Path
}
catch {
    $failures.Add("Skill path does not exist: $SkillPath")
    $resolvedSkillPath = $null
}

if ($resolvedSkillPath) {
    foreach ($relativePath in $expectedFiles) {
        $candidatePath = Join-Path $resolvedSkillPath $relativePath
        if (-not (Test-Path -LiteralPath $candidatePath -PathType Leaf)) {
            $failures.Add("Missing expected file: $relativePath")
        }
    }

    $skillFile = Join-Path $resolvedSkillPath "SKILL.md"
    if (Test-Path -LiteralPath $skillFile -PathType Leaf) {
        $skillContent = Get-Content -LiteralPath $skillFile -Raw
        $skillLines = @(Get-Content -LiteralPath $skillFile)

        $frontmatterMatch = [regex]::Match(
            $skillContent,
            '(?m)\A---\r?\n(?<frontmatter>(?:(?!^---\s*$)[^\r\n]*(?:\r?\n|$))*)^---\s*(?:\r?\n|$)'
        )
        $frontmatterIsValid = $frontmatterMatch.Success -and
            $frontmatterMatch.Groups['frontmatter'].Value -match '(?m)^name:\s*physics-lesson-prep\s*$' -and
            $frontmatterMatch.Groups['frontmatter'].Value -match '(?m)^description:\s*\S.*$'
        if (-not $frontmatterIsValid) {
            $failures.Add("SKILL.md frontmatter must define name and description")
        }
        if ($skillLines.Count -gt 300) {
            $failures.Add("SKILL.md must be 300 lines or fewer")
        }
        foreach ($state in @('S0', 'S9')) {
            if ($skillContent -notmatch "(?<![A-Za-z0-9])$state(?![A-Za-z0-9])") {
                $failures.Add("SKILL.md missing required state: $state")
            }
        }
        if ($skillContent -notmatch '(?im)^#{1,6}\s+Non-Negotiable Gate\s*$' -or
            $skillContent -notmatch '(?im)^\s*(?:[-*+]\s+)?Do not generate formal\b.*$') {
            $failures.Add("SKILL.md missing structured formal-material gate")
        }
        if ($skillContent -notmatch '(?im)^Current stage:\s*.*$') {
            $failures.Add("SKILL.md missing status field: Current stage:")
        }
        if ($skillContent -match '(?i)\bTODO\b|\bTBD\b|\bFIXME\b|\[TODO') {
            $failures.Add("SKILL.md contains a placeholder")
        }
    }

    $markdownFiles = @(Get-ChildItem -LiteralPath $resolvedSkillPath -Recurse -File -Filter '*.md')
    $markdownContent = @()
    foreach ($markdownFile in $markdownFiles) {
        $content = Get-Content -LiteralPath $markdownFile.FullName -Raw
        $markdownContent += $content
        if ($content -match '(?i)\bTODO\b|\bTBD\b|\bFIXME\b|\[TODO') {
            $relativeMarkdownPath = [System.IO.Path]::GetRelativePath($resolvedSkillPath, $markdownFile.FullName).Replace('\', '/')
            $failures.Add("Markdown contains a placeholder: $relativeMarkdownPath")
        }
    }

    $joinedMarkdown = $markdownContent -join "`n"
    foreach ($requiredPhrase in @(
        'primary goal',
        'diagnostic blueprint',
        'one to five',
        'carelessness',
        'score improvement',
        'synchronized consolidation',
        'advance preparation',
        'competition or enrichment',
        'Course Requirements Confirmation Sheet',
        'two or three',
        'primary textbook',
        'double-track',
        'teacher confirmation',
        'next two to four lessons',
        'anonymous',
        'representative errors',
        'search-result snippets',
        'Track A',
        'Track B',
        'ISBN',
        'WorldCat',
        'course fact',
        'disciplinary fact',
        'teaching recommendation',
        'Course Evidence Package',
        '5-10% contingency',
        'minimum viable route',
        'recommended route',
        'enhanced route',
        'Module Exit Criteria',
        'first lesson'
    )) {
        if ($joinedMarkdown -notmatch [regex]::Escape($requiredPhrase)) {
            $failures.Add("Markdown missing required phrase: $requiredPhrase")
        }
    }

    $intakeFile = Join-Path $resolvedSkillPath "references/intake-and-diagnosis.md"
    if (Test-Path -LiteralPath $intakeFile -PathType Leaf) {
        $intakeContent = Get-Content -LiteralPath $intakeFile -Raw
        $actualHeadings = @(Get-Content -LiteralPath $intakeFile | Where-Object { $_ -match '^#{1,2}\s' })
        $expectedHeadings = @(
            '# Intake And Diagnosis',
            '## Questioning Rules',
            '## S0 Anonymous Record Intake',
            '## S1 Domestic School Intake',
            '## S1 International Course Intake',
            '## S1 University Course Intake',
            '## S2 Four Goal Routes',
            '## Multiple-Goal Priority And Conflict Rules',
            '## S3 Evidence Priority',
            '## Error Analysis Taxonomy',
            '## Diagnostic Blueprint',
            '## Diagnostic Result Profile',
            '## S4 Teaching Conditions',
            '## Smart Skip And Conflict Rules'
        )
        if (($actualHeadings -join "`n") -cne ($expectedHeadings -join "`n")) {
            $failures.Add("intake-and-diagnosis.md headings or order do not match the required structure")
        }

        $rigidBodyFixture = @'
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
'@ -replace "`r`n", "`n"
        $normalizedIntake = $intakeContent -replace "`r`n", "`n"
        if (-not $normalizedIntake.Contains($rigidBodyFixture.Trim())) {
            $failures.Add("intake-and-diagnosis.md missing the exact rigid-body fixture")
        }

        foreach ($intakeRule in @(
            'if S0 is unresolved',
            'temporary consultation',
            'new unsaved anonymous record',
            'has not yet been created or saved',
            'Do not use this fixture for an existing record',
            'existing-record response must show its anonymous ID and current state',
            'redact names',
            'student IDs',
            'school account identifiers',
            'other students',
            'relevant pages',
            'anonymized replacement before saving',
            'No file delete unless authorized',
            'progress establishes exposure and scope only',
            'can never alone complete S3 or establish mastery',
            'performance artifact',
            'teacher-observed performance',
            'self-assessment is supplementary',
            'official marking evidence',
            'upcoming assessments and homework needs',
            'gap between classroom performance and independent work',
            'required readiness level',
            'future textbook sequence',
            'mathematics limits',
            'prior competition or enrichment experience',
            'permit work beyond the school curriculum',
            'Diagnostic Observation Detail',
            'prompt dependence',
            'transfer',
            'correction behavior',
            'instructional implication',
            'next evidence'
        )) {
            if ($intakeContent -notmatch [regex]::Escape($intakeRule)) {
                $failures.Add("intake-and-diagnosis.md missing required rule: $intakeRule")
            }
        }
    }

    $curriculumFile = Join-Path $resolvedSkillPath "references/curriculum-research.md"
    if (Test-Path -LiteralPath $curriculumFile -PathType Leaf) {
        $curriculumContent = Get-Content -LiteralPath $curriculumFile -Raw
        $curriculumLines = @(Get-Content -LiteralPath $curriculumFile)
        $expectedHeadings = @(
            '# Curriculum Research',
            '## Research Entry Gate',
            '## Research Task Card',
            '## Domestic Middle And High School Route',
            '## AP Route',
            '## IB Route',
            '## Cambridge International Route',
            '## Pearson Edexcel And Other Awarding Bodies',
            '## University Double-Track Research',
            '## Assigned Textbook Route',
            '## No Assigned Textbook Route',
            '## Secondary Teaching-Material Search',
            '## Research Failure And Offline Degradation'
        )
        if (-not (Test-ExactHeadings -Lines $curriculumLines -ExpectedHeadings $expectedHeadings)) {
            $failures.Add("curriculum-research.md headings or order do not match the required structure")
        }

        foreach ($researchRule in @(
            'exactly two or three candidates',
            'teacher confirms one primary textbook before S6 or S7',
            'no formal plan',
            'do not bypass login or paywall',
            'do not download an unauthorized full textbook or question bank',
            'boundary remains provisional',
            'cannot complete from a sparse course or department page alone'
        )) {
            if ($curriculumContent -notmatch [regex]::Escape($researchRule)) {
                $failures.Add("curriculum-research.md missing required rule: $researchRule")
            }
        }
        if (-not (Test-OrderedPhrases -Content $curriculumContent -Phrases @(
            'national curriculum standard',
            'local education or examination authority',
            'current official examination documents',
            'current textbook edition',
            'school progress and internal scope',
            'teacher book or publisher',
            'authoritative teaching organization',
            'other sources'
        ))) {
            $failures.Add("curriculum-research.md domestic evidence order is incorrect")
        }
        foreach ($trackChain in @(
            'Track A - Actual course boundary: teacher syllabus -> course/department page -> course code/catalog -> assigned chapters -> lectures/assignments/labs/examination scope.',
            'Track B - Disciplinary knowledge line: assigned textbook -> teacher references -> authoritative same-level textbooks/monographs -> reputable publisher resources -> professional bodies/open courses.'
        )) {
            if ($curriculumContent -notmatch [regex]::Escape($trackChain)) {
                $failures.Add("curriculum-research.md missing exact double-track chain: $trackChain")
            }
        }
    }

    $sourceValidationFile = Join-Path $resolvedSkillPath "references/source-validation.md"
    if (Test-Path -LiteralPath $sourceValidationFile -PathType Leaf) {
        $sourceValidationContent = Get-Content -LiteralPath $sourceValidationFile -Raw
        $sourceValidationLines = @(Get-Content -LiteralPath $sourceValidationFile)
        $expectedHeadings = @(
            '# Source Validation',
            '## Separate Three Claim Types',
            '## A-D Evidence Levels',
            '## Web Page Verification',
            '## Official PDF Verification',
            '## Book And Edition Verification',
            '## Cross-Validation Rules',
            '## Source Conflict Procedure',
            '## Question Provenance And Copyright',
            '## Research Record',
            '## Course Evidence Package'
        )
        if (-not (Test-ExactHeadings -Lines $sourceValidationLines -ExpectedHeadings $expectedHeadings)) {
            $failures.Add("source-validation.md headings or order do not match the required structure")
        }

        foreach ($sourceRule in @(
            'course fact: what the target course requires',
            'disciplinary fact: what physics and mathematics establish',
            'teaching recommendation: a pedagogical choice for this learner',
            'A - decisive official/assigned evidence',
            'B - authoritative professional evidence',
            'C - screened teaching practice',
            'D - lead only',
            'search-result snippets are never evidence',
            'WorldCat',
            'assigned textbook never decides official assessment requirements',
            'not physical truth',
            'No evidence tier is automatically decisive',
            'Within the same tier',
            'provenance and original/adapted status',
            'license and reuse status',
            'intended use',
            'Classify every unresolved item and conflict as blocking or non-blocking',
            'If any blocker remains, Decision A is unavailable'
        )) {
            if ($sourceValidationContent -notmatch [regex]::Escape($sourceRule)) {
                $failures.Add("source-validation.md missing required rule: $sourceRule")
            }
        }
    }

    $coursePlanningFile = Join-Path $resolvedSkillPath "references/course-planning.md"
    if (Test-Path -LiteralPath $coursePlanningFile -PathType Leaf) {
        $coursePlanningContent = Get-Content -LiteralPath $coursePlanningFile -Raw
        $coursePlanningLines = @(Get-Content -LiteralPath $coursePlanningFile)
        $expectedHeadings = @(
            '# Course Planning',
            '## Planning Entry Gate',
            '## Teaching Capacity Calculation',
            '## Goal-Capacity Conflict',
            '## Course-Cycle Layers',
            '## Module Dependencies And Minimum Remediation',
            '## Module Exit Criteria',
            '## Assessment Nodes',
            '## Four Goal Strategies',
            '## Concept-Practice Allocation',
            '## Risks And Alternative Routes',
            '## Rolling Two-To-Four-Lesson Rule',
            '## Course-Cycle Confirmation'
        )
        if (-not (Test-ExactHeadings -Lines $coursePlanningLines -ExpectedHeadings $expectedHeadings)) {
            $failures.Add("course-planning.md headings or order do not match the required structure")
        }

        foreach ($planningRule in @(
            'S6 Evidence Package', 'teacher option A', 'primary textbook or knowledge mainline',
            'no blocking conflicts', 'Course Requirements Confirmation Sheet remains current', 'roll back',
            'Calendar weeks', 'Lessons per week', 'Minutes per lesson', 'Theoretical lessons',
            'Holidays/cancellations', 'Diagnosis', 'Module/stage assessments',
            'Review/revision/simulation', '5-10% contingency', 'Usable teaching lessons',
            'Do not count homework as lesson capacity', 'range and a conservative case',
            'State every assumption', 'do not fabricate capacity',
            'final measurable outcomes', 'dependency graph', 'minimum prerequisite remediation',
            'not a reteach of the entire prior course',
            'knowledge, skill, notation, transfer, and accuracy/time', 'evidence source',
            'not advance automatically', 'entrance diagnosis', 'in-lesson formative',
            'module quiz', 'stage assessment', 'comprehensive assessment', 'mock/final output',
            'purpose, evidence, and response', 'concept maps and explanation',
            'strategy and nonstandard', 'score improvement', 'synchronized consolidation',
            'advance preparation', 'competition or enrichment',
            'explanation, guided practice, independent practice, and review',
            'insufficient time', 'math gap', 'school progress change', 'homework noncompletion',
            'source mismatch', 'score fluctuation', 'equipment', 'goal change',
            'trigger and an alternative route', 'full course-cycle framework only',
            'next two to four lessons', 'first lesson is fully fixed',
            'lessons 2-4 remain adjustable', 'do not detail all future lessons',
            'wait in S8 without regenerating', 'Only option A advances to S8',
            'Planned teaching weeks', 'Diagnostic lessons', 'Module/stage assessment lessons',
            'Effective lesson-equivalents/adjustments',
            'convert minutes to lesson equivalents', 'avoid double counting',
            'contingency percent and lesson equivalents', 'Selected capacity route',
            'lesson-level observations', 'urgent rollback'
        )) {
            if ($coursePlanningContent -notmatch [regex]::Escape($planningRule)) {
                $failures.Add("course-planning.md missing required rule: $planningRule")
            }
        }

        foreach ($routeDefinition in @(
            '(?is)Minimum viable route\b.*core outcomes.*defer',
            '(?is)Recommended route\b.*understanding.*practice.*feedback',
            '(?is)Enhanced route\b.*(?:lesson|homework|time)'
        )) {
            if ($coursePlanningContent -notmatch $routeDefinition) {
                $failures.Add("course-planning.md missing route distinction: $routeDefinition")
            }
        }

        foreach ($planningBehavior in @(
            '(?is)theoretical lesson(?:-equivalents| equivalents|s)?\s*=\s*planned teaching weeks\s*\*\s*lessons per week',
            '(?is)usable lesson equivalents\s*=\s*theoretical lesson-equivalents\s*\+\s*effective-session adjustment\s*-\s*cancellations\s*-\s*diagnostic lessons\s*-\s*module/stage assessment lessons\s*-\s*revision/simulation\s*-\s*contingency lesson-equivalents',
            '(?is)effective-session adjustment.*positive.*extended.*negative.*shortened',
            '(?is)contingency.*percentage.*theoretical.*after known fixed cancellations.*before other planned deductions',
            '(?is)capacity conflict.*teacher.*select.*Minimum viable.*Recommended.*Enhanced.*Option A.*unavailable.*no selected route',
            '(?is)carry.*selected route.*implications.*S8',
            '(?is)S8 remains active.*current.*(?:two-to-four|2-4).*lesson batch.*lesson-level observations.*urgent rollback.*S9 begins only.*teacher reports.*batch.*(?:taught|completed)'
        )) {
            if ($coursePlanningContent -notmatch $planningBehavior) {
                $failures.Add("course-planning.md missing required planning behavior: $planningBehavior")
            }
        }

        foreach ($strategy in @(
            'score-loss analysis -> high-frequency repair -> item and marking analysis -> timed mixed practice -> simulation -> retraining',
            'synchronized pre-activation -> concept repair -> schoolwork correction -> transfer -> assessment',
            'advance familiarity -> understanding -> readiness -> cognitive-load reduction -> mathematics preparation',
            'competition mathematics route -> model library -> multiple methods -> approximation -> dimensional analysis -> proof -> nonstandard problems -> strategy -> official problems'
        )) {
            if ($coursePlanningContent -notmatch [regex]::Escape($strategy)) {
                $failures.Add("course-planning.md missing exact goal strategy: $strategy")
            }
        }

        foreach ($confirmationOption in @(
            'A - confirm and advance to S8',
            'B - change proportions and stay in S7',
            'C - change order/allocation and stay in S7',
            'D - change objectives and return to S2 or S7 according to impact',
            'E - add evidence and return to the earliest affected state from S1-S6'
        )) {
            if ($coursePlanningContent -notmatch [regex]::Escape($confirmationOption)) {
                $failures.Add("course-planning.md missing exact confirmation option: $confirmationOption")
            }
        }
    }

    $templatesFile = Join-Path $resolvedSkillPath "references/templates.md"
    if (Test-Path -LiteralPath $templatesFile -PathType Leaf) {
        $templatesContent = Get-Content -LiteralPath $templatesFile -Raw
        if ($templatesContent -notmatch '\A# Templates\r?\n\r?\n## Turn Status Header(?:\r?\n|$)') {
            $failures.Add("templates.md must begin with the exact initial heading prefix")
        }

        foreach ($templateField in @(
            'Course record:', 'Current stage:', 'Confirmed:', 'Missing:', 'This turn:', 'Next gate:',
            'Anonymous record:', 'Course identity:', 'Primary and secondary goals:',
            'Target date and success criteria:', 'Learning evidence:',
            'Lesson duration and weekly frequency:', 'Available weeks and deadlines:',
            'Teaching mode and proportions:', 'Setting, class size, and delivery:',
            'Homework capacity:', 'Equipment and access:', 'Required outputs:',
            'Unresolved conditions:', 'Teacher decision: confirm / revise / provide missing information',
            'Diagnostic purpose:', 'Course boundary:', 'Prerequisites covered:',
            'Core content covered:', 'Ability dimensions:', 'Duration:',
            'Item count and format:', 'Scoring and interpretation:',
            'Evidence required to continue:', 'Teacher decision: confirm blueprint / revise blueprint',
            '| Dimension | Status | Evidence | Repeated pattern | Teaching impact | Confidence |'
        )) {
            if ($templatesContent -notmatch [regex]::Escape($templateField)) {
                $failures.Add("templates.md missing exact initial field: $templateField")
            }
        }

        $profileSection = ($templatesContent -split '(?m)^## Learner Evidence Profile\s*$', 2)[1]
        if ($profileSection) {
            $profileSection = ($profileSection -split '(?m)^##\s+', 2)[0]
            $profileRows = @($profileSection -split '\r?\n' | Where-Object { $_ -match '^\|' })
            if ($profileRows.Count -ne 2) {
                $failures.Add("Learner Evidence Profile must contain only its header and separator rows")
            }
        }

        foreach ($researchTemplateField in @(
            '## Research Task Card',
            'Course and version:', 'Student stage and setting:', 'Primary goal and target date:',
            'Current module:', 'Known textbook or syllabus:', 'Questions to verify:',
            'Required official evidence:', 'Required book evidence:',
            '## Source Record',
            'Claim type: course fact / disciplinary fact / teaching recommendation',
            'Evidence level: A / B / C / D', 'Institution or author:',
            'URL or bibliographic record:', 'Published/updated or edition year:',
            'Access date:', 'Course/version applicability:', 'Exact information used:',
            'Cross-validation:', 'Replacement or conflict risk:', 'Verification status:',
            'Provenance/original-adapted status:', 'License/reuse status:', 'Intended use:',
            '## Textbook Comparison',
            'Teacher decision: choose one primary textbook / request new candidates / provide assigned book',
            '## Course Evidence Package',
            'Course identity and version:', 'School Course Boundary:', 'Textbook Knowledge Mainline:',
            'Required / recommended / excluded content:', 'Prerequisite relationships:',
            'Assessment and marking requirements:', 'Official, school, and recommended sequence:',
            'Learner evidence gap:', 'Source list:', 'Source conflicts:', 'Unresolved items:',
            'Blocking unresolved items and conflicts:', 'Non-blocking follow-ups:',
            'Teacher decision: A confirm / B modify order / C research again / D provide school material',
            'If any blocking item remains, Decision A is unavailable'
        )) {
            if ($templatesContent -notmatch [regex]::Escape($researchTemplateField)) {
                $failures.Add("templates.md missing Task 4 field: $researchTemplateField")
            }
        }

        $exactTable = @'
| Candidate | Author | Publisher | ISBN | Edition | Chapters | Level | Strengths | Limitations | Notation differences | Adoption evidence |
|---|---|---|---|---|---|---|---|---|---|---|
'@
        if (-not ($templatesContent -replace "`r`n", "`n").Contains($exactTable.Trim())) {
            $failures.Add("templates.md Textbook Comparison must preserve the exact header and separator structure")
        }

        foreach ($planningTemplateField in @(
            '## Capacity Calculation', 'Calendar weeks:', 'Lessons per week:',
            'Minutes per lesson:', 'Theoretical lessons:', 'Holidays/cancellations:',
            'Diagnosis and assessments:', 'Revision and simulation:', '5-10% contingency:',
            'Usable teaching lessons:', 'Goal-capacity conflict:', '## Course-Cycle Framework',
            'Planned teaching weeks:', 'Diagnostic lessons:',
            'Module/stage assessment lessons:', 'Effective lesson-equivalents/adjustments:',
            'Contingency percent:', 'Contingency lesson equivalents:',
            'Calculation/usable formula:',
            'Final outcomes:', 'Minimum viable route:', 'Recommended route:', 'Enhanced route:',
            'Stages and lesson allocation:', 'Dependency graph:', 'Minimum prerequisite remediation:',
            'Concept/practice proportions:', 'Module exit criteria:', 'Assessment nodes:',
            'Review and contingency:', 'Risks, triggers, and alternatives:',
            'Next 2-4 lessons to prepare after confirmation:', 'Selected capacity route:',
            'Selected route basis and implications:',
            'Teacher decision: A confirm / B change proportions / C change order or allocation / D change objectives / E add evidence'
        )) {
            $fieldPattern = '(?m)^' + [regex]::Escape($planningTemplateField) + '\s*$'
            if ($templatesContent -notmatch $fieldPattern) {
                $failures.Add("templates.md missing exact Task 5 field: $planningTemplateField")
            }
        }

        if (-not (Test-OrderedPhrases -Content $templatesContent -Phrases @(
            '## Capacity Calculation',
            '## Course-Cycle Framework'
        ))) {
            $failures.Add("templates.md Task 5 planning headings are out of order")
        }
        if ($templatesContent -notmatch '(?m)^Diagnosis and assessments:\s*$' -or
            $templatesContent -notmatch '(?m)^Deduction source: use the separate Diagnostic lessons and Module/stage assessment lessons fields only; do not deduct this summary\.\s*$') {
            $failures.Add("templates.md must preserve Diagnosis and assessments as a non-deducted summary")
        }
    }

    $agentFile = Join-Path $resolvedSkillPath "agents/openai.yaml"
    if (Test-Path -LiteralPath $agentFile -PathType Leaf) {
        $agentContent = Get-Content -LiteralPath $agentFile -Raw
        if ($agentContent -notmatch [regex]::Escape('$physics-lesson-prep')) {
            $failures.Add("agents/openai.yaml must mention `$physics-lesson-prep")
        }
        if ($agentContent -notmatch '(?i)intake') {
            $failures.Add("agents/openai.yaml must mention intake")
        }
    }

    $actualFiles = @(Get-ChildItem -LiteralPath $resolvedSkillPath -Recurse -File | ForEach-Object {
        [System.IO.Path]::GetRelativePath($resolvedSkillPath, $_.FullName).Replace('\', '/')
    })
    foreach ($actualFile in $actualFiles) {
        if ($actualFile -notin $expectedFiles) {
            $failures.Add("Unexpected file: $actualFile")
        }
    }
}

if ($failures.Count -gt 0) {
    foreach ($failure in $failures) {
        Write-Error $failure
    }
    exit 1
}

Write-Output "PASS: physics-lesson-prep structure and required behaviors validated"
