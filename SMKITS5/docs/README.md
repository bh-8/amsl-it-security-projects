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
6. see step 2
7. to import test scripts and data, run `./stego-docker-importDefaults.sh`
## Script-Usage
- this projects works in two different nvironments:
  - physical repo: this pulled repository on your hard disk
  - virtual docker: can be entered via shell with `./stego-docker.sh --run`
- some scripts are specific to an environment so they can only operate in one (in brackets)
### stego-attrib.sh (virtual docker)
- vollständige Hilfe: `./stego-attrib.sh` oder `./stego-attrib.sh -h` oder `./stego-attrib.sh --help` (evtl. `chmod +x ./stego-attrib.sh` benötigt)
- mögliche Schalter (Reihenfolge ist egal)
  - `-i <pfad>` oder `--input <pfad>`: setzt den Input-Pfad (`.jpg`-Originalbild-Testset-Verzeichnis, standard ist `./coverData`)
  - `-o <pfad>` oder `--output <pfad>`: setzt den Output-Pfad (standard ist `./out-stego-attrib`)
  - `-n <int>` oder `--size <int>`: legt Anzahl der aus dem Originalbild-Testset zu untersuchenden Dateien fest (standard ist `1`)
  - `-m <int>` oder `--offset <int>`: legt Anzahl der aus dem Originalbild-Testset zu überspringenden Dateien fest (benötigt für Parallelisierung, standard ist `0`)
  - `-r` oder `--randomize`: Dateien aus dem Originalbild-Testset werden zufällig ausgewählt (Doppelungen ausgeschlossen)
  - `-c` oder `--clean`: löscht Ergebnisse früherer Untersuchungen im angegebenen Ausgabeverzeichnis
  - `-d` oder `--delete`: löscht Analysedaten während der laufenden Untersuchung, um Speicherplatzprobleme zu vermeiden
  - `-v` oder `--verbose`: jeder Befehlsaufruf wird ausgegeben
  - `-x` oder `--examine <stego jpg> [original jpg]`: Analysiert und attributiert eine jpg-Datei
### stego-docker.sh (physical repo)
### stego-docker-importDefaults.sh (physical repo)
### stego-utils-buildTestset.sh (physical repo)
### stego-utils-generateDiagrams.sh (physical repo)
### stego-utils-recompressAndDiffCC.sh (virtual docker)
