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
      <td><i>sha1sum</i></td>
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
          <li><b>theoretisch</b> betrachtet: Einbettungsgrenzen und -probleme bei verschiedenen Einbettungsvariationen</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td><i>file</i></td>
      <td>statistisch</td>
      <td>Text</td>
      <td>
        <ul>
          <li>Dateityp</li>
        </ul>
      </td>
      <td>
        <ul>
          <li><b>nicht</b> betrachtet: redundant zu <i>exiftool</i> und <i>binwalk</i></li>
        </ul>
      </td>
    </tr>
    <tr>
      <td><i>exiftool</i></td>
      <td>statistisch</td>
      <td>Text</td>
      <td>
        <ul>
          <li>Dateigröße</li>
          <li>Aufnahme-Kamera</li>
          <li>MIME-Type</li>
          <li>JFIF-Version</li>
          <li>Encoding</li>
          <li>Anzahl Farbkomponenten</li>
          <li>Auflösung</li>
          <li>Megapixel</li>
        </ul>
      </td>
      <td>
        <ul>
          <li><b>theoretisch</b> betrachtet: <b>Diagramme</b></li>
          <li><b>theoretisch</b> betrachtet: wird von allen Stego-Tools überschrieben</li>
          <li><b>nicht</b> betrachtet: keine Änderung</li>
          <li><b>praktisch</b> umgesetzt: wird von allen Stego-Tools überschrieben; <i>jsteg</i> entfernt JFIF-Version vollständig</li>
          <li><b>theoretisch</b> betrachtet: wird von allen Stego-Tools überschrieben</li>
          <li><b>nicht</b> betrachtet: keine Änderung</li>
          <li><b>nicht</b> betrachtet: keine Änderung</li>
          <li><b>nicht</b> betrachtet: keine Änderung</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td><i>binwalk</i></td>
      <td>statistisch</td>
      <td>Text</td>
      <td>
        <ul>
          <li>Dateityp</li>
          <li>JFIF-Version</li>
        </ul>
      </td>
      <td>
        <ul>
          <li><b>praktisch</b> umgesetzt: <i>jsteg</i> entfernt Datentyp vollständig</li>
          <li><b>praktisch</b> umgesetzt: wird von allen Stego-Tools überschrieben; <i>jsteg</i> entfernt JFIF-Version vollständig</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td><i>strings</i></td>
      <td>statistisch</td>
      <td>Text</td>
      <td>
        <ul>
          <li>Datei-Header</li>
        </ul>
      </td>
      <td>
        <ul>
          <li><b>praktisch</b> umgesetzt: wird von allen Stego-Tools überschrieben; <i>jsteg</i>: entfernt JFIF-Version, charakteristischer Header mit vielen 2en; <i>outguess</i> und <i>outguess-0.13</i>: charakteristischer Header mit vielen 2en; <i>f5</i>: charakteristischer Header mit 'JFIF written by fengji'</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td><i>foremost</i></td>
      <td>statistisch</td>
      <td>Dateistruktur</td>
      <td>
        <ul>
          <li>Bildintegrität durch Datenextraktion, Dateigröße</li>
        </ul>
      </td>
      <td>
        <ul>
          <li><b>theoretisch</b> betrachtet: <b>Diagramme</b></li>
        </ul>
      </td>
    </tr>
    <tr>
      <td><i>identify (imagemagick)</i></td>
      <td>inhaltsbasiert</td>
      <td>Text</td>
      <td>
        <ul>
          <li>Dateiformat</li>
          <li>Farbminima</li>
          <li>Farbmaxima</li>
          <li>Farb-Mittelwert</li>
          <li>Farb-Standardabweichng</li>
          <li>Kurtosis</li>
          <li>Skewness</li>
          <li>Entropie</li>
        </ul>
      </td>
      <td>
        <ul>
          <li><b>nicht</b> betrachtet: keine Änderung</li>
          <li><b>nicht</b> betrachtet: keine Änderung</li>
          <li><b>nicht</b> betrachtet: keine Änderung</li>
          <li><b>nicht</b> betrachtet: keine Zeit-Resourcen</li>
          <li><b>nicht</b> betrachtet: keine Zeit-Resourcen</li>
          <li><b>nicht</b> betrachtet: keine Zeit-Resourcen</li>
          <li><b>nicht</b> betrachtet: keine Zeit-Resourcen</li>
          <li><b>theoretisch</b> betrachtet: <b>Diagramme</b></li>
        </ul>
      </td>
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
      <td><i>stegdetect</i></td>
      <td>Detektion</td>
      <td>Text</td>
      <td>
        <ul>
          <li>Konnte <i>stegdetect</i> die Einbettung identifizieren?</li>
        </ul>
      </td>
      <td>
        <ul>
          <li><b>praktisch</b> umgesetzt: jsteg, (jphide), outguess-0.13</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td><i>stegbreak</i></td>
      <td>Detektion</td>
      <td>Text</td>
      <td>
        <ul>
          <li>Konnte <i>stegbreak</i> die Einbettung identifizieren?</li>
        </ul>
      </td>
      <td>
        <ul>
          <li><b>praktisch</b> umgesetzt: jsteg, (jphide), outguess-0.13</li>
        </ul>
      </td>
    </tr>
  </tbody>
</table>
