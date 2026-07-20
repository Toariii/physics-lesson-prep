param(
    [string]$OutputPath = "output/physics-lesson-prep-validation"
)

$failures = [System.Collections.Generic.List[string]]::new()
$acceptancePath = Join-Path $PSScriptRoot "acceptance-cases.md"

function Add-Failure {
    param([string]$Message)
    $failures.Add($Message)
}

function Require-Match {
    param(
        [string]$Content,
        [string]$Pattern,
        [string]$Message
    )
    if ($Content -notmatch $Pattern) {
        Add-Failure $Message
    }
}

function Require-Terms {
    param(
        [string]$Content,
        [string[]]$Terms,
        [string]$Scope
    )
    foreach ($term in $Terms) {
        if ($Content -notmatch [regex]::Escape($term)) {
            Add-Failure "$Scope missing evidence term: $term"
        }
    }
}

function Get-ResultPass {
    param([string]$Content)
    return $Content -match '(?im)^Result:\s*PASS\s*$|^## Result\s*\r?\n\s*PASS\s*$'
}

function Get-QuestionCount {
    param([string]$Content)
    $match = [regex]::Match($Content, '(?im)^Question count:\s*(\d+)\s*$')
    if (-not $match.Success) {
        return $null
    }
    return [int]$match.Groups[1].Value
}

if (-not (Test-Path -LiteralPath $acceptancePath -PathType Leaf)) {
    Add-Failure "Missing acceptance fixture: $acceptancePath"
}

$cases = @{}
if (Test-Path -LiteralPath $acceptancePath -PathType Leaf) {
    $acceptanceContent = Get-Content -LiteralPath $acceptancePath -Raw
    $caseMatches = [regex]::Matches(
        $acceptanceContent,
        '(?ms)^## Case (?<number>\d{2}) - (?<title>[^\r\n]+)\r?\nPrompt: (?<prompt>[^\r\n]+)\r?\nPass: (?<pass>[^\r\n]+)(?=\r?\n\r?\n## Case|\s*\z)'
    )
    if ($caseMatches.Count -ne 10) {
        Add-Failure "acceptance-cases.md must contain exactly ten complete Case/Prompt/Pass blocks; found $($caseMatches.Count)"
    }

    $expectedHeadings = 1..10 | ForEach-Object { "{0:D2}" -f $_ }
    $actualHeadings = @([regex]::Matches($acceptanceContent, '(?m)^## Case (\d{2}) - ') | ForEach-Object { $_.Groups[1].Value })
    if (($actualHeadings -join ',') -cne ($expectedHeadings -join ',')) {
        Add-Failure "acceptance-cases.md headings must be exactly Case 01 through Case 10 in order"
    }

    foreach ($match in $caseMatches) {
        $number = $match.Groups['number'].Value
        $cases[$number] = @{
            Prompt = $match.Groups['prompt'].Value.Trim()
            Pass = $match.Groups['pass'].Value.Trim()
        }
    }
}

$resolvedOutputPath = $null
try {
    $resolvedOutputPath = (Resolve-Path -LiteralPath $OutputPath -ErrorAction Stop).Path
}
catch {
    Add-Failure "Acceptance output directory does not exist: $OutputPath"
}

