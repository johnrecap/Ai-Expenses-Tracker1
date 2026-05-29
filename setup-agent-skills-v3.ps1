<#
.SYNOPSIS
  Agent Skills and Flutter UI tooling setup v3.

.DESCRIPTION
  Installs and verifies the agent skills, global CLIs, Flutter UI packages, and
  reference repositories useful for a UI-only Flutter prototype workflow.

  The script is intentionally defensive:
  - It reports every install/check as OK, WARN, FAIL, or SKIP.
  - It does not stop the whole setup when one optional tool fails.
  - It keeps backend/database/auth/API tools out of the default install set.
  - It treats awesome lists and large UI repos as local references, not app code.
  - It appends a managed block to AGENTS.md instead of replacing existing rules.

.USAGE
  pwsh -ExecutionPolicy Bypass -File .\setup-agent-skills-v3.ps1
  pwsh -ExecutionPolicy Bypass -File .\setup-agent-skills-v3.ps1 -ProjectPath "C:\path\to\project"
  pwsh -ExecutionPolicy Bypass -File .\setup-agent-skills-v3.ps1 -DryRun

.NOTES
  Run from the project root, or pass -ProjectPath. If pubspec.yaml is present,
  the script can add UI-only Flutter packages. If no pubspec.yaml is present,
  Flutter package installation is skipped and reported.
#>

[CmdletBinding()]
param(
    [string]$ProjectPath = (Get-Location).Path,
    [switch]$DryRun,
    [switch]$SkipSkillPacks,
    [switch]$SkipGlobalTools,
    [switch]$SkipReferenceRepos,
    [switch]$SkipFlutterPackages,
    [switch]$SkipSpecKit,
    [switch]$ForceSpecKitInit,
    [switch]$SkipCommunitySkillPacks,
    [switch]$SkipLargeReferenceRepos
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$script:Results = New-Object "System.Collections.Generic.List[object]"
$script:ProjectRoot = [System.IO.Path]::GetFullPath($ProjectPath)
$script:ReportDir = Join-Path $script:ProjectRoot "docs\agent-playbooks"
$script:ReferenceRoot = Join-Path $script:ReportDir "references"

function Write-Title {
    param([Parameter(Mandatory = $true)][string]$Text)
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}

function Write-Step {
    param([Parameter(Mandatory = $true)][string]$Text)
    Write-Host ""
    Write-Host $Text -ForegroundColor Yellow
}

function Test-Cmd {
    param([Parameter(Mandatory = $true)][string]$Name)
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Ensure-Dir {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        if ($DryRun) {
            Write-Host "  DRYRUN mkdir $Path" -ForegroundColor DarkGray
            return
        }
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Host "  + $Path" -ForegroundColor Green
    }
}

function Add-Result {
    param(
        [Parameter(Mandatory = $true)][string]$Area,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][ValidateSet("OK", "WARN", "FAIL", "SKIP")][string]$Status,
        [string]$Role = "",
        [string]$Command = "",
        [string]$Details = "",
        [string]$Fix = ""
    )

    $script:Results.Add([pscustomobject]@{
        area = $Area
        name = $Name
        status = $Status
        role = $Role
        command = $Command
        details = ($Details -replace "`r", " " -replace "`n", " ").Trim()
        fix = ($Fix -replace "`r", " " -replace "`n", " ").Trim()
    }) | Out-Null

    $color = switch ($Status) {
        "OK" { "Green" }
        "WARN" { "DarkYellow" }
        "FAIL" { "Red" }
        default { "DarkGray" }
    }
    Write-Host ("  [{0}] {1}: {2}" -f $Status, $Area, $Name) -ForegroundColor $color
    if ($Details) { Write-Host "      $Details" -ForegroundColor DarkGray }
    if ($Fix -and $Status -ne "OK") { Write-Host "      Fix: $Fix" -ForegroundColor DarkYellow }
}

function Format-CommandLine {
    param([string]$File, [string[]]$Arguments)
    return (($File, $Arguments) -join " ").Trim()
}

function Invoke-CheckedTool {
    param(
        [Parameter(Mandatory = $true)][string]$Area,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$File,
        [string[]]$Arguments = @(),
        [string]$Role = "",
        [string]$Fix = "",
        [switch]$AllowFailure
    )

    $commandLine = Format-CommandLine -File $File -Arguments $Arguments

    if ($DryRun) {
        Add-Result -Area $Area -Name $Name -Status "SKIP" -Role $Role -Command $commandLine -Details "Dry run only." -Fix ""
        return $false
    }

    if (-not (Test-Cmd $File)) {
        Add-Result -Area $Area -Name $Name -Status "FAIL" -Role $Role -Command $commandLine -Details "$File was not found on PATH." -Fix $Fix
        if (-not $AllowFailure) { throw "$File was not found on PATH" }
        return $false
    }

    Write-Host "  > $commandLine" -ForegroundColor DarkGray
    try {
        $output = & $File @Arguments 2>&1
        $exitCode = if ($null -ne $LASTEXITCODE) { $LASTEXITCODE } else { 0 }
        $text = (($output | Select-Object -First 12) -join " ").Trim()
        if ($exitCode -eq 0) {
            Add-Result -Area $Area -Name $Name -Status "OK" -Role $Role -Command $commandLine -Details $text -Fix ""
            return $true
        }

        Add-Result -Area $Area -Name $Name -Status "FAIL" -Role $Role -Command $commandLine -Details "Exit code $exitCode. $text" -Fix $Fix
        if (-not $AllowFailure) { throw "$commandLine failed with exit code $exitCode" }
        return $false
    } catch {
        Add-Result -Area $Area -Name $Name -Status "FAIL" -Role $Role -Command $commandLine -Details $_.Exception.Message -Fix $Fix
        if (-not $AllowFailure) { throw }
        return $false
    }
}

function Write-TextFile {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content,
        [switch]$Overwrite
    )
    $dir = Split-Path -Path $Path -Parent
    if ($dir) { Ensure-Dir $dir }

    if ((Test-Path -LiteralPath $Path) -and -not $Overwrite) {
        Add-Result -Area "file" -Name $Path -Status "SKIP" -Role "Existing file preserved." -Details "Use overwrite-capable workflow if this file must be replaced." -Fix ""
        return
    }

    if ($DryRun) {
        Add-Result -Area "file" -Name $Path -Status "SKIP" -Role "Would write file." -Details "Dry run only." -Fix ""
        return
    }

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($fullPath, $Content, $utf8NoBom)
    Add-Result -Area "file" -Name $Path -Status "OK" -Role "Wrote UTF-8 file." -Details "" -Fix ""
}

