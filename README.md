﻿NAS-KONV
========
Copyright (C) 2012 Luiko Czub MIT Lizenz

About
-----
NAS-KONV is a collection of examples, how informations could be extracted out of NAS files, using XSLT scripts. NAS is a GML3 exchange format, used by the german cadastral agencies for ALKIS®.

Ziel / Aufgabe NAS-KONV
-----------------------
Bereitstellung von Beispielskripten, wie Informationen aus NAS Dateien mittels XSLT extrahiert und in andere Formate konvertiert werden können. NAS ist das GML3 Austauschformat der deutschen Katasterbehörden für ALKIS®.

Aktuell unterstützte Ausgaben:

* Generierung von HTML Tabellen

Abhängigkeiten
---------------
Unterstützte GeoInfoDok Version: 6.0

Die von NASCONV bereitgestellten XML Dateien `nasconv_THEMA.xml` referenzieren XSLT 1.0 Skripte mit proprietären Firefox spezifischen XSL Erweiterungen [exsl:node-set()] zur Verarbeitung von temporären XML-Bäumen. Sie dienen zum _**Einstieg**_ in das Thema _**Datenextrahierung mittels XSLT**_ und nutzten deshalb bewusst nur die eingeschränkten XSLT 1.0 Elemente. Somit können die Anwender ohne die Installation eines vollwertigen XSLT 2.0 Parser (z.B. [Saxon-HE]) rein mit den Mitteln des Firefox (bzw. eines anderen Browsers, der die [Gecko Rendering Engine] nutzt), die NAS Daten analysieren.

Darüber hinaus stellt NASCONV für komplexere Analysen durchaus XSLT 2.0 Skripte bereit. Deren Verarbeitung setzt voraus, dass fortgeschrittene Anwender zur Analyse der NAS Daten zusätzlich einen separaten XSLT 2.0 Parser (z.B. [Saxon-HE]) installieren. In den Kommentaren der XSL Dateien ist jeweils vermerkt, auf welche XSLT Version sie sich beziehen und ob sie proprietäre Erweiterungen nutzen.

Da die XSLT Parser die zu konvertierenden XML Dateien nicht zeilenweise verarbeiten, sondern vollständig laden, beschränkt die Größe des zur Verfügung stehenden Hauptspeichers die Größe der zu verarbeitenden NAS Dateien.

Installation
------------
Aktuelles Archiv mit den XML-Dateien und Unterverzeichnissen `xslt` und `data` auspacken.

* Das Hauptverzeichnis enthält die XML Dateien `xslt/nasconv_THEMA.xml` und die Verzeichnisse `xslt` und `data`
* Das Verzeichnis `xslt` enthält die XSLT Skripte `xslt/nasconv_THEMA.xsl` 
* Das Verzeichnis `data` ist bis auf eine README Datei leer.

Für Tests mit den offiziellen NAS Testdateien der Länder diese von den Web-Seiten der Katasterbehörden herunterladen, auspacken und im Unterverzeichnis `data` ablegen.

* Eine Liste der bekannten Quellen findet sich in [data\README]

Sollen eigene NAS Dateien konvertiert werden, diese im Unterverzeichnis `data` einstellen und in den XML Dateien einen entsprechenden Eintrag <nas_file> analog zu den Beispielen der NAS Testdateien erzeugen.

Anleitung
----------
Die ausgelieferten XML Dateien `nasconv_THEMA.xml` bestehen aus einer Referenz auf das entsprechende proprietäre XSLT 1.0 Skript `xslt/nasconv_THEMA_exsl.xsl` und einer Liste von zu verarbeitenden NAS Testdateien, die im Unterverzeichnis `data` gesucht werden. 

Die XSLT 1.0 Konvertierung dieser NAS Dateien wird gestartet durch Laden der entsprechenden XML Datei `nasconv_THEMA.xml` im Web Browser Firefox. Der Browser wird nach dem Öffnen der XML Datei zuerst in einen "Busy" Zustand wechseln, während er die NAS Dateien liest und die XSLT Skripte anwendet. Nach einiger Zeit sollte sich dann eine HTML Seite mit den extrahierten Informationen aufbauen.

