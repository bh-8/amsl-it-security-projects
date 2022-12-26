# SMKITS5 / Dokumentation / Tool-Attributierung

diagramm-zeugs:
## steghide
- ✅ stegoveritas: Differenzbilder mit Originalbilddaten haben einen deutlich höheren Weiß-Anteil als bei anderen Tools (`~200`) [benötigt Original]
- ✅ exiftool: Stego-Dateigröße bleibt nahezu identisch mit Original-Dateigröße [benötigt Original]
- ✅ imagemagick: Differenzbild mit Originalbild deutlich höherer Weiß-Anteil als bei anderen Tools
- jsteg: höhere Einbettungslänge führt zu geringerer Entropie (zumindest bei BOWS-Bild)
- stegoveritas (bei steghide): differenzbilder mean-wert sind umso kleiner, umso mehr daten eingebettet worden (umso mehr entropie), geringe entropie wird wegkomprimiert