function Upsert-ManagedBlock {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$BlockName,
        [Parameter(Mandatory = $true)][string]$Content
    )

    $begin = "<!-- BEGIN $BlockName -->"
    $end = "<!-- END $BlockName -->"
    $block = "$begin`n$Content`n$end"
    $existing = ""
    if (Test-Path -LiteralPath $Path) {
        $existing = Get-Content -LiteralPath $Path -Raw -ErrorAction SilentlyContinue
    }

    if ($existing -match [regex]::Escape($begin)) {
        $pattern = "(?s)" + [regex]::Escape($begin) + ".*?" + [regex]::Escape($end)
        $updated = [regex]::Replace($existing, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $block })
    } elseif ([string]::IsNullOrWhiteSpace($existing)) {
        $updated = $block + "`n"
    } else {
        $updated = $existing.TrimEnd() + "`n`n" + $block + "`n"
    }

    Write-TextFile -Path $Path -Content $updated -Overwrite
}

function Remove-GitIgnoreEntry {
    param([Parameter(Mandatory = $true)][string]$Entry)
    $path = Join-Path $script:ProjectRoot ".gitignore"
    if (-not (Test-Path -LiteralPath $path)) {
        Add-Result -Area "gitignore" -Name $Entry -Status "OK" -Role "No .gitignore file present." -Details "Nothing to remove." -Fix ""
        return
    }
    if ($DryRun) {
        Add-Result -Area "gitignore" -Name $Entry -Status "SKIP" -Role "Would remove ignore entry." -Details "Dry run only." -Fix ""
        return
    }

    $lines = @(Get-Content -LiteralPath $path -ErrorAction SilentlyContinue)
    $updated = @($lines | Where-Object { $_.Trim() -ne $Entry })
    if ($updated.Count -ne $lines.Count) {
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText([System.IO.Path]::GetFullPath($path), (($updated -join "`n") + "`n"), $utf8NoBom)
        Add-Result -Area "gitignore" -Name $Entry -Status "OK" -Role "Removed ignore entry so Git can track files." -Details "" -Fix ""
    } else {
        Add-Result -Area "gitignore" -Name $Entry -Status "OK" -Role "Ignore entry was not present." -Details "" -Fix ""
    }
}

function Write-Skill {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Markdown
    )

    foreach ($root in @(".agents\skills", ".agent\skills")) {
        $dir = Join-Path $script:ProjectRoot (Join-Path $root $Name)
        Ensure-Dir $dir
        Write-TextFile -Path (Join-Path $dir "SKILL.md") -Content $Markdown -Overwrite
    }
}

function Test-ReadableSkill {
    param([Parameter(Mandatory = $true)][string]$SkillName)
    if ($DryRun) {
        Add-Result -Area "verify-skill" -Name $SkillName -Status "SKIP" -Role "Skill readability check." -Details "Dry run only." -Fix ""
        return
    }

    $paths = @(
        (Join-Path $script:ProjectRoot ".agents\skills\$SkillName\SKILL.md"),
        (Join-Path $script:ProjectRoot ".agent\skills\$SkillName\SKILL.md")
    )

    foreach ($path in $paths) {
        if (-not (Test-Path -LiteralPath $path)) {
            Add-Result -Area "verify-skill" -Name $SkillName -Status "WARN" -Role "Skill readability check." -Details "Missing $path" -Fix "Re-run the setup script. If this came from npx skills add, check that the repo exposes a valid skill."
            continue
        }

        $content = Get-Content -LiteralPath $path -Raw -ErrorAction SilentlyContinue
        if ($content -match "^---" -and $content -match "name:" -and $content -match "description:") {
            Add-Result -Area "verify-skill" -Name $SkillName -Status "OK" -Role "Skill is readable by agents." -Details $path -Fix ""
        } else {
            Add-Result -Area "verify-skill" -Name $SkillName -Status "WARN" -Role "Skill exists but metadata may be incomplete." -Details $path -Fix "Open SKILL.md and add YAML front matter with name and description."
        }
    }
}

function Install-SkillPack {
    param(
        [Parameter(Mandatory = $true)][string]$Repo,
        [string]$Skill = "*",
        [string]$Role = "",
        [switch]$FallbackPlain
    )

    if (-not (Test-Cmd "npx")) {
        Add-Result -Area "skill-pack" -Name $Repo -Status "FAIL" -Role $Role -Command "npx -y skills add $Repo" -Details "npx was not found." -Fix "Install Node.js LTS, then re-run this script."
        return
    }

    $args = @("-y", "skills", "add", $Repo)
    if ($Skill -and $Skill.Trim().Length -gt 0) {
        $args += @("--skill", $Skill)
    }
    $args += @("--agent", "universal", "--yes")

    $ok = Invoke-CheckedTool -Area "skill-pack" -Name $Repo -File "npx" -Arguments $args -Role $Role -Fix "Check that $Repo is a valid skills repository and that the network can reach npm/GitHub." -AllowFailure

    if (-not $ok -and $FallbackPlain) {
        Invoke-CheckedTool -Area "skill-pack" -Name "$Repo fallback" -File "npx" -Arguments @("-y", "skills", "add", $Repo) -Role "$Role Fallback without universal flags." -Fix "If this fails too, treat the repo as a reference repo, not an installable skill pack." -AllowFailure | Out-Null
    }
}

function Sync-UniversalSkillsToAntigravity {
    $source = Join-Path $script:ProjectRoot ".agents\skills"
    $dest = Join-Path $script:ProjectRoot ".agent\skills"
    if (-not (Test-Path -LiteralPath $source)) { return }
    Ensure-Dir $dest

    Get-ChildItem -Path $source -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $target = Join-Path $dest $_.Name
        if (-not (Test-Path -LiteralPath $target)) {
            if ($DryRun) {
                Add-Result -Area "skill-sync" -Name $_.Name -Status "SKIP" -Role "Would sync to .agent." -Details "Dry run only." -Fix ""
            } else {
                Copy-Item -LiteralPath $_.FullName -Destination $target -Recurse -Force
                Add-Result -Area "skill-sync" -Name $_.Name -Status "OK" -Role "Synced .agents skill to .agent." -Details "" -Fix ""
            }
        }
    }
}