$caseContents = @{}
if ($resolvedOutputPath) {
    $expectedFiles = @((1..10 | ForEach-Object { "case-{0:D2}.md" -f $_ }) + 'summary.md')
    $actualFiles = @(Get-ChildItem -LiteralPath $resolvedOutputPath -File | ForEach-Object { $_.Name } | Sort-Object)
    $sortedExpectedFiles = @($expectedFiles | Sort-Object)
    if (($actualFiles -join ',') -cne ($sortedExpectedFiles -join ',')) {
        Add-Failure "Output directory must contain exactly case-01.md through case-10.md plus summary.md; found: $($actualFiles -join ', ')"
    }

    foreach ($number in 1..10 | ForEach-Object { "{0:D2}" -f $_ }) {
        $casePath = Join-Path $resolvedOutputPath "case-$number.md"
        if (-not (Test-Path -LiteralPath $casePath -PathType Leaf)) {
            Add-Failure "Missing case artifact: case-$number.md"
            continue
        }

        $content = Get-Content -LiteralPath $casePath -Raw
        $caseContents[$number] = $content
        $scope = "case-$number.md"
        if ($cases.ContainsKey($number) -and -not $content.Contains($cases[$number].Prompt)) {
            Add-Failure "$scope does not contain its exact acceptance prompt"
        }
        if (-not (Get-ResultPass -Content $content)) {
            Add-Failure "$scope must contain a Result field set to PASS"
        }
        if ($content -match '(?im)^\s*(?:Result:\s*)?FAIL\s*$|^## Result\s*\r?\n\s*FAIL\s*$') {
            Add-Failure "$scope contains FAIL"
        }
        Require-Match $content '(?im)^(?:Chosen state|End state):\s*S[0-9]\b' "$scope missing Chosen state or End state"
        Require-Match $content '(?im)^Fresh-agent task:\s*`?/root/task8_(?:rerun_1_5|cases_6_10)`?\s*$' "$scope missing a valid Fresh-agent task field"
        Require-Match $content '(?im)^Evidence form:\s*\S.*$' "$scope missing Evidence form field"
        Require-Match $content '(?ims)^## Criteria Evidence\s*\r?\n\s*\S' "$scope missing non-empty Criteria Evidence section"

        $expectedTask = if ([int]$number -le 5) { '/root/task8_rerun_1_5' } else { '/root/task8_cases_6_10' }
        if ($content -notmatch ('(?im)^Fresh-agent task:\s*`?' + [regex]::Escape($expectedTask) + '`?\s*$')) {
            Add-Failure "$scope must map to fresh-agent task $expectedTask"
        }
    }

    foreach ($number in @('01', '02', '03', '04', '05', '10')) {
        if (-not $caseContents.ContainsKey($number)) { continue }
        $content = $caseContents[$number]
        $scope = "case-$number.md S0 evidence"
        Require-Match $content '(?i)new anonymous|新建匿名' "$scope missing new-anonymous route"
        Require-Match $content '(?i)existing (?:anonymous )?(?:record|ID)|已有匿名' "$scope missing existing-record route"
        Require-Match $content '(?i)temporary consultation|临时咨询' "$scope missing temporary-consultation route"
        Require-Match $content '(?i)pending|held|no advance|not advance|remain(?:s)? S0|暂存|不进入|不推进' "$scope missing pending/no-advance evidence"
        Require-Match $content '(?i)no formal|formal output|not produce.*formal|正式.*(?:材料|课程)|不规划课程|不备课' "$scope missing no-formal-output evidence"
        $questionCount = Get-QuestionCount -Content $content
        if ($null -eq $questionCount) {
            Add-Failure "case-$number.md missing Question count field"
        }
        elseif ($questionCount -gt 5) {
            Add-Failure "case-$number.md Question count must be at most 5; found $questionCount"
        }
    }

    if ($caseContents.ContainsKey('03')) {
        $content = $caseContents['03']
        Require-Match $content '(?i)(?:two|2)[ -]or[ -](?:three|3).{0,50}book|(?:two|2).{0,20}(?:three|3).{0,30}(?:book|textbook)|两到三本|2-3.*(?:book|教材)' "case-03.md missing positive two-or-three-book route"
        Require-Match $content '(?i)teacher.{0,50}confirm.{0,50}primary (?:textbook|book)|primary (?:textbook|book).{0,50}teacher.{0,30}confirm|教师.{0,30}确认.{0,30}主教材' "case-03.md missing teacher primary-textbook confirmation gate"
    }

    if ($caseContents.ContainsKey('06')) {
        $content = $caseContents['06']
        Require-Match $content '(?im)^Release label:\s*`?draft - teacher review required`?(?:\.|\s|$)' "case-06.md must use the draft release label"
        Require-Terms $content @(
            'prerequisite', 'central', 'phenomenon', 'model', 'representations',
            'counterexample', 'question chain', 'guided', 'foundation',
            'diagnostic', 'summary', 'Lessons 2-3', 'adjustable'
        ) 'case-06.md'
        Require-Match $content '(?i)deriv|Faraday.{0,80}dPhi|E_avg' "case-06.md missing derivation evidence"
        Require-Match $content '(?i)example.{0,80}(?:limit|does not explain)' "case-06.md missing example-limit evidence"
        if ($content -match '(?i)teacher-review-ready') {
            Add-Failure "case-06.md must not claim teacher-review-ready"
        }
    }

    if ($caseContents.ContainsKey('07')) {
        $content = $caseContents['07']
        Require-Match $content '(?im)^Release label:\s*`?draft - teacher review required`?(?:\.|\s|$)' "case-07.md must use the draft release label"
        Require-Terms $content @(
            'original', 'adapted', 'Student version', 'Teacher solution',
            'Marking points',
            'independent check', 'Accepted alternative', 'Common error',
            'second attempt', 'error record', 'time', 'difficulty'
        ) 'case-07.md'
        Require-Match $content '(?i)givens|has `L =|same `0\.4 m` link' "case-07.md missing givens"
        Require-Match ($content -replace '`', '') '(?i)v_B\s*=.*0\.600i.*1\.039j' "case-07.md missing original computed vB"
        Require-Match ($content -replace '`', '') '(?i)v_B\s*=.*1\.039j' "case-07.md missing adapted computed vB"
        Require-Match $content '(?i)variant|meaningful second attempt|changed-orientation' "case-07.md missing variant evidence"
        if ($content -match '(?i)teacher-review-ready') {
            Add-Failure "case-07.md must not claim teacher-review-ready"
        }
    }

    if ($caseContents.ContainsKey('08')) {
        $content = $caseContents['08']
        Require-Terms $content @(
            'representative success', 'representative error', 'homework evidence', 'mastery',
            'adjustment level', 'teacher confirmation', 'wait', 'no next batch'
        ) 'case-08.md'
    }

    if ($caseContents.ContainsKey('09')) {
        $content = $caseContents['09']
        Require-Match $content '(?i)at least two|至少两' "case-09.md must require at least two evidence types"
        Require-Match $content '(?i)diagnostic|诊断' "case-09.md missing rapid diagnostic route"
        Require-Match $content '(?i)no rewrite|does not rewrite|will not rewrite|不重写|现在不重做' "case-09.md missing no-rewrite boundary"
    }

    if ($caseContents.ContainsKey('10')) {
        $content = $caseContents['10']
        Require-Match $content '(?i)pseudonymous|pseudonymized|假名化' "case-10.md missing pseudonymous-record governance"
        Require-Match $content '(?i)re-identif' "case-10.md missing re-identification risk"
        Require-Terms $content @('retention', 'access', 'export') 'case-10.md'
        Require-Match $content '(?i)policy|lawful' "case-10.md missing policy/lawful-basis evidence"
        Require-Match $content '(?i)no (?:file )?write|does not write|not write|未写入|不写入' "case-10.md missing no-write evidence"
    }

    $summaryPath = Join-Path $resolvedOutputPath 'summary.md'
    if (Test-Path -LiteralPath $summaryPath -PathType Leaf) {
        $summaryContent = Get-Content -LiteralPath $summaryPath -Raw
        $passRows = @([regex]::Matches($summaryContent, '(?m)^\|\s*(0[1-9]|10)\s*\|[^\r\n]*\|\s*PASS\s*\|'))
        if ($passRows.Count -ne 10 -or (($passRows | ForEach-Object { $_.Groups[1].Value }) -join ',') -cne '01,02,03,04,05,06,07,08,09,10') {
            Add-Failure "summary.md must contain exactly ten ordered PASS rows for cases 01-10"
        }
        Require-Match $summaryContent '(?i)task manifest' "summary.md missing task manifest"
        Require-Match $summaryContent '(?is)(?:01-05.*?/root/task8_rerun_1_5|/root/task8_rerun_1_5.*?01-05)' "summary.md task manifest missing cases 01-05 mapping"
        Require-Match $summaryContent '(?is)(?:06-10.*?/root/task8_cases_6_10|/root/task8_cases_6_10.*?06-10)' "summary.md task manifest missing cases 06-10 mapping"
        Require-Match $summaryContent '(?i)Structural(?: validation)?:\s*PASS|Structural Validation.{0,120}Result:\s*PASS' "summary.md missing Structural PASS"
        Require-Match $summaryContent '\b726237d\b' "summary.md missing S0 revision 726237d"
        Require-Match $summaryContent '(?i)evidence limitation' "summary.md missing evidence limitation"
        Require-Match $summaryContent '(?i)residual risks' "summary.md missing residual risks"
        Require-Match $summaryContent '(?im)^PASS for beta/teacher-review workflow\s*$' "summary.md missing exact beta release decision"
        if ($summaryContent -match '(?i)\b(?:standalone|verbatim)\b') {
            Add-Failure "summary.md must not make standalone or verbatim evidence claims"
        }
        if ($summaryContent -match '(?i)production[- ]ready|autonomous(?:ly| workflow| operation)?') {
            Add-Failure "summary.md must not claim production-ready or autonomous operation"
        }
    }
}

if ($failures.Count -gt 0) {
    $message = "Physics lesson prep forward-test evidence validation failed:`n- " + ($failures -join "`n- ")
    Write-Error $message
    exit 1
}

Write-Output "PASS: physics-lesson-prep forward-test evidence validated"
