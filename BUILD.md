# Build and Deploy

Run from this folder:

```powershell
.\Build.ps1
```

That compiles `OSFSeduce.psc`, `OSFSeduceManager.psc`, and the fragment sources, then deploys the bridge mod payload to the sibling MO2 folder:

```text
..\MO2\mods\OSF Seduce
```

Useful variants:

```powershell
.\Build.ps1 -NoDeploy
.\Build.ps1 -NoCompile
.\Build.ps1 -Target "C:\Path\To\MO2\mods\OSF Seduce"
```

Deployment copies:

- `OSFSeduce.esp`
- `meta.ini`
- `Scripts`
- `OSF`
- `Sound`

It overwrites matching files but does not mirror-delete unrelated files from the target mod folder.