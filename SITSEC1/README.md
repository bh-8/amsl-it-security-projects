# SITSEC1
## Der Webauftritt durchleuchtet - das privatere datensparsamere, nachhaltigere und IT-sicherere Web
| Projektstruktur | Referenz |
| --- | --- |
| DR0-Foliensatz | [./presentations/SITSEC-Presentation DR0.pdf](./presentations/SITSEC-Presentation%20DR0.pdf) |
| DR1-Foliensatz | [./presentations/SITSEC-Presentation DR1.pdf](./presentations/SITSEC-Presentation%20DR1.pdf) |
| DR2-Foliensatz | [./presentations/SITSEC-Presentation DR2.pdf](./presentations/SITSEC-Presentation%20DR2.pdf) |
| EDPS Wrapper-Script mit Cookies (Ansatz 1) | [./website-evidence-collector-cookies.sh](./website-evidence-collector-cookies.sh) |
| EDPS Docker Container (Patched) (Ansatz 2) | [./edps-patched](./edps-patched) |
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
- [X] [KW 20] DR1-Meilenstein (14:45!) (Fortschritte der einzelnen Arbeitsteams)
  - [X] Untersuchung mit EDPS
  - [X] Untersuchung mit PrivacyScore
  - [X] Untersuchung mit Webbkoll
  - [X] Untersuchung mit noScript/uBlockOrigin
  - [X] erste Auswertung EDPS-Daten
  - [X] erste Auswertung PrivacyScore-Daten
  - [X] erste Auswertung Webbkoll-Daten
  - [X] erste Auswertung blockierbare Tracker mit Funktionseinschränkungen
  - [X] Untersuchung mit Firefox Netzwerkanalyse: Vergleich Datenmengen vorher nachher
  - [X] Untersuchung mit Wireshark: Vergleich Datenmengen vorher nachher, DNS-Hosts, IO-Graph
  - [X] Draft vorbereiten
  - [X] [KW 23] Draft und Vorbereitung DR2
- [ ] [KW 24] DR2-Meilenstein (14:45!)
  - [ ] Untersuchung mit Wireshark: entschlüsselte Protokolldaten, synchrone/asynchrone Kommunikation
  - [ ] Auswertung Ansatz 2, anschließend Vergleich
  - [ ] [KW 24-26] Abschlussbericht schreiben, dazu alle Referenzen prüfen und einbinden
  - [ ] [KW 26] Abschlussbericht fertig, Vorbereitung DR3
- [ ] [KW 27] DR3-Meilenstein (14:45!)

