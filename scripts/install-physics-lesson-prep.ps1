[CmdletBinding()]
param(
    [string]$Source,
    [string]$Destination = "C:/Users/admin/.codex/skills/physics-lesson-prep",
    [switch]$ValidateOnly
)

$ErrorActionPreference = "Stop"
$requiredLeaf = "physics-lesson-prep"
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$structuralValidator = Join-Path $repositoryRoot "tests/physics-lesson-prep/validate-skill.ps1"
$sourceInput = if ($Source) { $Source } else { "skills/physics-lesson-prep" }
$allowedRootInput = "C:/Users/admin/.codex/skills"
$backupRootInput = "C:/Users/admin/.codex/skill-backups/physics-lesson-prep"
$tempPrefix = "physics-lesson-prep-install-"

function Resolve-RepositoryPath {
    param([Parameter(Mandatory)][string]$Path)

    $candidate = if ([System.IO.Path]::IsPathRooted($Path)) {
        $Path
    }
    else {
        Join-Path $script:repositoryRoot $Path
    }
    return [System.IO.Path]::GetFullPath($candidate)
}

function Assert-NoReparsePoints {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Description
    )

    $root = Get-Item -LiteralPath $Path -Force
    if (-not $root.PSIsContainer) {
        throw "$Description is not a directory: $Path"
    }
    if ($root.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        throw "$Description root is a reparse point: $Path"
    }

    foreach ($item in @(Get-ChildItem -LiteralPath $Path -Force -Recurse)) {
        if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            throw "$Description contains a reparse point: $($item.FullName)"
        }
    }
}

