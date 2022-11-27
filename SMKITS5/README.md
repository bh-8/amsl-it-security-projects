# Attribution of Steganography and hidden Communication (jpg)
## Materialien
- [DR1-Präsentation]("./presentations/SMKITS-Presentation DR1.pdf")
- [Ablaufdiagramm](./presentations/flowchart.md)
- [Meeting- und Fortschrittsprotokoll](./presentations/meetings.md)
## ToDo KW47
- [ ] Theorie: mit Originalaufgabenstellung gegenchecken
## ToDo KW48
- [ ] Implementierung: Gesamtevaluation fertigstellen
---
- [ ] Aufgabenstellung bis zur Detailanalyse abgeschlossen bearbeitet
- [ ] Fokus auf Stichpunkte für Draft
- [ ] Fragen
  - jphide/jpseek SegFault-Problem, funktioniert nicht...
  - stegbreak SegFault-Problem sehr häufig, einige wenige Analysen funktionieren aber...
  - Einbettungslänge abhängig von Bildgröße? (8tel der Bilddateigröße)?
  - tabelle und diagramm präsentieren und feedback einholen
  - überspringen von f5 und stegoveritas-analyse bei bildern größer als 1024 ok (aktuell 5min pro bild -> 12 bilder pro stunde -> 288 bilder pro tag -> gut 3.5 Tage Analyse für alle 1024 Bilder)? sonst möglichkeit slow switch, um wenigstens einige bilder zu testen..
  - Parallelisierung/Ausführung auf Cluster? Slurm jobscript...
  - Attributietungsmerkmale überprüfen (stegoveritas gaussianblur? smooth? sharpened?)
- [ ] StegBreak Evaluation
## ToDo KW49
- [ ] ab 05.12. DR2-Präsentation ausarbeiten bis 09.12.
- [ ] ab 05.12. Draft-Schema bis 09.12.
- [ ] bis DR2 (14.12.) Feedback einholen und umsetzen
## ToDo KW49
- [ ] 14.12. DR2
## Weiteres
- Implementierung zum Prüfen eines Einzelbildes mit Analyse auf Basis der gesammelten Erkenntnisse (-x examine switch)?
## Aufgaben und Fortschritt
- [X] (KW45) Auswahl an zu nutzenden Stego-Verfahren/Tools:
  - [X] Stego-Tools: jphide/jpseek, jsteg, outguess, outguess-0.13, steghide, f5
  - [X] Stego-Analysis-Tools: stegoveritas, stegdetect, stegbreak
