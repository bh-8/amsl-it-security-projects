# Attribution of Steganography and hidden Communication (jpg)
## Components
- [Stego-Toolkit Reference](https://github.com/DominicBreuker/stego-toolkit) (no need to download, just for reference)
- `stego-docker.sh` is meant to manage the docker environment
- `stego-attrib.sh` is meant to perform stego testset generation, analysis and evaluation;  
  therefore it will be executed **inside** a docker container to call the stego tools
## Environment Setup (Docker)
- put `stego-docker.sh` and `stego-attrib.sh` to any directory you want to work in
- make both scripts executable using `chmod +x ./stego-docker.sh` and `chmod +x ./stego-attrib.sh`
- run `./stego-docker.sh --setup` to install and configure docker (this will also update & upgrade apt)
- make sure your docker container has stego-toolkit installed by running `./stego-docker.sh --pull`
- now you should be able to run your docker container by calling `./stego-docker.sh --run`
- you should add **jpg cover files** to your docker container (e.g. download [kaggle/alaska2 cover files](https://www.kaggle.com/competitions/alaska2-image-steganalysis/data?select=Cover)) to have something to work with
- while your docker instance is running, you can import files (**use a new terminal instance!**) to the container with `./stego-docker.sh --import ./your_cover_file_directory`
- also do not forget to import `stego-attrib.sh` by running `./stego-docker.sh --import ./stego-attrib.sh`
## Attribution Script Usage
- the following is done inside the docker container
- you will need some example cover data and the imported `stego-attrib.sh` (see above)
### Performing an analysis
- `./stego-attrib.sh -i ./your_cover_file_directory` is the most minimal call, it will generate a testset by using the first image in your cover data directory and analyse the generated stego files
- possible switches are
  - `-i` or `--input`: set input directory (path to your cover files, this argument is **mandatory**)
  - `-o` or `--output`: set output directory (default is `./out-stego-attrib`)
  - `-n` or `--size`: set the amount of cover files to analyse (default is `1`)
  - `-r` or `--randomize`: randomize the cover image selection
  - `-c` or `--clean`: clean the output directory prior to the generation
  - `-f` or `--fast`: skip stego tool `f5` and stego analysis tool `stegoveritas`, as those are the tools need the most time doing their thing
  - `-v` or `--verbose`: print every command execution to terminal
  - `-h` or `--help`: display usage
## ToDo-Liste nach Aufgabenstellung
### Aufgabenstellung
[ ] Erstellung eines Original-Bildtestsets (Coverdaten)
  - testset um bilder von handy-kamera erweitern und in github hochladen... gesamtgröße??
[ ] Recherche nach Bildmerkmalen zur Unterscheidung (Attributierung)
  [ ] statistische Bildmerkmale
  [ ] inhaltsbasierte Bildmerkmale (Differenzbild, Kanten, ...)
  [ ] tabellarische Zusammenfassung sowie Auswahl an Werkzeugen/Programmcode zur Analyse
[ ] Erarbeitung eines Testprotokolls (Tabelle und Ablaufdiagramm) für die Testziele
  [ ] (1) Variation von Schlüssel/Password unter Beachtung von kurzen und langen Schlüssel und des kompletten Schlüsselraums
  [ ] (2) Variation des Einbettungstextes/Payload (kurz, lang)
  [ ] (3) Kombinationen Schlüssel/Password-Payload sowie einschließlich Qualitätssicherungsmaßnehmen (Einbettung- und Auslesen erfolgreich plus Steganalysis erfolgreich oder nicht) im Intra- und Inter-Stegoverfahrenvergleich und Intra- und Intermedienvergleich 
[ ] zu nutzende Tools:
  [X] Stego-Tools: jphide/jpseek, jsteg, steghide, outguess, outguess-0.13, f5
  [X] Stego-Analysis-Tools: stegdetect, outguess, outguess-0.13, jsteg, stegoveritas
[ ] Auswahl, Umsetzung und Analyse von Bildmerkmalen zur Unterscheidung (Attributierung) auf Basis der tabellarischen Zusammenfassung (alle) für die Cover-Stego-Paare in den Variationen (1)-(3)
[ ] Detailanalyse der Stego-Cover-Daten vor den Testzielen (Variationen) vor den ausgewählten zu untersuchenden Bildmerkmalen
[ ] Umsetzung und Untersuchung sowie Dokumentation und Bewertung der betrachteten Testfälle
[ ] Darstellen der Ergebnisse im Intra- und Inter-Verfahren- und Intra-/Intermedien-Vergleich 
### Script
[ ] Fix --shuffle -> --randomize
[ ] mittlere Einbettungslänge, lange explizit länger (Lizenztext)
[ ] jphide Kompilierung (siehe email)
[ ] imageMagick verwenden (Differenzbild, ...) siehe https://stackoverflow.com/questions/5132749/diff-an-image-using-imagemagick
[ ] stegoveritas-Auswertung
[ ] stegbreak implementierung
[ ] steghide extract implementierung
[ ] strings-Tool: wie sinnvoll auswerten?
[ ] total detect count for cover
