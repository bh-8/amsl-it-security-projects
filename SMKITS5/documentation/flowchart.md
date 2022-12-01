# SMKITS5 / Dokumentation / Ablaufdiagramm des Testprotokolls
![Flowchart SVG](./flowchart.drawio.svg)
## Anmerkungen
| Phase | Anmerkungen |
| --- | --- |
| Qualitätssicherungsmaßnahmen | Prüfung der Docker-Umgebung; ImageMagick-Installation; Existenz der angegebenen Cover-Daten; Zählen der verfügbaren JPG-Dateien im Bildtestset; Herunterladen der Test-Einbettungsdaten, falls diese nicht vorhanden sind |
| Einbettungsphase | Einbetten und Extrahieren der Test-Einbettungsinhalte nach Testprotokoll |
| Steganalyse | fehlerhafte Einbettungen (Stego-Bild ist leer) werden übersprungen, da leere Dateien keinen Mehrwert für weitere Analysen bieten; relevante Attributierungsmerkmale (Tabellen oben) werden aus den beim Screening generierten Daten geparsed und in CSV gespeichert |
| Evaluation | bei Steganalyse erstellte CSV wird ausgewertet; Endergebnisse werden in finalen Output geschrieben |
## altes Diagramm (Entwurf)
```mermaid
  flowchart TB
    start(("Start"))
    subgraph Qualitätssicherungsmaßnahmen
      direction LR
      qastart(("Start"))
      paramchecks["Parameter-Prüfungen"]
      aborthelp["Abbruch mit Syntax-Hilfe"]
      aborthelpend(("Abbruch"))
      envchecks["Umgebungsprüfungen"]
      aborterr["Abbruch mit Fehlermeldung"]
      aborterrend(("Abbruch"))
      qa["Vorbereitungen abgeschlossen"]
      qadone(("Ende"))
      
      qastart-->paramchecks
      paramchecks--"Parameterfehler"-->aborthelp
      aborthelp-->aborthelpend
      paramchecks--"Parameter OK"-->envchecks
      envchecks--"Umgebungsfehler"-->aborterr
      aborterr-->aborterrend
      envchecks--"Umgebung OK"-->qa
      qa-->qadone
    end
    subgraph Coverdatenuntersuchung
      direction TB
      coverstart(("Start"))
      subgraph Einbettungsphase
        direction LR
        embedstart(("Start"))
        subgraph jphide
          direction TB
          jpelem["jphide-Einbettung"]
          jpelemE["jpseek-Extraktion"]
          jpbreak["stegbreak"]
          jpelem-->jpelemE
          jpelemE-->jpbreak
          jpbreak--"10x"-->jpelem
        end
        subgraph jsteg
          direction TB
          jselem["jsteg-Einbettung"]
          jselemE["jsteg-Extraktion"]
          jsbreak["stegbreak"]
          jselem-->jselemE
          jselemE-->jsbreak
          jsbreak--"5x"-->jselem
        end
        subgraph outguess
          direction TB
          oelem["outguess-Einbettung"]
          oelemE["outguess-Extraktion"]
          obreak["stegbreak"]
          oelem-->oelemE
          oelemE-->obreak
          obreak--"15x"-->oelem
        end
        subgraph outguess-0.13
          direction TB
          oelem13["outguess-0.13-Einbettung"]
          oelem13E["outguess-0.13-Extraktion"]
          obreak13["stegbreak"]
          oelem13-->oelem13E
          oelem13E-->obreak13
          obreak13--"15x"-->oelem13
        end
        subgraph steghide
          direction TB
          stelem["steghide-Einbettung"]
          stelemE["steghide-Extraktion"]
          stelem-->stelemE
          stelemE--"10x"-->stelem
        end
        subgraph f5
          direction TB
          f5elem["f5-Einbettung"]
          f5elemE["f5-Extraktion"]
          f5elem-->f5elemE
          f5elemE--"12x"-->f5elem
        end
        embeddone(("Ende"))
        
        embedstart-->jphide
        jphide-->jsteg
        jsteg-->outguess
        outguess-->outguess-0.13
        outguess-0.13-->steghide
        steghide-->f5
        f5-->embeddone
      end
      subgraph Steganalyse
        direction TB
        stegostart(("Start"))
        stegocheck["Prüfen des Stego-Bildes"]
        skipempty["Steganalyse überspringen"]
        subgraph Screening-Phase
          direction TB
          file["file"]
          exiftool["exiftool"]
          binwalk["binwalk"]
          strings["strings"]
          foremost["foremost"]
          imagemagick["imagemagick"]
          stegoveritas["stegoveritas"]
          stegdetect["stegdetect"]
          
          file-->exiftool
          exiftool-->binwalk
          binwalk-->strings
          strings-->foremost
          foremost-->imagemagick
          imagemagick-->stegoveritas
          stegoveritas-->stegdetect
        end
        subgraph Parsing-Phase
          direction TB
          parse["Auslesen von Attributen aus gesammelten Daten"]
        end
        savecsv["Zwischenspeichern der Steganalysis-Ergebnisse"]
        stegodone(("Ende"))
        
        stegostart-->stegocheck
        stegocheck--"Stego-Bild leer"-->skipempty
        skipempty--"nächste Einbettung"-->stegocheck
        stegocheck--"Einbettung durchgeführt"-->Screening-Phase
        Screening-Phase-->Parsing-Phase
        Parsing-Phase-->savecsv
        savecsv--"nächste Einbettung"-->stegocheck
        savecsv--"alle Einbettungen untersucht"-->stegodone
      end
      subgraph Evaluation
        direction LR
        evalstart(("Start"))
        eval["Auswerten der generierten Cover-Analyse"]
        saveout["Speichern der Cover-Analyse-Ergebnisse"]
        evaldone(("Ende"))
        
        evalstart-->eval
        eval-->saveout
        saveout-->evaldone
      end
      coverdone(("Ende"))
      
      coverstart-->Einbettungsphase
      Einbettungsphase-->Steganalyse
      Steganalyse-->Evaluation
      Evaluation--"nächstes Cover"-->Einbettungsphase
      Evaluation--"alle Cover untersucht"-->coverdone
    end
    finish(("Ende"))
    
    start-->Qualitätssicherungsmaßnahmen
    Qualitätssicherungsmaßnahmen-->Coverdatenuntersuchung
    Coverdatenuntersuchung-->finish
```
