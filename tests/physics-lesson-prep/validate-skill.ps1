param(
    [string]$SkillPath = "skills/physics-lesson-prep"
)

$failures = [System.Collections.Generic.List[string]]::new()
$expectedFilesPath = Join-Path $PSScriptRoot "expected-files.txt"
$expectedFiles = @(Get-Content -LiteralPath $expectedFilesPath | Where-Object { $_.Trim() })

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

        if ($skillContent -notmatch '(?ms)\A---\s*.*?^name:\s*physics-lesson-prep\s*$.*?^description:\s*\S.+?^---\s*$') {
            $failures.Add("SKILL.md frontmatter must define name and description")
        }
        if ($skillLines.Count -gt 300) {
            $failures.Add("SKILL.md must be 300 lines or fewer")
        }
        foreach ($requiredText in @('S0', 'S9', 'Do not generate formal', 'Current stage')) {
            if ($skillContent -notmatch [regex]::Escape($requiredText)) {
                $failures.Add("SKILL.md missing required text: $requiredText")
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
        'two or three',
        'primary textbook',
        'double-track',
        'teacher confirmation',
        'next two to four lessons',
        'anonymous',
        'representative errors',
        'search-result snippets'
    )) {
        if ($joinedMarkdown -notmatch [regex]::Escape($requiredPhrase)) {
            $failures.Add("Markdown missing required phrase: $requiredPhrase")
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
