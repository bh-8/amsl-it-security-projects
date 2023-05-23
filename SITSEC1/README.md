# SITSEC1
## Der Webauftritt durchleuchtet - das privatere datensparsamere, nachhaltigere und IT-sicherere Web
| Projektstruktur | Referenz |
| --- | --- |
| DR0-Foliensatz | [./presentations/SITSEC-Presentation DR0.pdf](./presentations/SITSEC-Presentation%20DR0.pdf) |
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
- [X] [KW 19] DR0-Meilenstein (15:00, BBB) (Arbeitsaufteilung und kurze Übersicht über Fortschritte (Umgebungsaufsetzung))
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
| [https://www.docinsider.de/](https://www.docinsider.de/) | `cookies=1` |
| [https://www.kliniken.de/](https://www.kliniken.de/) | `analytics-cookies-allowed=on;cookie-warning=2100-01-01T00:00:00+00:00;preferences-cookies-allowed=on` |
| [https://www.seniorenportal.de/](https://www.seniorenportal.de/) | `consentUUID=a8ea0754-24bf-4696-be89-440e406d6503_19;euconsent-v2=CPsOBQAPsOBQAAGABCENDECsAP_AAAAAAAYgINAZ5D5cTWFBeXx7QPs0eYwf11AVImAiChKAA6ABSDIAcLQEkmASMAyAAAACAAwEIBIBAAAkCAEEAEAQQIAAABHkAgAEhAAIICJEABERQAAACAIKCAAAAQAIAAARIgEAmQCAQ0LmRFQAgIAQZAAAgIgAAAAEAgMAAAAAAAIAAAAAgAAAAQAAAJBIEwACwAKgAZAA5AB4AIAAZAA0AB5AEQARQAmABPADeAHMAPwAhABDQCIAIkARwAlgBNAClAFuAMOAfgB-gEDAI4ASYAlIBigDcAHEASIAo8BSIC8wGSAMuAawEAEAAkAD-AOcAs4CPQErALqAZCGgEABcAEMAPwAgoBJgC0AJEAUiGAAgHUEQBQBDAD8AJMAkQBSIgACACQdA0AAWABUADIAHIAPgBAADIAGgAPAAfQBEAEUAJgAT4AuAC6AGIAMwAbwA5gB-AENAIgAiQBLACaAFKALEAW4AwwBowD8AP0AgYBFoCOAI6ASYAlIBaADFAG4AOIAc4A6gB9gEXgJEATIAo8BeYC-gGSAMsAZcA1UBrAEGhwBIAC4AJAA0AB_AEcAM0Ac4A7gCCgEIALOAYEA14CPQErAJiAXUAyElAbAAWABkADgAHwAeABEACYAFwAMQAZgBDQCIAIkARwApQBbgD8AI4AWgAxQBuADqAIvASIAo8BeYDLAGsEgBIAFwBcgDNAHcAa8A7YB9gEegJWFQBgAmABcAEcARwAtAC8xQAIAgoCPRkAQAJgAjgCOALzGAAQEekICQACwAMgBMAC4AGIAMwAbwBHAClAFiARwAlIBaADFAHOAOoAkQBqpAAQAGgAP4AzQBzgEFAO2Aj0BMRSBKAAsACoAGQAOQAfACAAGQANAAeQBEAEUAJgATwApABiADMAHMAPwAhoBEAESAKUAWIAtwBowD8AP0Ai0BHAEdAJSAYoA3AB9gEXgJEAXmAvoBkgDLAGXANYKADgALgAkADaAH8ARwAuQBmgDnAHcAXUA14B2wEegJiAAA.YAAAAAAAAAAA` |
| [https://www.jameda.de/](https://www.jameda.de/) | `OptanonAlertBoxClosed=2100-01-01T00:00:00.000Z` |
| [https://www.doctolib.de/](https://www.doctolib.de/) | `euconsent-v2=CPr28sAPr28sAAHABBENDECgAAAAAAAAAAAAAAAAAAAA.YAAAAAAAAAAA` |
| [https://www.gesundheit.de/](https://www.gesundheit.de/) | `__cmpcccx24566=aBPsN3XNgAANgABAAOAAsAB0AFwAaAA4AB4AEUAKAApABjAEAAQQAmgB8AEOAKUBDADiQHlAPRAigBYECyoFmALhAZEBHuCYUAcIHgUkwpKhZbC8UGJYe_A;__cmpconsentx24566=CPsNvrAPsNvrAAfI2BDEDFCsAP_AAH_AAAYgI5tb_TrfbXHC-X59fvs0OYwX1tTfA-QCCBSBJ2ABwAOQ8LwGkmAaNASghiACIQwgo1ZBAAJMDEkECUEB4AAEAAGkAQAEhAAIIAJAgBEBQEIYAAoCAIAAAACIgAAZkAQAm1BYA-bGTGAghIAwYEgUoAgBgIIBAgIAEAAAAAAAAAAEAAAAAAIAAIAAAAAAAQAAgjm1v9Ot9tccL5fn1--zQ5jBfW1N8D5AIIFIEnYAHAA5DwvAaSYBo0BKCGIAIhDCCjVkEAAkwMSQQJQQHgAAQAAaQBAASEAAggAkCAEQFAQhgACgIAgAAAAIiAABmQBACbUFgD5sZMYCCEgDBgSBSgCAGAggECAgAQAAAAAAAAAAQAAAAAAgAAgAAAAAABAACAUCgAgAyCQAQAZBoAIAMhEAEAGQqACADIZABABkOgAgAyIQAQAZEoAIAMikAEAGQA` |

## Analysedaten
| Website | PrivacyScore | Webbkoll | EDPS | Wireshark | Firefox Netzwerkanalyse | NoScript | uBlockOrigin |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [https://www.jameda.de/](https://www.jameda.de/) | [Link](https://privacyscore.org/site/95953/) (2023-05-14, 19:52) | [Link](https://webbkoll.dataskydd.net/de/results?url=http%3A%2F%2Fwww.jameda.de%2F) (2023-05-14, 19:53) | [Zip](./data/edps-jameda.zip) (2023-05-14, 21:59) | Pcap | ... | ... | ... |
