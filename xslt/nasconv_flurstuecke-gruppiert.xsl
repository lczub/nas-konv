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
	       Flurstücken (AX_Flurstueck) -> HTML
	       - gruppiert nach Gemarkung + Flur
	 aus NAS Dateien, Stand GeoInfoDok Version 6.0
	 
	 Verwendet XSLT 2.0 Element xsl:for-each-group und kann somit nicht 
	 durch Firefox/IE verarbeitet werden. Beispielhafter Aufruf mittels 
	 Saxon HE: 
	 net.sf.saxon.Transform -s:nasconv_flurstuecke.xml 
	                        -xsl:xslt/nasconv_flurstuecke-gruppiert.xsl 
	                        -o:nasconv_flurstuecke-gruppiert.html 
	 
	 In den Kommentaren der Datei nasconv_general.xsl ist beschrieben, in
	 welcher XML-Struktur die Liste der zu durchsuchenden NAS-Dateien 
	 übergeben werden muss.
	 ******************************************************************** -->

<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:adv="http://www.adv-online.de/namespaces/adv/gid/6.0" 
	xmlns:gml="http://www.opengis.net/gml/3.2"
	xmlns:xlink="http://www.w3.org/1999/xlink">
<!-- Allgemeine Regeln, Lesen nas_file Struktur, Regeln Flurstueck einbinden -->
<xsl:import href="nasconv_flurstuecke.xsl"/>	

<xsl:template match="/adv:*">
	<!-- Suche nach Knoten AX_Flurstueck und Ausgabe als Tabellenblock, 
	     grupppiert nach Gemarkung + Flur -->
	
	<xsl:for-each-group select="//adv:AX_Flurstueck" group-by="adv:gemarkung/*/adv:gemarkungsnummer">
		<!--  1. Gruppierung der Flurstücke nach Gemarkung /r -->
		<xsl:sort select="current-grouping-key()"/>
		<xsl:variable name="gemarkung" select="current-grouping-key()"/>		

		<xsl:for-each-group select="current-group()" group-by="adv:flurnummer">
			<!--  2. Gruppierung der Flurstücke nach Flurnummer -->
			<xsl:sort select="current-grouping-key()"/>			 

			<h3>Liste der Flurstücke - Gemarkung <xsl:value-of select="$gemarkung"/> - Flur <xsl:value-of select="current-grouping-key()"/></h3>
			<!--  Start Ausgabe Flurstückstabelle -->
			<table border="1">
				<xsl:call-template name="def-tabelle-flst"/>
			
				<!-- Ausgabe der einzelnen AX_Flurstueck Datensaetze -->
				<xsl:apply-templates select="current-group()" mode="html">
					<!--  Sortierung der Flurstuecke nach Gemarkung und Flur -->
					<xsl:sort select="adv:flurstueckskennzeichen"/>			 
				</xsl:apply-templates>
				
	    	</table>
			<!--  Ende Flurstückstabelle -->
		</xsl:for-each-group>
		
	</xsl:for-each-group>	     
</xsl:template> 

</xsl:stylesheet>