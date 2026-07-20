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
        'first lesson',
        'Concept-Focused Package',
        'Practice-Focused Package',
        'Mixed Package',
        'Competition Or Enrichment Package',
        'Accepted alternative methods',
        'instantaneous-center',
        'teacher-review-ready',
        'explicit permission',
        'real names',
        'at least two',
        'Adjustment level',
        'Course Summary'
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

    $materialFile = Join-Path $resolvedSkillPath "references/material-packages.md"
    if (Test-Path -LiteralPath $materialFile -PathType Leaf) {
        $materialContent = Get-Content -LiteralPath $materialFile -Raw
        $materialLines = @(Get-Content -LiteralPath $materialFile)
        $expectedHeadings = @(
            '# Material Packages',
            '## S8 Entry Gate And Common Header',
            '## Concept-Focused Package',
            '## Practice-Focused Package',
            '## Mixed Package',
            '## Competition Or Enrichment Package',
            '## Student And Teacher Version Separation',
            '## Question Provenance',
            '## Standard Solution Contract',
            '## Lesson One Versus Lessons Two To Four',
            '## Teacher-Review Label'
        )
        if (-not (Test-ExactHeadings -Lines $materialLines -ExpectedHeadings $expectedHeadings)) {
            $failures.Add("material-packages.md headings or order do not match the required structure")
        }
        foreach ($materialRule in @(
            'confirmed Course Evidence Package', 'confirmed primary textbook', 'selected capacity route',
            'no blocking unresolved item', 'objectives and observable exit criteria', 'central question',
            'model, assumptions, boundaries', 'real system', 'what the model explains',
            'what it does not explain', 'do not start with an equation', 'daily-life example',
            'question-type map', 'concept identification', 'model selection', 'equation construction',
            'representation conversion', 'multistep reasoning', 'evaluation', 'non-standard transfer',
            'Do not use a number-only change as a variant',
            'diagnosis -> targeted explanation -> teacher modeling -> scaffolded practice -> independent practice -> error discussion -> variant transfer -> exit evidence',
            'context with minimal information', 'graded hints', 'complete solution', 'official problem scope',
            'clean student version', 'no hidden commentary', 'accessibility', 'unknown source',
            'copyright', 'independent physics audit', 'alternative acceptable range',
            'Lesson 1 is fully fixed', 'Lessons 2-4 are adjustable branches',
            'do not silently regenerate the whole batch', 'course gate, education-design gate, physics audit, intended-use gate',
            'Otherwise use `draft` and list the exact blockers'
        )) {
            if ($materialContent -notmatch [regex]::Escape($materialRule)) {
                $failures.Add("material-packages.md missing required rule: $materialRule")
            }
        }
        $standardSolution = @'
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
'@ -replace "`r`n", "`n"
        if (-not (($materialContent -replace "`r`n", "`n").Contains($standardSolution.Trim()))) {
            $failures.Add("material-packages.md standard solution lines are missing or out of order")
        }
    }

    $physicsAuditFile = Join-Path $resolvedSkillPath "references/physics-audit.md"
    if (Test-Path -LiteralPath $physicsAuditFile -PathType Leaf) {
        $physicsAuditContent = Get-Content -LiteralPath $physicsAuditFile -Raw
        $physicsAuditLines = @(Get-Content -LiteralPath $physicsAuditFile)
        $expectedHeadings = @(
            '# Physics Audit',
            '## Universal Model And Calculation Audit',
            '## Mechanics And Rigid-Body Audit',
            '## Circuits And Electromagnetism Audit',
            '## Waves, Optics, And SHM Audit',
            '## Thermal, Fluids, Nuclear, And Modern Physics Audit',
            '## Graph And Data Audit',
            '## Diagram Specification And Release Gate',
            '## Experiment Safety And Feasibility',
            '## Question-Solution-Marking Consistency',
            '## Cross-Textbook Notation And Depth',
            '## Release Labels'
        )
        if (-not (Test-ExactHeadings -Lines $physicsAuditLines -ExpectedHeadings $expectedHeadings)) {
            $failures.Add("physics-audit.md headings or order do not match the required structure")
        }
        foreach ($auditRule in @(
            'system, boundary, reference frame, sign convention, assumptions, and approximation regime',
            'algebra, arithmetic, dimensions, units, prefixes, significant figures', 'limiting cases',
            'question, diagram, solution, final answer, and marking guidance', 'independently solve every numerical original or adapted question',
            '`confirmed`, `provisional`, or `unresolved`', 'choose the object -> isolate it',
            'relative velocity and relative acceleration', 'centripetal and tangential terms',
            'velocity relation only', 'undefined or at infinity', 'not an acceleration shortcut',
            'rolling no-slip constraints', 'parallel-axis theorem', 'energy and angular momentum',
            'planar from three-dimensional rotation', 'cross products and right-hand-rule directions',
            'nodes, branches, junctions', 'conventional current from electron motion', 'visual proximity',
            'particle motion from propagation', 'normal, focal points', 'displacement, velocity, acceleration',
            'temperature, heat, internal energy, and power', 'activity, count rate, dose, and energy',
            'raw versus transformed data', 'Do not infer causation', 'purpose, represented system, topology or geometry',
            'Generated art remains `draft`', 'apparatus ratings', 'hazards, persons at risk, controls, residual risk',
            'simulation, video, teacher demonstration, or prepared dataset fallback',
            'local policy and qualified-teacher approval', 'high risk', 'no undeclared assumption',
            'valid alternative solutions', 'confirmed primary textbook', 'Do not mix conventions silently',
            'Otherwise label it `draft` and list the exact blockers'
        )) {
            if ($physicsAuditContent -notmatch [regex]::Escape($auditRule)) {
                $failures.Add("physics-audit.md missing required rule: $auditRule")
            }
        }
        foreach ($prohibition in @(
            @{ Name = 'qualitative observation'; Pattern = '(?is)\b(?:do not|must not|cannot)\s+(?:present|treat|use|claim)\b[^.\r\n]{0,160}\bqualitative observation\b[^.\r\n]{0,100}\bquantitative verification\b' },
            @{ Name = 'spring-balance net force'; Pattern = '(?is)\b(?:do not|must not|cannot)\s+(?:treat|present|use|claim)\b[^.\r\n]{0,160}\bspring-balance reading\b[^.\r\n]{0,100}\bnet force\b[^.\r\n]{0,120}\b(?:unless|without)\b[^.\r\n]{0,160}\bmodel(?:ed|led|ing)?\b' },
            @{ Name = 'F = ma acceleration measurement'; Pattern = '(?is)\b(?:do not|must not|cannot)\s+(?:claim\s+to\s+)?verify\s+`?F\s*=\s*ma`?\s+without\s+(?:a\s+)?defensible acceleration measurement\b' }
        )) {
            if ($physicsAuditContent -notmatch $prohibition.Pattern) {
                $failures.Add("physics-audit.md missing explicit prohibition: $($prohibition.Name)")
            }
        }
        foreach ($conflict in @(
            @{ Name = 'qualitative observation permission'; Pattern = '(?im)(?:^|[.!?]\s+)(?:you\s+)?(?:may|can|treat|present)\b[^.!?\r\n]{0,160}\bqualitative observation\b[^.!?\r\n]{0,100}\bquantitative verification\b' },
            @{ Name = 'F = ma permission'; Pattern = '(?im)(?:^|[.!?]\s+)(?:you\s+)?(?:may|can)\s+claim\s+to\s+verify\s+`?F\s*=\s*ma`?\s+without\s+(?:a\s+)?defensible acceleration measurement\b' },
            @{ Name = 'spring-balance net-force permission'; Pattern = '(?im)(?:^|[.!?]\s+)(?:you\s+)?(?:may|can|treat|present)?\s*(?:a\s+)?spring-balance reading\s+is\s+(?:the\s+)?net force\s+without\b' }
        )) {
            if ($physicsAuditContent -match $conflict.Pattern) {
                $failures.Add("physics-audit.md contains contradictory permission: $($conflict.Name)")
            }
        }
        if ($physicsAuditContent -notmatch '(?is)\bteacher-review-ready\b[^.\r\n]{0,100}\bonly when\b[^.\r\n]{0,180}\bcourse\b[^.\r\n]{0,180}\beducation-design\b[^.\r\n]{0,180}\bphysics\b[^.\r\n]{0,180}\bintended-use\b[^.\r\n]{0,100}\bgates?\b[^.\r\n]{0,60}\bpass\b') {
            $failures.Add("physics-audit.md must restrict teacher-review-ready to all release gates passing")
        }
        if ($physicsAuditContent -match '(?im)(?:^|[.!?]\s+)(?:all\s+)?(?:packages?|outputs?|materials?)\s+(?:are|may be|can be|should be)\s+(?:label(?:ed|led)|released as)\s+`?teacher-review-ready`?\b' -or
            $physicsAuditContent -match '(?im)(?:^|[.!?]\s+)(?:always|unconditionally)\s+(?:label|release)\b[^.!?\r\n]{0,100}\bteacher-review-ready\b') {
            $failures.Add("physics-audit.md contains unconditional teacher-review-ready release")
        }
    }

    $reflectionFile = Join-Path $resolvedSkillPath "references/reflection-and-records.md"
    if (Test-Path -LiteralPath $reflectionFile -PathType Leaf) {
        $reflectionContent = Get-Content -LiteralPath $reflectionFile -Raw
        $reflectionLines = @(Get-Content -LiteralPath $reflectionFile)
        $reflectionHeadings = @(
            '# Reflection And Records',
            '## File-Write Consent Gate',
            '## Suggested Anonymous Record Structure',
            '## Allowed And Prohibited Fields',
            '## Source-Artifact Handling',
            '## One-To-One And Small-Group Reflection',
            '## Regular-Class Evidence',
            '## Five-Dimension Reflection Analysis',
            '## Mastery Scale 0-5',
            '## Minor, Moderate, And Major Adjustments',
            '## Rollback And Change History',
            '## Next-Batch Gate',
            '## Course Completion And Archive',
            '## Damaged Or Conflicting Record Handling'
        )
        if (-not (Test-ExactHeadings -Lines $reflectionLines -ExpectedHeadings $reflectionHeadings)) {
            $failures.Add("reflection-and-records.md headings or order do not match the required structure")
        }

        foreach ($reflectionPhrase in @(
            'explicit permission', 'save directory', 'anonymous identifier', 'exact fields',
            'preview changes', 'Temporary consultation', 'Never auto write', 'real names',
            'at least two', 'knowledge', 'method', 'representation',
            'notation and assessed communication', 'learning behavior', 'carelessness',
            'Every mastery update', 'teacher impression', 'minor', 'moderate', 'major',
            'timestamp', 'before', 'after', 'reason', 'teacher confirmation', 'impact',
            'prior batch reflection', 'read-only', 'new cycle', 'stop writes',
            'quarantine impacted materials', 're-audit'
        )) {
            if ($reflectionContent -notmatch [regex]::Escape($reflectionPhrase)) {
                $failures.Add("reflection-and-records.md missing required phrase: $reflectionPhrase")
            }
        }

        foreach ($masteryLine in @(
            '0 Not encountered',
            '1 Encountered but cannot explain',
            '2 Foundation tasks with prompts',
            '3 Independent standard tasks',
            '4 Transfer to varied contexts',
            '5 Explanation, method comparison, and non-standard problems'
        )) {
            if ($reflectionContent -notmatch ('(?m)^' + [regex]::Escape($masteryLine) + '\s*$')) {
                $failures.Add("reflection-and-records.md missing exact mastery scale line: $masteryLine")
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
        $normalizedTemplates = $templatesContent -replace "`r`n", "`n"
        $normalizedExactTable = ($exactTable -replace "`r`n", "`n").Trim()
        if (-not $normalizedTemplates.Contains($normalizedExactTable)) {
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

        foreach ($lessonTemplateField in @(
            '## Lesson Batch Header', 'Current state: S8', 'Primary textbook and chapters:',
            'Course-cycle stage:', 'Learner evidence used:', 'Package mode:', 'Lessons in this batch:',
            'Source status:', 'Release label: teacher-review-ready / draft', 'Teacher checks still required:',
            '## Single-Lesson Plan', 'Position in cycle:', 'Evidence addressed:',
            'Objectives and exit criteria:', 'Timeline with teacher move, learner action, question, evidence, and branch:',
            'Knowledge explanation or question route:', 'Anticipated errors and responses:',
            'Faster-progress branch:', 'Slower-progress branch:', 'Post-lesson reflection fields:',
            '## Practice Question Record', 'Year/series/edition and item:',
            'Official / licensed / original / adapted:', 'Concept and cognitive demand:',
            'Difficulty and expected time:', 'Student prompt:', 'Teacher solution:',
            'Common error and cause:', 'Variant:', 'Second-attempt problem:'
        )) {
            if ($templatesContent -notmatch [regex]::Escape($lessonTemplateField)) {
                $failures.Add("templates.md missing exact Task 6 field: $lessonTemplateField")
            }
        }
        if (-not (Test-OrderedPhrases -Content $templatesContent -Phrases @(
            '## Lesson Batch Header', '## Single-Lesson Plan', '## Practice Question Record'
        ))) {
            $failures.Add("templates.md Task 6 headings are out of order")
        }

        foreach ($reflectionTemplateField in @(
            '## Anonymous Record Write Preview', 'Proposed directory:', 'Anonymous identifier:',
            'Files to create or modify:', 'Fields to store:',
            'Original materials: reference only / copy allowed', 'Identifiable information excluded:',
            'Teacher decision: approve / revise / do not save',
            '## Post-Lesson Reflection', 'Planned versus completed content:',
            'Independent performance:', 'Representative success:', 'Representative errors:',
            'Exact sticking point:', 'Timing variance:', 'Homework evidence:', 'Learner feedback:',
            'Teacher judgment:', 'Evidence confidence:',
            '## Regular-Class Evidence', 'Class accuracy:', 'Sampled work:',
            'High/middle/foundation tier performance:', 'Teacher observation:',
            'Stage-test statistics:', 'Evidence items supplied:',
            '## Adjustment Proposal', 'Adjustment level: minor / moderate / major',
            'Evidence:', 'Current mastery state:', 'Proposed change:', 'Effect on next lessons:',
            'Effect on course cycle:', 'Rollback state if required:',
            'Teacher decision: confirm / revise / collect more evidence',
            '## Course Summary', 'Initial goals:', 'Actual teaching delivered:',
            'Evidence of knowledge and skill change:', 'Goals achieved or not achieved:',
            'Remaining gaps:', 'Effective methods:', 'Low-value methods:',
            'Recommended next chapters/books:', 'Teacher professional judgment to add:',
            'Archive decision:'
        )) {
            $fieldPattern = '(?m)^' + [regex]::Escape($reflectionTemplateField) + '\s*$'
            if ($templatesContent -notmatch $fieldPattern) {
                $failures.Add("templates.md missing exact Task 7 field: $reflectionTemplateField")
            }
        }
        if (-not (Test-OrderedPhrases -Content $templatesContent -Phrases @(
            '## Anonymous Record Write Preview', '## Post-Lesson Reflection',
            '## Regular-Class Evidence', '## Adjustment Proposal', '## Course Summary'
        ))) {
            $failures.Add("templates.md Task 7 headings are out of order")
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
    $reflectionPath = Join-Path $resolvedSkillPath 'references/reflection-and-records.md'
    $allowTransitionalGitkeep = -not (Test-Path -LiteralPath $reflectionPath -PathType Leaf)
    foreach ($actualFile in $actualFiles) {
        $isTransitionalGitkeep = $allowTransitionalGitkeep -and $actualFile -ceq 'references/.gitkeep'
        if ($actualFile -notin $expectedFiles -and -not $isTransitionalGitkeep) {
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
