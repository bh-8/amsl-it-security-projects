#!/bin/bash
# website-evidence-collector wrapper
clear
echo
echo Willkommen zum Aufruf des Website-Evidence-Collector
echo
echo Es wird die vollstaendige URL der zu untersuchenden Webseite 
echo benoetigt, d.h. mit 'http(s)' beginnend, z.B. http://www.meineseite.de
echo
echo Weiterhin wird der Verzeichnisname auf dem Schreibtisch fuer 
echo die Ergebnisse benoetigt. 
echo Verwenden Sie hierfuer bitte keine Sonderzeichen und Umlaute.
echo Achtung, dieses Verzeichnis wird automatisch auf dem Schreibtisch erzeugt  
echo und beim Neustart der Anwendung bei Namensgeleichheit überschrieben"!"
echo  
echo Insofern benoetigt, koennen nachfolgend Cookies angegeben werden, die beim
echo Aufruf der Website vom EDPS mit übertragen werden sollen.
echo So koennen beispielsweise Cookie-Banner automatisch akzeptiert werden,
echo um die Untersuchung der Website in diese Richtung auszuweiten.
echo Wenn nicht benoetigt, Feld leer lassen und mit Enter bestaetigen.
echo
read -p 'Wurden alle Daten gesichert? (Ja/Nein): ' agreed
[ $agreed != 'Ja' ] && exit 1
echo 
echo Alle drei Angaben werden nachfolgend abgefragt
echo
read -p 'vollstaendige URL: ' userurlvar
read -p 'Cookie-Data: ' cookiedata
read -p 'Verzeichnisname auf dem Schreibtisch: ' folder
resultpath=$HOME/Schreibtisch/$folder
echo
echo Es wurden folgende Daten entgegengenommen':' 
echo $userurlvar
echo Cookie-Data: $cookiedata
echo $resultpath
echo 
echo Wenn alles korrekt durchlaufen wurde, meldet sich das Skript mit einer 
echo Beendigungsmeldung und der Browser wird mit den Ergebnissen gestartet.
echo 
website-evidence-collector --set-cookie "$cookiedata" --overwrite --quiet --output $resultpath $userurlvar
echo 
echo Die Untersuchungergebnisse werden archiviert.
echo
cp -r $resultpath /media/tester/Datenaustausch/Website-Evidence-Collector-$folder
cd /media/tester/Datenaustausch
zip -r Website-Evidence-Collector-$folder.zip Website-Evidence-Collector-$folder
rm -r /media/tester/Datenaustausch/Website-Evidence-Collector-$folder
echo
echo
echo
echo "Die Untersuchungsergebnisse wurden in das Verzeichnis" 
echo $resultpath 
echo "gespeichert und nach" 
echo "/media/tester/Datenaustausch/"Website-Evidence-Collector-$folder.zip
echo archiviert.
sleep 10
firefox $resultpath/inspection.html
exit 1

