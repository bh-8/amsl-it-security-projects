# SMKITS5 / Dokumentation / Meeting- und Fortschrittsprotokoll
<table>
  <tbody>
    <tr>
      <th>Datum</th>
      <th>Meeting</th>
      <th>Anmerkungen/Inhalt</th>
      <th>Fragen</th>
    </tr>
    <tr>
      <td>KW 41<br />Mi, 12.10.2022</td>
      <td>Vorlesung: Themen</td>
      <td>
        <ul>
          <li>Themenvorstellung, Aufgabenverständnis, Einteilung</li>
        </ul>
      </td>
      <td>-</td>
    </tr>
    <tr>
      <td>KW 42<br />Mi, 19.10.2022</td>
      <td>Vorlesung: Grundlagen</td>
      <td>
        <ul>
          <li>Grundlagen-Vorlesung (<a href="https://elearning.ovgu.de/mod/resource/view.php?id=388327">Folien</a>), Tipps für späteren Bericht</li>
          <li>Folie 29: Attributierung relevant als Gegenmaßnahme? (Motivation/Stand der Technik)</li>
          <li>Folie 32: Wie kann Angreifer gegen Attributierung arbeiten, wenn er mehr Resourcen (Zeit, Geld, Rechenleistung) hat?</li>
          <li>Folie 33: Basisangriff einordnen</li>
          <li>Folie 56: Einordnen der These (Ausblick)</li>
          <li>Folie 59: zu untersuchenden Datenstrom einordnen (Konzept)</li>
        </ul>
      </td>
      <td>-</td>
    </tr>
    <tr>
      <td>KW 43<br />Mi, 26.10.2022</td>
      <td>Vorlesung: Einführung in Steganographie</td>
      <td>
        <ul>
          <li>TODO: Folie ausarbeiten</li>
        </ul>
      </td>
      <td>-</td>
    </tr>
    <tr>
      <td>KW 43<br />Sa, 29.10.2022</td>
      <td>Discord-Meeting (Bernhard, Ulrich)</td>
      <td>
        <ul>
          <li>Problem: Docker-Setup</li>
          <li>Script-Prototyp (Version 1)</li>
        </ul>
      </td>
      <td>-</td>
    </tr>
    <tr>
      <td>KW 43<br />Fortschritte</td>
      <td>Bernhard, Ulrich</td>
      <td>
        <ul>
          <li>Aufsetzen der Docker-Umgebung</li>
          <li><a href="www.citi.umich.edu/u/provos/papers/detecting.pdf">Referenz</a> gelesen: Attributierung</li>
          <li>alternative Bilddatenbank: <a href="https://www.kaggle.com/competitions/alaska2-image-steganalysis/data">Kaggle/Alaska2</a>, da BOWS nur pgm format</li>
        </ul>
      </td>
      <td>-</td>
    </tr>
    <tr>
      <td>KW 44<br />Di, 01.11.2022</td>
      <td>Task-Coach-Meeting (Bernhard, Christian)</td>
      <td>
        <ul>
          <li>Umwandeln von PGM-Bildern zu JPEG Bildern mit ImageMagick</li>
          <li>in Referenz-Paper sei genau eine Möglichkeit beschrieben, die wir untersuchen sollen</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>Probleme: Referenz-Links tot, Formate falsch</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>KW 44<br />Do, 03.11.2022</td>
      <td>Discord-Meeting (Bernhard, Ulrich)</td>
      <td>
        <ul>
          <li>Erarbeitung des <a href="./SMKITS-Presentation DR1.pdf">DR1-Foliensatzes</a></li>
          <li>Feedback von Christian angefordert</li>
        </ul>
      </td>
      <td>-</td>
    </tr>
    <tr>
      <td>KW 44<br />Fortschritte</td>
      <td>Bernhard, Ulrich</td>
      <td>
        <ul>
          <li>2 Shell-Scripte: Docker für Umgebung, Attributierungsscript für Stego-Untersuchung</li>
          <li>Bildtestset zusammenstellen begonnen &rarr; verschiedene Quellen werden benötigt</li>
          <li>Bildattributierungsmerkmale aus Referenz ausarbeiten: Erkennung von Manipulation in JPEG durch Betrachten der DCT-Koeffizienten
            <ul>
              <li>DCT: Discrete Cosine Transform</li>
              <li>Darstellung von 8x8 Pixel-Blöcken &rarr; Änderung der LSBs der Koeffizienten ist für Auge nicht erkennbar</li>
              <li>Einbettung sukzessive möglich, aber auch pseudo-zufällig &rarr; Unterschiede zwischen Tools</li>
            </ul>
          </li>
          <li>Überarbeitung des <a href="./SMKITS-Presentation DR1.pdf">DR1-Foliensatzes</a></li>
          <li>Einarbeitung in die zu verwendenden Tools</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>PGM-Bildformat in BOWS2-DB?</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>KW 45<br />Di, 08.11.2022</td>
      <td>Discord-Meeting (Bernhard, Ulrich)</td>
      <td>
        <ul>
          <li>Einteilung der Präsentation</li>
        </ul>
      </td>
      <td>-</td>
    </tr>
    <tr>
      <td>KW 45<br />Mi, 09.11.2022</td>
      <td>DR1-Präsentation</td>
      <td>
        <ul>
          <li>für stat. Signifikanz viele Bilder nötig &rarr; mindestens mehrere Hundert nötig</li>
          <li>Discord-Nachbesprechung: Einigung auf 1024 Bilder</li>
        </ul>
      </td>
      <td>-</td>
    </tr>
    <tr>
      <td>KW 45<br />Fr, 11.11.2022</td>
      <td>Discord-Meeting (Bernhard, Ulrich)</td>
      <td>
        <ul>
          <li>Aufgaben-Einteilung Bernhard: jphide-Fix (interaktive Eingabe automatisieren), Script</li>
          <li>Aufgaben-Einteilung Ulrich: Überlegungen zur Auswertung</li>
          <li>Erstellung GitHub-Repo</li>
        </ul>
      </td>
      <td>-</td>
    </tr>
    <tr>
      <td>KW 45<br />Fortschritte</td>
      <td>Bernhard</td>
      <td>
        <ul>
          <li>Ansatz: inhaltsunabhängig mit zufälligen Bildern, dabei Variationen nach Testprotokoll (Tools, Schlüssel, Inhalt)</li>
          <li>Einbettungen, dann Analyse, Ergebnisse mit Originalbild vergleichen, systematisches Vorgehen</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>Möglichkeit, wie man inhaltsbasierte Merkmale auslesen kann?</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>KW 46<br />Di, 15.11.2022</td>
      <td>Task-Coach-Meeting (Bernhard, Christian, Ulrich)</td>
      <td>
        <ul>
          <li>Script: Speicherplatzproblem, wenn erst alle Analysedaten erzeugt werden &rarr; Einbettungen erzeugen &rarr; analysieren &rarr; auswerten &rarr; löschen</li>
          <li>Problem mit Outguess-Binärdaten.. zu groß?</li>
          <li></li>
          <li>konzeptuelle Überlegungen sowie Vortests dokumentieren</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>Tool für Differenzbildberechnung? &rarr; ImageMagick/compare</li>
          <li>jphide-Problem: kein Passwort-Support</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>KW 46<br />Mi, 16.11.2022</td>
      <td>Vorlesung: Wissenschaftliches Schreiben</td>
      <td>
        <ul>
          <li>TODO: Folien durcharbeiten</li>
        </ul>
      </td>
      <td>-</td>
    </tr>
    <tr>
      <td>KW 46<br />Fortschritte</td>
      <td>Bernhard</td>
      <td>
        <ul>
          <li>Script umschreiben entsprechend Dienstags-Meeting (Version 2)</li>
          <li>Finalisieren des Bildtestsets (192+192+640=1024 Bilder)</li>
        </ul>
      </td>
      <td>-</td>
    </tr>
    <tr>
      <td>KW 47<br />Di, 22.11.2022</td>
      <td>Task-Coach-Meeting (Bernhard, Christian, Ulrich)</td>
      <td>
        <ul>
          <li>finalisiertes Bildtestset</li>
          <li>Werkzeugauswahl finalisiert</li>
          <li>Testziel-Tabelle</li>
          <li>Script-Fortschritt (Version 3): Auswertung der Daten direkt nach Einbettungserzeugung (gezielte Tool-Anwendung), alle Tools implementiert (jphide/stegbreak-Seg-Faults)</li>
          <li>Abschlussreport-Ausblick: Netze für höhere stat. Sign. und inhaltsbasierte Betrachtung, bessere Differenzbildanalyse &rarr; weiterführende Codeuntersuchungen (Contentanalyse)</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>jphide-Fix: Ausführung in Docker funktioniert nicht &rarr; statische Kompilierung</li>
          <li>StegBreak SegFault (immer, <a href="https://www.linux-community.de/ausgaben/linuxuser/2008/04/stegdetect-und-stegbreak/2/">Referenz</a>)</li>
          <li>strings-auswertung? &rarr; Fokus auf Unterschiede im Header</li>
          <li>Stegoveritas-Auswertung &rarr; Differenzbilder aller erzeugten Veritas-Bilder mit Original</li>
          <li>Schwarzes Differenzbild &rarr; Hervorgerufen von LSB-Frequenzraum-Pixel-Übersetzung</li>
          <li>Ablaufdiagramm klären &rarr; Ablauf der Analyse</li>
          <li>Dockerfile</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>KW 47<br />Fortschritte</td>
      <td>Bernhard</td>
      <td>
        <ul>
          <li>erneuter jphide-Fix-Versuch</li>
          <li>stegbreak-Fix-Versuch</li>
          <li>Attribute ausgearbeitet</li>
          <li>Evaluation angefangen</li>
          <li>QOL-Verbesserungen Script</li>
        </ul>
      </td>
      <td>-</td>
    </tr>
    <tr>
      <td>KW 48<br />Di, 29.11.2022</td>
      <td>Task-Coach-Meeting (Bernhard, Christian, Ulrich)</td>
      <td>
        <ul>
          <li>Notiz: Script-Entwicklung seit genau 1 Monat, sollte demnächst fertig werden</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>tabelle und diagramm präsentieren und feedback einholen</li>
          <li>jphide/jpseek SegFault-Problem, funktioniert nicht...</li>
          <li>stegbreak SegFault-Problem sehr häufig, einige wenige Analysen funktionieren aber...</li>
          <li>Überspringen von f5 und stegoveritas-Analyse bei Bildern größer als 1024x1024: aktuell 5 min pro Bild &rarr; 12 bilder pro Stunde -> 288 Bilder pro Tag -> gut 3.5 Tage Analyse für alle 1024 Bilder</li>
          <li>Parallelisierung/Ausführung auf Cluster &rarr; Slurm-Script</li>
          <li>lange Einbettungslänge abhängig von Bildgröße? (8tel der Bilddateigröße)?</li>
          <li>Attributietungsmerkmale auf "Vollständigkeit" überprüfen (stegoveritas gaussianblur? smooth? sharpened?)</li>
          <li>Aufgabenstellung: Variation 1: kompletter Schlüsselraum?</li>
          <li>Aufgabenstellung: Attribute für jedes Tool nochmal einzeln dokumentieren, die dafür relevant sind..? (Inter-Verfahrenvergleich)</li>
          <li>Implementierung: soll Funktion zum überprüfen eines einzelnen Bildes implementiert werden?</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>KW 48<br />Fortschritte</td>
      <td>Bernhard</td>
      <td>
        <ul>
          <li>jphide entfernt</li>
          <li>Diagramm für Testprotokoll überarbeitet</li>
          <li>Script examine-Funktion implementiert, grundsätzliche Script-Implementierung vollständig abgeschlossen, nur noch kleinere Ergänzungen und Fixes</li>
        </ul>
      </td>
      <td>-</td>
    </tr>
    <tr>
      <td>KW 49<br />Di, 06.12.2022</td>
      <td>Task-Coach-Meeting (Bernhard, Christian, Ulrich)</td>
      <td>
        <ul>
          <li>jphide exit code ist 139</li>
          <li>https://wasd.urz.uni-magdeburg.de/jschulen/urz_hpc/t100/ ist laut urz einziges cluster mit docker</li>
          <li>examine switch &rarr; weitere Attribute</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>StegBreak-Diagramm</li>
          <li>Flowchart</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>KW 49<br />Fortschritte</td>
      <td>Bernhard</td>
      <td>
        <ul>
          <li>DR2-Vorbereitung</li>
          <li>Aufgabenstellung einschränken</li>
        </ul>
      </td>
      <td>-</td>
    </tr>
    <tr>
      <td>KW 50<br />Mi, 14.12.2022</td>
      <td>DR2-Präsentation (Bernhard)</td>
      <td>-</td>
      <td>-</td>
    </tr>
    <tr>
      <td>KW 50<br />Do, 15.12.2022</td>
      <td>Task-Coach-Meeting (Bernhard, Christian)</td>
      <td>DR2-Ergebnisse</td>
      <td>-</td>
    </tr>
    <tr>
      <td>KW 50<br />Fortschritte</td>
      <td>Bernhard</td>
      <td>
        <ul>
          <li>Bericht schreiben begonnen</li>
          <li>Ausführung der Datenakquise begonnen</li>
          <li>Planung der zu betrachtenden Diagramme</li>
        </ul>
      </td>
      <td>-</td>
    </tr>
    <tr>
      <td>KW 51<br />Do, 22.12.2022</td>
      <td>Task-Coach-Meeting (Bernhard, Christian)</td>
      <td>
        <ul>
          <li>Annotation von 6 Bildern, jeweils aus unterschiedlichen Bildklassen</li>
          <li>Script zur Auswertung aller CSV-Dateien für die Merkmale in den Diagrammen</li>
          <li>Bericht: Attributierungsmerkmale ändern sich im Laufe der Untersuchung (Konzept: Recherche nach Merkmale, was sinnvoll sein könnte; Umsetzung: Welche Attribute werden tatsächlich betrachtet bzw. welche erweisen sich als sinnvoll?, Evaluation: Attributierung ist Hauptaufgabe, also welche davon sind nice)</li>
          <li>Was jetzt: Fertigstellen der Untersuchung, Generieren der finalen Diagramme, Bericht</li>
          <li>nächstes Meeting: evtl. Do, 29.12. oder dann am Do, 05.01.</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>Diagramme: so ok? (inhalt kommt später..)</li>
          <li>Bericht: Motivation und State of the Art (Wie Vorlesungsquellen referenzieren?, Wie einzelne Bilder aus Paper referenzieren?)</li>
          <li>Bericht: Relevante Vorarbeiten für diese Aufgabenstellung ausschließlich in Bezug auf Detektion.. was sonst in Stand d. Technik?</li>
          <li>Bericht: Wohin bildauflösungsabhängige Ausführung? Werkzeugauswahl oder Testprotokoll?</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>KW 52<br />Fortschritte</td>
      <td>Bernhard</td>
      <td>
        <ul>
          <li>Diagramme aus Analysedaten erstellt</li>
          <li>Auswertung [./attributes.md](./attributes.md)</li>
          <li>finale Attrib-Script-Anpassungen</li>
        </ul>
      </td>
      <td>-</td>
    </tr>
  </tbody>
</table>
