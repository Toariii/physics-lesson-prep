[CmdletBinding()]
param(
    [string]$Source = "skills/physics-lesson-prep",
    [string]$Destination = "C:/Users/admin/.codex/skills/physics-lesson-prep",
    [string]$ValidationOutput = "output/physics-lesson-prep-validation"
)

$ErrorActionPreference = "Stop"
$requiredLeaf = "physics-lesson-prep"
$allowedDestinationRoot = "C:/Users/admin/.codex/skills"
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$structuralValidator = Join-Path $repositoryRoot "tests/physics-lesson-prep/validate-skill.ps1"
$acceptanceValidator = Join-Path $repositoryRoot "tests/physics-lesson-prep/validate-acceptance.ps1"

function Assert-NoReparsePoints {
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$Description
    )

    $reparsePoints = @(Get-ChildItem -LiteralPath $Path -Force -Recurse | Where-Object {
        $_.Attributes -band [System.IO.FileAttributes]::ReparsePoint
    })
    if ($reparsePoints.Count -gt 0) {
        throw "$Description contains a reparse point and cannot be copied safely: $($reparsePoints[0].FullName)"
    }
}

function Assert-SafeDestination {
    param([Parameter(Mandatory)][string]$Path)

    $leaf = Split-Path -Leaf $Path
    $parent = Split-Path -Parent $Path
    if ($leaf -cne $script:requiredLeaf -or
        -not $parent.StartsWith($script:allowedPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing unsafe destination operation: $Path"
    }

    if (Test-Path -LiteralPath $Path) {
        $item = Get-Item -LiteralPath $Path -Force
        if (-not $item.PSIsContainer -or
            ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
            throw "Refusing unsafe destination object: $Path"
        }
    }
}

function Copy-DirectoryContents {
    param(
        [Parameter(Mandatory)]
        [string]$From,
        [Parameter(Mandatory)]
        [string]$To
    )

    New-Item -ItemType Directory -Path $To | Out-Null
    foreach ($item in @(Get-ChildItem -LiteralPath $From -Force)) {
        Copy-Item -LiteralPath $item.FullName -Destination $To -Recurse -Force
    }
}

function Get-DirectoryManifest {
    param([Parameter(Mandatory)][string]$Root)

    $rootPrefix = $Root.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    $entries = foreach ($item in @(Get-ChildItem -LiteralPath $rootPrefix -Force -Recurse)) {
        $relativePath = $item.FullName.Substring($rootPrefix.Length).TrimStart(
            [System.IO.Path]::DirectorySeparatorChar,
            [System.IO.Path]::AltDirectorySeparatorChar
        ).Replace('\', '/')

        if ($item.PSIsContainer) {
            "D|$relativePath"
        }
        else {
            $hash = (Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash
            "F|$relativePath|$hash"
        }
    }

    return @($entries | Sort-Object -CaseSensitive)
}

function Assert-ManifestsMatch {
    param(
        [Parameter(Mandatory)][string]$ExpectedRoot,
        [Parameter(Mandatory)][string]$ActualRoot
    )

    $expected = @(Get-DirectoryManifest -Root $ExpectedRoot)
    $actual = @(Get-DirectoryManifest -Root $ActualRoot)
    if (($expected -join "`n") -cne ($actual -join "`n")) {
        throw "Installed inventory or SHA-256 hashes do not match the canonical skill"
    }
}

function Invoke-Validator {
    param(
        [Parameter(Mandatory)][string]$Validator,
        [Parameter(Mandatory)][string[]]$Arguments,
        [Parameter(Mandatory)][string]$FailureMessage
    )

    & $script:pwshPath -NoProfile -File $Validator @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw $FailureMessage
    }
}

if (-not (Test-Path -LiteralPath $structuralValidator -PathType Leaf)) {
    throw "Structural validator does not exist: $structuralValidator"
}
if (-not (Test-Path -LiteralPath $acceptanceValidator -PathType Leaf)) {
    throw "Acceptance validator does not exist: $acceptanceValidator"
}

$pwshPath = (Get-Command pwsh -ErrorAction Stop).Source
$sourcePath = (Resolve-Path -LiteralPath $Source -ErrorAction Stop).Path
if (-not (Test-Path -LiteralPath $sourcePath -PathType Container)) {
    throw "Source is not a directory: $sourcePath"
}
Assert-NoReparsePoints -Path $sourcePath -Description "Source"

$validationOutputPath = (Resolve-Path -LiteralPath $ValidationOutput -ErrorAction Stop).Path
if (-not (Test-Path -LiteralPath $validationOutputPath -PathType Container)) {
    throw "Validation output is not a directory: $validationOutputPath"
}

$destinationInput = $Destination.TrimEnd('/', '\')
$destinationName = Split-Path -Leaf $destinationInput
if ($destinationName -cne $requiredLeaf) {
    throw "Refusing unexpected destination name: $destinationName"
}

$destinationParentInput = Split-Path -Parent $destinationInput
if (-not (Test-Path -LiteralPath $destinationParentInput -PathType Container)) {
    throw "Destination parent does not exist: $destinationParentInput"
}

$allowedRootPath = (Resolve-Path -LiteralPath $allowedDestinationRoot -ErrorAction Stop).Path.TrimEnd('\', '/')
$destinationParentPath = (Resolve-Path -LiteralPath $destinationParentInput -ErrorAction Stop).Path.TrimEnd('\', '/')
$destinationPath = Join-Path $destinationParentPath $requiredLeaf
$allowedPrefix = $allowedRootPath + [System.IO.Path]::DirectorySeparatorChar
if (-not $destinationPath.StartsWith($allowedPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing destination outside the approved skills root: $destinationPath"
}

$ancestor = $destinationParentPath
while ($ancestor.Length -ge $allowedRootPath.Length) {
    $ancestorItem = Get-Item -LiteralPath $ancestor -Force
    if ($ancestorItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        throw "Refusing destination beneath a reparse-point directory: $ancestor"
    }
    if ($ancestor.Equals($allowedRootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
        break
    }
    $nextAncestor = Split-Path -Parent $ancestor
    if ($nextAncestor -eq $ancestor) {
        throw "Could not verify destination ancestry: $destinationParentPath"
    }
    $ancestor = $nextAncestor
}

if (Test-Path -LiteralPath $destinationPath) {
    $existingDestination = Get-Item -LiteralPath $destinationPath -Force
    if (-not $existingDestination.PSIsContainer) {
        throw "Destination exists but is not a directory: $destinationPath"
    }
    if ($existingDestination.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        throw "Refusing reparse-point destination: $destinationPath"
    }
    Assert-NoReparsePoints -Path $destinationPath -Description "Existing destination"
}
Assert-SafeDestination -Path $destinationPath

Invoke-Validator -Validator $structuralValidator `
    -Arguments @('-SkillPath', $sourcePath) `
    -FailureMessage "Canonical skill structural validation failed"
Invoke-Validator -Validator $acceptanceValidator `
    -Arguments @('-OutputPath', $validationOutputPath) `
    -FailureMessage "Canonical skill acceptance validation failed"

$backupPath = $null
$hadExistingDestination = Test-Path -LiteralPath $destinationPath -PathType Container
if ($hadExistingDestination) {
    $backupPath = "$destinationPath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmssfff')"
    if (Test-Path -LiteralPath $backupPath) {
        throw "Backup path already exists: $backupPath"
    }
    Copy-DirectoryContents -From $destinationPath -To $backupPath
    Assert-ManifestsMatch -ExpectedRoot $destinationPath -ActualRoot $backupPath
}

try {
    if (Test-Path -LiteralPath $destinationPath) {
        Assert-SafeDestination -Path $destinationPath
        Remove-Item -LiteralPath $destinationPath -Recurse -Force
    }
    Copy-DirectoryContents -From $sourcePath -To $destinationPath

    Invoke-Validator -Validator $structuralValidator `
        -Arguments @('-SkillPath', $destinationPath) `
        -FailureMessage "Installed skill structural validation failed"
    Assert-ManifestsMatch -ExpectedRoot $sourcePath -ActualRoot $destinationPath
}
catch {
    $installationError = $_
    try {
        if (Test-Path -LiteralPath $destinationPath) {
            Assert-SafeDestination -Path $destinationPath
            Remove-Item -LiteralPath $destinationPath -Recurse -Force
        }
        if ($hadExistingDestination -and $backupPath -and (Test-Path -LiteralPath $backupPath -PathType Container)) {
            Copy-DirectoryContents -From $backupPath -To $destinationPath
            Assert-ManifestsMatch -ExpectedRoot $backupPath -ActualRoot $destinationPath
        }
    }
    catch {
        throw "Installation failed: $($installationError.Exception.Message). Rollback also failed: $($_.Exception.Message)"
    }
    if ($hadExistingDestination) {
        throw "Installation failed; the previous destination was restored and its backup retained: $($installationError.Exception.Message)"
    }
    throw "Installation failed; the failed destination was removed: $($installationError.Exception.Message)"
}

Write-Output "Installed physics-lesson-prep from $sourcePath to $destinationPath"
if ($backupPath -and (Test-Path -LiteralPath $backupPath -PathType Container)) {
    Write-Output "Backup retained at $backupPath"
}
