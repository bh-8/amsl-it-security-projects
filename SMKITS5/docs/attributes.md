# SMKITS5 / Dokumentation / Attributierungsmerkmale
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
          <li>können eingebetteten Daten verlustfrei extrahiert werden? welche Tools haben Probleme bei welchen Einbettungsvariationen</li>
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
      <td>- TODO: Kamera, JFIF-Version, ... ;;; - TODO: Grafikformat/Encoding durch Einbettung erhalten?</td>
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
      <td>imagemagick</td>
      <td>inhaltsbasiert</td>
      <td>Text/Dateistruktur</td>
      <td>
        <ul>
          <li>Differenzbild</li>
          <li>Neukompression</li>
          <li>Identify (Farbwerte (min, max, mean, ...), Entropie)</li>
        </ul>
      </td>
      <td>-</td>
    </tr>
    <tr>
      <td>stegoveritas</td>
      <td>inhaltsbasiert</td>
      <td>Dateistruktur</td>
      <td>
        <ul>
          <li>Farbkanalzerlegung</li>
          <li>Kanten</li>
        </ul>
      </td>
      <td>-</td>
    </tr>
    <tr>
      <td>stegdetect</td>
      <td>Detektion</td>
      <td>Text</td>
      <td>
        <ul>
          <li>-</li>
        </ul>
      </td>
      <td>konnte `stegdetect` die Einbettung identifizieren?</td>
    </tr>
    <tr>
      <td>stegbreak</td>
      <td>Detektion</td>
      <td>Text</td>
      <td>
        <ul>
          <li>-</li>
        </ul>
      </td>
      <td>konnte `stegbreak` die Einbettung identifizieren?</td>
    </tr>
  </tbody>
</table>
