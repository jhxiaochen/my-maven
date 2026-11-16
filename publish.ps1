param(
    [Parameter(Mandatory = $true)][string]$Jar,
    [string]$Version = "",
    [string]$Commit = "",
    [string]$BaseVersion = "6.1.11",
    [string]$Group = "dev.xy177.worldedit",
    [string]$Artifact = "worldedit-forge-mc1.12.2",
    [string]$ForkRepo = "https://github.com/DollanITH/WorldEdit",
    [string]$UpstreamRepo = "https://github.com/EngineHub/WorldEdit"
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

if (-not (Test-Path -LiteralPath $Jar)) { throw "jar not found: $Jar" }

if (-not $Commit) {
    $weDir = "E:\WorldEdit\we"
    if (Test-Path -LiteralPath $weDir) {
        $Commit = (& git -C $weDir rev-parse --short=8 HEAD).Trim()
    }
}
if (-not $Commit) { $Commit = "unknown" }

if (-not $Version) { $Version = "$BaseVersion-dev-$Commit" }

$groupPath = $Group -replace '\.', '\'
$dir = Join-Path $root "maven\$groupPath\$Artifact\$Version"
New-Item -ItemType Directory -Force -Path $dir | Out-Null

$jarName = "$Artifact-$Version.jar"
$pomName = "$Artifact-$Version.pom"

Copy-Item -LiteralPath $Jar -Destination (Join-Path $dir $jarName) -Force

$buildDate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:sszzz")
$pom = @"
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>$Group</groupId>
  <artifactId>$Artifact</artifactId>
  <version>$Version</version>
  <packaging>jar</packaging>

  <name>WorldEdit Forge 1.12.2 (height-extended fork, $Commit)</name>
  <description>WorldEdit $BaseVersion Forge platform module rebuilt from the height-extended fork at commit $Commit on $buildDate. Compile-time only; Forge classes come from the mod loader at runtime.</description>
  <url>$ForkRepo</url>

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
      <url>$ForkRepo</url>
    </developer>
  </developers>

  <properties>
    <worldedit.fork.commit>$Commit</worldedit.fork.commit>
    <worldedit.fork.build.date>$buildDate</worldedit.fork.build.date>
    <worldedit.upstream.source>$UpstreamRepo</worldedit.upstream.source>
  </properties>
</project>
"@
[IO.File]::WriteAllText((Join-Path $dir $pomName), $pom, (New-Object Text.UTF8Encoding($false)))

Write-Output "published to: $dir"
Write-Output "coordinate:   $Group`:$Artifact`:$Version"
Write-Output ""
Write-Output "consumer side:"
Write-Output "  flatCompileOnly '$Group`:$Artifact`:$Version'"