function Assert-DestinationRoot {
    $allowedRoot = (Resolve-Path -LiteralPath $script:allowedRootInput -ErrorAction Stop).Path.TrimEnd('\', '/')
    $allowedItem = Get-Item -LiteralPath $allowedRoot -Force
    if (-not $allowedItem.PSIsContainer -or
        ($allowedItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
        throw "Approved skills root is not a safe directory: $allowedRoot"
    }
    if (-not $allowedRoot.Equals($script:allowedRootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Approved skills root changed during installation: $allowedRoot"
    }
}

function Assert-SafeDestination {
    Assert-DestinationRoot

    $leaf = Split-Path -Leaf $script:destinationPath
    $parent = Split-Path -Parent $script:destinationPath
    if ($leaf -cne $script:requiredLeaf -or
        -not $parent.Equals($script:allowedRootPath, [System.StringComparison]::OrdinalIgnoreCase) -or
        -not $script:destinationPath.Equals($script:intendedDestinationPath, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing unsafe destination operation: $script:destinationPath"
    }

    if (Test-Path -LiteralPath $script:destinationPath) {
        $item = Get-Item -LiteralPath $script:destinationPath -Force
        if (-not $item.PSIsContainer -or
            ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
            throw "Refusing unsafe destination object: $script:destinationPath"
        }
    }
}

function Assert-SafeBackup {
    param([Parameter(Mandatory)][string]$Path)

    Assert-DestinationRoot
    Assert-BackupRoot
    $parent = Split-Path -Parent $Path
    $leaf = Split-Path -Leaf $Path
    if (-not $parent.Equals($script:backupRootPath, [System.StringComparison]::OrdinalIgnoreCase) -or
        -not $leaf.StartsWith("backup-", [System.StringComparison]::Ordinal)) {
        throw "Refusing unsafe backup operation: $Path"
    }
    if (Test-Path -LiteralPath $Path) {
        Assert-NoReparsePoints -Path $Path -Description "Content backup"
    }
}

function Assert-BackupRoot {
    if (-not (Test-Path -LiteralPath $script:backupRootPath -PathType Container)) {
        New-Item -ItemType Directory -Path $script:backupRootPath | Out-Null
    }
    $resolvedBackupRoot = (Resolve-Path -LiteralPath $script:backupRootPath -ErrorAction Stop).Path.TrimEnd('\', '/')
    if (-not $resolvedBackupRoot.Equals($script:backupRootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Backup root changed during installation: $resolvedBackupRoot"
    }
    $backupItem = Get-Item -LiteralPath $script:backupRootPath -Force
    if (-not $backupItem.PSIsContainer -or
        ($backupItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
        throw "Backup root is not a safe directory: $script:backupRootPath"
    }
}

function Assert-SafeSnapshot {
    param([Parameter(Mandatory)][string]$Path)

    $fullPath = [System.IO.Path]::GetFullPath($Path).TrimEnd('\', '/')
    $parent = Split-Path -Parent $fullPath
    $leaf = Split-Path -Leaf $fullPath
    if (-not $parent.Equals($script:tempRootPath, [System.StringComparison]::OrdinalIgnoreCase) -or
        -not $leaf.StartsWith($script:tempPrefix, [System.StringComparison]::Ordinal)) {
        throw "Refusing unsafe snapshot operation: $fullPath"
    }
    if (Test-Path -LiteralPath $fullPath) {
        Assert-NoReparsePoints -Path $fullPath -Description "Temporary snapshot"
    }
}

function Copy-TreeContent {
    param(
        [Parameter(Mandatory)][string]$From,
        [Parameter(Mandatory)][string]$To
    )

    Assert-NoReparsePoints -Path $From -Description "Copy source"
    if (Test-Path -LiteralPath $To) {
        throw "Copy target already exists: $To"
    }
    New-Item -ItemType Directory -Path $To | Out-Null

    $sourcePrefix = $From.TrimEnd('\', '/')
    foreach ($item in @(Get-ChildItem -LiteralPath $sourcePrefix -Force -Recurse | Sort-Object FullName)) {
        if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            throw "Copy source changed to include a reparse point: $($item.FullName)"
        }
        $relative = $item.FullName.Substring($sourcePrefix.Length).TrimStart('\', '/')
        $target = Join-Path $To $relative
        if ($item.PSIsContainer) {
            New-Item -ItemType Directory -Path $target | Out-Null
        }
        else {
            $targetParent = Split-Path -Parent $target
            if (-not (Test-Path -LiteralPath $targetParent -PathType Container)) {
                New-Item -ItemType Directory -Path $targetParent | Out-Null
            }
            Copy-Item -LiteralPath $item.FullName -Destination $target
        }
    }
    Assert-NoReparsePoints -Path $To -Description "Copy result"
}

function Get-ContentManifest {
    param([Parameter(Mandatory)][string]$Root)

    Assert-NoReparsePoints -Path $Root -Description "Manifest source"
    $rootPrefix = $Root.TrimEnd('\', '/')
    $entries = foreach ($item in @(Get-ChildItem -LiteralPath $rootPrefix -Force -Recurse)) {
        $relative = $item.FullName.Substring($rootPrefix.Length).TrimStart('\', '/').Replace('\', '/')
        if ($item.PSIsContainer) {
            "D|$relative"
        }
        else {
            "F|$relative|$((Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash)"
        }
    }
    return @($entries | Sort-Object -CaseSensitive)
}

function Assert-Manifest {
    param(
        [Parameter(Mandatory)][string[]]$Expected,
        [Parameter(Mandatory)][string]$ActualRoot,
        [Parameter(Mandatory)][string]$Description
    )

    $actual = @(Get-ContentManifest -Root $ActualRoot)
    if (($Expected -join "`n") -cne ($actual -join "`n")) {
        throw "$Description content inventory or SHA-256 hashes do not match"
    }
}

function Invoke-StructuralValidator {
    param([Parameter(Mandatory)][string]$SkillPath)

    & $script:pwshPath -NoProfile -File $script:structuralValidator -SkillPath $SkillPath
    if ($LASTEXITCODE -ne 0) {
        throw "Skill structural validation failed: $SkillPath"
    }
}

if (-not (Test-Path -LiteralPath $structuralValidator -PathType Leaf)) {
    throw "Structural validator does not exist: $structuralValidator"
}

# Destination validation intentionally precedes every recursive filesystem operation.
$destinationInput = $Destination.TrimEnd('/', '\')
$destinationName = Split-Path -Leaf $destinationInput
if ($destinationName -cne $requiredLeaf) {
    throw "Refusing unexpected destination name: $destinationName"
}
$destinationParentInput = Split-Path -Parent $destinationInput
if (-not (Test-Path -LiteralPath $destinationParentInput -PathType Container)) {
    throw "Destination parent does not exist: $destinationParentInput"
}

$allowedRootPath = (Resolve-Path -LiteralPath $allowedRootInput -ErrorAction Stop).Path.TrimEnd('\', '/')
$backupRootPath = [System.IO.Path]::GetFullPath($backupRootInput).TrimEnd('\', '/')
$destinationParentPath = (Resolve-Path -LiteralPath $destinationParentInput -ErrorAction Stop).Path.TrimEnd('\', '/')
if (-not $destinationParentPath.Equals($allowedRootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Destination parent must be the approved skills root: $allowedRootPath"
}
$destinationPath = Join-Path $destinationParentPath $requiredLeaf
$intendedDestinationPath = Join-Path $allowedRootPath $requiredLeaf
$normalizedInput = [System.IO.Path]::GetFullPath($destinationInput).TrimEnd('\', '/')
if (-not $normalizedInput.Equals($intendedDestinationPath, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Destination must be exactly: $intendedDestinationPath"
}
Assert-SafeDestination

$pwshPath = (Get-Command pwsh -ErrorAction Stop).Source
$sourceCandidate = Resolve-RepositoryPath -Path $sourceInput
$sourcePath = (Resolve-Path -LiteralPath $sourceCandidate -ErrorAction Stop).Path
if (-not (Test-Path -LiteralPath $sourcePath -PathType Container)) {
    throw "Source is not a directory: $sourcePath"
}
Assert-NoReparsePoints -Path $sourcePath -Description "Canonical source"

$tempRootPath = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd('\', '/')
$snapshotPath = Join-Path $tempRootPath "$tempPrefix$([guid]::NewGuid().ToString('N'))"
$snapshotCreated = $false
$backupPath = $null
$backupManifest = @()
$hadExistingDestination = $false

try {
    Assert-SafeSnapshot -Path $snapshotPath
    Copy-TreeContent -From $sourcePath -To $snapshotPath
    $snapshotCreated = $true
    Assert-SafeSnapshot -Path $snapshotPath
    $snapshotManifest = @(Get-ContentManifest -Root $snapshotPath)
    Invoke-StructuralValidator -SkillPath $snapshotPath

    if ($ValidateOnly) {
        Write-Output "PASS: physics-lesson-prep installation inputs validated; no destination changes made"
        return
    }

    Assert-SafeDestination
    $hadExistingDestination = Test-Path -LiteralPath $destinationPath -PathType Container
    if ($hadExistingDestination) {
        Assert-NoReparsePoints -Path $destinationPath -Description "Existing destination"
        $backupPath = Join-Path $backupRootPath "backup-$(Get-Date -Format 'yyyyMMdd-HHmmssfff')"
        Assert-SafeBackup -Path $backupPath
        Copy-TreeContent -From $destinationPath -To $backupPath
        Assert-SafeBackup -Path $backupPath
        $backupManifest = @(Get-ContentManifest -Root $backupPath)
        Assert-Manifest -Expected $backupManifest -ActualRoot $destinationPath -Description "Content backup"
    }

    try {
        Assert-SafeDestination
        if (Test-Path -LiteralPath $destinationPath) {
            Assert-NoReparsePoints -Path $destinationPath -Description "Destination before replacement"
            Remove-Item -LiteralPath $destinationPath -Recurse -Force
        }

        Assert-SafeSnapshot -Path $snapshotPath
        Assert-Manifest -Expected $snapshotManifest -ActualRoot $snapshotPath -Description "Frozen snapshot"
        Assert-SafeDestination
        Copy-TreeContent -From $snapshotPath -To $destinationPath
        Assert-SafeDestination
        Invoke-StructuralValidator -SkillPath $destinationPath
        Assert-Manifest -Expected $snapshotManifest -ActualRoot $destinationPath -Description "Installed skill"
    }
    catch {
        $installationError = $_
        try {
            Assert-SafeDestination
            if (Test-Path -LiteralPath $destinationPath) {
                Assert-NoReparsePoints -Path $destinationPath -Description "Failed destination"
                Remove-Item -LiteralPath $destinationPath -Recurse -Force
            }
            if ($hadExistingDestination) {
                Assert-SafeBackup -Path $backupPath
                Assert-Manifest -Expected $backupManifest -ActualRoot $backupPath -Description "Content backup"
                Assert-SafeDestination
                Copy-TreeContent -From $backupPath -To $destinationPath
                Assert-Manifest -Expected $backupManifest -ActualRoot $destinationPath -Description "Restored content backup"
            }
        }
        catch {
            throw "Installation failed: $($installationError.Exception.Message). Content backup rollback also failed: $($_.Exception.Message)"
        }
        if ($hadExistingDestination) {
            throw "Installation failed; the previous content backup was restored and retained: $($installationError.Exception.Message)"
        }
        throw "Installation failed; the failed destination was removed: $($installationError.Exception.Message)"
    }

    Write-Output "Installed structurally validated physics-lesson-prep snapshot from $sourcePath to $destinationPath"
    if ($backupPath) {
        Write-Output "Content backup retained at $backupPath"
    }
}
finally {
    if ($snapshotCreated -and (Test-Path -LiteralPath $snapshotPath)) {
        Assert-SafeSnapshot -Path $snapshotPath
        Remove-Item -LiteralPath $snapshotPath -Recurse -Force
    }
}
