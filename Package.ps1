param(
    [string]$OutDir,
    [string]$Version,
    [switch]$ExcludeSource,
    [switch]$NoCompile
)

$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot

# Resolve version: explicit param wins, else read from meta.ini.
if ([string]::IsNullOrWhiteSpace($Version)) {
    $metaPath = Join-Path $Root "meta.ini"
    if (Test-Path -LiteralPath $metaPath) {
        $line = Get-Content -LiteralPath $metaPath | Where-Object { $_ -match '^\s*version\s*=' } | Select-Object -First 1
        if ($line) { $Version = ($line -split '=', 2)[1].Trim() }
    }
    if ([string]::IsNullOrWhiteSpace($Version)) { $Version = "0.0.0" }
}

if ([string]::IsNullOrWhiteSpace($OutDir)) { $OutDir = Join-Path $Root "dist" }

# 1. Compile fresh .pex (deploy step skipped — we stage manually below).
if (!$NoCompile) {
    & (Join-Path $Root "Build.ps1") -NoDeploy
    if ($LASTEXITCODE -ne 0) { throw "Compile failed; aborting package." }
}

# 2. Stage the Data-relative payload in a clean temp dir.
$stage = Join-Path ([System.IO.Path]::GetTempPath()) ("osfseduce_pkg_" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $stage | Out-Null

try {
    # Top-level ESM (master-flagged; safe to leave in a save's load order).
    Copy-Item -LiteralPath (Join-Path $Root "OSFSeduce.esm") -Destination $stage -Force

    # Asset trees that ship verbatim.
    foreach ($dir in @("OSF", "Sound")) {
        Copy-Item -Path (Join-Path $Root $dir) -Destination $stage -Recurse -Force
    }

    # Scripts: always ship compiled .pex; ship Source too unless excluded.
    Copy-Item -Path (Join-Path $Root "Scripts") -Destination $stage -Recurse -Force
    if ($ExcludeSource) {
        $src = Join-Path (Join-Path $stage "Scripts") "Source"
        if (Test-Path -LiteralPath $src) { Remove-Item -LiteralPath $src -Recurse -Force }
    }

    # Scrub local-only leftovers that may sit alongside assets.
    Get-ChildItem -Path $stage -Recurse -File -Include '*.bak', '*.bak-*', '*.tmp', '*.log' |
        Remove-Item -Force

    # 3. Zip it.
    New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
    $archive = Join-Path $OutDir ("OSF Seduce v$Version.zip")
    if (Test-Path -LiteralPath $archive) { Remove-Item -LiteralPath $archive -Force }

    Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $archive -CompressionLevel Optimal

    $size = "{0:N1} MB" -f ((Get-Item -LiteralPath $archive).Length / 1MB)
    Write-Host "Packaged: $archive ($size)"
}
finally {
    Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
}
