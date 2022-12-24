# SMKITS5 / Dokumentation
## Übersicht
| Dokumentation | Referenz |
| --- | --- |
| ToDo-Liste | [./todo.md](./todo.md) |
| Abschlussbericht | [https://sharelatex.cs.uni-magdeburg.de/project/634ef52d9aa238009023f370](https://sharelatex.cs.uni-magdeburg.de/project/634ef52d9aa238009023f370) |
| **SMK-Aspekt**: Meeting- und Fortschrittsprotokoll | [./meetings.md](./meetings.md) |
| akquidierte Daten | [./acquiredData/](./acquiredData/) |
| DR1-Foliensatz | [./presentations/SMKITS-Presentation DR1.pdf](./presentations/SMKITS-Presentation%20DR1.pdf) |
| DR2-Foliensatz | [./presentations/SMKITS-Presentation DR2.pdf](./presentations/SMKITS-Presentation%20DR2.pdf) |
| *Theorieaufgabe*: Testprotokoll-Tabelle | [./variations.md](./variations.md) |
| *Theorieaufgabe*: Testprotokoll-Diagramm | [./materials/flowchart.drawio.svg](./materials/flowchart.drawio.svg) |
| *Theorieaufgabe*: Werkzeug-Tabelle | [./tools.md](./tools.md) |
| *Theorieaufgabe*: Attributierungsmerkmale | [./attributes.md](./attributes.md) |
| *Theorieaufgabe*: Tool-Attributierung | [./tool-attrib.md](./tool-attrib.md) |
| *stegbreak*-Fehlerdiagramm | [./materials/stegbreak-failure.svg](./materials/stegbreak-failure.svg) |
## Quick Start
1. clone git-repo: `git clone https://github.com/birne420/amsl-it-security-projects amsl-sec`
2. open new terminal in `./amsl-sec/SMKITS5/`
3. to install docker, run `./stego-docker.sh --setup` (wsl2: make sure `systemd` is enabled)
4. to download Stego-Toolkit, run `./stego-docker.sh --pull`
5. enter container with `./stego-docker.sh --run`
6. do step 2 again
7. to import test scripts and data, run (in new terminal) `./stego-docker-importDefaults.sh`
8. done, now should be able to run e.g. `./stego-attrib.sh -n 1` to analyse a file
## Script-Usage
- this projects works in two different nvironments:
  - physical repo: this pulled repository on your hard disk
  - virtual docker: can be entered via shell with `./stego-docker.sh --run`
- some scripts are specific to an environment so they can only operate in one (in brackets)
### stego-attrib.sh (virtual docker)
- `-h`, `--help` display help
1. data acquisition 
  - `-i | --input <directory>` set cover file input (default is `./coverData`)
  - `-o | --output <directory>` set analysis data output (default is `./out-stego-attrib`)
  - `-z | --tar <file>` create tarball after analysis of output directory
  - `-n | --size <int>` set subset size for analysis (default is `1`)
  - `-m | --offset <int>` set amount of testset-samples to skip (default is `0`)
  - `-r | --randomize` randomize selection of test-samples
  - `-c | --clean` wipe output directory prior analysis
  - `-d | --delete` delete analysis temp data and only keep results
  - `-v | --verbose` print every command execution to console
2. `JPEG`-file attribution
  - `-x | --examine <stego jpg> [original jpg]` analyse and attribute any `jpg`-file based on this project's results, with optional orginal file (cover-stego-pair) attribution will be easier
### stego-docker.sh (physical repo)
### stego-docker-importDefaults.sh (physical repo)
### stego-utils-buildTestset.sh (physical repo)
### stego-utils-generateDiagrams.sh (physical repo)
### stego-utils-recompressAndDiffCC.sh (virtual docker)
