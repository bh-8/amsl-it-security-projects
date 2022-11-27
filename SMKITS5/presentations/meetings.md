# Meeting-Übersicht
<table>
  <tbody>
    <tr>
      <th>Datum</th>
      <th>Personen</th>
      <th>Fragen</th>
      <th>Anmerkungen/Inhalt</th>
    </tr>
    <tr>
      <td>KW 41<br />Mi, 12.10.2022</td>
      <td>SMKITS Vorlesung</td>
      <td>-</td>
      <td>
        <ul>
          <li>Themenvorstellung, Aufgabenverständnis</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>KW 42<br />Mi, 19.10.2022</td>
      <td>SMKITS Vorlesung</td>
      <td>-</td>
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
    </tr>
    <tr>
      <td>KW 43<br />Fortschritte</td>
      <td>Bernhard, Ulrich</td>
      <td>-</td>
      <td>
        <ul>
          <li>Aufsetzen der Docker-Umgebung</li>
          <li><a href="www.citi.umich.edu/u/provos/papers/detecting.pdf">Referenz</a> gelesen: Attributierung</li>
          <li>alternative Bilddatenbank: <a href="https://www.kaggle.com/competitions/alaska2-image-steganalysis/data">Kaggle/Alaska2</a>, da BOWS nur pgm format</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>KW 43<br />Mi, 26.10.2022</td>
      <td>Einführung in Steganographie-Vorlesung</td>
      <td>-</td>
      <td>
        <ul>
          <li>TODO: Folie ausarbeiten</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>KW 44<br />Fortschritte</td>
      <td>Bernhard</td>
      <td>
        <ul>
          <li>PGM-Bildformat in BOWS2-DB?</li>
        </ul>
      </td>
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
          <li>Erarbeitung des <a href="./SMKITS-Presentation DR1.pdf">DR1-Foliensatzes</a></li>
          <li>Einarbeitung in die zu verwendenden Tools</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>KW 44<br />Mi, 02.11.2022</td>
      <td>Bernhard, Christian, Ulrich</td>
      <td>
        <ul>
          <li>Probleme: Referenz-Links tot, Formate falsch</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>Umwandeln von PGM-Bildern zu JPEG Bildern mit ImageMagick</li>
          <li>in Referenz-Paper sei genau eine Möglichkeit beschrieben, die wir untersuchen sollen</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>KW XX<br />Tag, Datum</td>
      <td>Bernhard, Christian, Ulrich</td>
      <td>
        <ul>
          <li>...</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>...</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>15.11.</td>
      <td>Bernhard, Christian, Ulrich</td>
      <td>
        <ul>
          <li>Tool für Differenzbildberechnung?<br />&rarr; ImageMagick/compare</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>konzeptuelle Überlegungen sowie Vortests dokumentieren</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>22.11.</td>
      <td>Bernhard, Christian, Ulrich</td>
      <td>
        <ul>
          <li></li>
        </ul>
      </td>
      <td>
        <ul>
          <li></li>
        </ul>
      </td>
    </tr>
  </tbody>
</table>
