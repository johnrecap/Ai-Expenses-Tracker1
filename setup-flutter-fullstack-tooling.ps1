<#
.SYNOPSIS
  Flutter full-stack tooling and reference repository setup.

.DESCRIPTION
  Creates a repeatable setup for Flutter projects that may include frontend,
  backend, BaaS integrations, local storage, testing, CI, and agent skills.

  This script is intentionally separate from the UI-only prototype script.
  Use it for projects where backend/API/database/auth work is explicitly allowed.

.USAGE
  # Safe catalog/reference setup only
  pwsh -ExecutionPolicy Bypass -File .\setup-flutter-fullstack-tooling.ps1

  # Install frontend packages into the current Flutter app if pubspec.yaml exists
  pwsh -ExecutionPolicy Bypass -File .\setup-flutter-fullstack-tooling.ps1 -Profile Frontend -ApplyPubPackages

  # Install backend packages into the current Dart backend package if pubspec.yaml exists
  pwsh -ExecutionPolicy Bypass -File .\setup-flutter-fullstack-tooling.ps1 -Profile Backend -ApplyPubPackages

  # Full-stack reference + tools + packages. Use only in a planned full-stack repo.
  pwsh -ExecutionPolicy Bypass -File .\setup-flutter-fullstack-tooling.ps1 -Profile FullStack -ApplyPubPackages

  # Test without changing anything
  pwsh -ExecutionPolicy Bypass -File .\setup-flutter-fullstack-tooling.ps1 -DryRun -Profile FullStack
#>

