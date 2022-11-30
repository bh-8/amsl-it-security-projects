# SMKITS5 / Dokumentation / Tool-Attributierung
## jsteg
- stegbreak: `Premature end of JPEG file` bei Stego-Dateien, wo der Inhalt nicht korrekt ausgelesen werden konnte, vermutlich aufgrund von zu großer Einbettungslänge
- exiftool: JFIF-Version kann nicht ausgelesen werden
- binwalk: Datentyp und JFIF kann nicht ausgelesen werden
- strings: Header beginnt nicht mit `JFIF` und beinhaltet viele `2`en
- foremost: keine Datenextraktion
## outguess
- strings: Header beginnt mit `JFIF` und beinhaltet viele `2`en
- stegdetect: detektiert outguess-Manipulationen häufig als `jphide(*)`
- stegbreak: wenn outguess detektiert wird, stimmt es meistens
## steghide
- stegoveritas: Differenzbilder mit Originalbilddaten haben einen deutlich höheren Weiß-Anteil als bei anderen Tools (`~200`) [benötigt Original]
- exiftool: Stego-Dateigröße bleibt nahezu identisch mit Original-Dateigröße [benötigt Original]
- imagemagick: Differenzbild mit Originalbild deutlich höherer Weiß-Anteil als bei anderen Tools
## f5
- strings: Header beginnt mit `JFIF written by fengji` und beinhaltet viele `(`
---
## Variation der Einbettungslänge
- jsteg: höhere Einbettungslänge führt zu geringerer Entropie (zumindest bei BOWS-Bild)
## Variation der Schlüssellänge
- 