function Install-NpmGlobal {
    param([string]$Package, [string]$Role, [string]$CheckCommand)
    if (-not (Test-Cmd "npm")) {
        Add-Result -Area "global-tool" -Name $Package -Status "FAIL" -Role $Role -Command "npm install -g $Package" -Details "npm was not found." -Fix "Install Node.js LTS, then re-run this script."
        return
    }

    Invoke-CheckedTool -Area "global-tool" -Name $Package -File "npm" -Arguments @("install", "-g", $Package) -Role $Role -Fix "Check npm registry/network permissions, then retry." -AllowFailure | Out-Null
    Test-ToolCommand -ToolName $Package -CommandLine $CheckCommand -Role $Role
}

function Install-UvTool {
    param([string]$Package, [string]$Role, [string]$Executable)
    if (-not (Test-Cmd "uv")) {
        Add-Result -Area "global-tool" -Name $Package -Status "FAIL" -Role $Role -Command "uv tool install $Package" -Details "uv was not found." -Fix "Install uv, then re-run this script."
        return
    }

    Invoke-CheckedTool -Area "global-tool" -Name $Package -File "uv" -Arguments @("tool", "install", $Package) -Role $Role -Fix "Check PyPI/network permissions. If the package name is invalid, replace it with the correct package." -AllowFailure | Out-Null
    Test-ToolCommand -ToolName $Package -CommandLine "$Executable --help" -Role $Role
}

function Install-DartGlobal {
    param([string]$Package, [string]$Role, [string]$CheckFile, [string[]]$CheckArgs)
    if (-not (Test-Cmd "dart")) {
        Add-Result -Area "global-tool" -Name $Package -Status "FAIL" -Role $Role -Command "dart pub global activate $Package" -Details "dart was not found." -Fix "Install Flutter/Dart SDK, then re-run this script."
        return
    }

    Invoke-CheckedTool -Area "global-tool" -Name $Package -File "dart" -Arguments @("pub", "global", "activate", $Package) -Role $Role -Fix "Check pub.dev/network permissions and package name." -AllowFailure | Out-Null
    Invoke-CheckedTool -Area "verify-tool" -Name $Package -File $CheckFile -Arguments $CheckArgs -Role $Role -Fix "Add the Dart pub global cache bin folder to PATH, or run with dart pub global run." -AllowFailure | Out-Null
}

function Test-ToolCommand {
    param([string]$ToolName, [string]$CommandLine, [string]$Role)
    $parts = $CommandLine -split " "
    $file = $parts[0]
    $args = @()
    if ($parts.Count -gt 1) { $args = $parts[1..($parts.Count - 1)] }
    Invoke-CheckedTool -Area "verify-tool" -Name $ToolName -File $file -Arguments $args -Role $Role -Fix "The install may have succeeded but the executable is not on PATH, or the tool uses a different command name." -AllowFailure | Out-Null
}

function Sync-ReferenceRepo {
    param(
        [Parameter(Mandatory = $true)][string]$Repo,
        [Parameter(Mandatory = $true)][string]$Role,
        [switch]$Large
    )

    if ($Large -and $SkipLargeReferenceRepos) {
        Add-Result -Area "reference-repo" -Name $Repo -Status "SKIP" -Role $Role -Details "Skipped because -SkipLargeReferenceRepos was used." -Fix ""
        return
    }

    if (-not (Test-Cmd "git")) {
        Add-Result -Area "reference-repo" -Name $Repo -Status "FAIL" -Role $Role -Command "git clone https://github.com/$Repo.git" -Details "git was not found." -Fix "Install Git, then re-run this script."
        return
    }

    Ensure-Dir $script:ReferenceRoot
    $safeName = $Repo.Replace("/", "__")
    $target = Join-Path $script:ReferenceRoot $safeName
    $url = "https://github.com/$Repo.git"

    if (Test-Path -LiteralPath $target) {
        if (Test-Path -LiteralPath (Join-Path $target ".git")) {
            Invoke-CheckedTool -Area "reference-repo" -Name $Repo -File "git" -Arguments @("-C", $target, "pull", "--ff-only") -Role $Role -Fix "If the repo has local changes, remove or archive the reference folder and rerun." -AllowFailure | Out-Null
        } else {
            Add-Result -Area "reference-repo" -Name $Repo -Status "OK" -Role $Role -Details "Reference folder already exists as vendored files without nested .git metadata." -Fix ""
        }
    } else {
        $args = @("clone", "--depth", "1", "--filter=blob:none", $url, $target)
        $ok = Invoke-CheckedTool -Area "reference-repo" -Name $Repo -File "git" -Arguments $args -Role $Role -Fix "Check GitHub/network access. If partial clone is unsupported, try a normal shallow clone." -AllowFailure
        if (-not $ok -and -not $DryRun) {
            Invoke-CheckedTool -Area "reference-repo" -Name "$Repo fallback" -File "git" -Arguments @("clone", "--depth", "1", $url, $target) -Role "$Role Fallback shallow clone." -Fix "If this fails, open the GitHub URL manually and confirm the repo exists." -AllowFailure | Out-Null
        }
    }

    Remove-ReferenceGitMetadata -Root $target -Repo $Repo
    Test-ReferenceReadable -Repo $Repo -Target $target -Role $Role
}

function Test-ReferenceReadable {
    param([string]$Repo, [string]$Target, [string]$Role)
    if ($DryRun) { return }

    if (-not (Test-Path -LiteralPath $Target)) {
        Add-Result -Area "verify-reference" -Name $Repo -Status "FAIL" -Role $Role -Details "Reference folder was not created: $Target" -Fix "Check clone errors above."
        return
    }

    $readme = Get-ChildItem -LiteralPath $Target -Filter "README*" -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($readme) {
        Add-Result -Area "verify-reference" -Name $Repo -Status "OK" -Role $Role -Details "Readable: $($readme.FullName)" -Fix ""
    } else {
        Add-Result -Area "verify-reference" -Name $Repo -Status "WARN" -Role $Role -Details "Cloned but no README was found at root." -Fix "Inspect the repo manually and document the correct entry point."
    }
}

