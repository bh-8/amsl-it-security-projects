# IFOR2
## PaymentTraces - gone but not forgotten
| Projektstruktur | Referenz |
| --- | --- |
| DR1-Foliensatz | [./presentations/IFOR-Presentation DR1.pdf](./presentations/IFOR-Presentation%20DR1.pdf) |

## Aufgabenstellung
- [ ] virtualisiertes Ökosystem für App-Payments auf Basis existierender Versuche [[EBE+22](https://dl.acm.org/doi/pdf/10.1145/3538969.3543786)] einrichten und anpassen
  - [X] Virtualisierung einrichten
  - [ ] Android-VM intern aufsetzen, dazu vorher Zahlungsdienstleister auf Team-Mitglieder aufteilen
- DR1-Meilenstein
- [ ] zu untersuchende Zahlungsdienste auswählen
  - [ ] Klarna.
  - [ ] Amazon Pay
  - [ ] Giropay
  - [ ] Google Pay
  - [ ] (PayPal)
- [ ] Bezahlvorgang von App-basierten Bezahlvorgängen forensisch untersuchen
  - [ ] komplette Bearbeitungskette (Eingangsdaten, Konfigurationsdaten, Ausgangsdaten) nach [[Kil20](http://dx.doi.org/10.25673/34647)] dokumentieren
  - [ ] live+post mortem IT-forensische Methoden
    - [ ] Netzwerk --> [Wireshark](https://www.wireshark.org/)
    - [ ] Haupt-/Massenspeicher --> [Volatility](https://github.com/volatilityfoundation/volatility)
  - [ ] Flowchart: Untersuchungsverlauf als Kette von Untersuchungsmethoden und deren Ein- und Ausgabedaten beschreiben 
  - [ ] Ontologie: Mitre Att@ck-Schema [[Mit23](https://attack.mitre.org/)] ergänzen/erweitern
- DR2-Meilenstein
  - [ ] Dokumentation und Abschlussbericht
- DR3-Meilenstein
