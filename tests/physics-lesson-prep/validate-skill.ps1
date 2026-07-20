param(
    [string]$SkillPath = "skills/physics-lesson-prep"
)

$failures = [System.Collections.Generic.List[string]]::new()
$expectedFilesPath = Join-Path $PSScriptRoot "expected-files.txt"
$expectedFiles = @(Get-Content -LiteralPath $expectedFilesPath | Where-Object { $_.Trim() })

function Test-RequiredHeadingSequence {
    param([string[]]$Lines, [string[]]$ExpectedHeadings)

    $headings = @($Lines | Where-Object { $_ -match '^#{1,2}\s' })
    $previousIndex = -1
    foreach ($expectedHeading in $ExpectedHeadings) {
        $matchingIndices = @()
        for ($index = 0; $index -lt $headings.Count; $index++) {
            if ($headings[$index] -ceq $expectedHeading) {
                $matchingIndices += $index
            }
        }
        if ($matchingIndices.Count -ne 1 -or $matchingIndices[0] -le $previousIndex) {
            return $false
        }
        $previousIndex = $matchingIndices[0]
    }
    return $true
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
        'Course Evidence Package'
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
        if (-not (Test-RequiredHeadingSequence -Lines $curriculumLines -ExpectedHeadings $expectedHeadings)) {
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
        foreach ($trackPhrase in @(
            'Track A - Actual course boundary:', 'teacher syllabus', 'course/department page',
            'course code/catalog', 'assigned chapters', 'lectures/assignments/labs/examination scope',
            'Track B - Disciplinary knowledge line:', 'assigned textbook', 'teacher references',
            'authoritative same-level textbooks/monographs', 'reputable publisher resources',
            'professional bodies/open courses'
        )) {
            if ($curriculumContent -notmatch [regex]::Escape($trackPhrase)) {
                $failures.Add("curriculum-research.md missing double-track element: $trackPhrase")
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
        if (-not (Test-RequiredHeadingSequence -Lines $sourceValidationLines -ExpectedHeadings $expectedHeadings)) {
            $failures.Add("source-validation.md headings or order do not match the required structure")
        }

        foreach ($sourceRule in @(
            'course fact: what the target course requires',
            'disciplinary fact: what physics and mathematics establish',
            'teaching recommendation: a pedagogical choice for this learner',
            'A - decisive official/assigned evidence',
            'B - authoritative professional evidence',
            'C - screened practice material',
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

        $textbookSection = ($templatesContent -split '(?m)^## Textbook Comparison\s*$', 2)[1]
        if ($textbookSection) {
            $textbookSection = ($textbookSection -split '(?m)^##\s+', 2)[0]
        }
        $tableHeaderLine = @($textbookSection -split '\r?\n' | Where-Object { $_ -match '^\|' } | Select-Object -First 1)
        foreach ($requiredColumn in @(
            'Candidate', 'Author', 'Publisher', 'ISBN', 'Edition', 'Chapters', 'Level',
            'Strengths', 'Limitations', 'Notation differences', 'Adoption evidence'
        )) {
            if ($tableHeaderLine.Count -ne 1 -or $tableHeaderLine[0] -notmatch "(?i)(?:^|\|)\s*$([regex]::Escape($requiredColumn))\s*(?:\||$)") {
                $failures.Add("templates.md Textbook Comparison missing column: $requiredColumn")
            }
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
