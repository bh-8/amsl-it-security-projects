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
  - [X] Untersuchung mit EDPS
  - [X] Untersuchung mit PrivacyScore
  - [X] Untersuchung mit Webbkoll
  - [X] Untersuchung mit noScript/uBlockOrigin
  - [X] erste Auswertung EDPS-Daten
  - [X] erste Auswertung PrivacyScore-Daten
  - [X] erste Auswertung Webbkoll-Daten
  - [X] erste Auswertung blockierbare Tracker mit Funktionseinschränkungen
  - [X] Untersuchung mit Firefox Netzwerkanalyse: Vergleich Datenmengen vorher nachher
  - [ ] Untersuchung mit Wireshark: Vergleich Datenmengen vorher nachher, DNS-Hosts, entschlüsselte Protokolldaten, synchrone/asynchrone Kommunikation, IO-Graph
  - [ ] Besonderheiten in Draft schreiben in Auswertung
  - [KW 23] Draft und Vorbereitung DR2
- [ ] [KW 24] DR2-Meilenstein (14:45!)
  - [ ] [KW 24-26] Abschlussbericht schreiben, dazu alle Referenzen prüfen und einbinden
  - [ ] [KW 26] Abschlussbericht fertig, Vorbereitung DR3
- [ ] [KW 27] DR3-Meilenstein (14:45!)

