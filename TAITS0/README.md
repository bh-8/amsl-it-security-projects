# TAITS0
## Industrie-Ransom 2.0 - Evaluation der Anwendung von YARA zur Erkennung netzwerkbasierter Ransomware
...
<!---
| Projektstruktur | Referenz |
| --- | --- |
| Abschlussbericht | [./smkits5-stegodetect.pdf](./smkits5-stegodetect.pdf) |
-->
## Aufgabenstellung
- Thema: Untersuchung von netzwerkbasierter Ransomware im industriellen Umfeld (Modbus) und Systematisierung mit YARA
- Zentrale Frage: Nutzung und Demonstration netzwerkabsierter Ransomware mit minimalen Rechten: Möglichkeiten und Grenzen
- [X] [KW46/47] Einarbeitung in Tools/Technologien
    - [X] YARA
    - [X] Scapy
    - [X] Modbus
- [ ] [KW48-52] Aufbau eines eigenen Demonstrators:
    - [X] Erzeugen von Samples/Mitschnitten/Evaluierung
    - [ ] Erzeugung von YARA-Patterns
    - [ ] Evaluierung, ob diese YARA-Patterns zur Detektion verwendbar sind
- [ ] [KW01/02] Bericht schreiben: Können YARA-Patterns netzwerkbasierte Ransomware mit verdeckten Funktionen beschreiben?
    - [ ] Wenn ja, wie?
    - [ ] Wenn nein, was fehlt und was für Anpassungen wären nötig?
## Notizen
### Einleitung
- netzwerkbasierte Ransomware mit verdeckten Funktionen sind eine spezielle, neue Art von Schadsoftware, Modbus wird häufig verwendet (siehe vorgegebene Paper bla bla)
- Tools/Technologien: YARA Scapy Wireshark
- Thema wird gefördert durch das Projekt SMARTEST2
### Methodik
- Scapy zeichnet Netzwerkdatenstrom auf
- (aktuelle) Pakete werden in einer Queue gehalten
- Queue wird in Rohdaten gewandelt
- Regeln werden auf Rohdaten angewandt
- Queue wird in Rohdaten gewandelt
- Regeln werden auf Rohdaten angewandt
```mermaid
graph TD;
    Netzwerkdatenstrom-->Packet;
    Packet-->PacketBufferQueue;
    PacketBufferQueue-->RawData;
    RawData-->YARA;
```
### Erkenntnisse
- verschlüsselter Traffic kann nicht detektiert werden, da die (u.u. schädlichen) Anweisungen nicht lesbar sind; als Warden wäre allerdings stets die Möglichkeit gegeben, den Netzwerkverkehr zu überwachen
- YARA Modules werden benötigt, um komplexere Regeln zu ermöglichen
    - Modul geschrieben, um Gleitkommazahlen aus Paketdaten zu extrahieren und zu vergleichen
- Werte in Netzwerkpaketen können abgeglichen werden. (`opcua_kochvorgang.yara`/`opcua_kochvorgang_temperature_exceeds_50`)
- Werteveränderungen über mehrere Pakete hinweg können betrachtet werden. (`opcua_kochvorgang.yara`/`opcua_kochvorgang_temperature_difference_exceeds_5`)
- Zeitintervalle zwischen einzelnen Paketen können NICHT bestimmt werden. (Modbus-Polling-Interval kann nicht verifiziert werden.)
### zu klärende Fragestellungen
- Grenzen von Modulen: prinzipiell kann mit C turing-vollständig gearbeitet werden --> Was ist aber wirklich praktikabel?
- Metasploit-Angriffe: EXE Dateien detektierbar?
- LSB-Stego in Modbus-Registern detektierbar?
### Referenzen
- YARA: https://github.com/VirusTotal/yara
- YARA Regeln: https://yara.readthedocs.io/en/stable/writingrules.html
- YARA Python: https://github.com/VirusTotal/yara-python
- ENISA Threat Landscape for Ransomware Attacks https://www.enisa.europa.eu/publications/enisa-threat-landscape-for-ransomware-attacks/@@download/fullReport
- 2 vorangegangene Arbeiten von Studenten (intern)
- ICS datasets: https://gitti.cs.uni-magdeburg.de/klamshoeft/ics-datasets
- https://gitti.cs.uni-magdeburg.de/klamshoeft/ics-datasets/-/tree/main/Modbus/Lemay/dataset?ref_type=heads
- weitere Referenzen in Mail von Robert
