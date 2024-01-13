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
- [X] [KW48-52] Aufbau eines eigenen Demonstrators:
    - [X] Erzeugen von Samples/Mitschnitten/Evaluierung
    - [X] Erzeugung von YARA-Patterns
    - [X] Evaluierung, ob diese YARA-Patterns zur Detektion verwendbar sind
- [ ] [KW01/02] Bericht schreiben: Können YARA-Patterns netzwerkbasierte Ransomware mit verdeckten Funktionen beschreiben?
    - [X] Wenn ja, wie?
    - [X] Wenn nein, was fehlt und was für Anpassungen wären nötig?
## Notizen
### Erkenntnisse
| Detektion/Angriffsvektor | Kurzbeschreibung | Erkenntnis | Aufruf | Quelle |
| --- | --- | --- | --- | --- |
| Modbus query-flooding I | *i* von den *n* letzten Paketen aus Netzwerkdatenstrom sind vom selben Pattern | ✅ detektierbar | `./run -pbs 3 -pcap io/icsdataset-CRITIS18/critis18-eth2dump-modbusQueryFlooding1m-0,5h_1.pcap io/yara_rules/modbus_queryflooding.yara` | [[CRITIS18](https://doi.org/10.1007/978-3-030-05849-4_19)] [[ICSDS](https://gitti.cs.uni-magdeburg.de/klamshoeft/ics-datasets)] |
| Modbus query-flooding II | Zeitintervall zwischen den letzten zwei Paketen vom selben Pattern | ✅ detektierbar | `./run -pbs 3 -pcap io/icsdataset-CRITIS18/critis18-eth2dump-modbusQueryFlooding1m-0,5h_1.pcap io/yara_rules/modbus_queryflooding.yara` | [[CRITIS18](https://doi.org/10.1007/978-3-030-05849-4_19)] [[ICSDS](https://gitti.cs.uni-magdeburg.de/klamshoeft/ics-datasets)] |
| ARP mitm | unbekannte MAC-Adresse taucht auf | ✅ detektierbar | `./run -pcap io/icsdataset-CRITIS18/critis18-eth2dump-mitm-change-1m-0,5h_1.pcap io/yara_rules/arp_mitm.yara` | [[CRITIS18](https://doi.org/10.1007/978-3-030-05849-4_19)] [[ICSDS](https://gitti.cs.uni-magdeburg.de/klamshoeft/ics-datasets)] |
| OPCUA value-range | Auslesen und Abgleichen von konkreten Werten aus einzelnen Netzwerkpaketen | ✅ detektierbar | `./run -pcap io/martin-Kochvorgang/ContainmentPi_Kochvorgangbis100Grad.pcapng io/yara_rules/opcua_kochvorgang_xcds50.yara` | [[KVGMT](./io/KochvorgangMartin/ContainmentPi_Kochvorgangbis100Grad.pcapng)] |
| OPCUA value-difference | Auslesen und Verrechnen von konkreten Werten aus mehreren Netzwerkpaketen | ✅ detektierbar | `./run -pbs 40 -pcap io/martin-Kochvorgang/ContainmentPi_Kochvorgangbis100Grad.pcapng io/yara_rules/opcua_kochvorgang_diff5.yara` | [[KVGMT](./io/KochvorgangMartin/)] |
| Modbus-LSB-Stego | Entropie-Validierung von Modbus-Registerwerten | ❌ nicht detektierbar, da Entropie bei Normalfunktion bereits sehr stark schwankt | - | [[LeF16](https://doi.org/10.1109/SYSCON.2016.7490631)] [[ICSDS](https://gitti.cs.uni-magdeburg.de/klamshoeft/ics-datasets)] |
| OPCUA-SCID | durch Verschlüsselung der SecureChannelID durch die RansomWare stürzt der Client ab |  | - | [[SRC](https://cloud.ovgu.de/s/F4HyWsXF25SSdEd?path=%2FNetzwerk-Ransomware-Angriffe%2FLaborRansomware-Angriff-SCID)] (2. Mail Robert, Uni-Cloud) |
| OPCUA-WriteValue |  |  | - | [[SRC](https://cloud.ovgu.de/s/F4HyWsXF25SSdEd?path=%2FNetzwerk-Ransomware-Angriffe%2FLaborRansomware-Angriff-SCID)] (2. Mail Robert, Uni-Cloud) |
| OPCUA-Sign |  |  | - | [[SRC](https://cloud.ovgu.de/s/F4HyWsXF25SSdEd?path=%2FNetzwerk-Ransomware-Angriffe%2FLaborRansomware-Angriff-SCID)] (2. Mail Robert, Uni-Cloud) |
| OPCUA-SignEncrypt | SignAndEncrypt | ❌ nicht detektierbar, da Inhalt bis auf OPCUA header verschlüsselt sind | - | [[SRC](https://cloud.ovgu.de/s/F4HyWsXF25SSdEd?path=%2FNetzwerk-Ransomware-Angriffe%2FRansomware-Angriff-ImSignAndEncryptModus)] (2. Mail Robert, Uni-Cloud) |
| Prosys |  |  | - | [[SRC](https://cloud.ovgu.de/s/F4HyWsXF25SSdEd?path=%2FProsys-2023-12)] (2. Mail Robert, Uni-Cloud) |
