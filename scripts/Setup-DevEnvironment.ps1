[CmdletBinding()]
param(
    [string]$InstallRoot = "",
    [switch]$SkipDownload
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ExpectedVersion = "4.2.2.stable.official.15073afe3"
$TemplateVersion = "4.2.2.stable"
$ReleaseBaseUrl = "https://github.com/godotengine/godot/releases/download/4.2.2-stable"
$EditorArchiveName = "Godot_v4.2.2-stable_win64.exe.zip"
$TemplateArchiveName = "Godot_v4.2.2-stable_export_templates.tpz"
$EditorArchiveSha512 = "49e2252f862f3a73b11d1d77e8dfd2966633aa49a9033a75e067df0f6daf0da7accc91323a88f830daa6ef0ff2eefe2f53e1247afb10d56966f642bd5bc45877"
$TemplateArchiveSha512 = "a0c810c984a282f5874a991652be5603a7c8be4a0e47849df9d4cf9f44f2b7f2b864aaa1febec29a6a77a1784d45fedcb82173a99a39bc7ae03323de9e0d5cea"

$RepoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
if ([string]::IsNullOrWhiteSpace($InstallRoot)) {
    $WorkspaceRoot = Split-Path -Parent (Split-Path -Parent $RepoRoot)
    $InstallRoot = Join-Path $WorkspaceRoot "tools\godot\4.2.2"
}
$InstallRoot = [IO.Path]::GetFullPath($InstallRoot)
$EditorDir = Join-Path $InstallRoot "editor"
$EditorExe = Join-Path $EditorDir "Godot_v4.2.2-stable_win64.exe"
$ConsoleExe = Join-Path $EditorDir "Godot_v4.2.2-stable_win64_console.exe"
$EditorArchive = Join-Path $InstallRoot $EditorArchiveName
$TemplateArchive = Join-Path $InstallRoot $TemplateArchiveName
$TemplateDir = Join-Path $EditorDir "editor_data\export_templates\$TemplateVersion"

function Get-Sha512 {
    param([Parameter(Mandatory = $true)][string]$Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA512).Hash.ToLowerInvariant()
}

function Assert-Hash {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Expected
    )
    $Actual = Get-Sha512 -Path $Path
    if ($Actual -ne $Expected) {
        throw "SHA-512 mismatch for '$Path'. Expected $Expected, got $Actual."
    }
}

function Ensure-Download {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [Parameter(Mandatory = $true)][string]$Destination,
        [Parameter(Mandatory = $true)][string]$ExpectedSha512
    )

    if (Test-Path -LiteralPath $Destination -PathType Leaf) {
        Assert-Hash -Path $Destination -Expected $ExpectedSha512
        Write-Host "[OK] Verified cached download: $Destination"
        return
    }

    if ($SkipDownload) {
        throw "Required download is missing and -SkipDownload was supplied: $Destination"
    }

    New-Item -ItemType Directory -Path (Split-Path -Parent $Destination) -Force | Out-Null
    Write-Host "[..] Downloading $Url"
    try {
        Import-Module BitsTransfer -ErrorAction Stop
        Start-BitsTransfer -Source $Url -Destination $Destination -Priority Foreground -ErrorAction Stop
    }
    catch {
        Write-Warning "BITS download failed; falling back to Invoke-WebRequest. $($_.Exception.Message)"
        Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing
    }
    Assert-Hash -Path $Destination -Expected $ExpectedSha512
    Write-Host "[OK] Download verified: $Destination"
}

New-Item -ItemType Directory -Path $InstallRoot -Force | Out-Null
Ensure-Download `
    -Url "$ReleaseBaseUrl/$EditorArchiveName" `
    -Destination $EditorArchive `
    -ExpectedSha512 $EditorArchiveSha512

if (-not (Test-Path -LiteralPath $EditorExe -PathType Leaf) -or
    -not (Test-Path -LiteralPath $ConsoleExe -PathType Leaf)) {
    if (Test-Path -LiteralPath $EditorDir) {
        throw "Editor directory exists but is incomplete: $EditorDir"
    }
    Expand-Archive -LiteralPath $EditorArchive -DestinationPath $EditorDir
}

Set-Content -LiteralPath (Join-Path $EditorDir "_sc_") `
    -Value "Nodebuster portable Godot 4.2.2 environment" `
    -Encoding ascii

Ensure-Download `
    -Url "$ReleaseBaseUrl/$TemplateArchiveName" `
    -Destination $TemplateArchive `
    -ExpectedSha512 $TemplateArchiveSha512

Add-Type -AssemblyName System.IO.Compression.FileSystem
New-Item -ItemType Directory -Path $TemplateDir -Force | Out-Null
$TemplateFiles = @(
    "version.txt",
    "windows_debug_x86_64_console.exe",
    "windows_debug_x86_64.exe",
    "windows_release_x86_64_console.exe",
    "windows_release_x86_64.exe"
)
$Archive = [IO.Compression.ZipFile]::OpenRead($TemplateArchive)
try {
    foreach ($Name in $TemplateFiles) {
        $Entry = $Archive.GetEntry("templates/$Name")
        if ($null -eq $Entry) {
            throw "Template archive entry is missing: templates/$Name"
        }
        [IO.Compression.ZipFileExtensions]::ExtractToFile(
            $Entry,
            (Join-Path $TemplateDir $Name),
            $true
        )
    }
}
finally {
    $Archive.Dispose()
}

$VersionLines = @(& $ConsoleExe --version)
$VersionExitCode = $LASTEXITCODE
$VersionOutput = ($VersionLines | Select-Object -First 1).Trim()
if ($VersionExitCode -ne 0 -or $VersionOutput -ne $ExpectedVersion) {
    throw "Unexpected Godot version. Expected '$ExpectedVersion', got '$VersionOutput'."
}

Write-Host ""
Write-Host "# Nodebuster Godot environment"
Write-Host ""
Write-Host "| Item | Value |"
Write-Host "|---|---|"
Write-Host "| Godot | $VersionOutput |"
Write-Host "| Editor | $EditorExe |"
Write-Host "| Console | $ConsoleExe |"
Write-Host "| Templates | $TemplateDir |"
Write-Host "| Mode | self-contained (`_sc_`) |"