## Tabelle mit extrahierten Consent-Cookies
| Website | Bearbeitung | Cookies (für EDPS) |
| --- | --- | --- |
| [https://www.docinsider.de/](https://www.docinsider.de/) | Jonas | `cookies=1` |
| [https://www.gesundheit.de/](https://www.gesundheit.de/) | Meryem | `__cmpcccx24566=aBPtr2PxgAANgABAAOAAsAB0AFwAaAA4AB4AEUAKAApABjAEAAQQAmgB8AEOAKUBDADiQHlAPRAigBYECyoFmALhAZEBHuCYUAcIHgUkwpKhZbC8UGJYe_A;__cmpconsentx24566=CPtqB7APtqB7AAfI2BDEDJCsAP_AAH_AAAYgI5tb_TrfbXHC-X59fvs0OYwX1tTfA-QCABSBJ2ABwAOQ8LwGkmAaNASghiACIQwgo1ZBAAJMDEkECUEB4AAEAAGkAQAEhAAIIAJAgBEBQEIYAAoCAIAAAACIgAAZkAQAm1BYA-bGTGAghIAwYEgUoAgBgIIBAgIAEAAAAAAAAAAEAAAAAAIAAIAAAAAAAQAAgjm1v9Ot9tccL5fn1--zQ5jBfW1N8D5AIAFIEnYAHAA5DwvAaSYBo0BKCGIAIhDCCjVkEAAkwMSQQJQQHgAAQAAaQBAASEAAggAkCAEQFAQhgACgIAgAAAAIiAABmQBACbUFgD5sZMYCCEgDBgSBSgCAGAggECAgAQAAAAAAAAAAQAAAAAAgAAgAAAAAABAACAUCgAgAyCQAQAZBoAIAMhEAEAGQqACADIZABABkOgAgAyIQAQAZEoAIAMikAEAGQA` |
| [https://www.jameda.de/](https://www.jameda.de/) | Bernhard | `OptanonAlertBoxClosed=2023-06-20T11:16:07.799Z;OptanonConsent=isGpcEnabled=0&datestamp=Tue+Jun+20+2023+13%3A16%3A07+GMT%2B0200+(Mitteleurop%C3%A4ische+Sommerzeit)&version=202211.1.0&isIABGlobal=false&consentId=02a5762f-f508-48d4-90fc-06ae971cfe57&interactionCount=1&landingPath=NotLandingPage&groups=C0001%3A1%2CC0003%3A1%2CC0004%3A1%2CC0002%3A1&hosts=H10%3A1%2CH77%3A1%2CH112%3A1%2CH28%3A1%2CH81%3A1%2CH82%3A1%2CH84%3A1%2CH85%3A1%2CH86%3A1%2CH75%3A1%2CH87%3A1%2CH11%3A1%2CH38%3A1%2CH12%3A1%2CH89%3A1%2CH92%3A1%2CH93%3A1%2CH94%3A1%2CH32%3A1%2CH96%3A1%2CH34%3A1%2CH8%3A1&genVendors=` |
| [https://www.kliniken.de/](https://www.kliniken.de/) | Jonas | `analytics-cookies-allowed=on;cookie-warning=2024-06-20T13:18:29+02:00;preferences-cookies-allowed=on` |
| [https://www.sanego.de/](https://www.sanego.de/) | Bernhard | `consentUUID=d0ebada5-33a4-47c0-a87d-4517b19b6a90_20` |
| [https://www.seniorenportal.de/](https://www.seniorenportal.de/) | Meryem | `consentUUID=f8ddccc1-faca-4e1b-a1f8-7a2e02385452_20;euconsent-v2=CPtqTgAPtqTgAAGABCENDECsAP_AAAAAAAYgINAZ5D5cTWFBeXx7QPs0eYwf11AVImAiChKAA6ABSDIAcLQEkmASMAyAAAACAAwEIBIBAAAkCAEEAEAQQIAAABHkAgAEhAAIICJEABERQAAACAIKCAAAAQAIAAARIgEAmQCAQ0LmRFQAgIAQZAAAgIgAAAAEAgMAAAAAAAIAAAAAgAAAAQAAAJBIEwACwAKgAZAA5AB4AIAAZAA0AB5AEQARQAmABPADeAHMAPwAhABDQCIAIkARwAlgBNAClAFuAMOAfgB-gEDAI4ASYAlIBigDcAHEASIAo8BSIC8wGSAMuAawEAEAAkAD-AOcAs4CPQErALqAZCGgEABcAEMAPwAgoBJgC0AJEAUiGAAgHUEQBQBDAD8AJMAkQBSIgACACQdA0AAWABUADIAHIAPgBAADIAGgAPAAfQBEAEUAJgAT4AuAC6AGIAMwAbwA5gB-AENAIgAiQBLACaAFKALEAW4AwwBowD8AP0AgYBFoCOAI6ASYAlIBaADFAG4AOIAc4A6gB9gEXgJEATIAo8BeYC-gGSAMsAZcA1UBrAEGhwBIAC4AJAA0AB_AEcAM0Ac4A7gCCgEIALOAYEA14CPQErAJiAXUAyElAbAAWABkADgAHwAeABEACYAFwAMQAZgBDQCIAIkARwApQBbgD8AI4AWgAxQBuADqAIvASIAo8BeYDLAGsEgBIAFwBcgDNAHcAa8A7YB9gEegJWFQBgAmABcAEcARwAtAC8xQAIAgoCPRkAQAJgAjgCOALzGAAQEekICQACwAMgBMAC4AGIAMwAbwBHAClAFiARwAlIBaADFAHOAOoAkQBqpAAQAGgAP4AzQBzgEFAO2Aj0BMRSBKAAsACoAGQAOQAfACAAGQANAAeQBEAEUAJgATwApABiADMAHMAPwAhoBEAESAKUAWIAtwBowD8AP0Ai0BHAEdAJSAYoA3AB9gEXgJEAXmAvoBkgDLAGXANYKADgALgAkADaAH8ARwAuQBmgDnAHcAXUA14B2wEegJiAAA.YAAAAAAAAAAA` |
