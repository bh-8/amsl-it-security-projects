# Aufsetzen der Arbeitsumgebung
- Ausgangslage
  - Testerstick-Images (.img) der Arbeitsgruppe AMSL (1x statisch, 1x dynamisch)
  - Android-Betriebssystem bereits auf virtueller Disk installiert
- Anpassung Android-System
  - Laden des Testerstick-Images in VBox: Umwandlung des .img-Abbildes in .vdi (virtuelle Disk) [[rA](https://superuser.com/questions/554862/how-to-convert-img-to-usable-virtualbox-format)]
    ```
    VBoxManage convertfromraw --format VDI [file].img [file].vdi
    ```
  - Tester-Umgebung in VBox mit eingebundener virtuellen Android-Festplatte starten
  - m.H. von gparted die Android-Partition und -Dateisystem auf 4GB vergrößern, Änderungen anwenden
  --> Android fertig konfiguriert und bereit für Installation von Payment-Apps
- Anpassung der Testerstick-Umgebung
  - Laden des Testerstick-Images in VBox: Umwandlung des .img-Abbildes in .vdi (virtuelle Disk) [[rA](https://superuser.com/questions/554862/how-to-convert-img-to-usable-virtualbox-format)]
    ```
    VBoxManage convertfromraw --format VDI [file].img [file].vdi
    ```
  - Tester-Umgebung in VBox mit eingebundener virtuellen Tester-Festplatte starten
  - m.H. von gparted die Tester-Partition und -Dateisystem auf 64GB vergrößern, Änderungen anwenden
  - Einrichtung von VBox m.H. des bereits oben aktualisierten Android-Systems
    - mit Snapshots
    - eine App-Download-Instanz für die APK-Files der Apps (APK-Dateien werden bei der Installation der Apps mit dynamischer Analyse ausgewertet)
  - Umwandlung des .vdi-Laufwerks in .img (schreibbares Image) [[rB](https://superuser.com/questions/241269/exporting-a-virtualbox-vdi-to-a-harddrive-to-boot-it-natively)]
    ```
    VBoxManage clonemedium --format RAW [file].vdi [file].img
    ```
