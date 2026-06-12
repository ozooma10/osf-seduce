# Build and Deploy

Run from this folder:

```powershell
.\Build.ps1
```

That compiles `OSFSeduce.psc` plus all TIF fragment sources, then deploys the mod
payload to:

```text
C:\Modding\Starfield\MO2\mods\OSF Seduce
```

Useful variants:

```powershell
.\Build.ps1 -NoDeploy
.\Build.ps1 -NoCompile
.\Build.ps1 -Target "C:\Modding\Starfield\MO2\mods\OSF Seduce"
```

Deployment copies `OSFSeduce.esp`, `meta.ini`, `OSF`, and `Scripts`.
It overwrites matching files but does not mirror-delete unrelated files from the
target mod folder.

Animations and audio are **not** part of this mod — they live in the separate
**OSF Seduce Animations** pack. This mod triggers scenes by tag (`osf`/`seduce`)
and requires that pack (or any pack providing matching tags) plus OSF Director.