function Remove-ReferenceGitMetadata {
    param([Parameter(Mandatory = $true)][string]$Root, [Parameter(Mandatory = $true)][string]$Repo)
    if ($DryRun -or -not (Test-Path -LiteralPath $Root)) { return }

    $referenceRootResolved = [System.IO.Path]::GetFullPath($script:ReferenceRoot)
    $rootResolved = [System.IO.Path]::GetFullPath($Root)
    if (-not $rootResolved.StartsWith($referenceRootResolved, [System.StringComparison]::OrdinalIgnoreCase)) {
        Add-Result -Area "reference-git" -Name $Repo -Status "FAIL" -Role "Protect workspace from unsafe metadata removal." -Details "$Root is outside $script:ReferenceRoot" -Fix "Check ReferenceRoot before removing nested .git folders."
        return
    }

    $gitDirs = @(Get-ChildItem -LiteralPath $Root -Force -Directory -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq ".git" })
    foreach ($gitDir in $gitDirs) {
        $gitDirResolved = [System.IO.Path]::GetFullPath($gitDir.FullName)
        if (-not $gitDirResolved.StartsWith($referenceRootResolved, [System.StringComparison]::OrdinalIgnoreCase)) {
            Add-Result -Area "reference-git" -Name $Repo -Status "FAIL" -Role "Skipped unsafe .git metadata path." -Details $gitDir.FullName -Fix "Check ReferenceRoot before retrying."
            continue
        }
        Remove-Item -LiteralPath $gitDir.FullName -Recurse -Force
        Add-Result -Area "reference-git" -Name $Repo -Status "OK" -Role "Removed nested .git metadata so parent Git tracks files normally." -Details $gitDir.FullName -Fix ""
    }
}

function Write-ReferenceNote {
    param(
        [Parameter(Mandatory = $true)][string]$FileName,
        [Parameter(Mandatory = $true)][string]$Title,
        [Parameter(Mandatory = $true)][string]$Url,
        [Parameter(Mandatory = $true)][string]$Role
    )

    $content = @"
# $Title

- URL: $Url
- Role: $Role
- Use as: Reference only. Do not copy code into the app without checking license, freshness, and fit.
- Project rule: UI-only Flutter prototype. No backend, no Firebase, no auth provider, no database, no API calls, no WebView.
"@
    Write-TextFile -Path (Join-Path $script:ReferenceRoot $FileName) -Content $content -Overwrite
}

function Add-FlutterPackages {
    if (-not (Test-Path -LiteralPath (Join-Path $script:ProjectRoot "pubspec.yaml"))) {
        Add-Result -Area "flutter-package" -Name "pubspec.yaml" -Status "SKIP" -Role "Flutter UI package install." -Details "No pubspec.yaml found in $script:ProjectRoot." -Fix "Run this script from the Flutter app root or pass -ProjectPath."
        return
    }

    if (-not (Test-Cmd "flutter")) {
        Add-Result -Area "flutter-package" -Name "flutter" -Status "FAIL" -Role "Flutter package install." -Details "flutter was not found." -Fix "Install Flutter SDK and add it to PATH."
        return
    }

    $dependencies = @(
        "go_router",
        "fl_chart",
        "lucide_icons_flutter",
        "flutter_svg",
        "flutter_animate",
        "forui",
        "shadcn_ui",
        "responsive_framework"
    )

    $devDependencies = @(
        "widgetbook",
        "alchemist",
        "patrol",
        "flutter_gen_runner",
        "build_runner",
        "very_good_analysis"
    )

    Invoke-CheckedTool -Area "flutter-package" -Name "UI dependencies" -File "flutter" -Arguments (@("pub", "add") + $dependencies) -Role "Native Flutter UI packages only." -Fix "If a package fails, check pub.dev availability and package compatibility with the current Flutter SDK." -AllowFailure | Out-Null
    Invoke-CheckedTool -Area "flutter-package" -Name "UI dev dependencies" -File "flutter" -Arguments (@("pub", "add", "--dev") + $devDependencies) -Role "Widget catalog, golden tests, generated assets, and lint support." -Fix "If a package fails, check pub.dev availability and package compatibility with the current Flutter SDK." -AllowFailure | Out-Null
    Invoke-CheckedTool -Area "flutter-package" -Name "pub get" -File "flutter" -Arguments @("pub", "get") -Role "Resolve package graph." -Fix "Inspect dependency conflicts in pubspec.lock output and pin compatible versions." -AllowFailure | Out-Null
}

function Ensure-SpecKit {
    if (-not (Test-Cmd "uv")) {
        Add-Result -Area "speckit" -Name "uv" -Status "FAIL" -Role "Spec Kit installer." -Details "uv was not found." -Fix "Install uv, then run: uv tool install specify-cli --from git+https://github.com/github/spec-kit.git"
        return
    }

    if (-not (Test-Cmd "specify")) {
        Invoke-CheckedTool -Area "speckit" -Name "specify-cli" -File "uv" -Arguments @("tool", "install", "specify-cli", "--from", "git+https://github.com/github/spec-kit.git") -Role "Official GitHub Spec Kit CLI." -Fix "Check GitHub/PyPI access and uv installation." -AllowFailure | Out-Null
    }

    if (Test-Cmd "specify") {
        Invoke-CheckedTool -Area "speckit" -Name "specify version" -File "specify" -Arguments @("--version") -Role "Verify Spec Kit CLI." -Fix "Reinstall specify-cli with uv." -AllowFailure | Out-Null
    }

    $specifyDir = Join-Path $script:ProjectRoot ".specify"
    if ((-not (Test-Path -LiteralPath $specifyDir)) -or $ForceSpecKitInit) {
        $env:PYTHONUTF8 = "1"
        $env:PYTHONIOENCODING = "utf-8"
        $env:NO_COLOR = "1"

        $currentArgs = @("init", "--here", "--force", "--integration", "codex", "--integration-options=--skills", "--no-git")
        $ok = Invoke-CheckedTool -Area "speckit" -Name "specify init" -File "specify" -Arguments $currentArgs -Role "Initialize official Spec Kit files and Codex skills." -Fix "If this fails due CLI syntax, the script will try a legacy fallback." -AllowFailure
        if (-not $ok) {
            Invoke-CheckedTool -Area "speckit" -Name "specify init legacy fallback" -File "specify" -Arguments @("init", "--here", "--ai", "codex", "--script", "ps") -Role "Fallback for older Spec Kit CLI syntax." -Fix "Check specify --help and adjust init options for the installed version." -AllowFailure | Out-Null
        }
    } else {
        Add-Result -Area "speckit" -Name ".specify" -Status "OK" -Role "Spec Kit already initialized." -Details $specifyDir -Fix ""
    }
}

