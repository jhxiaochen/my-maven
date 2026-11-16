#!/usr/bin/env python3
"""Stage a built WorldEdit jar into a static Maven layout."""

import argparse
import datetime
import pathlib
import shutil

POM = """<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>{group}</groupId>
  <artifactId>{artifact}</artifactId>
  <version>{version}</version>
  <packaging>jar</packaging>

  <name>WorldEdit Forge 1.12.2 (height-extended fork, {commit})</name>
  <description>WorldEdit Forge platform module rebuilt from the height-extended fork at commit {commit} on {date}. Compile-time only; Forge classes come from the mod loader at runtime.</description>
  <url>{fork_repo}</url>

  <licenses>
    <license>
      <name>GNU General Public License v3.0 (WorldEdit as a whole)</name>
      <url>https://www.gnu.org/licenses/gpl-3.0.html</url>
      <distribution>repo</distribution>
    </license>
  </licenses>

  <developers>
    <developer>
      <id>DollanITH</id>
      <name>DollanITH fork maintainer</name>
      <url>{fork_repo}</url>
    </developer>
  </developers>

  <properties>
    <worldedit.fork.commit>{commit}</worldedit.fork.commit>
    <worldedit.fork.build.date>{date}</worldedit.fork.build.date>
    <worldedit.upstream.source>{upstream_repo}</worldedit.upstream.source>
  </properties>
</project>
"""


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--jar", required=True)
    parser.add_argument("--version", required=True)
    parser.add_argument("--commit", default="unknown")
    parser.add_argument("--group", default="dev.xy177.worldedit")
    parser.add_argument("--artifact", default="worldedit-forge-mc1.12.2")
    parser.add_argument("--out", default="maven")
    parser.add_argument("--fork-repo", default="https://github.com/DollanITH/WorldEdit")
    parser.add_argument("--upstream-repo", default="https://github.com/EngineHub/WorldEdit")
    args = parser.parse_args()

    jar = pathlib.Path(args.jar)
    if not jar.is_file():
        raise SystemExit(f"jar not found: {jar}")

    group_path = args.group.replace(".", "/")
    target_dir = pathlib.Path(args.out) / group_path / args.artifact / args.version
    target_dir.mkdir(parents=True, exist_ok=True)

    jar_name = f"{args.artifact}-{args.version}.jar"
    pom_name = f"{args.artifact}-{args.version}.pom"
    shutil.copyfile(jar, target_dir / jar_name)

    (target_dir / pom_name).write_text(
        POM.format(
            group=args.group,
            artifact=args.artifact,
            version=args.version,
            commit=args.commit,
            date=datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
            fork_repo=args.fork_repo,
            upstream_repo=args.upstream_repo,
        ),
        encoding="utf-8",
    )

    (pathlib.Path(args.out) / ".nojekyll").touch()

    print(f"staged: {target_dir}")
    print(f"coordinate: {args.group}:{args.artifact}:{args.version}")


if __name__ == "__main__":
    main()
