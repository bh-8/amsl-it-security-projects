# SITSEC1
## Der Webauftritt durchleuchtet - das privatere datensparsamere, nachhaltigere und IT-sicherere Web
| Projektstruktur | Referenz |
| --- | --- |
| DR1-Foliensatz | [./presentations/SITSEC-Presentation DR1.pdf](./presentations/SITSEC-Presentation%20DR1.pdf) |
| WEC Wrapper mit Cookies | [./website-evidence-collector-cookies.sh](./website-evidence-collector-cookies.sh) |

## Aufgabenstellung
- [X] Einarbeitung
  - [X] [KW 16] Untersuchungsumgebung einrichten
  - [X] [KW 17] Einarbeiten in Referenzen
    - [[Rie23](https://github.com/EU-EDPS/website-evidence-collector)]
    - [[AKL+20](https://www.thinkmind.org/articles/securware_2020_2_80_30032.pdf)]
    - [[Kil23f](https://cloud.ovgu.de/s/N4NmmD79N9X5HZD)]
  - [X] [KW 17] Einarbeitung in WEC mit Stefan
- [ ] [KW 18/19] DR0-Meilenstein (Arbeitsaufteilung und kurze Übersicht über Fortschritte (Umgebungsaufsetzung))
  - [X] Website Evidence Collector erweitern: Fähigkeit des Überschreitens von Cookie-Bannern
  - [X] Methodikdiagramm für den Ablauf der Untersuchung einer Website mit allen Tools und Schritten
  - [ ] Vorbereitung Foliensatz
- [ ] [KW 20] DR1-Meilenstein (14:45!) (Fortschritte der einzelnen Arbeitsteams)
  - [ ] SiSy ODT als Basis für Untersuchungen
  - [ ] NoScript/uBlock Origin: zum eigentlichen Zweck des Webauftritts unnötige Verbindungsaufbauten blockieren
  - [ ] Vergleichsmessung Datenmengen vor und nach Blockieren --> Nachhaltigkeit einschätzen
  - [ ] zu untersuchende Webauftritte (Fokus auf Gesundheitswesen); siehe Tabelle unten
  - [ ] [KW 23] Draft und Vorbereitung DR2
- [ ] [KW 24] DR2-Meilenstein (14:45!)
  - [ ] [KW 24-26] Abschlussbericht schreiben, dazu alle Referenzen prüfen und einbinden
  - [ ] [KW 26] Abschlussbericht fertig, Vorbereitung DR3
- [ ] [KW 27] DR3-Meilenstein (14:45!)

## Tabelle mit zu untersuchenden Seiten und Cookies
| Website | Cookies (für WEC) |
| --- | --- |
| [https://meine.aok.de/](https://meine.aok.de/) | `user_cookie_settings=WyJwcC1mdW5jdGlvbmFsIiwicHAtY29tZm9ydCIsInBwLW1hcmtldGluZyJd` |
| [https://www.kliniken.de/](https://www.kliniken.de/) | `analytics-cookies-allowed=on;cookie-warning=2100-01-01T00:00:00+00:00;preferences-cookies-allowed=on` |
| [https://www.seniorenportal.de/pflege](https://www.seniorenportal.de/pflege) | kein Cookie-Banner |
| ... | ... |