function Write-BridgeSkills {
    Write-Skill -Name "semantic-code-search" -Markdown @'
---
name: semantic-code-search
description: Use when the user describes a code behavior, feature, architecture concern, or data flow and you need to locate relevant implementation by meaning rather than exact text. Prefer rg for exact strings/errors.
---
# Semantic Code Search via osgrep

## Prerequisites
- `osgrep` installed: `npm install -g osgrep`
- Optional first-time setup: `osgrep setup`

## Workflow
1. Use exact search first when the user gives a symbol, exact text, or error.
2. Use `osgrep "<natural language query>"` when the user describes behavior.
3. Use `osgrep trace "<function_or_symbol>"` to inspect call relationships.
4. Report file paths, symbols, and why each result matters before editing.

## Failure handling
- If `osgrep` is missing, use `rg` and say semantic search is unavailable.
- If indexing fails, report the index path and the command output.
'@

    Write-Skill -Name "persistent-memory" -Markdown @'
---
name: persistent-memory
description: Use when the user asks to remember project decisions, retrieve prior project context, summarize conventions, or maintain long-lived knowledge across sessions.
---
# Persistent Memory via memsearch

## Prerequisites
- `memsearch` installed, preferably via `uv tool install memsearch`.

## Workflow
1. Save stable decisions, architecture notes, and conventions as Markdown.
2. Search before planning work that depends on earlier decisions.
3. Never store secrets, tokens, passwords, or private customer data.
4. Summarize retrieved memory and cite the local note/file when possible.

## Failure handling
- If `memsearch` is unavailable, write or search project memory manually in `docs/agent-playbooks`.
'@

    Write-Skill -Name "stable-local-urls" -Markdown @'
---
name: stable-local-urls
description: Use when a project has multiple local services or when agents/users need stable named localhost URLs instead of remembering ports.
---
# Stable Local URLs via portless

## Prerequisites
- `portless` installed: `npm install -g portless`

## Workflow
1. Prefer wrapping dev commands, e.g. `portless myapp npm run dev`.
2. Use readable names: `frontend`, `api`, `admin`, `storybook`.
3. Document the chosen local URLs in the project quickstart.

## Failure handling
- If `portless` is unavailable, report the normal localhost URL and port.
'@

    Write-Skill -Name "mobile-agent-qa" -Markdown @'
---
name: mobile-agent-qa
description: Use when testing a Flutter/mobile app on Android or iOS devices/emulators, validating UI flows, producing reproducible QA steps, or converting manual mobile checks into integration tests.
---
# Mobile QA via Flutter integration tests + Mobilerun

## Prerequisites
- Flutter SDK and a connected device/emulator.
- Android: `adb devices` must show a device.
- Optional natural-language device automation: `uv tool install mobilerun`.

## Workflow
1. First run deterministic checks: `flutter analyze` and `flutter test`.
2. For UI flows, prefer Flutter `integration_test` when behavior should be permanent.
3. Use Mobilerun only for exploratory/manual-like QA flows.
4. Capture failing steps, screen name, expected result, actual result, and proposed fix.

## Failure handling
- If Mobilerun is unavailable, continue with Flutter integration tests and adb/simulator tools.
'@

    Write-Skill -Name "flutter-ui-from-design" -Markdown @'
---
name: flutter-ui-from-design
description: Use when converting screenshots, Figma/Stitch screens, UI kits, or visual references into Flutter UI. Focuses on pixel structure, responsive layout, design tokens, assets, and no-backend MVP screens.
---
# Flutter UI From Design References

## Workflow
1. Inventory all screens/assets before coding.
2. Define design tokens first: colors, spacing, typography, radii, shadows.
3. Build shared widgets before screens.
4. Use Material 3 by default unless the project chooses another design system.
5. Keep backend/API calls out of UI-only work unless explicitly requested.
6. Run `flutter analyze`, widget tests for reusable widgets, and manual screenshot comparison.

## Required output for tasks
- Why this task exists.
- Expected result.
- Possible bugs.
- Fix strategy.
- Verification command or manual check.
- Stop condition.
'@

    Write-Skill -Name "ui-only-prototype-guardrails" -Markdown @'
---
name: ui-only-prototype-guardrails
description: Use before implementing or reviewing this project's Flutter prototype. Enforces UI-only, native widgets, responsive mobile sizes, and RTL/LTR readiness.
---
# UI-only Flutter Prototype Guardrails

## Hard rules
- No backend implementation.
- No Firebase.
- No real authentication.
- No database.
- No API calls.
- No WebView.
- Rebuild screens as native Flutter widgets.
- Reuse components instead of duplicating UI.
- Validate 360x800, 375x812, and 390x844.
- Arabic RTL and English LTR ready.

## Review checks
1. Search for network/database/auth/WebView imports before finalizing.
2. Check common widgets are extracted into shared components.
3. Check text direction and localization readiness.
4. Run compile/static checks required by the plan.
'@

    Write-Skill -Name "agent-tooling-audit" -Markdown @'
---
name: agent-tooling-audit
description: Use before adding new agent skills, MCP servers, CLIs, or automation tools. Checks necessity, install method, security risk, token/context impact, and project fit.
---
# Agent Tooling Audit

## Checklist
1. Is this a real project need or just a shiny tool?
2. Is it an instruction skill, an executable tool, a Flutter package, or a reference repo?
3. Does it require secrets, broad filesystem access, browser control, or network access?
4. Can it be installed per-project instead of globally?
5. Does it duplicate an existing skill?
6. Add it to `docs/agent-playbooks/tooling-inventory.md` with install command, purpose, verification, and uninstall command.
'@
}