[CmdletBinding()]
param(
    [string]$ProjectPath = (Get-Location).Path,
    [ValidateSet("ReferenceOnly", "Frontend", "Backend", "FullStack")]
    [string]$Profile = "ReferenceOnly",
    [switch]$ApplyPubPackages,
    [switch]$DryRun,
    [switch]$SkipAgentSkills,
    [switch]$SkipGlobalTools,
    [switch]$SkipReferenceRepos,
    [switch]$IncludeLargeReferenceRepos,
    [switch]$SkipReports
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$script:ProjectRoot = [System.IO.Path]::GetFullPath($ProjectPath)
$script:ReportDir = Join-Path $script:ProjectRoot "docs\agent-playbooks"
$script:ReferenceRoot = Join-Path $script:ReportDir "flutter-fullstack-references"
$script:Results = New-Object "System.Collections.Generic.List[object]"

function Write-Title {
    param([string]$Text)
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}

function Write-Step {
    param([string]$Text)
    Write-Host ""
    Write-Host $Text -ForegroundColor Yellow
}

function Test-Cmd {
    param([string]$Name)
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Ensure-Dir {
    param([string]$Path)
    if (Test-Path -LiteralPath $Path) { return }
    if ($DryRun) {
        Write-Host "  DRYRUN mkdir $Path" -ForegroundColor DarkGray
        return
    }
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
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
        [string]$Area,
        [string]$Name,
        [string]$File,
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
        $text = (($output | Select-Object -First 8) -join " ").Trim()
        if ($exitCode -eq 0) {
            Add-Result -Area $Area -Name $Name -Status "OK" -Role $Role -Command $commandLine -Details $text -Fix ""
            return $true
        }
        Add-Result -Area $Area -Name $Name -Status "FAIL" -Role $Role -Command $commandLine -Details "Exit code $exitCode. $text" -Fix $Fix
        if (-not $AllowFailure) { throw "$commandLine failed" }
        return $false
    } catch {
        Add-Result -Area $Area -Name $Name -Status "FAIL" -Role $Role -Command $commandLine -Details $_.Exception.Message -Fix $Fix
        if (-not $AllowFailure) { throw }
        return $false
    }
}

function Write-TextFile {
    param([string]$Path, [string]$Content)
    $dir = Split-Path -Path $Path -Parent
    if ($dir) { Ensure-Dir $dir }
    if ($DryRun) {
        Add-Result -Area "file" -Name $Path -Status "SKIP" -Role "Would write file." -Details "Dry run only." -Fix ""
        return
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText([System.IO.Path]::GetFullPath($Path), $Content, $utf8NoBom)
    Add-Result -Area "file" -Name $Path -Status "OK" -Role "Wrote UTF-8 file." -Details "" -Fix ""
}

function Remove-GitIgnoreEntry {
    param([string]$Entry)
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

function Install-SkillPack {
    param([string]$Repo, [string]$Role, [string]$Skill = "*")
    if (-not (Test-Cmd "npx")) {
        Add-Result -Area "skill-pack" -Name $Repo -Status "FAIL" -Role $Role -Command "npx -y skills add $Repo" -Details "npx was not found." -Fix "Install Node.js LTS."
        return
    }
    $args = @("-y", "skills", "add", $Repo)
    if ($Skill -and $Skill.Length -gt 0) { $args += @("--skill", $Skill) }
    $args += @("--agent", "universal", "--yes")
    Invoke-CheckedTool -Area "skill-pack" -Name $Repo -File "npx" -Arguments $args -Role $Role -Fix "Confirm the repo exposes Agent Skills and that npm/GitHub are reachable." -AllowFailure | Out-Null
}

function Install-DartGlobal {
    param([string]$Package, [string]$Executable, [string]$Role)
    if (-not (Test-Cmd "dart")) {
        Add-Result -Area "global-tool" -Name $Package -Status "FAIL" -Role $Role -Command "dart pub global activate $Package" -Details "dart was not found." -Fix "Install Flutter/Dart SDK."
        return
    }
    Invoke-CheckedTool -Area "global-tool" -Name $Package -File "dart" -Arguments @("pub", "global", "activate", $Package) -Role $Role -Fix "Check pub.dev/network access and package compatibility." -AllowFailure | Out-Null
    Invoke-CheckedTool -Area "verify-tool" -Name $Package -File $Executable -Arguments @("--version") -Role $Role -Fix "Add Pub Cache bin to PATH or verify the executable name." -AllowFailure | Out-Null
}

function Install-NpmGlobal {
    param([string]$Package, [string]$Executable, [string]$Role)
    if (-not (Test-Cmd "npm")) {
        Add-Result -Area "global-tool" -Name $Package -Status "FAIL" -Role $Role -Command "npm install -g $Package" -Details "npm was not found." -Fix "Install Node.js LTS."
        return
    }
    Invoke-CheckedTool -Area "global-tool" -Name $Package -File "npm" -Arguments @("install", "-g", $Package) -Role $Role -Fix "Check npm registry/network access." -AllowFailure | Out-Null
    Invoke-CheckedTool -Area "verify-tool" -Name $Package -File $Executable -Arguments @("--version") -Role $Role -Fix "Add npm global bin to PATH or verify the executable name." -AllowFailure | Out-Null
}

function Install-UvTool {
    param([string]$Package, [string]$Executable, [string]$Role)
    if (-not (Test-Cmd "uv")) {
        Add-Result -Area "global-tool" -Name $Package -Status "FAIL" -Role $Role -Command "uv tool install $Package" -Details "uv was not found." -Fix "Install uv."
        return
    }
    Invoke-CheckedTool -Area "global-tool" -Name $Package -File "uv" -Arguments @("tool", "install", $Package) -Role $Role -Fix "Check PyPI/network access or package name." -AllowFailure | Out-Null
    Invoke-CheckedTool -Area "verify-tool" -Name $Package -File $Executable -Arguments @("--help") -Role $Role -Fix "Add uv tool bin to PATH or verify the executable name." -AllowFailure | Out-Null
}

function Sync-ReferenceRepo {
    param(
        [string]$Repo,
        [string]$Category,
        [string]$Role,
        [switch]$Large,
        [switch]$AllowFailure
    )

    if ($Large -and -not $IncludeLargeReferenceRepos) {
        Add-Result -Area "reference-repo" -Name $Repo -Status "SKIP" -Role "$Category - $Role" -Details "Large repo skipped. Use -IncludeLargeReferenceRepos to clone it." -Fix ""
        return
    }
    if (-not (Test-Cmd "git")) {
        Add-Result -Area "reference-repo" -Name $Repo -Status "FAIL" -Role "$Category - $Role" -Command "git clone https://github.com/$Repo.git" -Details "git was not found." -Fix "Install Git."
        return
    }

    Ensure-Dir $script:ReferenceRoot
    $safeName = $Repo.Replace("/", "__")
    $target = Join-Path $script:ReferenceRoot $safeName
    $url = "https://github.com/$Repo.git"

    if (Test-Path -LiteralPath $target) {
        if (Test-Path -LiteralPath (Join-Path $target ".git")) {
            Invoke-CheckedTool -Area "reference-repo" -Name $Repo -File "git" -Arguments @("-C", $target, "pull", "--ff-only") -Role "$Category - $Role" -Fix "Remove local reference changes or archive the folder, then retry." -AllowFailure | Out-Null
        } else {
            Add-Result -Area "reference-repo" -Name $Repo -Status "OK" -Role "$Category - $Role" -Details "Reference folder already exists as vendored files without nested .git metadata." -Fix ""
        }
    } else {
        $ok = Invoke-CheckedTool -Area "reference-repo" -Name $Repo -File "git" -Arguments @("clone", "--depth", "1", "--filter=blob:none", $url, $target) -Role "$Category - $Role" -Fix "Check GitHub/network access. If partial clone fails, try a normal shallow clone." -AllowFailure
        if (-not $ok -and -not $DryRun -and -not $AllowFailure) {
            Invoke-CheckedTool -Area "reference-repo" -Name "$Repo fallback" -File "git" -Arguments @("clone", "--depth", "1", $url, $target) -Role "$Category - $Role" -Fix "Confirm repo exists and network can reach GitHub." -AllowFailure | Out-Null
        }
    }

    Remove-ReferenceGitMetadata -Root $target -Repo $Repo
    if (-not $DryRun -and (Test-Path -LiteralPath $target)) {
        $readme = Get-ChildItem -LiteralPath $target -Filter "README*" -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($readme) {
            Add-Result -Area "verify-reference" -Name $Repo -Status "OK" -Role "$Category - $Role" -Details "Readable: $($readme.FullName)" -Fix ""
        } else {
            Add-Result -Area "verify-reference" -Name $Repo -Status "WARN" -Role "$Category - $Role" -Details "Cloned but README was not found at root." -Fix "Inspect repository structure manually."
        }
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

function Add-PubPackages {
    param([string[]]$Runtime, [string[]]$Dev, [string]$Role)
    $pubspec = Join-Path $script:ProjectRoot "pubspec.yaml"
    if (-not (Test-Path -LiteralPath $pubspec)) {
        Add-Result -Area "pub-packages" -Name $Profile -Status "SKIP" -Role $Role -Details "No pubspec.yaml found in $script:ProjectRoot." -Fix "Run from the intended Flutter/Dart package root or pass -ProjectPath."
        return
    }

    $tool = if (Test-Cmd "flutter") { "flutter" } elseif (Test-Cmd "dart") { "dart" } else { "" }
    if (-not $tool) {
        Add-Result -Area "pub-packages" -Name $Profile -Status "FAIL" -Role $Role -Details "Neither flutter nor dart was found." -Fix "Install Flutter/Dart SDK."
        return
    }

    if ($Runtime.Count -gt 0) {
        $args = if ($tool -eq "flutter") { @("pub", "add") + $Runtime } else { @("pub", "add") + $Runtime }
        Invoke-CheckedTool -Area "pub-packages" -Name "$Profile runtime" -File $tool -Arguments $args -Role $Role -Fix "Resolve version conflicts or remove packages not needed for this package root." -AllowFailure | Out-Null
    }
    if ($Dev.Count -gt 0) {
        $args = if ($tool -eq "flutter") { @("pub", "add", "--dev") + $Dev } else { @("pub", "add", "--dev") + $Dev }
        Invoke-CheckedTool -Area "pub-packages" -Name "$Profile dev" -File $tool -Arguments $args -Role $Role -Fix "Resolve version conflicts or remove packages not needed for this package root." -AllowFailure | Out-Null
    }
    Invoke-CheckedTool -Area "pub-packages" -Name "pub get" -File $tool -Arguments @("pub", "get") -Role "Resolve dependencies." -Fix "Inspect dependency solver output." -AllowFailure | Out-Null
}

function Get-PackageSet {
    $frontendRuntime = @(
        "go_router",
        "flutter_riverpod",
        "hooks_riverpod",
        "riverpod_annotation",
        "flutter_bloc",
        "get_it",
        "injectable",
        "dio",
        "retrofit",
        "json_annotation",
        "freezed_annotation",
        "equatable",
        "intl",
        "flex_color_scheme",
        "flutter_svg",
        "cached_network_image",
        "flutter_animate",
        "fl_chart",
        "lucide_icons_flutter",
        "forui",
        "shadcn_ui",
        "responsive_framework",
        "formz",
        "reactive_forms",
        "permission_handler",
        "url_launcher",
        "connectivity_plus",
        "package_info_plus",
        "device_info_plus",
        "path_provider",
        "shared_preferences",
        "flutter_secure_storage",
        "flutter_local_notifications"
    )

    $frontendDev = @(
        "build_runner",
        "riverpod_generator",
        "custom_lint",
        "riverpod_lint",
        "freezed",
        "json_serializable",
        "retrofit_generator",
        "injectable_generator",
        "very_good_analysis",
        "widgetbook",
        "alchemist",
        "patrol",
        "mocktail"
    )

    $backendRuntime = @(
        "serverpod",
        "serverpod_client",
        "dart_frog",
        "shelf",
        "shelf_router",
        "shelf_cors_headers",
        "http",
        "postgres",
        "redis",
        "grpc",
        "protobuf",
        "crypto",
        "dart_jsonwebtoken",
        "bcrypt",
        "drift",
        "drift_flutter",
        "sqlite3_flutter_libs",
        "objectbox",
        "objectbox_flutter_libs",
        "firebase_core",
        "firebase_auth",
        "cloud_firestore",
        "firebase_storage",
        "cloud_functions",
        "firebase_messaging",
        "firebase_crashlytics",
        "firebase_analytics",
        "firebase_remote_config",
        "supabase_flutter",
        "appwrite"
    )

    $backendDev = @(
        "build_runner",
        "drift_dev",
        "objectbox_generator",
        "serverpod_test",
        "test",
        "mocktail",
        "very_good_analysis"
    )

    if ($Profile -eq "Frontend") {
        return [pscustomobject]@{ Runtime = $frontendRuntime; Dev = $frontendDev; Role = "Frontend Flutter app packages." }
    }
    if ($Profile -eq "Backend") {
        return [pscustomobject]@{ Runtime = $backendRuntime; Dev = $backendDev; Role = "Backend/BaaS/Dart server packages. Run from backend package root." }
    }
    if ($Profile -eq "FullStack") {
        return [pscustomobject]@{ Runtime = @($frontendRuntime + $backendRuntime | Select-Object -Unique); Dev = @($frontendDev + $backendDev | Select-Object -Unique); Role = "Full-stack package set. Use only in a planned full-stack package/root." }
    }
    return [pscustomobject]@{ Runtime = @(); Dev = @(); Role = "Reference-only profile; no pub packages." }
}

function Write-Inventory {
    $content = @"
# Flutter Full-stack Tooling Inventory

Generated by `setup-flutter-fullstack-tooling.ps1`.

## Profiles
- `ReferenceOnly`: clone/sync reference repositories and write docs only.
- `Frontend`: Flutter UI, routing, state, networking client, forms, device APIs, local preferences, testing.
- `Backend`: Dart backend frameworks, BaaS clients, local database, auth/security helpers, backend tests.
- `FullStack`: frontend + backend package sets. Use deliberately because it is broad.

## Important Scope Rule
This script is for full-stack projects. Do not run `-ApplyPubPackages` in a UI-only prototype unless backend/API/database/auth is explicitly approved.

## Key Reference Categories
- Core Flutter/Dart: official Flutter, samples, packages, Dart SDK/tools.
- Frontend architecture: Riverpod, Bloc, go_router, GetIt, codegen.
- UI/design: Forui, shadcn_ui, Widgetbook, animations, charts, SVG, responsive utilities.
- API/network: http, Dio, Retrofit, GraphQL/gRPC/protobuf.
- Local data: Drift/SQLite, ObjectBox, Hive as a legacy/reference option.
- Backend: Serverpod, Dart Frog, Shelf, gRPC.
- BaaS: FlutterFire/Firebase, Supabase, Appwrite, Amplify Flutter.
- Testing/quality: Patrol, Alchemist, Very Good CLI, Melos, Mason.
"@
    Write-TextFile -Path (Join-Path $script:ReportDir "flutter-fullstack-tooling-inventory.md") -Content $content
}

function Save-Report {
    if ($SkipReports) { return }
    Ensure-Dir $script:ReportDir
    $mdPath = Join-Path $script:ReportDir "flutter-fullstack-tooling-report.md"
    $jsonPath = Join-Path $script:ReportDir "flutter-fullstack-tooling-report.json"

    $generatedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"
    $lines = New-Object "System.Collections.Generic.List[string]"
    $lines.Add("# Flutter Full-stack Tooling Report") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add(("- Project root: ``{0}``" -f $script:ProjectRoot)) | Out-Null
    $lines.Add(("- Profile: ``{0}``" -f $Profile)) | Out-Null
    $lines.Add(("- Apply pub packages: {0}" -f $ApplyPubPackages.IsPresent)) | Out-Null
    $lines.Add("- Generated: $generatedAt") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("| Status | Area | Name | Role | Details | Fix |") | Out-Null
    $lines.Add("|---|---|---|---|---|---|") | Out-Null
    foreach ($r in $script:Results) {
        $role = ($r.role -replace "\|", "/")
        $details = ($r.details -replace "\|", "/")
        $fix = ($r.fix -replace "\|", "/")
        $lines.Add("| $($r.status) | $($r.area) | $($r.name) | $role | $details | $fix |") | Out-Null
    }

    if (-not $DryRun) {
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($mdPath, ($lines -join "`n") + "`n", $utf8NoBom)
        [System.IO.File]::WriteAllText($jsonPath, ($script:Results | ConvertTo-Json -Depth 5), $utf8NoBom)
    }

    $ok = @($script:Results | Where-Object { $_.status -eq "OK" }).Count
    $warn = @($script:Results | Where-Object { $_.status -eq "WARN" }).Count
    $fail = @($script:Results | Where-Object { $_.status -eq "FAIL" }).Count
    $skip = @($script:Results | Where-Object { $_.status -eq "SKIP" }).Count
    Write-Host ""
    Write-Host "Summary: OK=$ok WARN=$warn FAIL=$fail SKIP=$skip" -ForegroundColor White
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
foreach ($path in ($pubCacheCandidates | Where-Object { $_ -and (Test-Path -LiteralPath $_) })) {
    if ($env:PATH -notlike "*$path*") { $env:PATH = "$path;$env:PATH" }
}

Write-Title "Flutter Full-stack Tooling Setup"
Write-Host "Project root: $script:ProjectRoot" -ForegroundColor White
Write-Host "Profile:      $Profile" -ForegroundColor White
Write-Host "Dry run:      $($DryRun.IsPresent)" -ForegroundColor White

Write-Step "[1/7] Create base directories"
Ensure-Dir $script:ReportDir
Ensure-Dir $script:ReferenceRoot

Write-Step "[2/7] Install agent skill packs"
if ($SkipAgentSkills) {
    Add-Result -Area "skill-pack" -Name "all" -Status "SKIP" -Role "Agent skill installation." -Details "-SkipAgentSkills was used." -Fix ""
} else {
    $skillPacks = @(
        @{ Repo = "openai/skills"; Role = "General OpenAI agent skills."; Skill = "*" },
        @{ Repo = "flutter/skills"; Role = "Official Flutter skills."; Skill = "*" },
        @{ Repo = "dart-lang/skills"; Role = "Official Dart skills."; Skill = "*" },
        @{ Repo = "nank1ro/flutter-shadcn-ui"; Role = "Flutter shadcn UI skill/repo if skills-compatible."; Skill = "" },
        @{ Repo = "phuryn/pm-skills"; Role = "Planning/product-management skills."; Skill = "*" },
        @{ Repo = "obra/superpowers"; Role = "Planning, debugging, TDD, verification workflows."; Skill = "*" },
        @{ Repo = "Dimillian/Skills"; Role = "Community skill pack from the older setup script."; Skill = "*" },
        @{ Repo = "googleworkspace/cli"; Role = "Google Workspace CLI skills from the older setup script."; Skill = "*" }
    )
    foreach ($pack in $skillPacks) {
        Install-SkillPack -Repo $pack.Repo -Role $pack.Role -Skill $pack.Skill
    }
}

Write-Step "[3/7] Install global CLIs"
if ($SkipGlobalTools) {
    Add-Result -Area "global-tool" -Name "all" -Status "SKIP" -Role "Global CLI installation." -Details "-SkipGlobalTools was used." -Fix ""
} else {
    Install-DartGlobal -Package "very_good_cli" -Executable "very_good" -Role "Flutter/Dart project quality tooling."
    Install-DartGlobal -Package "melos" -Executable "melos" -Role "Dart/Flutter monorepo orchestration."
    Install-DartGlobal -Package "mason_cli" -Executable "mason" -Role "Code generation templates/bricks."
    Install-DartGlobal -Package "flutter_gen" -Executable "fluttergen" -Role "Generated Flutter asset accessors."
    Install-DartGlobal -Package "patrol_cli" -Executable "patrol" -Role "Flutter UI/integration testing CLI."
    Install-DartGlobal -Package "dart_frog_cli" -Executable "dart_frog" -Role "Dart Frog backend CLI."
    Install-DartGlobal -Package "serverpod_cli" -Executable "serverpod" -Role "Serverpod full-stack Dart backend CLI."
    Install-DartGlobal -Package "flutterfire_cli" -Executable "flutterfire" -Role "Firebase/FlutterFire configuration CLI."
    Install-NpmGlobal -Package "firebase-tools" -Executable "firebase" -Role "Firebase project/emulator/deploy CLI."
    Install-NpmGlobal -Package "supabase" -Executable "supabase" -Role "Supabase local development/deploy CLI when npm package is available."
    Install-NpmGlobal -Package "appwrite-cli" -Executable "appwrite" -Role "Appwrite project CLI."
    Install-NpmGlobal -Package "osgrep" -Executable "osgrep" -Role "Semantic code search."
    Install-NpmGlobal -Package "portless" -Executable "portless" -Role "Stable named local URLs."
    Install-UvTool -Package "memsearch" -Executable "memsearch" -Role "Persistent project memory."
    Install-UvTool -Package "mobilerun" -Executable "mobilerun" -Role "Mobile device automation."
}

Write-Step "[4/7] Sync reference repositories"
if ($SkipReferenceRepos) {
    Add-Result -Area "reference-repo" -Name "all" -Status "SKIP" -Role "Reference repo sync." -Details "-SkipReferenceRepos was used." -Fix ""
} else {
    $repos = @(
        @{ Repo = "flutter/flutter"; Category = "core"; Role = "Flutter framework source."; Large = $true },
        @{ Repo = "flutter/samples"; Category = "core"; Role = "Official runnable Flutter samples."; Large = $true },
        @{ Repo = "flutter/packages"; Category = "core"; Role = "Official Flutter packages including go_router, camera, url_launcher, google_maps_flutter."; Large = $true },
        @{ Repo = "dart-lang/sdk"; Category = "core"; Role = "Dart SDK source/reference."; Large = $true },
        @{ Repo = "dart-lang/http"; Category = "network"; Role = "Official composable Dart HTTP client." },
        @{ Repo = "dart-lang/build"; Category = "codegen"; Role = "Dart build system/build_runner ecosystem." },
        @{ Repo = "google/json_serializable.dart"; Category = "codegen"; Role = "JSON serialization generator." },
        @{ Repo = "rrousselGit/riverpod"; Category = "frontend"; Role = "Riverpod state management." },
        @{ Repo = "rrousselGit/freezed"; Category = "codegen"; Role = "Immutable models/unions/codegen." },
        @{ Repo = "felangel/bloc"; Category = "frontend"; Role = "Bloc/Cubit state management." },
        @{ Repo = "fluttercommunity/get_it"; Category = "frontend"; Role = "Service locator/dependency injection." },
        @{ Repo = "cfug/dio"; Category = "network"; Role = "Dio HTTP client and adapters." },
        @{ Repo = "trevorwang/retrofit.dart"; Category = "network"; Role = "Dio REST client generator." },
        @{ Repo = "gql-dart/gql"; Category = "network"; Role = "GraphQL libraries for Dart." },
        @{ Repo = "grpc/grpc-dart"; Category = "network"; Role = "gRPC for Dart." },
        @{ Repo = "forus-labs/forui"; Category = "ui"; Role = "Minimal Flutter UI library." },
        @{ Repo = "nank1ro/flutter-shadcn-ui"; Category = "ui"; Role = "Flutter shadcn-style UI reference."; AllowFailure = $true },
        @{ Repo = "widgetbook/widgetbook"; Category = "ui"; Role = "Widget catalog/design system tooling."; Large = $true },
        @{ Repo = "imaNNeo/fl_chart"; Category = "ui"; Role = "Flutter charts." },
        @{ Repo = "gskinner/flutter_animate"; Category = "ui"; Role = "Animation helpers." },
        @{ Repo = "dnfield/flutter_svg"; Category = "ui"; Role = "SVG rendering for Flutter." },
        @{ Repo = "Baseflow/flutter_cached_network_image"; Category = "ui"; Role = "Network image caching." },
        @{ Repo = "MaikuB/flutter_local_notifications"; Category = "device"; Role = "Local notifications plugin." },
        @{ Repo = "Baseflow/flutter-permission-handler"; Category = "device"; Role = "Permission handling plugin." },
        @{ Repo = "fluttercommunity/plus_plugins"; Category = "device"; Role = "Connectivity, device info, package info and other plus plugins." },
        @{ Repo = "simolus3/drift"; Category = "data"; Role = "Reactive SQLite persistence." },
        @{ Repo = "objectbox/objectbox-dart"; Category = "data"; Role = "ObjectBox local database/vector support." },
        @{ Repo = "isar/isar"; Category = "data"; Role = "Isar database reference; evaluate maintenance before adopting."; AllowFailure = $true },
        @{ Repo = "hivedb/hive"; Category = "data"; Role = "Hive key-value database legacy/reference; evaluate maintenance before adopting."; AllowFailure = $true },
        @{ Repo = "serverpod/serverpod"; Category = "backend"; Role = "Full-stack Dart backend for Flutter." },
        @{ Repo = "dart-frog-dev/dart_frog"; Category = "backend"; Role = "Minimal Dart backend framework." },
        @{ Repo = "dart-frog-dev/awesome_dart_frog"; Category = "backend"; Role = "Dart Frog ecosystem catalog." },
        @{ Repo = "dart-lang/shelf"; Category = "backend"; Role = "Dart server middleware foundation." },
        @{ Repo = "firebase/flutterfire"; Category = "baas"; Role = "Official Firebase plugins for Flutter."; Large = $true },
        @{ Repo = "firebase/FirebaseUI-Flutter"; Category = "baas"; Role = "Firebase UI widgets/auth helpers."; AllowFailure = $true },
        @{ Repo = "supabase/supabase-flutter"; Category = "baas"; Role = "Official Supabase Flutter SDK." },
        @{ Repo = "supabase/supabase"; Category = "baas"; Role = "Supabase platform source/reference."; Large = $true },
        @{ Repo = "appwrite/sdk-for-flutter"; Category = "baas"; Role = "Official Appwrite Flutter SDK." },
        @{ Repo = "appwrite/appwrite"; Category = "baas"; Role = "Self-hostable Appwrite backend platform."; Large = $true },
        @{ Repo = "aws-amplify/amplify-flutter"; Category = "baas"; Role = "AWS Amplify Flutter libraries."; Large = $true },
        @{ Repo = "leancodepl/patrol"; Category = "testing"; Role = "Flutter-first E2E/UI testing." },
        @{ Repo = "Betterment/alchemist"; Category = "testing"; Role = "Golden testing utilities." },
        @{ Repo = "VeryGoodOpenSource/very_good_cli"; Category = "quality"; Role = "Flutter/Dart quality CLI." },
        @{ Repo = "invertase/melos"; Category = "quality"; Role = "Monorepo orchestration." },
        @{ Repo = "felangel/mason"; Category = "quality"; Role = "Template/bricks code generation." },
        @{ Repo = "subosito/flutter-action"; Category = "ci"; Role = "GitHub Action for Flutter CI." },
        @{ Repo = "Solido/awesome-flutter"; Category = "catalog"; Role = "Flutter ecosystem catalog." },
        @{ Repo = "fluttergems/awesome-open-source-flutter-apps"; Category = "catalog"; Role = "Open-source Flutter apps catalog." },
        @{ Repo = "fluttergems/fluttergems"; Category = "catalog"; Role = "Flutter Gems package catalog source."; Large = $true },
        @{ Repo = "VoltAgent/awesome-agent-skills"; Category = "agent"; Role = "Agent skills catalog." }
    )

    foreach ($repo in $repos) {
        Sync-ReferenceRepo -Repo $repo.Repo -Category $repo.Category -Role $repo.Role -Large:([bool]$repo.Large) -AllowFailure:([bool]$repo.AllowFailure)
    }
}

Write-Step "[5/7] Apply pub packages when explicitly requested"
if (-not $ApplyPubPackages) {
    Add-Result -Area "pub-packages" -Name $Profile -Status "SKIP" -Role "Package installation." -Details "Use -ApplyPubPackages to modify pubspec.yaml." -Fix ""
} else {
    $packageSet = Get-PackageSet
    Add-PubPackages -Runtime $packageSet.Runtime -Dev $packageSet.Dev -Role $packageSet.Role
}

Write-Step "[6/7] Write reports, inventory, and keep Git tracking open"
Write-Inventory
@(
    "docs/agent-playbooks/flutter-fullstack-references/**/.git/",
    "docs/agent-playbooks/flutter-fullstack-references/",
    ".dart_tool/",
    "build/",
    ".osgrep/",
    ".memsearch/",
    ".mobilerun/",
    ".portless/"
) | ForEach-Object { Remove-GitIgnoreEntry $_ }

Write-Step "[7/7] Verify local base tools"
foreach ($tool in @("git", "flutter", "dart", "npx", "npm", "uv")) {
    if (Test-Cmd $tool) {
        Invoke-CheckedTool -Area "verify-tool" -Name $tool -File $tool -Arguments @("--version") -Role "Base command availability." -Fix "Reinstall or fix PATH." -AllowFailure | Out-Null
    } else {
        Add-Result -Area "verify-tool" -Name $tool -Status "WARN" -Role "Base command availability." -Details "$tool not found on PATH." -Fix "Install it if this project needs it."
    }
}

Save-Report

$failed = @($script:Results | Where-Object { $_.status -eq "FAIL" }).Count
if ($failed -gt 0) {
    Write-Host ""
    Write-Host "Finished with $failed failed item(s). See the generated report for causes and fixes." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green
