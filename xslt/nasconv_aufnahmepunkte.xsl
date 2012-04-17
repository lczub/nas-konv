<?xml version="1.0" encoding="utf-8"?>
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
	       Aufnahmepunkten (AX_Aufnahmepunkt) -> HTML
	 aus NAS Dateien, Stand GeoInfoDok Version 6.0

	 Verwendet nur XSLT 1.0 Elemente, kann somit direkt durch Firefox/IE 
	 verarbeitet werden. 
	 
	 In den Kommentaren der Datei nasconv_general.xsl ist beschrieben, in
	 welcher XML-Struktur die Liste der zu durchsuchenden NAS-Dateien 
	 übergeben werden muss.
	 ******************************************************************** -->

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:adv="http://www.adv-online.de/namespaces/adv/gid/6.0" 
	xmlns:gml="http://www.opengis.net/gml/3.2"
	xmlns:xlink="http://www.w3.org/1999/xlink">
<!-- Allgemeine Regeln und Lesen nas_file Struktur einbinden -->
<xsl:import href="nasconv_general.xsl"/>	

<xsl:template match="/adv:*">
	<!-- Ausgabe Tabellenblock mit Suche nach Knoten AX_Aufnahmepunkt -->
	<h3>Liste der Aufnahmepunkte</h3>
	<table border="1">
		<tr bgcolor="#9acd32">
			<th>Punktkennung</th><th>zust. Stelle</th>
			<th>Vermarkung</th><th>Identifier</th>
			<th>Punktorte</th>
		</tr>
		<xsl:apply-templates select="//adv:AX_Aufnahmepunkt"/>
    </table>
</xsl:template> 

<xsl:template match="adv:AX_Aufnahmepunkt|adv:AX_Sicherungspunkt">
	<!-- Ausgabe Sachdaten zu AX_Aufnahmepunkt oder AX_Sicherungspunkt
		 und Suche nach zugehörigen Punktorten -->
	<xsl:variable name="objid"><xsl:value-of select="gml:identifier"/></xsl:variable>
	<tr>
        <td><xsl:value-of select="adv:punktkennung"/></td>
        <td><xsl:value-of select="adv:zustaendigeStelle/*/adv:land"/> -
        	<xsl:value-of select="adv:zustaendigeStelle/*/adv:stelle"/></td>
        <td><xsl:value-of select="adv:vermarkung_Marke"/></td>
        <td><xsl:value-of select="$objid"/></td>
        <td><xsl:apply-templates select="//adv:*[adv:istTeilVon/@xlink:href=$objid]"/></td>
	</tr>
</xsl:template>

<xsl:template match="adv:AX_PunktortAU">
	<!-- Ausgabe Koordinaten und Bezugsystem eines AX_PunktortAU -->
	<xsl:value-of select="adv:position/gml:Point/gml:pos"/>
	<xsl:text> (</xsl:text>
	<xsl:value-of select="adv:position//@srsName[1]"/>
	<xsl:text>)</xsl:text>
	<br />
</xsl:template>

</xsl:stylesheet>

