# SMKITS5 / Dokumentation
| Dokumentation | Referenz |
| --- | --- |
| Aktuelle ToDo-Liste | [Liste](./todo.md) |
| Präsentationsfolien | [DR1-Foliensatz](./SMKITS-Presentation%20DR1.pdf) |
| Originalbild-Testset | [Bildverzeichnis](../coverData), `640x` [Kaggle/Alaska2](https://www.kaggle.com/competitions/alaska2-image-steganalysis/data?select=Cover), `192x` [BOWS2](http://bows2.ec-lille.fr/), `192x` private Bilder |
| Theorieaufgaben | [Variationen nach Testprotokoll](./variations.md), [Ablaufdiagramm des Testprotokolls](./flowchart.drawio.svg), [Werkzeuge](./tools.md), [Attributierungsmerkmale](./attributes.md), [Tool-Attributierung](./tool-attrib.md) |
| Meeting- und Fortschrittsprotokoll | [Tabelle](./meetings.md) |
| Notizen zum Abschlussbericht | [Liste](./report-notes.md) |
| gegebene Projektreferenzen | [Stego-Toolkit](https://github.com/DominicBreuker/stego-toolkit), [ImageMagick](https://imagemagick.org), [Detecting Steganographic Content on the Internet](http://www.citi.umich.edu/u/provos/papers/detecting.pdf) |
| weitere Projektreferenzen | [StegBreak Bug](https://www.linux-community.de/ausgaben/linuxuser/2008/04/stegdetect-und-stegbreak/2/) |
## ./stego-docker.sh (Setup)
1. dieses Git-Repo klonen
2. neues Terminal in `./amsl-it-security-projects/SMKITS5/` öffnen
3. `./stego-docker.sh --setup` ausführen (Docker-Installation und -Konfiguration, evtl. `chmod +x ./stego-docker.sh` benötigt)
4. `./stego-docker.sh --pull` ausführen (Stego-Toolkit in Container herunterladen)
5. `./stego-docker.sh --run` startet den Container und öffnet eine interne Shell
6. `Schritt 2` wiederholen und `./utility/dockerImportDefaults.sh` ausführen, um interne Umgebung einzurichten (evtl. `chmod +x ./utility/dockerImportDefaults.sh` benötigt)
## ./stego-attrib.sh (Untersuchung)
- Ausführung nach `./stego-docker.sh --run` (s.o. Setup Schritt 5) in interner Container-Shell möglich
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
