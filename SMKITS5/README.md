# SMKITS5
## Attribution of Steganography and hidden Communication (jpg)
| Projektstruktur | Referenz |
| --- | --- |
| Projekt-Dokumentation | [./docs/](./docs/) |
| Coverbild-Testset (`192+192+640 .jpg-Dateien`) | [./coverData/](./coverData/) |
| Entwicklungsartefakte | [./dev-artifacts/](./dev-artifacts/) |
| Einbettungsdaten | [./embeddingData/](./embeddingData/) |
| `stego-attrib.sh` (Umsetzung der Untersuchung nach Testprotokoll) | [./stego-attrib.sh](./stego-attrib.sh) |
| `stego-docker.sh` (Management der Docker-Umgebung) | [./stego-docker.sh](./stego-docker.sh) |
| `stego-docker-importDefaults.sh` (Standarddaten-Import in Container) | [./stego-docker-importDefaults.sh](./stego-docker-importDefaults.sh) |
| `stego-utils-buildTestset.sh` (Zusammenkopieren des Coverbild-Testsets) | [./stego-utils-buildTestset.sh](./stego-utils-buildTestset.sh) |
| `stego-utils-generateDiagrams.sh` (Diagramme ausgewählter Attribute generieren) | [./stego-utils-generateDiagrams.sh](./stego-utils-generateDiagrams.sh) |
| `stego-utils-recompressAndDiffCC.sh` (Bildneukompression) | [./stego-utils-recompressAndDiffCC.sh](./stego-utils-recompressAndDiffCC.sh) |
## Aufgabenstellung
- [ ] aktuelle [ToDo-Liste](./docs/todo.md)
- [ ] Umsetzung des SMK-Aspektes
  - [X] [Meeting Protokoll](./docs/meetings.md)
  - [ ] Bericht
- [X] [KW45] Auswahl an zu nutzenden Stego-Verfahren/Tools:
  - [X] Stego-Tools: jphide/jpseek, jsteg, outguess, outguess-0.13, steghide, f5
  - [X] Stego-Analysis-Tools: stegoveritas, stegdetect, stegbreak
- [X] [KW45/46] Erstellung eines [Original-Bildtestsets](./coverData) (bestehend aus 1024 Bildern)
- [X] [KW46/47] Erstellung von Cover-Stego-Datenpaaren mit den zu testenden Variationen aus dem **Testprotokoll** und dazugehörigen Metadaten (Auslesen erfolgreich?/Detektion erfolgreich?)
- [X] [KW47] Erarbeitung eines **Testprotokolls** (Tabelle und Ablaufdiagramm) für die Testziele
  - [X] (1) Variation von Schlüssel/Password unter Beachtung von kurzen und langen Schlüssel und des kompletten Schlüsselraums
  - [X] (2) Variation des Einbettungstextes/Payload (kurz, lang)
  - [X] (3) Kombinationen Schlüssel/Password-Payload sowie einschließlich Qualitätssicherungsmaßnehmen (Einbettung- und Auslesen erfolgreich plus Steganalysis erfolgreich oder nicht) im Intra- und Inter-Stegoverfahrenvergleich und Intra- und Intermedienvergleich 
  - [X] **Tabelle** für die **Testziele** (1)-(3): für **jedes Stego-Tool** werden, insofern die Operation unterstützt wird, **folgende Variationen** berücksichtigt: [Tabelle](./docs/variations.md)
  - [X] **Ablaufdiagramm** für die **Testziele** (1)-(3): [Ablaufdiagramm](./docs/flowchart.md)
- [X] [KW46/47] Auswahl von Werkzeugen zur Analyse und Recherche nach Bildmerkmalen zur Unterscheidung (Attributierung)
  - [X] **tabellarische Zusammenfassung statistischer Bildmerkmale** zur Unterscheidung/Attributierung: [Tabelle](./docs/attributes.md)
  - [X] **tabellarische Zusammenfassung inhaltsbasierter Bildmerkmale** zur Unterscheidung/Attributierung: [Tabelle](./docs/attributes.md)
  - [X] Auswahl an Werkzeugen/Programmcode zur Analyse: [Tabelle](./docs/tools.md) und [Attributierungsmerkmale](./docs/tool-attrib.md) zuordnen
- [X] [KW48] Auswahl, Umsetzung und Analyse von Bildmerkmalen zur Unterscheidung (Attributierung) auf Basis der **tabellarischen Zusammenfassung** für die Cover-Stego-Paare in den Variationen (1)-(3) pro Verfahren (Intra-Verfahrensattributierung) und Inter-Verfahrensattributierung
- [X] [KW50/51] Detailanalyse der Stego-Cover-Daten vor den Testzielen (Variationen) vor den ausgewählten zu untersuchenden Bildmerkmalen
- [ ] [KW51/52] Umsetzung und Untersuchung sowie Dokumentation und Bewertung der betrachteten Testfälle
- [ ] [KW01/02] Darstellen der Ergebnisse im Intra- und Inter-Verfahren- und Intra-/Intermedien-Vergleich 
