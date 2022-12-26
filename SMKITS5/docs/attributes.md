# SMKITS5 / Dokumentation / Attributierungsmerkmale
# SMKITS5 / Dokumentation / Meeting- und Fortschrittsprotokoll
<table>
  <tbody>
    <tr>
      <th>Attributierungs-Tool</th>
      <th>Attribut-Typ</th>
      <th>Datenformat</th>
      <th>Beschreibung</th>
      <th>Stego-ID</th>
    </tr>
    <tr>
      <td>sha1sum</td>
      <td>statistisch</td>
      <td>Text</td>
      <td>
        <ul>
          <li>beinhaltet zu untersuchende Stego-Datei Daten?</li>
          <li>können eingebetteten Daten verlustfrei extrahiert werden?</li>
        </ul>
      </td>
      <td>-</td>
    </tr>
    <tr>
      <td>file</td>
      <td>statistisch</td>
      <td>Text</td>
      <td>
        <ul>
          <li>Dateityp, JFIF-Version? TODO</li>
          <li>Informationen sind redundant zu denen von exiftool</li>
        </ul>
      </td>
      <td>-</td>
    </tr>
    <tr>
      <td>exiftool</td>
      <td>statistisch</td>
      <td>Text</td>
      <td>
        <ul>
          <li>Dateigröße, Aufnahme-Kamera, MIME-Type, JFIF-Version, Encoding, Anzahl Farbkomponenten, Auflösung, Megapixel</li>
        </ul>
      </td>
      <td>- TODO: Kamera, JFIF-Version, ...</td>
      <td>- TODO: Grafikformat/Encoding durch Einbettung erhalten?</td>
    </tr>
    <tr>
      <td>binwalk</td>
      <td>statistisch</td>
      <td>Text</td>
      <td>
        <ul>
          <li>Dateityp, JFIF-Version</li>
        </ul>
      </td>
      <td>-</td>
    </tr>
    <tr>
      <td>strings</td>
      <td>statistisch</td>
      <td>Text</td>
      <td>
        <ul>
          <li>Datei-Header</li>
        </ul>
      </td>
      <td>-</td>
    </tr>
    <tr>
      <td>foremost</td>
      <td>statistisch</td>
      <td>Dateistruktur</td>
      <td>
        <ul>
          <li>Bildintegrität durch Datenextraktion, Dateigröße</li>
        </ul>
      </td>
      <td>- TODO: filesize diagramm-auswertung hier!</td>
    </tr>
    <tr>
      <td>-</td>
      <td>-</td>
      <td>-</td>
      <td>
        <ul>
          <li>-</li>
        </ul>
      </td>
      <td>-</td>
    </tr>
  </tbody>
</table>
## inhaltsbasierte Merkmale
| inhaltsbasiertes Bildmerkmal | Anmerkung |
| --- | --- |
| Differenzbild | lässt sich im Differenzbild (vorher/nachher) die Einbettung erkennen? |
| Kanten | findet die Einbettung vorrangig an Kanten statt? |
| Farbkanäle | wurde speziell ein einzelner Farbkanal manipuliert? |
| generell Farbwerte | wie ändern sich z.B. Farbminima, -maxima, -durchschnittswerte und Entropie? |
| ... | ... |
## Wohin?
| Merkmal | Anmerkung |
| --- | --- |
| stegdetect | konnte `stegdetect` die Einbettung identifizieren? |
| stegbreak | konnte `stegbreak` die Einbettung identifizieren? |
| fehlerhafte Einbettungen | welche Tools haben Probleme bei welchen Einbettungsvariationen? |
| ... | ... |