function Write-AgentWorkflow {
    $workflow = @'
---
description: Practical development workflow for Codex/Antigravity in this repo.
---
# Development Workflow

## Phase 0: Understand context
- Read `AGENTS.md`.
- Read `.specify/memory/constitution.md` if present.
- Check `.agents/skill-matcher.json` and load only relevant skills.
- For Flutter work, prefer official Flutter/Dart skills plus project-specific guardrails.

## Phase 1: Specify
- For meaningful features or ambiguous work, create/update Spec Kit artifacts.
- For tiny mechanical fixes, write a short change note instead of adding ceremony.

## Phase 2: Plan
- Identify affected files, dependencies, risks, verification commands, and acceptance criteria.
- Every task must include why, expected result, possible bugs, fix strategy, verification, and stop condition.

## Phase 3: Implement
- Follow the plan and keep changes scoped.
- For UI-only work: no backend, no Firebase, no real auth, no database, no API calls, no WebView.
- Rebuild screens as native Flutter widgets.
- Reuse components instead of duplicating UI.
- Keep Arabic RTL and English LTR ready.

## Phase 4: Verify
- Flutter: `flutter analyze`, `flutter test`, and targeted screenshot/manual checks for 360x800, 375x812, and 390x844.
- Report commands and outcomes.

## Phase 5: Update project memory
- Update specs/conventions only when architecture, dependencies, routes, design tokens, or long-lived decisions changed.
'@

    foreach ($path in @(".agents\workflows\development.md", ".agent\workflows\development.md")) {
        Write-TextFile -Path (Join-Path $script:ProjectRoot $path) -Content $workflow -Overwrite
    }

    $matcher = @'
{
  "_description": "Maps project tasks to relevant skills. Load only relevant skills to reduce context noise.",
  "matchers": [
    {
      "keywords": ["flutter", "dart", "widget", "screen", "responsive", "layout", "overflow", "material 3"],
      "skills": ["flutter-build-responsive-layout", "flutter-fix-layout-issues", "flutter-ui-from-design", "ui-only-prototype-guardrails", "dart-run-static-analysis"]
    },
    {
      "keywords": ["stitch", "figma", "screenshot", "ui only", "design", "screens", "design tokens"],
      "skills": ["flutter-ui-from-design", "ui-only-prototype-guardrails", "flutter-add-widget-preview", "flutter-add-widget-test"]
    },
    {
      "keywords": ["test", "integration", "qa", "device", "adb", "emulator", "screenshot"],
      "skills": ["mobile-agent-qa", "flutter-add-integration-test", "flutter-add-widget-test", "dart-add-unit-test"]
    },
    {
      "keywords": ["where", "find", "trace", "architecture", "data flow", "implemented"],
      "skills": ["semantic-code-search"]
    },
    {
      "keywords": ["remember", "decision", "convention", "previous", "memory"],
      "skills": ["persistent-memory"]
    },
    {
      "keywords": ["skill", "mcp", "tool", "install", "automation", "agent setup"],
      "skills": ["agent-tooling-audit"]
    },
    {
      "keywords": ["spec", "plan", "tasks", "feature", "build", "implement"],
      "skills": ["speckit-specify", "speckit-plan", "speckit-tasks", "speckit-implement"]
    }
  ]
}
'@
    foreach ($path in @(".agents\skill-matcher.json", ".agent\skill-matcher.json")) {
        Write-TextFile -Path (Join-Path $script:ProjectRoot $path) -Content $matcher -Overwrite
    }

    $agentBlock = @'
# Agent Tooling v3

This repository uses project-local Agent Skills and Spec Kit.

## Before changing code
1. Read `.agents/workflows/development.md`.
2. Check `.agents/skill-matcher.json` and load only relevant skills.
3. Inspect existing project structure and conventions before generating files.
4. For Flutter/Dart work, run `flutter analyze` and `flutter test` when available.

## UI-only Flutter prototype rules
- Do not implement backend.
- Do not implement Firebase.
- Do not implement real authentication.
- Do not implement database.
- Do not implement API calls.
- Do not use WebView.
- Rebuild all screens as native Flutter widgets.
- Reuse shared components instead of duplicating UI.
- Keep layouts responsive for 360x800, 375x812, and 390x844.
- Keep Arabic RTL and English LTR ready.
'@

    Upsert-ManagedBlock -Path (Join-Path $script:ProjectRoot "AGENTS.md") -BlockName "AGENT-TOOLING-V3" -Content $agentBlock
    Write-TextFile -Path (Join-Path $script:ProjectRoot ".agents\MANDATORY_RULES.md") -Content $agentBlock -Overwrite
    Write-TextFile -Path (Join-Path $script:ProjectRoot ".agent\MANDATORY_RULES.md") -Content $agentBlock -Overwrite
}

function Write-ToolingInventory {
    $content = @'
# Agent Tooling Inventory

## Agent skill packs
- `openai/skills`: general Codex skills.
- `flutter/skills`: official Flutter task skills.
- `dart-lang/skills`: official Dart task skills.
- `nank1ro/flutter-shadcn-ui`: shadcn-style Flutter UI reference/skill if compatible with `npx skills`.
- `phuryn/pm-skills`: project/product management skills.
- `obra/superpowers`: planning, debugging, TDD, and verification workflows.
- `Dimillian/Skills`: community skills from the original setup script.
- `googleworkspace/cli`: Google Workspace CLI skills from the original setup script.

## Global CLIs
- `osgrep`: semantic code search.
- `portless`: stable named local URLs.
- `memsearch`: persistent project memory.
- `mobilerun`: exploratory mobile automation if available.
- `flutter_gen`: generated asset references.
- `very_good_cli`: Flutter/Dart project quality scaffolding and checks.
- `patrol_cli`: mobile integration testing CLI.

## Flutter UI packages added when pubspec.yaml exists
- Runtime: `go_router`, `fl_chart`, `lucide_icons_flutter`, `flutter_svg`, `flutter_animate`, `forui`, `shadcn_ui`, `responsive_framework`.
- Dev: `widgetbook`, `alchemist`, `patrol`, `flutter_gen_runner`, `build_runner`, `very_good_analysis`.

## Reference repositories
- `Solido/awesome-flutter`: broad Flutter ecosystem list.
- `fluttergems/awesome-open-source-flutter-apps`: open-source Flutter app references.
- `fluttergems/fluttergems`: Flutter Gems catalog source.
- `Hamed233/Awesome-Flutter-Packages`: Flutter package catalog reference.
- `VoltAgent/awesome-agent-skills`: agent skills catalog.
- `forus-labs/forui`: Forui UI library source/docs.
- `VeryGoodOpenSource/very_good_cli`: quality tooling source.
- `widgetbook/widgetbook`: widget catalog source.
- `flutter/samples`: official Flutter samples.
- `gskinnerTeam/flutter_vignettes`: polished animation/UI examples.
- `RIP-Comm/sossoldi`: personal finance UX reference.
- `TNT-Likely/BeeCount`: AI bookkeeping/finance UX reference.
- `am-will/codex-skills`: extra Codex skills examples.
- `jscraik/Agent-Skills`: agent skill governance examples.
- `flutter/genui`: Flutter generative UI research/reference.

## Security and scope rules
- These tools do not authorize backend, Firebase, database, API, or real authentication implementation.
- Reference repos are for learning only. Do not copy code without license review.
- Keep secrets out of repo files.
'@

    Write-TextFile -Path (Join-Path $script:ReportDir "tooling-inventory.md") -Content $content -Overwrite
}

