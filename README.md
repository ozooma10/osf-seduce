# OSF Seduce

OSF Seduce is a Starfield port of the **SAF/NAF Seduce** mod by **Gray User**, rebuilt to run on the OSF Animation framework.

The mod requires:

- OSF Animation (https://github.com/ozooma10/osf-animation)

## Build

```powershell
.\Build.ps1
```

See `BUILD.md` for compile-only, deploy-only, and custom target examples.

## In-Game Smoke Test

Enable this mod and OSF Animation in MO2, launch through SFSE, then use the console:

```text
cgf "OSFSeduce.Random" <refA> <refB>
cgf "OSFSeduce.Bridge" <refA> <refB>
cgf "OSFSeduce.Stop" <refA>
cgf "OSFSeduce.Reload"
```

The bridge selects scenes by tags, so any installed pack with matching `osf`/`seduce` tags can satisfy the calls.

## Credits

- **Gray User** - original NAF Seduce mod, animations, and sounds.
- This project is a port of NAF Seduce to the OSF framework for Starfield.
