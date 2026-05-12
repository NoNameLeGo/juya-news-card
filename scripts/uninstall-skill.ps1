<#
.SYNOPSIS
    Uninstall juya-news-card-operator from all system-level agent skill paths.
#>

$ErrorActionPreference = 'Stop'

$SkillName = 'juya-news-card-operator'

$TargetRoots = @(
    "$env:USERPROFILE\.agents\skills",
    "$env:USERPROFILE\.claude\skills",
    "$env:USERPROFILE\.config\opencode\skills"
)

$Found = $false

foreach ($TargetDir in $TargetRoots) {
    $SkillTarget = Join-Path $TargetDir $SkillName
    if (Test-Path $SkillTarget) {
        $Item = Get-Item -LiteralPath $SkillTarget
        if ($Item.LinkType -or ($Item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
            Remove-Item -LiteralPath $SkillTarget -Force
            Write-Host "Removed symlink: $SkillTarget" -ForegroundColor Yellow
        } else {
            Remove-Item -LiteralPath $SkillTarget -Recurse -Force
            Write-Host "Removed directory: $SkillTarget" -ForegroundColor Yellow
        }
        $Found = $true
    }
}

if (-not $Found) {
    Write-Warning "Skill '$SkillName' not found in any skill path."
} else {
    Write-Host "juya-news-card-operator uninstalled." -ForegroundColor Cyan
}