function Save-SetupReport {
    Ensure-Dir $script:ReportDir
    $mdPath = Join-Path $script:ReportDir "setup-agent-skills-report.md"
    $jsonPath = Join-Path $script:ReportDir "setup-agent-skills-report.json"

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# Agent Skills Setup Report") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add(("- Project root: ``{0}``" -f $script:ProjectRoot)) | Out-Null
    $generatedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"
    $lines.Add("- Generated: $generatedAt") | Out-Null
    $lines.Add("- Dry run: $($DryRun.IsPresent)") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("| Status | Area | Name | Role | Details | Fix |") | Out-Null
    $lines.Add("|---|---|---|---|---|---|") | Out-Null

    foreach ($result in $script:Results) {
        $details = ($result.details -replace "\|", "/")
        $fix = ($result.fix -replace "\|", "/")
        $role = ($result.role -replace "\|", "/")
        $lines.Add("| $($result.status) | $($result.area) | $($result.name) | $role | $details | $fix |") | Out-Null
    }

    if (-not $DryRun) {
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($mdPath, ($lines -join "`n") + "`n", $utf8NoBom)
        $json = $script:Results | ConvertTo-Json -Depth 5
        [System.IO.File]::WriteAllText($jsonPath, $json, $utf8NoBom)
    }

    $failCount = @($script:Results | Where-Object { $_.status -eq "FAIL" }).Count
    $warnCount = @($script:Results | Where-Object { $_.status -eq "WARN" }).Count
    $okCount = @($script:Results | Where-Object { $_.status -eq "OK" }).Count
    $skipCount = @($script:Results | Where-Object { $_.status -eq "SKIP" }).Count

    Write-Host ""
    Write-Host "Summary: OK=$okCount WARN=$warnCount FAIL=$failCount SKIP=$skipCount" -ForegroundColor White
    if (-not $DryRun) {
        Write-Host "Report: $mdPath" -ForegroundColor Green
        Write-Host "JSON:   $jsonPath" -ForegroundColor Green
    }
}

Set-Location -LiteralPath $script:ProjectRoot

$pubCacheCandidates = @()
if ($env:LOCALAPPDATA) { $pubCacheCandidates += (Join-Path $env:LOCALAPPDATA "Pub\Cache\bin") }
if ($env:APPDATA) { $pubCacheCandidates += (Join-Path $env:APPDATA "Pub\Cache\bin") }
if ($HOME) { $pubCacheCandidates += (Join-Path $HOME ".pub-cache\bin") }
$pubCacheCandidates = $pubCacheCandidates | Where-Object { $_ -and (Test-Path -LiteralPath $_) }
foreach ($path in $pubCacheCandidates) {
    if ($env:PATH -notlike "*$path*") {
        $env:PATH = "$path;$env:PATH"
    }
}

Write-Title "Agent Skills and Flutter UI Tooling Setup v3"
Write-Host "Project root: $script:ProjectRoot" -ForegroundColor White
Write-Host "Dry run:      $($DryRun.IsPresent)" -ForegroundColor White

Write-Step "[1/9] Create base directories"
@(
    ".agents\skills",
    ".agents\workflows",
    ".agent\skills",
    ".agent\workflows",
    "docs\agent-playbooks",
    "docs\agent-playbooks\references"
) | ForEach-Object { Ensure-Dir (Join-Path $script:ProjectRoot $_) }

Write-Step "[2/9] Install requested agent skill packs"
if ($SkipSkillPacks) {
    Add-Result -Area "skill-pack" -Name "all" -Status "SKIP" -Role "Skill pack installation." -Details "-SkipSkillPacks was used." -Fix ""
} else {
    $skillPacks = @(
        @{ Repo = "openai/skills"; Skill = "*"; Role = "General OpenAI agent skills."; FallbackPlain = $false },
        @{ Repo = "flutter/skills"; Skill = "*"; Role = "Official Flutter skills requested by user."; FallbackPlain = $false },
        @{ Repo = "dart-lang/skills"; Skill = "*"; Role = "Official Dart skills requested by user."; FallbackPlain = $false },
        @{ Repo = "nank1ro/flutter-shadcn-ui"; Skill = ""; Role = "Flutter shadcn UI skill/repo if skills-compatible."; FallbackPlain = $true }
    )

    if (-not $SkipCommunitySkillPacks) {
        $skillPacks += @(
            @{ Repo = "phuryn/pm-skills"; Skill = "*"; Role = "Project/product management skills."; FallbackPlain = $false },
            @{ Repo = "obra/superpowers"; Skill = "*"; Role = "Planning, debugging, and verification workflows."; FallbackPlain = $false },
            @{ Repo = "Dimillian/Skills"; Skill = "*"; Role = "Community skills from the original setup script."; FallbackPlain = $false },
            @{ Repo = "googleworkspace/cli"; Skill = "*"; Role = "Google Workspace CLI skills from the original setup script."; FallbackPlain = $true }
        )
    }

    foreach ($pack in $skillPacks) {
        Install-SkillPack -Repo $pack.Repo -Skill $pack.Skill -Role $pack.Role -FallbackPlain:([bool]$pack.FallbackPlain)
    }
    Sync-UniversalSkillsToAntigravity
}

Write-Step "[3/9] Create project bridge skills"
Write-BridgeSkills
foreach ($skillName in @("semantic-code-search", "persistent-memory", "stable-local-urls", "mobile-agent-qa", "flutter-ui-from-design", "ui-only-prototype-guardrails", "agent-tooling-audit")) {
    Test-ReadableSkill -SkillName $skillName
}

