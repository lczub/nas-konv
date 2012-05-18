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
	 Definition von XSLT-Transformationsregeln zur Extrahierung von
		Flurstücken (AX_Flurstuecke) und Personen (AX_Person)-> HTML
	 aus NAS Dateien, Stand GeoInfoDok Version 6.0

	 Verwendet proprietäre XSLT 1.0 Erweiterung exsl:node-set() zur 
	 Verarbeitung von temporären XML Bäumen. Dies kann nur von Web Browsern
	 verarbeitet werden, die als XSL Parser Gecko einsetzen (z.B. Firefox).
	 
	 Parser, die XSLT 1.1  oder 2.0 unterstützen, können direkt mit dem 
	 allgemeinen Stylesheet nasconv_flurstuecke.xsl arbeiten.
	 
	 Hintergrundinfos siehe Kommentare zu NASKONV Ticket 1 
	 - https://github.com/lczub/nas-konv/issues/1
	 ******************************************************************** -->
	 
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:adv="http://www.adv-online.de/namespaces/adv/gid/6.0" 
	xmlns:exsl="http://exslt.org/common">
	
<!-- Allgeine Regeln zur Extrahierung von Flurstücken einbinden -->
<xsl:import href="nasconv_flurstuecke_personen.xsl"/>	

<!-- =======================================================================
	 Templates zur Verarbeitung von temporären XML Bäumen mit proprietärer
	 XSLT 1.0 Erweiterung exsl:node-set() 
 	 ======================================================================= -->

<xsl:template match="adv:AX_Flurstueck" mode="html">
	<!-- Aufsammeln der Infos eines AX_Flurstueck und HTML Ausgabe anstossen 
		 Pro Person, die vom Flurstück über das Grundbuchblatt referenziert 
		 wird, wird eine Tabellenzeile erzeugt
		 verwendet proprietäre XSLT 1.0 Erweiterung exsl:node-set() -->
	
	<!-- Infos des AX_Flurstueck aufsammeln -->
	<xsl:variable name="flst_info">
			<xsl:apply-templates select="." mode="info"/>
	</xsl:variable>

	<!-- HTML Ausgabe anstossen, Person, die vom Flurstück über das 
		 Grundbuchblatt referenziert wird, eine Tabellenzeile -->
	<xsl:apply-templates select="exsl:node-set($flst_info)//info[@class='AX_Person']" mode="html">
		<!-- Sortierung der Personen / Eigentümer eines Flurstückes 
			 entsprechend der Namensnummer -->
		<xsl:sort  select="../@laufendeNummer"></xsl:sort>
	</xsl:apply-templates>
	
	
</xsl:template>
 	 
</xsl:stylesheet>