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

function Get-S0PolicyIssues {
    param([string]$Content)

    $issues = [System.Collections.Generic.List[string]]::new()
    $semanticRequirements = @{
        'S0 must require an explicit record choice before advancing' = '(?is)\bS0\b.*\bexplicit\b.*\bnew anonymous\b.*\bexisting\b.*\btemporary consultation\b.*\bbefore advancing\b'
        'S0 must allow a non-advancing next-gate preview' = '(?is)\bS0\b.*\bnon-advancing preview\b.*\bnext gate.{0,80}(?:questions|information)\b'
        'S0 preview must keep the current stage at S0' = '(?is)\bcurrent stage (?:remains|stays) S0\b'
        'S0 preview must hold answers pending the record choice' = '(?is)\banswers? (?:are|will be) held pending (?:the )?S0 choice\b'
        'S0 preview must not complete or advance a later state' = '(?is)\bno later state (?:is|has been|has) (?:completed or advanced|advanced)\b'
        'S0 preview must forbid formal output and source research' = '(?is)\bS0\b.*\b(?:must not|never)\b.*\b(?:perform )?(?:source |S5 )?research\b.*\bformal\b'
    }
    foreach ($entry in $semanticRequirements.GetEnumerator()) {
        if ($Content -notmatch $entry.Value) {
            $issues.Add($entry.Key)
        }
    }

    $contradictions = @{
        'S0 is limited to the record choice' = '(?im)\bS0\b[^.!?\r\n]{0,120}\b(?:only|solely)\b[^.!?\r\n]{0,80}\b(?:record (?:choice|options?)|privacy summary)\b'
        'S0 preview completes S1' = '(?im)\bS0\b[^.!?\r\n]{0,160}\bpreview\b[^.!?\r\n]{0,120}(?<!not )\bcompletes? S1\b'
    }
    foreach ($entry in $contradictions.GetEnumerator()) {
        if ($Content -match $entry.Value) {
            $issues.Add("contradiction: $($entry.Key)")
        }
    }
    return @($issues)
}

