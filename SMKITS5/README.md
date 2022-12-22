# SMKITS5
## Attribution of Steganography and hidden Communication (jpg)
| Projektstruktur | Referenz |
| --- | --- |
| Dokumentation (Umsetzung SMK-Aspekt) | [./documentation/README.md](./documentation/README.md) |
| Originalbild-Testset (`192+192+640 .jpg-Dateien`) | [./coverData](./coverData) |
| Einbettungsdaten (nach Testprotokoll) | [./embeddingData](./embeddingData) |
| Utilities und Entwicklungsartefakte | [./utility](./utility) |
| `stego-docker.sh` (Setup der Umgebung) | [./stego-docker.sh](./stego-docker.sh) |
| `stego-attrib.sh` (Umsetzung der Untersuchung nach Testprotokoll) | [./stego-attrib.sh](./stego-attrib.sh) |
| `slurm-jobscript.sh` (Cluster-Parallelisierung) | [./slurm-jobscript.sh](./slurm-jobscript.sh) |
## Aufgaben und Fortschritt
- [X] [KW45] Auswahl an zu nutzenden Stego-Verfahren/Tools:
  - [X] Stego-Tools: jphide/jpseek, jsteg, outguess, outguess-0.13, steghide, f5
  - [X] Stego-Analysis-Tools: stegoveritas, stegdetect, stegbreak
- [X] [KW45/46] Erstellung eines [Original-Bildtestsets](./coverData) (bestehend aus 1024 Bildern)
- [X] [KW46/47] Erstellung von Cover-Stego-Datenpaaren mit den zu testenden Variationen aus dem **Testprotokoll** und dazugehörigen Metadaten (Auslesen erfolgreich?/Detektion erfolgreich?)
- [X] [KW47] Erarbeitung eines **Testprotokolls** (Tabelle und Ablaufdiagramm) für die Testziele
  - [X] (1) Variation von Schlüssel/Password unter Beachtung von kurzen und langen Schlüssel und des kompletten Schlüsselraums
  - [X] (2) Variation des Einbettungstextes/Payload (kurz, lang)
  - [X] (3) Kombinationen Schlüssel/Password-Payload sowie einschließlich Qualitätssicherungsmaßnehmen (Einbettung- und Auslesen erfolgreich plus Steganalysis erfolgreich oder nicht) im Intra- und Inter-Stegoverfahrenvergleich und Intra- und Intermedienvergleich 
  - [X] **Tabelle** für die **Testziele** (1)-(3): für **jedes Stego-Tool** werden, insofern die Operation unterstützt wird, **folgende Variationen** berücksichtigt: [Tabelle](./documentation/variations.md)
  - [X] **Ablaufdiagramm** für die **Testziele** (1)-(3): [Ablaufdiagramm](./documentation/flowchart.md)
- [X] [KW46/47] Auswahl von Werkzeugen zur Analyse und Recherche nach Bildmerkmalen zur Unterscheidung (Attributierung)
  - [X] **tabellarische Zusammenfassung statistischer Bildmerkmale** zur Unterscheidung/Attributierung: [Tabelle](./documentation/attributes.md)
  - [X] **tabellarische Zusammenfassung inhaltsbasierter Bildmerkmale** zur Unterscheidung/Attributierung: [Tabelle](./documentation/attributes.md)
  - [X] Auswahl an Werkzeugen/Programmcode zur Analyse: [Tabelle](./documentation/tools.md)
- [X] [KW48] Auswahl, Umsetzung und Analyse von Bildmerkmalen zur Unterscheidung (Attributierung) auf Basis der **tabellarischen Zusammenfassung** für die Cover-Stego-Paare in den Variationen (1)-(3) pro Verfahren (Intra-Verfahrensattributierung) und Inter-Verfahrensattributierung
- [X] Detailanalyse der Stego-Cover-Daten vor den Testzielen (Variationen) vor den ausgewählten zu untersuchenden Bildmerkmalen
- [ ] Umsetzung und Untersuchung sowie Dokumentation und Bewertung der betrachteten Testfälle
- [ ] Darstellen der Ergebnisse im Intra- und Inter-Verfahren- und Intra-/Intermedien-Vergleich 
