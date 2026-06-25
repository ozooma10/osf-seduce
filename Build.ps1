param(
    [string]$Target = "C:\Modding\Starfield\MO2\mods\OSF Seduce",
    [switch]$NoCompile,
    [switch]$NoDeploy
)

$ErrorActionPreference = "Stop"

$Root = $PSScriptRoot
$Compiler = "C:\Program Files (x86)\Steam\steamapps\common\Starfield\Tools\Papyrus Compiler\PapyrusCompiler.exe"
$Flags = "C:\Modding\Starfield\PapyrusSource\Starfield_Papyrus_Flags.flg"
$Imports = @(
    (Join-Path $Root "Scripts\Source"),
    "C:\Modding\Starfield\OSF Animation\dist\Scripts\Source",
    "C:\Modding\Starfield\PapyrusSource"
) -join ";"
$ScriptOutput = Join-Path $Root "Scripts"

function Invoke-PapyrusCompile {
    param(
        [string]$Target,
        [switch]$All
    )

    if (!(Test-Path -LiteralPath $Compiler)) {
        throw "Papyrus compiler not found: $Compiler"
    }
    if (!(Test-Path -LiteralPath $Flags)) {
        throw "Papyrus flags file not found: $Flags"
    }

    $args = @($Target, "-i=$Imports", "-o=$ScriptOutput", "-f=$Flags")
    if ($All) { $args += "-all" }

    Write-Host "Compiling $Target"
    $output = & $Compiler @args 2>&1
    $output | ForEach-Object { Write-Host $_ }

    if ($LASTEXITCODE -ne 0 -or ($output -match "compilation failed|Failed on|Assembly failed|[1-9]\d* failed")) {
        throw "Papyrus compile failed for $Target"
    }
}

function Copy-ModItem {
    param([string]$RelativePath)

    $source = Join-Path $Root $RelativePath
    $dest = Join-Path $Target $RelativePath

    if (!(Test-Path -LiteralPath $source)) {
        throw "Required mod item missing: $source"
    }

    if ((Get-Item -LiteralPath $source).PSIsContainer) {
        New-Item -ItemType Directory -Force -Path $dest | Out-Null
        Copy-Item -Path (Join-Path $source "*") -Destination $dest -Recurse -Force
    } else {
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dest) | Out-Null
        Copy-Item -LiteralPath $source -Destination $dest -Force
    }
}

if (!$NoCompile) {
    # One batch invocation compiles OSFSeduce.psc + all Fragments\TopicInfos\*.psc
    # in a single process. The compiler loads the (large) import tree once and
    # compiles in parallel, instead of paying that startup cost per script.
    Invoke-PapyrusCompile (Join-Path $Root "Scripts\Source") -All
}

if (!$NoDeploy) {
    Write-Host "Deploying to $Target"
    New-Item -ItemType Directory -Force -Path $Target | Out-Null

    @(
        "OSFSeduce.esp",
        "meta.ini",
        "OSF",
        "Scripts"
    ) | ForEach-Object {
        Copy-ModItem $_
    }
}

Write-Host "Build complete."
