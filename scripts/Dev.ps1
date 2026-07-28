[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet("doctor", "import", "editor", "run", "build", "smoke")]
    [string]$Task = "doctor",

    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Release",

    [string]$GodotExe = "",
    [string]$OutputPath = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ExpectedVersion = "4.2.2.stable.official.15073afe3"
$TemplateVersion = "4.2.2.stable"
$OriginalAppData = $env:APPDATA
$RepoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$ProjectRoot = Join-Path $RepoRoot "project"
$WorkspaceRoot = Split-Path -Parent (Split-Path -Parent $RepoRoot)
$DefaultGodot = Join-Path $WorkspaceRoot "tools\godot\4.2.2\editor\Godot_v4.2.2-stable_win64.exe"

function Resolve-Godot {
    $Candidates = @()
    if (-not [string]::IsNullOrWhiteSpace($GodotExe)) {
        $Candidates += $GodotExe
    }
    if (-not [string]::IsNullOrWhiteSpace($env:NODEBUSTER_GODOT)) {
        $Candidates += $env:NODEBUSTER_GODOT
    }
    $Candidates += $DefaultGodot

    foreach ($Candidate in $Candidates) {
        if (Test-Path -LiteralPath $Candidate -PathType Leaf) {
            return [IO.Path]::GetFullPath($Candidate)
        }
    }

    foreach ($CommandName in @("godot", "godot4")) {
        $Command = Get-Command $CommandName -ErrorAction SilentlyContinue
        if ($null -ne $Command) {
            return $Command.Source
        }
    }

    throw "Godot 4.2.2 was not found. Run scripts\Setup-DevEnvironment.ps1 or pass -GodotExe."
}

function ConvertTo-ProcessArguments {
    param([Parameter(Mandatory = $true)][string[]]$Values)
    return @(
        foreach ($Argument in $Values) {
            if ($Argument -match '\s|"') {
                '"' + $Argument.Replace('"', '\"') + '"'
            }
            else {
                $Argument
            }
        }
    )
}

function Invoke-Godot {
    param([Parameter(Mandatory = $true)][string[]]$CommandArguments)
    $QuotedArguments = ConvertTo-ProcessArguments -Values $CommandArguments
    $Process = Start-Process `
        -FilePath $script:GuiGodot `
        -ArgumentList $QuotedArguments `
        -WorkingDirectory $ProjectRoot `
        -Wait `
        -PassThru
    if ($Process.ExitCode -ne 0) {
        throw "Godot exited with code $($Process.ExitCode)."
    }
}

$SelectedGodot = Resolve-Godot
$GodotDir = Split-Path -Parent $SelectedGodot
$GuiGodot = $SelectedGodot -replace "_console\.exe$", ".exe"
if (-not (Test-Path -LiteralPath $GuiGodot -PathType Leaf)) {
    $GuiGodot = $SelectedGodot
}
$ConsoleGodot = $GuiGodot -replace "\.exe$", "_console.exe"
if (-not (Test-Path -LiteralPath $ConsoleGodot -PathType Leaf)) {
    $ConsoleGodot = $GuiGodot
}

$VersionLines = @(& $ConsoleGodot --version)
$VersionExitCode = $LASTEXITCODE
$VersionOutput = ($VersionLines | Select-Object -First 1).Trim()
if ($VersionExitCode -ne 0 -or $VersionOutput -ne $ExpectedVersion) {
    throw "Expected Godot '$ExpectedVersion', got '$VersionOutput' from '$ConsoleGodot'."
}

$RequiredProjectFiles = @(
    "project.godot",
    "MainScene.tscn",
    "export_presets.cfg",
    "addons\godotsteam\godotsteam.gdextension",
    "addons\godotsteam\win64\libgodotsteam.windows.template_debug.x86_64.dll",
    "addons\godotsteam\win64\libgodotsteam.windows.template_release.x86_64.dll",
    "addons\godotsteam\win64\steam_api64.dll"
)
foreach ($RelativePath in $RequiredProjectFiles) {
    $FullPath = Join-Path $ProjectRoot $RelativePath
    if (-not (Test-Path -LiteralPath $FullPath -PathType Leaf)) {
        throw "Required project file is missing: $FullPath"
    }
}

$RuntimeRoot = Join-Path $RepoRoot ".runtime"
$env:APPDATA = Join-Path $RuntimeRoot "appdata"
$env:LOCALAPPDATA = Join-Path $RuntimeRoot "localappdata"
New-Item -ItemType Directory -Path $env:APPDATA, $env:LOCALAPPDATA -Force | Out-Null

function Invoke-GodotImport {
    $LogRoot = Join-Path $RuntimeRoot "logs"
    New-Item -ItemType Directory -Path $LogRoot -Force | Out-Null
    $FailurePattern = "(?m)^(?:ERROR:|SCRIPT ERROR:|USER ERROR: (?!Resources still in use at exit))|Parse Error|Failed loading|Can't open dynamic library"

    foreach ($Pass in 1..2) {
        $Stamp = Get-Date -Format "yyyyMMdd-HHmmss-fff"
        $StdOutPath = Join-Path $LogRoot "import-$Stamp-$Pass.stdout.log"
        $StdErrPath = Join-Path $LogRoot "import-$Stamp-$Pass.stderr.log"
        $Arguments = ConvertTo-ProcessArguments -Values @(
            "--headless",
            "--path", $ProjectRoot,
            "--import"
        )
        $Process = Start-Process `
            -FilePath $ConsoleGodot `
            -ArgumentList $Arguments `
            -WorkingDirectory $ProjectRoot `
            -RedirectStandardOutput $StdOutPath `
            -RedirectStandardError $StdErrPath `
            -Wait `
            -PassThru

        $CombinedLog = @(
            Get-Content -LiteralPath $StdOutPath -Raw -Encoding utf8 -ErrorAction SilentlyContinue
            Get-Content -LiteralPath $StdErrPath -Raw -Encoding utf8 -ErrorAction SilentlyContinue
        ) -join "`n"
        $HasImportErrors = $CombinedLog -match $FailurePattern
        $FileSystemCache = Join-Path $ProjectRoot ".godot\editor\filesystem_cache8"
        $ExtensionList = Join-Path $ProjectRoot ".godot\extension_list.cfg"
        $HasGodotSteam = (Test-Path -LiteralPath $ExtensionList -PathType Leaf) -and
            ((Get-Content -LiteralPath $ExtensionList -Raw -Encoding utf8) -match "godotsteam\.gdextension")
        $AcceptableExitCode = $Process.ExitCode -eq 0 -or $Process.ExitCode -eq 1

        if ($AcceptableExitCode -and
            -not $HasImportErrors -and
            (Test-Path -LiteralPath $FileSystemCache -PathType Leaf) -and
            $HasGodotSteam) {
            $ExitNote = if ($Process.ExitCode -eq 1) {
                " (known Godot 4.2.2 Windows headless import exit-code anomaly)"
            }
            else {
                ""
            }
            Write-Host "[OK] Godot import pass $Pass$ExitNote"
            return
        }

        if ($Pass -eq 1) {
            Write-Host "[..] Import pass 1 was incomplete; retrying after cache generation."
        }
        else {
            throw "Godot import validation failed. Exit code: $($Process.ExitCode). Logs: $StdOutPath ; $StdErrPath"
        }
    }
}

