# SITSEC1 / EDPS Docker Container (Patched)
- `browser-session.js` aus [ajpqa/ovgu](https://gitlab.informatik.uni-halle.de/ajpqa/ovgu) von Tim Reiprich
- bietet EDPS als Docker-Container mit vollautomatischer Umgebung von Cookie-Bannern basierend auf Keyword-Suche
### Hinweise zur Benutzung
1. Download des Images als [ZIP](https://github.com/birnbaum01/amsl-it-security-projects/raw/main/SITSEC1/edps-patched/edps-patched.zip), anschließend entpacken und in Ordner navigieren
2. `chmod +x ./build-edps.sh && ./build-edps.sh` - baut das Docker-Image mit neuster `browser-session.js` von [hier](https://gitlab.informatik.uni-halle.de/ajpqa/ovgu/-/raw/main/docker/website-evidence-collector/browser-session.js)
3. Ausgabeverzeichnis erstellen: `mkdir ./edps-output && sudo chown 1001:1001 ./edps-output`
4. `chmod +x ./run-edps.sh && ./run-edps.sh <URL>` - ruft EDPS für Analyse auf
