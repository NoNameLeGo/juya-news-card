<#
.SYNOPSIS
    Install juya-news-card-operator as a system-level agent skill.
.DESCRIPTION
    Creates symlinks (default) or copies the skill directory to all
    recognized OpenCode skill discovery paths:
      - ~/.agents/skills/juya-news-card-operator/
      - ~/.claude/skills/juya-news-card-operator/
      - ~/.config/opencode/skills/juya-news-card-operator/
    This makes the skill available to AI coding agents across all projects.
.PARAMETER Mode
    'symlink' (default) — creates directory junctions (reflinks).
    'copy' — copies the skill files instead.
.PARAMETER Force
    Overwrite existing installation.
.EXAMPLE
    .\scripts\install-skill.ps1
    .\scripts\install-skill.ps1 -Mode copy -Force
#>

param(
    [ValidateSet('symlink', 'copy')]
    [string]$Mode = 'symlink',
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$ProjectRoot = Resolve-Path "$PSScriptRoot\.."
$SkillSource = Join-Path $ProjectRoot '.agents\skills\juya-news-card-operator'
$SkillName = 'juya-news-card-operator'

# All recognized OpenCode skill discovery paths
$TargetRoots = @(
    "$env:USERPROFILE\.agents\skills",
    "$env:USERPROFILE\.claude\skills",
    "$env:USERPROFILE\.config\opencode\skills"
)

# Validate source
if (-not (Test-Path $SkillSource)) {
    Write-Error "Skill source not found: $SkillSource"
    exit 1
}

Write-Host "juya-news-card-operator installer" -ForegroundColor Cyan
Write-Host "  Source : $SkillSource"
Write-Host "  Mode   : $Mode"
Write-Host ""

$InstalledCount = 0

foreach ($TargetDir in $TargetRoots) {
    $SkillTarget = Join-Path $TargetDir $SkillName

    # Create target parent directory
    if (-not (Test-Path $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }

    # Check existing installation
    if (Test-Path $SkillTarget) {
        if ($Force) {
            Remove-Item -Recurse -Force $SkillTarget
        } else {
            Write-Warning "Already exists at: $SkillTarget (use -Force to overwrite)"
            continue
        }
    }

    # Install
    if ($Mode -eq 'symlink') {
        New-Item -ItemType Junction -Path $SkillTarget -Target $SkillSource | Out-Null
        Write-Host "  [symlink] $SkillTarget" -ForegroundColor Green
    } else {
        Copy-Item -Path $SkillSource -Destination $SkillTarget -Recurse -Force
        Write-Host "  [copy]    $SkillTarget" -ForegroundColor Green
    }

    # Verify
    if (Test-Path (Join-Path $SkillTarget 'SKILL.md')) {
        $InstalledCount++
    } else {
        Write-Error "  Verification failed at: $SkillTarget"
    }
}

Write-Host ""
Write-Host "Installed to $InstalledCount of $($TargetRoots.Count) paths." -ForegroundColor Cyan
Write-Host "Note: Skills are loaded at session startup. Please start a new session to use the skill." -ForegroundColor Yellow