function Get-ReflectionPolicyIssues {
    param([string]$Content)

    $issues = [System.Collections.Generic.List[string]]::new()
    $semanticRequirements = @{
        'pseudonymous records must warn that identifiers and combined quasi-identifiers can re-identify a learner' = '(?is)\bpseudonym(?:ous|ized)\b.*\banonymous identifier\b.*\b(?:does not|cannot)\b.*\banonymity\b.*\bquasi-identifiers?\b.*\bre-identif'
        'privacy review must minimize and generalize quasi-identifiers' = '(?is)\bdata minimization review\b.*\bquasi-identifiers?\b.*\b(?:coarsen|generalize)\b'
        'retention, access, export, and policy controls must be explicit' = '(?is)\bretention (?:period|review)\b.*\bauthorized teacher or institution\b.*\bencryption\b.*\blocal law\b.*\blawful basis\b.*\bexports?\b.*\bapproval\b'
        'reflection must contain both representative success and error entries' = '(?is)\brepresentative success entry\b.*\brepresentative error entry\b'
        'truthful null error states must include scope, confidence, and a stability probe' = '(?is)\bnone observed in supplied evidence\b.*\bevidence scope\b.*\bconfidence\b.*\b(?:transfer|probe)\b.*\bstability\b.*\bNever (?:invent|fabricate)\b'
        'homework must use a truthful null or class-assessment alternative' = '(?is)\bnot assigned\b.*\bclass or assessment evidence\b'
        'next-batch gate must require error entry and approved adjustment decision' = '(?is)\bnext batch requires\b.*\brepresentative-error entry\b.*\bhomework or class or assessment evidence\b.*\bteacher-confirmed adjustment decision\b'
        'continue-unchanged decisions must meet exit criteria and record rationale' = '(?is)\bcontinue unchanged\b.*\bexit criteria\b.*\bapproved no-change decision\b.*\brationale\b'
        'no-change decisions must use a non-applicable adjustment level' = '(?is)\bcontinue unchanged\b.*\bAdjustment level\b.*\bnot applicable \(continue unchanged\)'
        'recovery must preserve and hash the damaged original and restore to a new path' = '(?is)\bpreserve the damaged original\b.*\bread-only\b.*\bhash\b.*\bnew path\b.*\bnever overwrite\b'
        'recovery must validate, preview, reconfirm, resolve conflicts, and retain an audit trail' = '(?is)\bvalidate (?:the )?backup structure and inventory\b.*\bprovenance\b.*\brecovered fields\b.*\bpreview\b.*\brenew teacher consent\b.*\bcompare and resolve conflicts\b.*\bonly replace the active record after\b.*\baudit trail\b'
        'rollback mappings must preserve S1-S9 routing' = '(?is)\bcourse identity or version returns to S1\b.*\bgoals return to S2\b.*\bprofile returns to S3\b.*\bconditions return to S4\b.*\bsource evidence returns to S5-S6\b.*\bcycle design returns to S7\b.*\breturns to S9\b'
        'archive must be read-only and renewed work must start a new cycle' = '(?is)\barchive\b.*\bread-only\b.*\bnew cycle\b.*\brather than overwrite\b'
        'artifact handling must require a copy-or-reference decision' = '(?is)\bartifact\b.*\bcopied or reference only\b'
    }
    foreach ($entry in $semanticRequirements.GetEnumerator()) {
        if ($Content -notmatch $entry.Value) {
            $issues.Add($entry.Key)
        }
    }

    $contradictions = @{
        'unconditional write without consent' = '(?im)(?:^|[.!?]\s+)(?:always|automatically|immediately)\s+(?:write|save|create)\b(?![^.!?\r\n]{0,100}\b(?:permission|consent|approval)\b)'
        'identifier falsely guarantees anonymity' = '(?im)\banonymous identifier\b(?![^.!?\r\n]{0,100}\b(?:does not|cannot|never)\b)[^.!?\r\n]{0,100}\b(?:guarantees?|ensures?|makes?)\b[^.!?\r\n]{0,80}\b(?:anonymous|anonymity)\b'
        'homework evidence is mandatory' = '(?im)(?![^.!?\r\n]{0,160}\bonly when\b)\b(?:requires?|must include|mandatory)\b[^.!?\r\n]{0,80}\bhomework evidence\b'
        'adjustment confirmation may be bypassed' = '(?im)\b(?:may|can|should)\s+(?:bypass|skip)\b[^.!?\r\n]{0,80}\bteacher confirmation\b|\bapply\b[^.!?\r\n]{0,80}\bwithout teacher confirmation\b'
        'no-change decision is forced into an adjustment level' = '(?im)\bcontinue unchanged\b[^.!?\r\n]{0,120}\bAdjustment level:\s*(?:minor|moderate|major)\b'
        'damaged records may be overwritten' = '(?im)(?<!never )\b(?:overwrite|replace)\b[^.!?\r\n]{0,80}\bdamaged (?:original|record)\b'
        'archive is mutable' = '(?im)\barchive\b[^.!?\r\n]{0,80}\b(?:mutable|editable|may be changed|can be changed)\b'
        'exports may proceed without approval' = '(?im)\bexports?\b[^.!?\r\n]{0,100}\bwithout (?:teacher )?approval\b'
    }
    foreach ($entry in $contradictions.GetEnumerator()) {
        if ($Content -match $entry.Value) {
            $issues.Add("contradiction: $($entry.Key)")
        }
    }
    return @($issues)
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
        if ($skillContent -notmatch '(?im)^当前步骤:\s*.*$') {
            $failures.Add("SKILL.md missing Chinese teacher-facing status field: 当前步骤:")
        }
        foreach ($teacherFacingRule in @(
            'Default teacher-facing output to Chinese',
            'Do not expose internal state labels',
            'local named roster record',
            '生成PDF',
            '生成PPT',
            '批准第1节课'
        )) {
            if ($skillContent -notmatch [regex]::Escape($teacherFacingRule)) {
                $failures.Add("SKILL.md missing teacher-facing rule: $teacherFacingRule")
            }
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
        'Local Named Roster Excel',
        '姓名',
        '科目或学习体系',
        '学到哪里了',
        'Optional PDF And PPT Export',
        '导出选项',
        '暂不导出',
        '当前步骤',
        '确认学生和课程信息',
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
课程档案: 未创建
当前步骤: 确认学生和课程信息
已确认: 主题是刚体运动
缺少信息: 学生阶段、实际课程、课程体系或课程代码、当前单元、教学场景
本轮处理: 收集最低限度的课程身份信息
下一步: 确认可追踪的课程边界

请提供:
1. 学生所在国家/地区和年级或大学阶段。
2. 完整课程名称、课程体系/考试局，或大学课程代码。
3. 当前教材、考纲、课程页面或目录。

在实际课程可以确认前，我不会生成正式课程。
'@ -replace "`r`n", "`n"
        $normalizedIntake = $intakeContent -replace "`r`n", "`n"
        if (-not $normalizedIntake.Contains($rigidBodyFixture.Trim())) {
            $failures.Add("intake-and-diagnosis.md missing the exact rigid-body fixture")
        }

        foreach ($intakeRule in @(
            'do not waste the turn',
            'one to three',
            'most material S1, S2, or S3 questions',
            'no more than five',
            'sparse university request',
            'formal course code',
            'exactly two or three books',
            'international-version conflict',
            'current official guide',
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

    $stateFile = Join-Path $resolvedSkillPath "references/state-machine.md"
    if (Test-Path -LiteralPath $stateFile -PathType Leaf) {
        $stateContent = Get-Content -LiteralPath $stateFile -Raw
        $s0PolicyContent = @($skillContent, $stateContent, $intakeContent) -join "`n"
        foreach ($policyIssue in @(Get-S0PolicyIssues -Content $s0PolicyContent)) {
            $failures.Add("S0 policy issue: $policyIssue")
        }

        $s0Mutants = @(
            @{ Text = $s0PolicyContent + "`nS0 only allows the record choice."; Expected = 'S0 is limited to the record choice' },
            @{ Text = $s0PolicyContent + "`nThe S0 preview completes S1."; Expected = 'S0 preview completes S1' }
        )
        foreach ($mutant in $s0Mutants) {
            $detected = @(Get-S0PolicyIssues -Content $mutant.Text) -join "`n"
            if ($detected -notmatch [regex]::Escape($mutant.Expected)) {
                $failures.Add("S0 policy mutant escaped detection: $($mutant.Expected)")
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
            '## Teacher Decision And Export Options',
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
            '## Local Named Roster Excel',
            '## Optional PDF And PPT Export',
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

        foreach ($policyIssue in @(Get-ReflectionPolicyIssues -Content $reflectionContent)) {
            $failures.Add("reflection-and-records.md policy issue: $policyIssue")
        }

        $mutants = @(
            @{ Text = 'An anonymous identifier guarantees anonymity.'; Expected = 'identifier falsely guarantees anonymity' },
            @{ Text = 'The next batch must include homework evidence.'; Expected = 'homework evidence is mandatory' },
            @{ Text = 'Exports may proceed without approval.'; Expected = 'exports may proceed without approval' },
            @{ Text = 'The adjustment may bypass teacher confirmation.'; Expected = 'adjustment confirmation may be bypassed' }
        )
        foreach ($mutant in $mutants) {
            $mutantIssues = @(Get-ReflectionPolicyIssues -Content $mutant.Text)
            if (-not ($mutantIssues -match [regex]::Escape($mutant.Expected))) {
                $failures.Add("reflection policy mutant was not rejected: $($mutant.Expected)")
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
            '课程档案:', '当前步骤:', '已确认:', '缺少信息:', '本轮处理:', '下一步:',
            '匿名课程ID:', '课程身份:', '主目标和次目标:',
            '目标日期和成功标准:', '学习证据:',
            '单节时长和每周频率:', '可用周数和截止时间:',
            '教学形式和精讲/练习比例:', '教学场景、人数和授课方式:',
            '课后作业容量:', '设备和访问条件:', '需要输出的材料:',
            '未解决条件:', '教师决定: 确认课程条件 / 修改课程条件 / 补充缺失信息',
            '诊断目的:', 'Course boundary:', '覆盖的前置知识:',
            '覆盖的核心内容:', '能力维度:', '时长:',
            '题量和形式:', '评分和解释方式:',
            '继续下一步所需证据:', '教师决定: 确认蓝图 / 修改蓝图',
            '| 维度 | 状态 | 证据 | 重复模式 | 教学影响 | 置信度 |'
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
            '课程和版本:', '学生阶段和教学场景:', '主目标和目标日期:',
            '当前单元:', '已知教材或 syllabus:', '需要核验的问题:',
            '需要的官方证据:', '需要的书籍证据:',
            '## Source Record',
            'Claim type: course fact / disciplinary fact / teaching recommendation',
            'Evidence level: A / B / C / D', 'Institution or author:',
            'URL or bibliographic record:', 'Published/updated or edition year:',
            'Access date:', 'Course/version applicability:', 'Exact information used:',
            'Cross-validation:', 'Replacement or conflict risk:', 'Verification status:',
            'Provenance/original-adapted status:', 'License/reuse status:', 'Intended use:',
            '## Textbook Comparison',
            '教师决定: 选择一本主教材 / 重新推荐教材 / 提供指定教材',
            '## Course Evidence Package',
            'Course identity and version:', 'School Course Boundary:', 'Textbook Knowledge Mainline:',
            'Required / recommended / excluded content:', 'Prerequisite relationships:',
            'Assessment and marking requirements:', 'Official, school, and recommended sequence:',
            'Learner evidence gap:', 'Source list:', 'Source conflicts:', 'Unresolved items:',
            'Blocking unresolved items and conflicts:', 'Non-blocking follow-ups:',
            '教师决定: A 确认资料包 / B 修改顺序 / C 重新检索 / D 提供学校材料',
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
            '教师决定: A 确认课程周期 / B 修改比例 / C 修改顺序或课时分配 / D 修改目标 / E 补充证据'
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
            '## Lesson Batch Header', '当前步骤: 准备本次课程', '主教材和章节:',
            '课程周期位置:', '使用的学生证据:', '材料类型:', '本批次课程:',
            '资料状态:', '发布标签: 可供老师审阅 / 草稿', '仍需老师检查:',
            '## Single-Lesson Plan', '课程周期位置:', '针对的证据:',
            '目标和退出标准:', '时间线（教师动作、学生动作、问题、证据、分支）:',
            '知识讲解或提问路线:', '预判错误和应对:',
            '进度更快分支:', '进度更慢分支:', '课后复盘字段:',
            '## Practice Question Record', '年份/系列/版本和题号:',
            '官方 / 授权 / 原创 / 改编:', '知识点和认知要求:',
            '难度和预计用时:', '学生版题目:', '教师版解答:',
            '常见错误和原因:', '变式:', '二次尝试题:'
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
            '## Anonymous Record Write Preview', '拟保存目录:', '匿名标识:',
            '将创建或修改的文件:', '将保存的字段:',
            '原始材料: 仅引用 / 允许复制', '已排除可识别信息:',
            '教师决定: 确认保存 / 修改后保存 / 不保存',
            '## Post-Lesson Reflection', '计划内容与实际完成:',
            '独立完成表现:', '代表性成功:', 'Representative errors:',
            '精确卡点:', '时间偏差:', '作业证据:', '学生反馈:',
            '教师判断:', '证据置信度:',
            '## Regular-Class Evidence', 'Class accuracy:', 'Sampled work:',
            'High/middle/foundation tier performance:', 'Teacher observation:',
            'Stage-test statistics:', 'Evidence items supplied:',
            '## Adjustment Proposal', '调整级别: 小调整 / 中等调整 / 大调整',
            '决定类型: 调整 / 保持不变',
            '不调整理由和退出标准证据:',
            'Evidence:', '当前掌握状态:', '拟调整内容:', '对下一节课的影响:',
            '对课程周期的影响:', '如需要则回退到:',
            '教师决定: 确认调整 / 修改调整 / 继续收集证据',
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
        if (-not (Test-OrderedPhrases -Content $templatesContent -Phrases @(
            '## Anonymous Record Write Preview', '## Local Roster Write Preview',
            '## Export Options', '## Post-Lesson Reflection'
        ))) {
            $failures.Add("templates.md local roster/export headings are out of order")
        }
        foreach ($localRosterOrExportField in @(
            '本地档案路径:', '学生姓名:', '年级:', '科目或学习体系:', '一共几节课:',
            '学到哪里了:', '下一节课重点:', '最近一次上课日期:', '匿名课程ID:',
            '教师决定: 确认写入本地档案 / 修改后再写入 / 不保存档案',
            '可导出材料:', '默认排除真实姓名: 是', '导出选项: 生成PDF / 生成PPT / PDF和PPT都生成 / 暂不导出',
            '教师决定: 生成PDF / 生成PPT / 都生成 / 暂不导出 / 修改后再导出'
        )) {
            if ($templatesContent -notmatch [regex]::Escape($localRosterOrExportField)) {
                $failures.Add("templates.md missing local roster/export field: $localRosterOrExportField")
            }
        }

        if (-not (Test-OrderedPhrases -Content $templatesContent -Phrases @(
            '已排除可识别信息:', '记录分类: 假名化 / 匿名最小化',
            '保留期限和复查日期:', '授权访问范围:', '导出决定和批准:',
            '合法依据和机构政策确认:',
            '教师决定: 确认保存 / 修改后保存 / 不保存'
        ))) {
            $failures.Add("templates.md anonymous write preview must place teacher decision after all governance fields")
        }
        if (-not (Test-OrderedPhrases -Content $templatesContent -Phrases @(
            '决定类型: 调整 / 保持不变',
            '调整级别: 小调整 / 中等调整 / 大调整',
            '不调整理由和退出标准证据:'
        ))) {
            $failures.Add("templates.md adjustment proposal must represent decision type before level and rationale")
        }

        foreach ($recordTemplateField in @(
            '记录分类: 假名化 / 匿名最小化',
            '保留期限和复查日期:', '授权访问范围:',
            '导出决定和批准:', '合法依据和机构政策确认:',
            '## Mastery Update Record', 'Concept:', 'Previous level:', 'New level:',
            'Limitations:', 'Date:', 'Confidence:',
            'Teacher impression / direct evidence:',
            '## Change History Entry', 'Change time:', 'Before:', 'After:', 'Reason:',
            'Teacher confirmation:', 'Course-cycle impact:', 'Source/evidence:'
        )) {
            $fieldPattern = '(?m)^' + [regex]::Escape($recordTemplateField) + '\s*$'
            if ($templatesContent -notmatch $fieldPattern) {
                $failures.Add("templates.md missing exact hardened record field: $recordTemplateField")
            }
        }
        if (-not (Test-OrderedPhrases -Content $templatesContent -Phrases @(
            '## Course Summary', '## Mastery Update Record', '## Change History Entry'
        ))) {
            $failures.Add("templates.md hardened record headings are out of order")
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
