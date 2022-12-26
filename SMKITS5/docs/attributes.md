# SMKITS5 / Dokumentation / Attributierungsmerkmale
<table>
  <tbody>
    <tr>
      <th>Attributierungs-Tool</th>
      <th>Attribut-Typ</th>
      <th>Datenformat</th>
      <th>Attributierungsmerkmale</th>
      <th>Stego-ID</th>
    </tr>
    <tr>
      <td>sha1sum</td>
      <td>statistisch</td>
      <td>Text</td>
      <td>
        <ul>
          <li>Stego-Einbettung erfolgreich (ist erzeugte Stego-Datei evtl. leer)?</li>
          <li>Stego-Extraktion erfolgreich (konnten Daten verlustfrei extrahiert werden)?</li>
        </ul>
      </td>
      <td>
        <ul>
          <li><i>theoretisch</i> betrachtet: Einbettungsgrenzen und -probleme bei verschiedenen Einbettungsvariationen</li>
        </ul>
      </td>
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
          <li>Konnte `stegdetect` die Einbettung identifizieren?</li>
        </ul>
      </td>
      <td>
        <ul>
          <li><i>praktisch</i> umgesetzt: jsteg, (jphide), outguess-0.13</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>stegbreak</td>
      <td>Detektion</td>
      <td>Text</td>
      <td>
        <ul>
          <li>Konnte `stegbreak` die Einbettung identifizieren?</li>
        </ul>
      </td>
      <td>
        <ul>
          <li><i>praktisch</i> umgesetzt: jsteg, (jphide), outguess-0.13</li>
        </ul>
      </td>
    </tr>
  </tbody>
</table>
