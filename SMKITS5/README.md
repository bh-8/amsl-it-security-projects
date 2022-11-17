# Attribution of Steganography and hidden Communication (jpg)
## Aufgabenstellung und Fortschritt
- [X] Erstellung eines Original-Bildtestsets (Coverdaten)
  - [Cover-Set](./coverData) besteht aus 1024 Bildern aus folgenden Quellen:
  - [Kaggle/Alaska2](https://www.kaggle.com/competitions/alaska2-image-steganalysis/data?select=Cover) Datenbank, Farbbilder, 512x512 (640x)
  - [BOWS2](http://bows2.ec-lille.fr/) Datenbank, Schwarz-Weiß-Bilder, 512x512 (192x)
  - private Bilder, verschiedenste Auflösungen und Größen (192x)
- [ ] Recherche nach Bildmerkmalen zur Unterscheidung (Attributierung): statistische, inhaltliche, und Auswahl von Werkzeugen zur Analyse
  - [ ] **tabellarische Zusammenfassung** statistischer Bildmerkmale zur Unterscheidung/Attributierung
    | statistisches Bildmerkmal | Anmerkung |
    | --- | --- |
    | Bildformat/MIME-Type | ist das Bild nach der Einbettung immer noch ein gültiges JPEG-Bild? |
    | JFIF | bleibt das Grafikformat durch die Einbettung erhalten? |
    | Auflösung | Wird die Auflösung durch die Manipulation geändert? |
    | Kodierung | Verändert sich die Kodierung durch die Einbettung (DCT) |
    | Bits pro Pixel | Wird die Bittiefe geändert?  |
    | Dateigröße | Inwiefern ändert sich die Dateigröße durch Einbettung? |
    | ... | ... |
  - [ ] **tabellarische Zusammenfassung** inhaltsbasierter Bildmerkmale zur Unterscheidung/Attributierung
    | inhaltsbasiertes Bildmerkmal | Anmerkung |
    | --- | --- |
    | Differenzbild | Lässt sich im Differenzbild (vorher/nachher) die Einbettung erkennen? |
    | Kanten | Findet die Einbettung an speziellen Bildstellen, z.B. an Kanten statt? |
    | RGB-Farbwerte (Minima, Maxima, Mittelwert, Standardabweichung) | Wie ändert sich das Bild optisch? |
    | ... | ... |
  - [ ] Auswahl an Werkzeugen/Programmcode zur Analyse (unvollständige Umsetzung*)
    | Tool | Stego-Tool | Stego-Analysis | General Screening/Utility | Anmerkungen zum Tool |
    | --- | --- | --- | --- | --- |
    | `jsteg` | ✅ | ✅ | ❌ | keine Unterstützung für Einbettungsschlüssel |
    | `steghide` | ✅ | ✅ | ❌ | **TODO**: Script-Implementierung unvollständig |
    | `f5` | ✅ | ❌ | ❌ | Ausführung langsam |
    | `outguess` | ✅ | ✅ | ❌ | keine Unterstützung für Binärdaten-Einbettung, bildabhängiger Crash bei Analyse tritt relativ häufig auf |
    | `outguess-0.13` | ✅ | ✅ | ❌ | keine Unterstützung für Binärdaten-Einbettung, bildabhängiger Crash bei Analyse tritt relativ häufig auf |
    | `jphide`/`jpseek` | ✅ | ✅ | ❌ | **TODO**: Neukompilierung erforderlich, erst dann im Script implementierbar |
    | `stegdetect` | ❌ | ✅ | ❌ | - |
    | `stegoveritas` | ❌ | ✅ | ❌ | **TODO**: Script-Implementierung bzw. Auswertung ausstehend, evtl. mit `imagemagick`?; Ausführung langsam |
    | `stegbreak` | ❌ | ✅ | ❌ | **TODO**: Script-Implementierung ausstehend |
    | `file` | ❌ | ❌ | ✅ | **TODO**: evtl. redundante Informationen mit `exiftool` |
    | `exiftool` | ❌ | ❌ | ✅ | - |
    | `binwalk` | ❌ | ❌ | ✅ | - |
    | `strings` | ❌ | ❌ | ✅ | **TODO**: effiziente Auswertung problematisch |
    | `foremost` | ❌ | ❌ | ✅ | - |
    | `identify` | ❌ | ❌ | ✅ | - |
    | `imagemagick` | ❌ | ❌ | ✅ | **TODO**: Script-Implementierung ausstehend; Allgemeines Utility-Tool für Arbeit mit Bildern |
- [ ] Erarbeitung eines **Testprotokolls** (Tabelle und Ablaufdiagramm) für die Testziele
  - [ ] (1) Variation von Schlüssel/Password unter Beachtung von kurzen und langen Schlüssel und des kompletten Schlüsselraums
  - [ ] (2) Variation des Einbettungstextes/Payload (kurz, lang)
  - [ ] (3) Kombinationen Schlüssel/Password-Payload sowie einschließlich Qualitätssicherungsmaßnehmen (Einbettung- und Auslesen erfolgreich plus Steganalysis erfolgreich oder nicht) im Intra- und Inter-Stegoverfahrenvergleich und Intra- und Intermedienvergleich 
- [ ] Auswahl an zu nutzenden Stego-Verfahren/Tools:
  - [X] Stego-Tools: jphide/jpseek, jsteg, steghide, outguess, outguess-0.13, f5
  - [ ] Stego-Analysis-Tools: stegdetect, outguess, outguess-0.13, jsteg, stegoveritas
- [ ] Erstellung von Cover-Stego-Datenpaaren mit den zu testenden Variationen aus dem **Testprotokoll** und dazugehörigen Metadaten (Auslesen erfolgreich?/Detektion erfolgreich?)
- [ ] Auswahl, Umsetzung und Analyse von Bildmerkmalen zur Unterscheidung (Attributierung) auf Basis der **tabellarischen Zusammenfassung** für die Cover-Stego-Paare in den Variationen (1)-(3)
- [ ] Detailanalyse der Stego-Cover-Daten vor den Testzielen (Variationen) vor den ausgewählten zu untersuchenden Bildmerkmalen
- [ ] Umsetzung und Untersuchung sowie Dokumentation und Bewertung der betrachteten Testfälle
- [ ] Darstellen der Ergebnisse im Intra- und Inter-Verfahren- und Intra-/Intermedien-Vergleich 
### Script
- [ ] Fix --shuffle -> --randomize
- [ ] mittlere Einbettungslänge, lange explizit länger (Lizenztext)
- [ ] imageMagick verwenden (Differenzbild, ...) siehe https://stackoverflow.com/questions/5132749/diff-an-image-using-imagemagick
- [ ] total detect count for cover

## Project Components
- [Stego-Toolkit Reference](https://github.com/DominicBreuker/stego-toolkit)
- `stego-docker.sh` is meant to manage the docker environment
- `stego-attrib.sh` is meant to perform stego testset generation, analysis and evaluation;  
  therefore it will be executed **inside** a docker container to call the stego tools
- `coverData` contains JPEG-image testset

## Environment Setup (Docker)
- pull this repo and open terminal in `./amsl-it-security-projects/SMKITS5/`
- make scripts executable using `chmod +x ./stego-docker.sh` and `chmod +x ./stego-attrib.sh`
- run `./stego-docker.sh --setup` to install and configure docker (this will also update & upgrade apt)
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