Alternativ können diese XSLT 1.0 Konvertierungen über einen externen XSLT Parser angestossen und in eine HTML Datei ausgegeben werden. Beispiel Aufruf [Saxon-HE]: 

    java -jar saxon9he.jar -s:nasconv_flurstuecke.xml -a -o:nasconv_flurstuecke.html
  
Soll eine XSLT 2.0 Konvertierungen angewendet werden, muss ein externer XSLT 2.0 Parser verwendet werden. Hierbei ist es nicht notwendig, eine neue Datei `nasconv_THEMA.xml` zu definieren, da dass zu verwendende XSLT 2.0 Skript auch separat angegeben werden kann. Beispiel Aufruf [Saxon-HE]:

    java -jar saxon9he.jar -s:nasconv_flurstuecke.xml -xsl:xslt/nasconv_flurstuecke-gruppiert.xsl -o:nasconv_flurstuecke-gruppiert.html

Eine Auflistung der aktuell bereitgestellten XSLT Konvertierungen findet sich in [xslt\README]

fachliche Informationen
------------------------
Eine Einführung in XSLT findet sich auf [W3Schools Online Web Tutorial] im [XSLT Tutorial] .

Eine Beschreibung der NAS Strukturen finden sich auf [Adv Online - Aktuelle Dokumente der GeoInfoDok] im ZIP-Archiv [NAS_6.0.1.zip] . Das Unterverzeichnis `NAS_6.0.1\definitions` enthält zu jedem Datensatz und Datentyp des NAS Formates eine XML Datei, die mit einem Web Browser geöffnet eine lesbare Beschreibung präsentiert und über Links die Navigation zu verknüpften Datensatzbeschreibungen erlaubt.
  
Formales zum Projekt
--------------------
* Autor     - Luiko Czub
* Downloads - [Sourceforge Projekt NAS-KONV]
* Code      - [GitHub NAS-KONV Repository] - Korrekturen, Verbesserungsvorschläge sind willkommen
* Fehlermeldungen, Anregungen - [GitHub NAS-KONV Tickets]

Lizenz
------
Copyright (C) 2012  Luiko Czub
Diese Skripte sind freie Software. Sie können es unter den Bedingungen der [MIT License (MIT)], wie von der Open Source Initiative veröffentlicht, weitergeben und/oder modifizieren.
Die Veröffentlichung dieser Skripte erfolgt in der Hoffnung, daß es Ihnen von Nutzen sein wird, aber OHNE IRGENDEINE GARANTIE, sogar ohne die implizite Garantie der MARKTREIFE oder der VERWENDBARKEIT FÜR EINEN BESTIMMTEN ZWECK. Details finden Sie in der [MIT License (MIT)].
Sie sollten ein Exemplar der MIT License zusammen mit diesem Programm erhalten 
haben. Falls nicht, siehe <http://opensource.org/licenses/MIT>.


[exsl:node-set()]: http://www.exslt.org/exsl/functions/node-set
[Gecko Rendering Engine]: https://de.wikipedia.org/wiki/Gecko_%28Software%29
[Saxon-6.5.5]: http://saxon.sourceforge.net/#F6.5.5
[Saxon-HE]: http://saxon.sourceforge.net/
[W3Schools Online Web Tutorial]: http://www.w3schools.com
[XSLT Tutorial]: http://www.w3schools.com/xsl/default.asp
[data\README]: https://github.com/lczub/nas-konv/blob/master/data/README.md
[xslt\README]: https://github.com/lczub/nas-konv/blob/master/xslt/README.md
[Sourceforge Projekt NAS-KONV]: http://sourceforge.net/projects/naskonv
[GitHub NAS-KONV Repository]: https://github.com/lczub/nas-konv
[GitHub NAS-KONV Tickets]: https://github.com/lczub/nas-konv/issues
[Adv Online - Aktuelle Dokumente der GeoInfoDok]: http://www.adv-online.de/icc/extdeu/broker.jsp?uMen=4b370024-769d-8801-e1f3-351ec0023010
[NAS_6.0.1.zip]: http://www.adv-online.de/icc/extdeu/binarywriterservlet?imgUid=70425220-0746-2210-3ca0-c0608a438ad1&uBasVariant=11111111-1111-1111-1111-111111111111
[MIT License (MIT)]: https://github.com/lczub/nas-konv/blob/master/LICENSE.txt