## Analysedaten
| Website | PrivacyScore | Webbkoll | EDPS | Wireshark | Firefox Netzwerkanalyse | NoScript | uBlockOrigin |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [https://www.kliniken.de/](https://www.kliniken.de/) | ... | ... | [Zip](./data/edps-kliniken.zip) (2023-05-23, 13:32), [noCookie-Zip](./data/edps-kliniken-nocookie.zip) | ... | ... | ... | ... |
| [https://www.docinsider.de/](https://www.docinsider.de/) | ... | ... | [Zip](./data/edps-docinsider.zip) (2023-05-23, 12:56), [noCookie-Zip](./data/edps-docinsider-nocookie.zip) | ... | ... | ... | ... |
| [https://www.jameda.de/](https://www.jameda.de/) | [Link](https://privacyscore.org/site/95953/) (2023-05-31, 20:25) | [Link](https://webbkoll.dataskydd.net/de/results?url=http%3A%2F%2Fwww.jameda.de%2F) (2023-05-31, 21:14:48) | [Zip](./data/edps-jameda.zip) (2023-05-06, 22:07:44), [noCookie-Zip](./data/edps-jameda-nocookie.zip) | [blocking-pcapng](./data/wireshark-jameda-blocking.pcapng), [blocking-ssl](./data/wireshark-jameda-blocking.ssl), [noBlocking-pcapng](./data/wireshark-jameda-no-blocking.pcapng), [noBlocking-ssl](./data/wireshark-jameda-no-blocking.ssl), | ... | ... | ... |
| [https://www.sanego.de/](https://www.sanego.de/) | [Link](https://privacyscore.org/site/214171/) (2023-06-08, 08:20) | [Link](https://webbkoll.dataskydd.net/de/results?url=http%3A%2F%2Fwww.sanego.de%2F) (2023-06-08, 08:26:48) | [Zip](./data/edps-sanego.zip) (2023-05-23, 13:30), [noCookie-Zip](./data/edps-sanego-nocookie.zip) | [blocking-pcapng](./data/wireshark-sanego-blocking.pcapng), [ssl-pcapng](./data/wireshark-sanego-blocking.ssl), [noBlocking-pcapng](./data/wireshark-sanego-no-blocking.pcapng), [noBlocking-ssl](./data/wireshark-sanego-no-blocking.ssl) | ... | ... | ... |
| [https://www.seniorenportal.de/](https://www.seniorenportal.de/) | ... | ... | [Zip](./data/edps-seniorenportal.zip) (2023-05-23, 13:06), [noCookie-Zip](./data/edps-seniorenportal-nocookie.zip) | ... | ... | ... | ... |
| [https://www.gesundheit.de/](https://www.gesundheit.de/) | ... | ... | [Zip](./data/edps-gesundheit.zip) (2023-05-23, 13:11), [noCookie-Zip](./data/edps-gesundheit-nocookie.zip) | ... | ... | ... | ... |

## Tabelle mit zu untersuchenden Seiten und Cookies
| Website | Bearbeitung | Cookies (für EDPS) |
| --- | --- | --- |
| [https://www.kliniken.de/](https://www.kliniken.de/) | Jonas | `analytics-cookies-allowed=on;cookie-warning=2100-01-01T00:00:00+00:00;preferences-cookies-allowed=on` |
| [https://www.docinsider.de/](https://www.docinsider.de/) | Jonas | `cookies=1` |
| [https://www.jameda.de/](https://www.jameda.de/) | Bernhard | `OptanonAlertBoxClosed=2100-01-01T00:00:00.000Z` |
| [https://www.sanego.de/](https://www.sanego.de/) | Bernhard | `consentUUID=a6ab7709-0a13-4506-9f92-cf55bb72893f_19` |
| [https://www.seniorenportal.de/](https://www.seniorenportal.de/) | Meryem | `consentUUID=a8ea0754-24bf-4696-be89-440e406d6503_19;euconsent-v2=CPsOBQAPsOBQAAGABCENDECsAP_AAAAAAAYgINAZ5D5cTWFBeXx7QPs0eYwf11AVImAiChKAA6ABSDIAcLQEkmASMAyAAAACAAwEIBIBAAAkCAEEAEAQQIAAABHkAgAEhAAIICJEABERQAAACAIKCAAAAQAIAAARIgEAmQCAQ0LmRFQAgIAQZAAAgIgAAAAEAgMAAAAAAAIAAAAAgAAAAQAAAJBIEwACwAKgAZAA5AB4AIAAZAA0AB5AEQARQAmABPADeAHMAPwAhABDQCIAIkARwAlgBNAClAFuAMOAfgB-gEDAI4ASYAlIBigDcAHEASIAo8BSIC8wGSAMuAawEAEAAkAD-AOcAs4CPQErALqAZCGgEABcAEMAPwAgoBJgC0AJEAUiGAAgHUEQBQBDAD8AJMAkQBSIgACACQdA0AAWABUADIAHIAPgBAADIAGgAPAAfQBEAEUAJgAT4AuAC6AGIAMwAbwA5gB-AENAIgAiQBLACaAFKALEAW4AwwBowD8AP0AgYBFoCOAI6ASYAlIBaADFAG4AOIAc4A6gB9gEXgJEATIAo8BeYC-gGSAMsAZcA1UBrAEGhwBIAC4AJAA0AB_AEcAM0Ac4A7gCCgEIALOAYEA14CPQErAJiAXUAyElAbAAWABkADgAHwAeABEACYAFwAMQAZgBDQCIAIkARwApQBbgD8AI4AWgAxQBuADqAIvASIAo8BeYDLAGsEgBIAFwBcgDNAHcAa8A7YB9gEegJWFQBgAmABcAEcARwAtAC8xQAIAgoCPRkAQAJgAjgCOALzGAAQEekICQACwAMgBMAC4AGIAMwAbwBHAClAFiARwAlIBaADFAHOAOoAkQBqpAAQAGgAP4AzQBzgEFAO2Aj0BMRSBKAAsACoAGQAOQAfACAAGQANAAeQBEAEUAJgATwApABiADMAHMAPwAhoBEAESAKUAWIAtwBowD8AP0Ai0BHAEdAJSAYoA3AB9gEXgJEAXmAvoBkgDLAGXANYKADgALgAkADaAH8ARwAuQBmgDnAHcAXUA14B2wEegJiAAA.YAAAAAAAAAAA` |
| [https://www.gesundheit.de/](https://www.gesundheit.de/) | Meryem | `__cmpcccx24566=aBPsN3XNgAANgABAAOAAsAB0AFwAaAA4AB4AEUAKAApABjAEAAQQAmgB8AEOAKUBDADiQHlAPRAigBYECyoFmALhAZEBHuCYUAcIHgUkwpKhZbC8UGJYe_A;__cmpconsentx24566=CPsNvrAPsNvrAAfI2BDEDFCsAP_AAH_AAAYgI5tb_TrfbXHC-X59fvs0OYwX1tTfA-QCCBSBJ2ABwAOQ8LwGkmAaNASghiACIQwgo1ZBAAJMDEkECUEB4AAEAAGkAQAEhAAIIAJAgBEBQEIYAAoCAIAAAACIgAAZkAQAm1BYA-bGTGAghIAwYEgUoAgBgIIBAgIAEAAAAAAAAAAEAAAAAAIAAIAAAAAAAQAAgjm1v9Ot9tccL5fn1--zQ5jBfW1N8D5AIIFIEnYAHAA5DwvAaSYBo0BKCGIAIhDCCjVkEAAkwMSQQJQQHgAAQAAaQBAASEAAggAkCAEQFAQhgACgIAgAAAAIiAABmQBACbUFgD5sZMYCCEgDBgSBSgCAGAggECAgAQAAAAAAAAAAQAAAAAAgAAgAAAAAABAACAUCgAgAyCQAQAZBoAIAMhEAEAGQqACADIZABABkOgAgAyIQAQAZEoAIAMikAEAGQA` |