$PortableTemplateDir = Join-Path $GodotDir "editor_data\export_templates\$TemplateVersion"
$StandardTemplateDir = Join-Path $OriginalAppData "Godot\export_templates\$TemplateVersion"
$TemplateDir = $null
foreach ($Candidate in @($PortableTemplateDir, $StandardTemplateDir)) {
    if (Test-Path -LiteralPath (Join-Path $Candidate "windows_release_x86_64.exe") -PathType Leaf) {
        $TemplateDir = $Candidate
        break
    }
}

switch ($Task) {
    "doctor" {
        if ($null -eq $TemplateDir) {
            throw "Godot 4.2.2 Windows x86_64 export templates were not found."
        }
        $Checks = @(
            [pscustomobject]@{ Item = "Godot"; Status = "OK"; Value = $VersionOutput },
            [pscustomobject]@{ Item = "Project"; Status = "OK"; Value = $ProjectRoot },
            [pscustomobject]@{ Item = "Windows preset"; Status = "OK"; Value = (Join-Path $ProjectRoot "export_presets.cfg") },
            [pscustomobject]@{ Item = "Export templates"; Status = "OK"; Value = $TemplateDir },
            [pscustomobject]@{ Item = "GodotSteam"; Status = "OK"; Value = "Windows x86_64 debug/release + steam_api64.dll" },
            [pscustomobject]@{ Item = "Test user data"; Status = "isolated"; Value = $RuntimeRoot }
        )
        Write-Host "# Nodebuster development environment"
        Write-Host ""
        $Checks | Format-Table -AutoSize
    }
    "import" {
        Invoke-GodotImport
    }
    "editor" {
        $Process = Start-Process `
            -FilePath $GuiGodot `
            -ArgumentList @("--editor", "--path", "`"$ProjectRoot`"") `
            -WorkingDirectory $ProjectRoot `
            -PassThru
        Write-Host "Godot editor started (PID $($Process.Id)): $ProjectRoot"
    }
    "run" {
        $Process = Start-Process `
            -FilePath $GuiGodot `
            -ArgumentList @("--path", "`"$ProjectRoot`"") `
            -WorkingDirectory $ProjectRoot `
            -PassThru
        Write-Host "Nodebuster started with isolated user data (PID $($Process.Id))."
        Write-Host "APPDATA=$env:APPDATA"
    }
    "build" {
        if ($null -eq $TemplateDir) {
            throw "Godot 4.2.2 Windows x86_64 export templates were not found."
        }

        $ConfigurationName = $Configuration.ToLowerInvariant()
        if ([string]::IsNullOrWhiteSpace($OutputPath)) {
            $OutputPath = Join-Path $RepoRoot "build\windows\$ConfigurationName\Nodebuster.exe"
        }
        elseif (-not [IO.Path]::IsPathRooted($OutputPath)) {
            $OutputPath = Join-Path $RepoRoot $OutputPath
        }
        $OutputPath = [IO.Path]::GetFullPath($OutputPath)
        $OutputDir = Split-Path -Parent $OutputPath
        New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

        Invoke-GodotImport
        $ExportSwitch = if ($Configuration -eq "Debug") { "--export-debug" } else { "--export-release" }
        Invoke-Godot -CommandArguments @(
            "--headless",
            "--path", $ProjectRoot,
            $ExportSwitch, "Windows Desktop", $OutputPath
        )

        $NativeLibrary = if ($Configuration -eq "Debug") {
            "libgodotsteam.windows.template_debug.x86_64.dll"
        }
        else {
            "libgodotsteam.windows.template_release.x86_64.dll"
        }
        $ExpectedOutputs = @(
            $OutputPath,
            [IO.Path]::ChangeExtension($OutputPath, ".pck"),
            (Join-Path $OutputDir $NativeLibrary),
            (Join-Path $OutputDir "steam_api64.dll")
        )
        foreach ($ExpectedOutput in $ExpectedOutputs) {
            if (-not (Test-Path -LiteralPath $ExpectedOutput -PathType Leaf)) {
                throw "Expected build output is missing: $ExpectedOutput"
            }
        }

        Write-Host "# Nodebuster $Configuration build"
        Write-Host ""
        Get-Item -LiteralPath $ExpectedOutputs |
            Select-Object Name, Length, LastWriteTime |
            Format-Table -AutoSize
    }
    "smoke" {
        $ConfigurationName = $Configuration.ToLowerInvariant()
        if ([string]::IsNullOrWhiteSpace($OutputPath)) {
            $OutputPath = Join-Path $RepoRoot "build\windows\$ConfigurationName\Nodebuster.exe"
        }
        elseif (-not [IO.Path]::IsPathRooted($OutputPath)) {
            $OutputPath = Join-Path $RepoRoot $OutputPath
        }
        $OutputPath = [IO.Path]::GetFullPath($OutputPath)
        if (-not (Test-Path -LiteralPath $OutputPath -PathType Leaf)) {
            throw "Build output is missing: $OutputPath. Run the matching build task first."
        }

        $Stamp = Get-Date -Format "yyyyMMdd-HHmmss-fff"
        $SmokeRuntime = Join-Path $RuntimeRoot "smoke\$ConfigurationName\$Stamp"
        $env:APPDATA = Join-Path $SmokeRuntime "appdata"
        $env:LOCALAPPDATA = Join-Path $SmokeRuntime "localappdata"
        New-Item -ItemType Directory -Path $env:APPDATA, $env:LOCALAPPDATA -Force | Out-Null

        $Arguments = ConvertTo-ProcessArguments -Values @(
            "--headless",
            "--fixed-fps", "60",
            "--quit-after", "300"
        )
        $Process = Start-Process `
            -FilePath $OutputPath `
            -ArgumentList $Arguments `
            -WorkingDirectory (Split-Path -Parent $OutputPath) `
            -Wait `
            -PassThru

        $LogPath = Join-Path $env:APPDATA "Nodebuster\logs\godot.log"
        if (-not (Test-Path -LiteralPath $LogPath -PathType Leaf)) {
            throw "Smoke-test log was not created: $LogPath"
        }
        $LogContent = Get-Content -LiteralPath $LogPath -Raw -Encoding utf8
        $FailurePattern = "(?m)^(?:ERROR:|SCRIPT ERROR:|USER ERROR: (?!Resources still in use at exit))|Parse Error|Failed loading|Can't open dynamic library"
        if ($Process.ExitCode -notin @(0, 1) -or $LogContent -match $FailurePattern) {
            throw "Smoke test failed. Exit code: $($Process.ExitCode). Log: $LogPath"
        }
        $CleanupDiagnosticCount = [regex]::Matches(
            $LogContent,
            "(?m)^USER ERROR: Resources still in use at exit"
        ).Count

        $ExitNote = if ($Process.ExitCode -eq 1) {
            "known Godot 4.2.2 Windows headless auto-quit anomaly"
        }
        else {
            "normal"
        }
        Write-Host "# Nodebuster $Configuration smoke test"
        Write-Host ""
        @(
            [pscustomobject]@{ Item = "Frames"; Value = "300 at fixed 60 FPS" },
            [pscustomobject]@{ Item = "Exit"; Value = "$($Process.ExitCode) ($ExitNote)" },
            [pscustomobject]@{ Item = "Load/script errors"; Value = "0" },
            [pscustomobject]@{ Item = "Forced-exit cleanup diagnostics"; Value = $CleanupDiagnosticCount },
            [pscustomobject]@{ Item = "User data"; Value = $SmokeRuntime },
            [pscustomobject]@{ Item = "Log"; Value = $LogPath }
        ) | Format-Table -AutoSize
    }
}
