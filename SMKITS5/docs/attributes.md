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
      <td>-</td>
      <td>-</td>
      <td>-</td>
      <td>-</td>
      <td>-</td>
    </tr>
  </tbody>
</table>
## statistische Merkmale
| Bildformat/MIME-Type | ist das Bild nach der Einbettung immer noch ein gültiges JPEG-Bild? |
| JFIF und Encoding | bleibt das Grafikformat/Encoding durch die Einbettung erhalten? |
| Dateigröße | inwiefern ändert sich die Dateigröße durch Einbettung? |
| Kamera | werden Metainformationen wie die verwendete Aufnahmekamera durch die Einbettung verworfen? |
| Auflösung | wird die Auflösung durch die Manipulation geändert? |
| Dateiheader | ist eine Manipulation am Dateiheader erkennbar? |
| ... | ... |
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
