# WorldEdit Maven

Static Maven repository hosting rebuilt **WorldEdit 6.1.11 Forge** platform jars for
Minecraft 1.12.2, taken from the fork at
[DollanITH/WorldEdit](https://github.com/DollanITH/WorldEdit).

The only change in this fork is the buildable height range: `HeightManager` extends the
minimum and maximum Y of a world, and `MixinForgeWorld` forwards `getMinY`/`getMaxY` to it.

## License

WorldEdit as a whole is licensed under the **GNU General Public License v3.0**, and new
contributions are licensed under the **GNU Lesser General Public License v3.0**. The
original `LICENSE.txt` of the upstream project applies unchanged; this repository only
redistributes built artifacts.

- Upstream source: https://github.com/EngineHub/WorldEdit
- Corresponding source of these builds (modified version, remapped to SRG names):
  https://github.com/DollanITH/WorldEdit
- GPLv3 text: https://www.gnu.org/licenses/gpl-3.0.html

Each artifact is a **modified version** of WorldEdit. Its POM records the exact fork
commit and build date under `worldedit.fork.commit` / `worldedit.fork.build.date`.

## Coordinates

```groovy
repositories {
    maven {
        name = 'DollanWorldEdit'
        url = 'https://dollanith.github.io/worldedit-maven/'
    }
}

dependencies {
    // Compile-time only: the jar is MCP-named, do not remap it.
    flatCompileOnly 'dev.xy177.worldedit:worldedit-forge-mc1.12.2:6.1.11-dev-4fdf351e'
}
```

`flatCompileOnly` is the configuration used by the consuming projects, so that Unimined
does not attempt to remap this already-built dev jar.

## Version policy

A built jar is never uploaded twice under the same coordinate. Maven assumes immutability,
and both Gradle and the local Maven cache will keep serving a stale artifact if a
coordinate is overwritten.

Every build gets a version of the form `<base>-dev-<commit>`:

```
6.1.11-dev-4fdf351e    WorldEdit 6.1.11, fork commit 4fdf351e
6.1.11-dev-9c2a71b0    a later fork commit
```

Publish a new build with:

```powershell
.\publish.ps1 -Jar "E:\WorldEdit\we\worldedit-forge\build\libs\worldedit-forge-mc1.12.2-6.1.11-dev.jar"
```

The script reads the fork's current `HEAD` for the version suffix, writes the POM with the
commit and build date, and copies the jar into the matching directory. Pass `-Version` to
override the suffix when the jar was built from a different commit than `HEAD`.

Old version directories stay in place so that consumers pinned to an earlier commit
continue to resolve.

## Contents

```
maven/dev/xy177/worldedit/worldedit-forge-mc1.12.2/
  6.1.11-dev-4fdf351e/
    worldedit-forge-mc1.12.2-6.1.11-dev-4fdf351e.jar
    worldedit-forge-mc1.12.2-6.1.11-dev-4fdf351e.pom
```

The repository is served from the `gh-pages` branch. `.github/workflows/publish.yml`
publishes the `maven/` directory on every push that touches it, and on manual dispatch.
