# Attribution of Steganography and hidden Communication (jpg)
## Aufgabenstellung und Fortschritt
- [X] (KW45) Auswahl an zu nutzenden Stego-Verfahren/Tools:
  - [X] Stego-Tools: jphide/jpseek, jsteg, outguess, outguess-0.13, steghide, f5
  - [X] Stego-Analysis-Tools: stegoveritas, stegdetect, stegbreak
- [X] (KW45/46) Erstellung eines [Original-Bildtestsets](./coverData) bestehend aus 1024 Bildern aus folgenden Quellen:
  - [Kaggle/Alaska2](https://www.kaggle.com/competitions/alaska2-image-steganalysis/data?select=Cover) Datenbank, Farbbilder, 512x512 (640x)
  - [BOWS2](http://bows2.ec-lille.fr/) Datenbank, Schwarz-Weiß-Bilder, 512x512 (192x)
  - private Bilder, verschiedenste Auflösungen und Größen (192x)
- [ ] (KW46/47) Auswahl von Werkzeugen zur Analyse und Recherche nach Bildmerkmalen zur Unterscheidung (Attributierung)
  - [X] Auswahl an Werkzeugen/Programmcode zur Analyse:
    | Tool | Stego-Tool | Stego-Analysis | General Screening/Utility | Anmerkungen zum Tool |
    | --- | :---: | :---: | :---: | --- |
    | `jphide`/`jpseek` | ✅ | ✅ | ❌ | 📋 **TODO**: Neukompilierung läuft in Docker aktuell nicht (?), stegbreak dementsprechend noch ausstehend für jphide, 📋 **TODO**: Auswertung (KW47) |
    | `jsteg` | ✅ | ✅ | ❌ | ✅ vollständig implementiert, **keine** Unterstützung von **Einbettungsschlüsseln**, 📋 **TODO**: Auswertung (KW47) |
    | `outguess` | ✅ | ✅ | ❌ | ✅ vollständig implementiert, **keine** Unterstützung von **Binärdaten-Einbettung**, Bildabhängiger Crash bei Analyse tritt relativ häufig auf, 📋 **TODO**: Auswertung (KW47) |
    | `outguess-0.13` | ✅ | ✅ | ❌ | ✅ vollständig implementiert, **keine** Unterstützung von **Binärdaten-Einbettung**, Bildabhängiger Crash bei Analyse tritt relativ häufig auf, 📋 **TODO**: Auswertung (KW47) |
    | `steghide` | ✅ | ✅ | ❌ | ✅ vollständig implementiert, **keine** Ausführung **ohne Einbettungsschlüssel** möglich, 📋 **TODO**: Auswertung (KW47) |
    | `f5` | ✅ | ✅ | ❌ | ✅ vollständig implementiert, **keine** Unterstützung von **Binärdaten-Einbettung**, Ausführung teilweise extrem langsam, 📋 **TODO**: Auswertung (KW47) |
    | `stegoveritas` | ❌ | ✅ | ❌ | Ausführung relativ langsam, 📋 **TODO**: Auswertung (siehe `imagemagick`) (KW47) |
    | `stegdetect` | ❌ | ✅ | ❌ | 📋 **TODO**: Auswertung (KW47) |
    | `stegbreak` | ❌ | ✅ | ❌ | 📋 **TODO**: https://www.linux-community.de/ausgaben/linuxuser/2008/04/stegdetect-und-stegbreak/2/ , 📋 **TODO**: Auswertung (KW47) |
    | `file` | ❌ | ❌ | ✅ | ✅ vollständig implementiert |
    | `exiftool` | ❌ | ❌ | ✅ | ✅ vollständig implementiert |
    | `binwalk` | ❌ | ❌ | ✅ | ✅ vollständig implementiert |
    | `strings` | ❌ | ❌ | ✅ | ✅ vollständig implementiert, 📋 **TODO**: Auswertung (KW47) |
    | `foremost` | ❌ | ❌ | ✅ | ✅ vollständig implementiert, 📋 **TODO**: Auswertung verbessern? (KW47) |
    | `identify` (imagemagick) | ❌ | ❌ | ✅ | ✅ vollständig implementiert, 📋 **TODO**: Auswertung verbessern? (KW47) |
    | `compare` (imagemagick) | ❌ | ❌ | ✅ | ✅ vollständig implementiert, Erstellung von Differenzbildern |
  - [ ] **tabellarische Zusammenfassung statistischer Bildmerkmale** zur Unterscheidung/Attributierung:
    | statistisches Bildmerkmal | Anmerkung |
    | --- | --- |
    | Bildformat/MIME-Type | Ist das Bild nach der Einbettung immer noch ein gültiges JPEG-Bild? |
    | JFIF | Bleibt das Grafikformat durch die Einbettung erhalten? |
    | Auflösung | Wird die Auflösung durch die Manipulation geändert? |
    | Kodierung | Verändert sich die Kodierung durch die Einbettung (DCT)? |
    | Bits pro Pixel | Wird die Bittiefe geändert?  |
    | Dateigröße | Inwiefern ändert sich die Dateigröße durch Einbettung? |
    | ... | ... |
  - [ ] **tabellarische Zusammenfassung inhaltsbasierter Bildmerkmale** zur Unterscheidung/Attributierung:
    | inhaltsbasiertes Bildmerkmal | Anmerkung |
    | --- | --- |
    | Differenzbild | Lässt sich im Differenzbild (vorher/nachher) die Einbettung erkennen? |
    | Kanten | Findet die Einbettung an speziellen Bildstellen, z.B. an Kanten statt? |
    | RGB-Farbwerte (Minima, Maxima, Mittelwert, Standardabweichung) | Wie ändert sich das Bild optisch? |
    | ... | ... |
- [ ] (KW48) Erarbeitung eines **Testprotokolls** (Tabelle und Ablaufdiagramm) für die Testziele
  - [ ] (1) Variation von Schlüssel/Password unter Beachtung von kurzen und langen Schlüssel und des kompletten Schlüsselraums
  - [ ] (2) Variation des Einbettungstextes/Payload (kurz, lang)
  - [ ] (3) Kombinationen Schlüssel/Password-Payload sowie einschließlich Qualitätssicherungsmaßnehmen (Einbettung- und Auslesen erfolgreich plus Steganalysis erfolgreich oder nicht) im Intra- und Inter-Stegoverfahrenvergleich und Intra- und Intermedienvergleich 
  - [ ] **Tabelle** für die **Testziele** (1)-(3): für **jedes Stego-Tool** (jphide/jpseek, jsteg, outguess, outguess-0.13, steghide, f5) werden, insofern die Operation unterstützt wird, **folgende Variationen** berücksichtigt:
    | Schlüssel/Passwort | Einbettungsdaten | nicht-unterstützte Tools |
    | --- | --- | --- |
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
    - kurzer Schlüssel: 4 Bytes
    - langer Schlüssel: 50 Bytes
    - kurze Einbettung: 67 Bytes
    - mittellange Einbettung: 1.53 KB
    - lange Einbettung: 17.5 KB
    - Einbettung mit geringer Entropie: 16 KB
    - binäre Einbettung: 16.8 KB
  - [ ] **Ablaufdiagramm** für die **Testziele** (1)-(3):
    - 📋 **TODO** (https://mermaid-js.github.io/mermaid/#/flowchart)
    ```mermaid
    flowchart LR;
      start["Start"]
      subgraph Vorbereitung
        direction TB
        params["Parameter Checks"]
        env["Environment Checks"]
        params-->env
      end
      subgraph Coveranalyse
        direction TB
        new["Cover-Bild"]
        embed["Einbettungen nach Testprotokoll"]
        subgraph Analyse
          direction LR
          screening["Screening"]
          parsing["Parsing"]
          screening-->parsing
        end
        eval["Evaluation"]
        new-->embed
        embed-->screening
        parsing-->eval
        eval--nächstes Cover-->new
      end
      start-->params
      env-->new
    ```
- [ ] (KW49) Erstellung von Cover-Stego-Datenpaaren mit den zu testenden Variationen aus dem **Testprotokoll** und dazugehörigen Metadaten (Auslesen erfolgreich?/Detektion erfolgreich?)
- [ ] (KW49) Auswahl, Umsetzung und Analyse von Bildmerkmalen zur Unterscheidung (Attributierung) auf Basis der **tabellarischen Zusammenfassung** für die Cover-Stego-Paare in den Variationen (1)-(3)
- [ ] Detailanalyse der Stego-Cover-Daten vor den Testzielen (Variationen) vor den ausgewählten zu untersuchenden Bildmerkmalen
- [ ] Umsetzung und Untersuchung sowie Dokumentation und Bewertung der betrachteten Testfälle
- [ ] Darstellen der Ergebnisse im Intra- und Inter-Verfahren- und Intra-/Intermedien-Vergleich 
### Script
- [ ] evaluation overhaul (KW 47)

## Project Components
- [Stego-Toolkit Reference](https://github.com/DominicBreuker/stego-toolkit)
- `stego-docker.sh` is meant to manage the docker environment
- `stego-attrib.sh` is meant to perform stego testset generation, analysis and evaluation; therefore it will be executed **inside** a docker container to call the stego tools
- `coverData` contains JPEG-image testset

## Environment Setup (Docker)
- pull this repo and open terminal in `./amsl-it-security-projects/SMKITS5/`
- make scripts executable using `chmod +x ./stego-docker.sh` and `chmod +x ./stego-attrib.sh`
- run `./stego-docker.sh --setup` to install and configure docker
- make sure your docker container has stego-toolkit installed by running `./stego-docker.sh --pull`
- now you should be able to run your docker container by calling `./stego-docker.sh --run`
- while your docker instance is running, you can import files (**use a new terminal instance!**) to the container:
  - `./stego-docker.sh --import ./coverData`
  - `./stego-docker.sh --import ./stego-attrib.sh`
  - **or** use the shortcut `./utility/dockerImportDefaults.sh` if you want to use default files

## Attribution Script Usage
- the following is done inside the docker container
- `./stego-attrib.sh -i ./coverData` is the most minimal call, it will generate a testset by using the first image in your cover data directory and analyse the generated stego files
- possible switches are
  - `-i` or `--input`: set input directory (path to your cover files, this argument is **mandatory**)
  - `-o` or `--output`: set output directory (default is `./out-stego-attrib`)
  - `-n` or `--size`: set the amount of cover files to analyse (default is `1`)
  - `-r` or `--randomize`: randomize the cover image selection
  - `-c` or `--clean`: clean the output directory prior to the generation
  - `-f` or `--fast`: skip stego tool `f5` and stego analysis tool `stegoveritas`, as those are the tools need the most time doing their thing
  - `-v` or `--verbose`: print every command execution to terminal
  - `-h` or `--help`: display usage
