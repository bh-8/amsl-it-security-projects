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
- [ ] [KW 19] DR0-Meilenstein (15:00, BBB) (Arbeitsaufteilung und kurze Übersicht über Fortschritte (Umgebungsaufsetzung))
  - [X] Website Evidence Collector erweitern: Fähigkeit des Überschreitens von Cookie-Bannern
  - [X] Methodikdiagramm für den Ablauf der Untersuchung einer Website mit allen Tools und Schritten
  - [X] Vorbereitung Foliensatz
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
| [https://www.gesundheit.de/](https://www.gesundheit.de/) | `__cmpcccx24566=aBPrUbJOgAANgABAAOAAsAB0AFwAaAA4AB4AEUAKAApABjAEAAQQAmgB8AEOAKUBDADiQHlAPRAigBYECyoFmALhAZEBHuCYUAcIHgUkwpKhZbC8UGJYe_A;__cmpconsentx24566=CPrSazAPrSazAAfI2BDEDDCsAP_AAH_AAAYgI5tb_TrfbXHC-X59fvs0OYwX1tTfA-QCCBSBJ2ABwAOQ8LwGkmAaNASghiACIQwgo1ZBAAJMDEkECUEB4AAEAAGkAQAEhAAIIAJAgBEBQEIYAAoCAIAAAACIgAAZkAQAm1BYA-bGTGAghIAwYEgUoAgBgIIBAgIAEAAAAAAAAAAEAAAAAAIAAIAAAAAAAQAAgjm1v9Ot9tccL5fn1--zQ5jBfW1N8D5AIIFIEnYAHAA5DwvAaSYBo0BKCGIAIhDCCjVkEAAkwMSQQJQQHgAAQAAaQBAASEAAggAkCAEQFAQhgACgIAgAAAAIiAABmQBACbUFgD5sZMYCCEgDBgSBSgCAGAggECAgAQAAAAAAAAAAQAAAAAAgAAgAAAAAABAACAUCgAgAyCQAQAZBoAIAMhEAEAGQqACADIZABABkOgAgAyIQAQAZEoAIAMikAEAGQA` |
| [https://www.zentrum-der-gesundheit.de/](https://www.zentrum-der-gesundheit.de/) | kein Cookie-Banner |
| [https://www.jameda.de/](https://www.jameda.de/) | `OptanonAlertBoxClosed=2100-01-01T00:00:00.355Z;OptanonConsent=isGpcEnabled=0&datestamp=Fri+May+05+2023+14%3A31%3A27+GMT%2B0200+(Mitteleurop%C3%A4ische+Sommerzeit)&version=202211.1.0&isIABGlobal=false&consentId=c321236d-a923-401f-b262-271500ec7a77&interactionCount=2&landingPath=NotLandingPage&groups=C0001%3A1%2CC0003%3A1%2CC0004%3A1%2CC0002%3A1&hosts=H10%3A1%2CH77%3A1%2CH112%3A1%2CH28%3A1%2CH81%3A1%2CH82%3A1%2CH84%3A1%2CH85%3A1%2CH86%3A1%2CH75%3A1%2CH87%3A1%2CH11%3A1%2CH38%3A1%2CH12%3A1%2CH89%3A1%2CH92%3A1%2CH93%3A1%2CH94%3A1%2CH32%3A1%2CH96%3A1%2CH34%3A1%2CH8%3A1&genVendors=` |
| [https://www.deutschesarztportal.de/](https://www.deutschesarztportal.de/) | `CookieConsent={stamp:%27+g3NjkKSpj2XqFBo2O/VU71ML/Hp+AWOrvSFqZkUfpR4cUlVu9L+VA==%27%2Cnecessary:true%2Cpreferences:true%2Cstatistics:true%2Cmarketing:true%2Cmethod:%27explicit%27%2Cver:1%2Cutc:1683290910749%2Cregion:%27de%27}` |
| [https://www.doctolib.de/](https://www.doctolib.de/) | `euconsent-v2=CPrSsYAPrSsYAAHABBENDCCgAAAAAAAAAAAAAAAAAAAA.YAAAAAAAAAAA` |