- [X] (KW45/46) Erstellung eines [Original-Bildtestsets](./coverData) bestehend aus 1024 Bildern aus folgenden Quellen:
  - [Kaggle/Alaska2](https://www.kaggle.com/competitions/alaska2-image-steganalysis/data?select=Cover) Datenbank, Farbbilder, 512x512 (640x)
  - [BOWS2](http://bows2.ec-lille.fr/) Datenbank, Schwarz-Weiß-Bilder, 512x512 (192x)
  - private Bilder, verschiedenste Auflösungen und Größen (192x)
- [X] (KW46/47) Erstellung von Cover-Stego-Datenpaaren mit den zu testenden Variationen aus dem **Testprotokoll** und dazugehörigen Metadaten (Auslesen erfolgreich?/Detektion erfolgreich?)
- [X] (KW47) Erarbeitung eines **Testprotokolls** (Tabelle und Ablaufdiagramm) für die Testziele
  - [X] (1) Variation von Schlüssel/Password unter Beachtung von kurzen und langen Schlüssel und des kompletten Schlüsselraums
  - [X] (2) Variation des Einbettungstextes/Payload (kurz, lang)
  - [X] (3) Kombinationen Schlüssel/Password-Payload sowie einschließlich Qualitätssicherungsmaßnehmen (Einbettung- und Auslesen erfolgreich plus Steganalysis erfolgreich oder nicht) im Intra- und Inter-Stegoverfahrenvergleich und Intra- und Intermedienvergleich 
  - [X] **Tabelle** für die **Testziele** (1)-(3): für **jedes Stego-Tool** (**jphide/jpseek**, **jsteg**, **outguess**, **outguess-0.13**, **steghide**, **f5**) werden, insofern die Operation unterstützt wird, **folgende Variationen** berücksichtigt <details><summary>Tabelle</summary>
    | Schlüssel/Passwort | Einbettungsdaten | nicht-unterstützte Tools |
    | :---: | :---: | --- |
    | kein Schlüssel | kurze Einbettung | jphide, steghide |
    | kein Schlüssel | mittellange Einbettung | jphide, steghide |
    | kein Schlüssel | lange Einbettung | jphide, steghide |
    | kein Schlüssel | Einbettung mit geringer Entropie | jphide, steghide |
    | kein Schlüssel | binäre Einbettung | jphide, steghide, f5 |
    | kurzer Schlüssel | kurze Einbettung | jsteg |
    | kurzer Schlüssel | mittellange Einbettung | jsteg |
    | kurzer Schlüssel | lange Einbettung | jsteg |
    | kurzer Schlüssel | Einbettung mit geringer Entropie | jsteg |
    | kurzer Schlüssel | binäre Einbettung | jsteg, f5 |
    | langer Schlüssel | kurze Einbettung | jsteg |
    | langer Schlüssel | mittellange Einbettung | jsteg |
    | langer Schlüssel | lange Einbettung | jsteg |
    | langer Schlüssel | Einbettung mit geringer Entropie | jsteg |
    | langer Schlüssel | binäre Einbettung | jsteg, f5 |
    - **jphide**: benötigt zwangsweise eine Schlüssel zur Einbettung, kein Schlüssel wird nicht unterstützt
      - `2 Schlüsselvariationen ⋅ 5 Einbettungen = 10 Stego-Einbettungen` nach Testprotokoll
    - **jsteg**: unterstützt generell keine Einbettungsschlüssel
      - `1 Schlüsselvariation ⋅ 5 Einbettungen = 5 Stego-Einbettungen` nach Testprotokoll
    - **outguess**:
      - `3 Schlüsselvariationen ⋅ 5 Einbettungen = 15 Stego-Einbettungen` nach Testprotokoll
    - **outguess-0.13**:
      - `3 Schlüsselvariationen ⋅ 5 Einbettungen = 15 Stego-Einbettungen` nach Testprotokoll
    - **steghide**: benötigt zwangsweise eine Schlüssel zur Einbettung, kein Schlüssel wird nicht unterstützt
      - `2 Schlüsselvariationen ⋅ 5 Einbettungen = 10 Stego-Einbettungen` nach Testprotokoll
    - **f5**: Binärdaten werden nicht unterstützt, da die Einbettungsdaten als Parameter übergeben werden und Steuerzeichen dabei falsch interpretiert werden können, was zu falschem Auslesen führt
      - `3 Schlüsselvariationen ⋅ 4 Einbettungen = 12 Stego-Einbettungen` nach Testprotokoll
    - das bedeutet in der Summe `67 Stego-Einbettungen` pro Cover-Bild
    - **kurzer Schlüssel**: `4 Bytes`, langer Schlüssel: `50 Bytes`
    - **kurze Einbettung**: `67 Bytes`, mittellange Einbettung: `1.53 KB`, lange Einbettung: `17.5 KB`, Einbettung mit geringer Entropie: `16 KB`, binäre Einbettung: `16.8 KB`
    </details>
  - [X] [**Ablaufdiagramm**](./presentations/flowchart.md) für die **Testziele** (1)-(3) <details><summary>Tabelle</summary>
    | Phase | Anmerkungen |
    | --- | --- |
    | Qualitätssicherungsmaßnahmen | Prüfung der Docker-Umgebung; ImageMagick-Installation; Existenz der angegebenen Cover-Daten; Zählen der verfügbaren JPG-Dateien im Bildtestset; Herunterladen der Test-Einbettungsdaten, falls diese nicht vorhanden sind |
    | Einbettungsphase | Einbetten und Extrahieren der Test-Einbettungsinhalte nach Testprotokoll |
    | Steganalyse | fehlerhafte Einbettungen (Stego-Bild ist leer) werden übersprungen, da leere Dateien keinen Mehrwert für weitere Analysen bieten; relevante Attributierungsmerkmale (Tabellen oben) werden aus den beim Screening generierten Daten geparsed und in CSV gespeichert |
    | Evaluation | bei Steganalyse erstellte CSV wird ausgewertet; Endergebnisse werden in finalen Output geschrieben |
    </details>
- [ ] (KW46/47) Auswahl von Werkzeugen zur Analyse und Recherche nach Bildmerkmalen zur Unterscheidung (Attributierung)
  - [X] Auswahl an Werkzeugen/Programmcode zur Analyse <details><summary>Tabelle</summary>
    | Tool | Stego-Tool | Stego-Analysis | General Screening/Utility | Anmerkungen zum Tool |
    | --- | :---: | :---: | :---: | --- |
    | `jphide`/`jpseek` | ✅ | ✅ | ❌ | ✅ vollständig implementiert, 📋 **TODO**: SegFault Error |
    | `jsteg` | ✅ | ✅ | ❌ | ✅ vollständig implementiert |
    | `outguess` | ✅ | ✅ | ❌ | ✅ vollständig implementiert, bildabhängiger Crash möglich |
    | `outguess-0.13` | ✅ | ✅ | ❌ | ✅ vollständig implementiert, bildabhängiger Crash möglich |
    | `steghide` | ✅ | ✅ | ❌ | ✅ vollständig implementiert |
    | `f5` | ✅ | ✅ | ❌ | ✅ vollständig implementiert, Ausführung teilweise extrem langsam (deshalb nur Bilder kleiner 1024x1024) |
    | `stegoveritas` | ❌ | ✅ | ❌ | ✅ vollständig implementiert, Ausführung relativ langsam (deshalb nur Bilder kleiner 1024x1024) |
    | `stegdetect` | ❌ | ✅ | ❌ | ✅ vollständig implementiert |
    | `stegbreak` | ❌ | ✅ | ❌ | ✅ vollständig implementiert, 📋 **TODO**: SegFault Error bei 90% |
    | `file` | ❌ | ❌ | ✅ | ✅ vollständig implementiert |
    | `exiftool` | ❌ | ❌ | ✅ | ✅ vollständig implementiert |
    | `binwalk` | ❌ | ❌ | ✅ | ✅ vollständig implementiert |
    | `strings` | ❌ | ❌ | ✅ | ✅ vollständig implementiert |
    | `foremost` | ❌ | ❌ | ✅ | ✅ vollständig implementiert |
    | `identify` (imagemagick) | ❌ | ❌ | ✅ | ✅ vollständig implementiert |
    | `compare` (imagemagick) | ❌ | ❌ | ✅ | ✅ vollständig implementiert | </details>
  - [ ] **tabellarische Zusammenfassung statistischer Bildmerkmale** zur Unterscheidung/Attributierung <details><summary>Tabelle</summary>
    | statistisches Bildmerkmal | Anmerkung |
    | --- | --- |
    | Dateiinhalt | beinhaltet die Stego-Bilddatei überhaupt Daten? |
    | Einbettungsinhalt | konnte der Einbettungsinhalt ohne Verluste aus der Stego-Bilddatei extrahiert werden? |
    | Bildformat/MIME-Type | ist das Bild nach der Einbettung immer noch ein gültiges JPEG-Bild? |
    | JFIF und Encoding | bleibt das Grafikformat/Encoding durch die Einbettung erhalten? |
    | Dateigröße | inwiefern ändert sich die Dateigröße durch Einbettung? |
    | Kamera | werden Metainformationen wie die verwendete Aufnahmekamera durch die Einbettung verworfen? |
    | Auflösung | wird die Auflösung durch die Manipulation geändert? |
    | Dateiheader | ist eine Manipulation am Dateiheader erkennbar? |
    | ... | ... | </details>
  - [ ] **tabellarische Zusammenfassung inhaltsbasierter Bildmerkmale** zur Unterscheidung/Attributierung <details><summary>Tabelle</summary>
    | inhaltsbasiertes Bildmerkmal | Anmerkung |
    | --- | --- |
    | Differenzbild | lässt sich im Differenzbild (vorher/nachher) die Einbettung erkennen? |
    | Kanten | findet die Einbettung vorrangig an Kanten statt? |
    | Farbkanäle | wurde speziell ein einzelner Farbkanal manipuliert? |
    | generell Farbwerte | wie ändern sich z.B. Farbminima, -maxima, -durchschnittswerte und Entropie? |
    | ... | ... | </details>
  - [ ] Wohin damit? <details><summary>Tabelle</summary>
    | Merkmal | Anmerkung |
    | --- | --- |
    | stegdetect | konnte `stegdetect` die Einbettung identifizieren? |
    | stegbreak | konnte `stegbreak` die Einbettung identifizieren? |
    | fehlerhafte Einbettungen | welche Tools haben Probleme bei welchen Einbettungsvariationen? |
    | ... | ... | </details>
- [ ] (KW47) Auswahl, Umsetzung und Analyse von Bildmerkmalen zur Unterscheidung (Attributierung) auf Basis der **tabellarischen Zusammenfassung** für die Cover-Stego-Paare in den Variationen (1)-(3)
- [ ] (KW48) Detailanalyse der Stego-Cover-Daten vor den Testzielen (Variationen) vor den ausgewählten zu untersuchenden Bildmerkmalen
- [ ] (KW48) Umsetzung und Untersuchung sowie Dokumentation und Bewertung der betrachteten Testfälle
- [ ] Darstellen der Ergebnisse im Intra- und Inter-Verfahren- und Intra-/Intermedien-Vergleich 
## Abschlussreport-Notizen
- [ ] f5-Ausführung langsam --> Begründung für eingeschränkte Tests
- [ ] Nutzen alter Tools notwendig, da neue Stego-Algorithmen nicht veröffentlicht werden, da die Verfahren dadurch bekannt werden würden
- [ ] Differenzbild von Original und Gimp Export (mit Übernahme der Originalparameter) weist einige wenige Stellen im Differenzbild auf
- [ ] Ausblick: Implementierung von neuronalen Netzen mit höherer stat. Signifikanz und inhaltsbasierter Betrachtung
- [ ] Ausblick: Bessere Differenzbildanalyse möglich durch genauere Codeuntersuchungen der verwendeten Tools

# Documentation
## Project Components
- [Stego-Toolkit Reference](https://github.com/DominicBreuker/stego-toolkit)
- [ImageMagick](https://imagemagick.org/)
- `stego-docker.sh` is meant to manage the docker environment
- `stego-attrib.sh` is meant to perform stego testset generation, analysis and evaluation; therefore it will be executed **inside** a docker container to call the stego tools
- `coverData` contains JPEG-image testset

## Environment Setup (Docker)
1. pull this repo and open terminal in `./amsl-it-security-projects/SMKITS5/`
2. run `./stego-docker.sh --setup` to install and configure docker, then make sure your docker container has stego-toolkit installed by running `./stego-docker.sh --pull` (make scripts executable using `chmod +x ./stego-docker.sh` and `chmod +x ./stego-attrib.sh`)
3. start docker container using `./stego-docker.sh --run`
4. while your docker instance is running, you can import files (**use a new terminal instance!**) to the container: use `./utility/dockerImportDefaults.sh` for the first time setup; otherwise use `./stego-docker.sh --import <file/directory>` for custom imports

## Attribution Script Usage (inside Docker Container)
- `./stego-attrib.sh` for help
- start by trying `./stego-attrib.sh -f -v`, it will generate a testset by using the first image in your cover data directory and analyse the generated stego files
- important switches:
  - `-i` or `--input`: set input directory (path to your cover files, this argument is **mandatory**)
  - `-o` or `--output`: set output directory (default is `./out-stego-attrib`)
  - `-n` or `--size`: set the amount of cover files to analyse (default is `1`)
  - `-m` or `--offset`: set the amount of cover files skip (default is `0`, meant for parallelization)
  - `-r` or `--randomize`: randomize the cover image selection
  - `-c` or `--clean`: clean the output directory prior to the generation
  - `-d` or `--delete`: delete analysis data after evaluation
  - `-f` or `--fast`: skip stego tool `f5` and stego analysis tool `stegoveritas` for every image, as those are the tools need the most time doing their thing; by default, f5 and stegoveritas will be skipped for images larger than `1024x1024`
  - `-v` or `--verbose`: print every command execution to terminal
  - `-h` or `--help`: display usage