Write-Step "[4/9] Install and verify global CLIs"
if ($SkipGlobalTools) {
    Add-Result -Area "global-tool" -Name "all" -Status "SKIP" -Role "Global CLI installation." -Details "-SkipGlobalTools was used." -Fix ""
} else {
    Install-NpmGlobal -Package "osgrep" -Role "Semantic code search." -CheckCommand "osgrep --help"
    Install-NpmGlobal -Package "portless" -Role "Stable named localhost URLs." -CheckCommand "portless --help"
    Install-UvTool -Package "memsearch" -Role "Persistent project memory." -Executable "memsearch"
    Install-UvTool -Package "mobilerun" -Role "Exploratory mobile automation if package exists." -Executable "mobilerun"
    Install-DartGlobal -Package "flutter_gen" -Role "Generated asset references." -CheckFile "dart" -CheckArgs @("pub", "global", "run", "flutter_gen:flutter_gen_command", "-v")
    Install-DartGlobal -Package "very_good_cli" -Role "Flutter/Dart quality tooling." -CheckFile "very_good" -CheckArgs @("--version")
    Install-DartGlobal -Package "patrol_cli" -Role "Mobile integration testing CLI." -CheckFile "patrol" -CheckArgs @("--version")
}

Write-Step "[5/9] Ensure Spec Kit"
if ($SkipSpecKit) {
    Add-Result -Area "speckit" -Name "all" -Status "SKIP" -Role "Spec Kit setup." -Details "-SkipSpecKit was used." -Fix ""
} else {
    Ensure-SpecKit
}

Write-Step "[6/9] Add Flutter UI-only packages when pubspec.yaml exists"
if ($SkipFlutterPackages) {
    Add-Result -Area "flutter-package" -Name "all" -Status "SKIP" -Role "Flutter package installation." -Details "-SkipFlutterPackages was used." -Fix ""
} else {
    Add-FlutterPackages
}

Write-Step "[7/9] Sync reference repositories and catalog links"
if ($SkipReferenceRepos) {
    Add-Result -Area "reference-repo" -Name "all" -Status "SKIP" -Role "Reference repo sync." -Details "-SkipReferenceRepos was used." -Fix ""
} else {
    Sync-ReferenceRepo -Repo "Solido/awesome-flutter" -Role "Broad Flutter ecosystem and package catalog."
    Sync-ReferenceRepo -Repo "fluttergems/awesome-open-source-flutter-apps" -Role "Open-source Flutter apps catalog."
    Sync-ReferenceRepo -Repo "fluttergems/fluttergems" -Role "Flutter Gems catalog source and package taxonomy." -Large
    Sync-ReferenceRepo -Repo "Hamed233/Awesome-Flutter-Packages" -Role "Awesome Flutter packages reference."
    Sync-ReferenceRepo -Repo "VoltAgent/awesome-agent-skills" -Role "Agent skills discovery catalog."
    Sync-ReferenceRepo -Repo "forus-labs/forui" -Role "Forui minimal Flutter UI library source/docs."
    Sync-ReferenceRepo -Repo "VeryGoodOpenSource/very_good_cli" -Role "Very Good CLI source and conventions."
    Sync-ReferenceRepo -Repo "widgetbook/widgetbook" -Role "Widgetbook component catalog source/docs." -Large
    Sync-ReferenceRepo -Repo "flutter/samples" -Role "Official Flutter samples." -Large
    Sync-ReferenceRepo -Repo "gskinnerTeam/flutter_vignettes" -Role "Polished Flutter UI and animation examples." -Large
    Sync-ReferenceRepo -Repo "RIP-Comm/sossoldi" -Role "Personal finance Flutter UX reference."
    Sync-ReferenceRepo -Repo "TNT-Likely/BeeCount" -Role "AI bookkeeping and finance UX reference."
    Sync-ReferenceRepo -Repo "am-will/codex-skills" -Role "Additional Codex skill examples and workflows."
    Sync-ReferenceRepo -Repo "jscraik/Agent-Skills" -Role "Agent skill organization and governance examples."
    Sync-ReferenceRepo -Repo "flutter/genui" -Role "Flutter generative UI research/reference. Reference only, not required for prototype implementation." -Large

    Write-ReferenceNote -FileName "flutter-gems-animation-transition.md" -Title "Flutter Gems Animation and Transition" -Url "https://fluttergems.dev/animation-transition/" -Role "Package discovery for animation/transition effects. Reference only."
    Write-ReferenceNote -FileName "forui-package.md" -Title "Forui Package" -Url "https://pub.dev/packages/forui" -Role "Minimalistic Flutter UI library package reference."
    Write-ReferenceNote -FileName "awesome-flutter-packages-search.md" -Title "Awesome Flutter Packages" -Url "https://github.com/search?q=awesome+flutter+packages&type=repositories" -Role "Search entry for multiple awesome package lists. Prefer audited repos over copying snippets."
}

Write-Step "[8/9] Write workflow, matcher, inventory, and keep Git tracking open"
Write-AgentWorkflow
Write-ToolingInventory
@(
    ".osgrep/",
    ".memsearch/",
    ".mobilerun/",
    ".portless/",
    ".dart_tool/",
    "build/",
    "docs/agent-playbooks/references/",
    "docs/agent-playbooks/references/**/.git/"
) | ForEach-Object { Remove-GitIgnoreEntry $_ }

Write-Step "[9/9] Final verification summary"
if (Test-Cmd "flutter") {
    Invoke-CheckedTool -Area "verify-tool" -Name "flutter" -File "flutter" -Arguments @("--version") -Role "Flutter SDK available." -Fix "Install Flutter SDK or add it to PATH." -AllowFailure | Out-Null
}
if (Test-Cmd "dart") {
    Invoke-CheckedTool -Area "verify-tool" -Name "dart" -File "dart" -Arguments @("--version") -Role "Dart SDK available." -Fix "Install Dart/Flutter SDK or add it to PATH." -AllowFailure | Out-Null
}
if (Test-Cmd "npx") {
    Invoke-CheckedTool -Area "verify-tool" -Name "npx" -File "npx" -Arguments @("--version") -Role "Skills CLI runner available." -Fix "Install Node.js LTS." -AllowFailure | Out-Null
}
if (Test-Cmd "uv") {
    Invoke-CheckedTool -Area "verify-tool" -Name "uv" -File "uv" -Arguments @("--version") -Role "Python tool installer available." -Fix "Install uv." -AllowFailure | Out-Null
}

Save-SetupReport

$failed = ($script:Results | Where-Object { $_.status -eq "FAIL" }).Count
if ($failed -gt 0) {
    Write-Host ""
    Write-Host "Setup finished with $failed failed item(s). See the report for exact reasons and fixes." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green
