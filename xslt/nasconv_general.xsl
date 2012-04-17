<?xml version="1.0" encoding="UTF-8"?>
<!-- ********************************************************************
	 This file is part of NAS-KONV, a collection of examples, how 
	 informations could be extracted from NAS files (ALKIS data).
     ******************************************************************** --> 
	 
<!-- ********************************************************************
	 The MIT License (MIT)

	 Copyright (c) 2012 Luiko Czub

	 Permission is hereby granted, free of charge, to any person 
	 obtaining a copy of this software and associated documentation 
	 files (the "Software"), to deal in the Software without restriction,
	 including without limitation the rights to use, copy, modify, merge,
	 publish, distribute, sublicense, and/or sell copies of the Software,
	 and to permit persons to whom the Software is furnished to do so, 
	 subject to the following conditions:

	 The above copyright notice and this permission notice shall be 
	 included in all copies or substantial portions of the Software.

	 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
	 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
	 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
	 CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
	 TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
	 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
     ******************************************************************** --> 

<!-- ******************************************************************** 
	 Generelle XSLT-Transformationsregeln zur Extrahierung von 
	 Informationen aus NAS Dateien nach HTML Stand GeoInfoDok Version 6.0
	 
	 Verwendet nur XSLT 1.0 Elemente, kann somit direkt durch Firefox/IE 
	 verarbeitet werden. 
	 
	 Die Liste der zu durchsuchenden NAS-Dateien muss in folgender 
	 XML-Struktur definiert sein:
	 <nas_files>
	    <nas_file name="NASFILE1.xml"/>
	    <nas_file name="NASFILE2.xml"/>
	 </nas_files>
	 
	 Dieses StyleSheet sollte nicht direkt aufgerufen werden, sondern 
	 mittels xml:import von anderen NAS-KONV StyleSheets eingebunden werden. 
	 Als Einstieg für die Suche nach bestimmten Informationen sollten sie das 
	 Template "/adv:*" überdefinieren. 
	 ******************************************************************** -->

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:adv="http://www.adv-online.de/namespaces/adv/gid/6.0" 
	xmlns:xlink="http://www.w3.org/1999/xlink">

<xsl:template match="/nas_files">
	<!-- Ausgabe HTML Start/Ende Kennung und Suche nach Knoten nas_file -->
	<html><body>
		<xsl:apply-templates select="nas_file"/>
	</body></html>
</xsl:template>

<xsl:template match="nas_file">
	<!-- Ausgabe HTML Ueberschrift Stufe 2, öffnen der NAS Datei  -->
	<h2>Auswertung der NAS Datei <xsl:value-of select="@name"/></h2>
	<xsl:apply-templates select="document(@name)"/>
</xsl:template>

<xsl:template match="/adv:*">
    <!-- Regel, die von den spezifischen StyleSheets überdefiniert werden 
         sollte, um die Suche nach bestimmten Informationen zu starten. 
	     Generell wird die Antragsnummer und Erläuterung der NAS Datei 
	     ausgegeben -->
	<h3>Datei Infos</h3>
	<p>Antragsnummer <xsl:value-of select="adv:antragsnummer"/></p>
	<p>Erläuterung <xsl:value-of select="adv:erlaeuterung"/></p>
</xsl:template> 

</xsl:stylesheet>
