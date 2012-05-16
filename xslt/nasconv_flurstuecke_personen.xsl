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

	 Verwendet im Template "adv:AX_Flurstueck" den erst ab XSLT 1.1 nutzbaren 
	 XPath Aufruf 'select="$flst_info/info"'.
	 Somit kann dieses Stylesheet nicht direkt von Web Browsern verwendet
	 werden, da diese nur XSLT 1.0 Elemente kennen. XSLT 1.1 (Saxon 6.5.5) oder 
	 XSLT 2.0 Parser (Saxon HE) können es direkt verwenden.
	 
	 Web Browser müssen ein Stylesheet vorschalten, das das Template 
	     "adv:AX_Flurstueck"
	 mit einer proprietären, Browser spezifischen Erweiterung überdefiniert.
	 - z.B. exsl:node-set() für Firefox oder msxsl:node-set() für IE
	 - Beispiel siehe nasconv_flurstueck_exsl.xsl. 
	 - siehe auch NASKONV Ticket 1 - https://github.com/lczub/nas-konv/issues/1
	 
	 In den Kommentaren der Datei nasconv_general.xsl ist beschrieben, in
	 welcher XML-Struktur die Liste der zu durchsuchenden NAS-Dateien 
	 übergeben werden muss.
	 ******************************************************************** -->

<xsl:stylesheet version="1.1"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:adv="http://www.adv-online.de/namespaces/adv/gid/6.0" 
	xmlns:gml="http://www.opengis.net/gml/3.2"
	xmlns:xlink="http://www.w3.org/1999/xlink">
<!-- Allgemeine Regeln zum Erzeugung temp. Infobäume mit Flurstücksdaten und 
	 Ausgabe als HTML Tabelle einbinden -->	
<xsl:import href="nasconv_flurstuecke.xsl"/>

<!-- ===================================================================
	 HTML spezifische Templates zur Ausgabe von Flurstücken und Personen
 	 =================================================================== -->

<xsl:template name="def-tabelle-flst">
	<!-- Definition der Tabelle zur Ausgabe von Flurstuecken und Personen -->
	
	<tr bgcolor="#9acd32">
		<th>Gemarkung Kennzeichen</th><th>Gemarkung Name</th><th>Flur</th>
		<th>Flurstück Nummer</th><th>Flurstück Kennzeichen</th>
		<th>amtliche Fläche</th>
		<th>Gemeinde Kennzeichen</th>
		<th>Gemeinde Name</th>
		<th>Lagebezeichnung</th>
		<th>Lagebez. mit Hsnr</th>
		<th>Buchungsstelle Buchungsart</th>
		<th>Buchungsstelle laufende Nr</th>
		<th>Buchungsblatt Kennzeichen</th>
		<th>Buchungsblatt Blattart</th>
		<th>Namensnummer laufende Nr</th>
		<th>Namensnummer Anteil</th>
		<th>Name / Firma</th>
		<th>Vorname</th>
		<th>Geburtsdatum</th>
		<th>Strasse Hsnr</th>
		<th>PLZ</th>
		<th>Ort</th>
	</tr>
		
</xsl:template>

<xsl:template match="adv:AX_Flurstueck" mode="html">
	<!-- Aufsammeln der Infos eines AX_Flurstueck und HTML Ausgabe anstossen 
		 Pro Person, die vom Flurstück über das Grundbuchblatt referenziert 
		 wird, wird eine Tabellenzeile erzeugt -->
	
	<!-- Infos des AX_Flurstueck aufsammeln -->
	<xsl:variable name="flst_info">
			<xsl:apply-templates select="." mode="info"/>
	</xsl:variable>

	<!-- HTML Ausgabe anstossen, Person, die vom Flurstück über das 
		 Grundbuchblatt referenziert wird, eine Tabellenzeile -->
	<xsl:apply-templates select="$flst_info//info[@class='AX_Person']" mode="html">
		<!-- Sortierung der Personen / Eigentümer eines Flurstückes 
			 entsprechend der Namensnummer -->
		<xsl:sort  select="../@laufendeNummer"></xsl:sort>
	</xsl:apply-templates>
	
	
</xsl:template>


<xsl:template match="info[@class='AX_Person']" mode="html">
	<!-- Ausgabe der Infos einer AX_Person mit denen des Flurstueckes, dass
		 diese Person über das Grundbuchblatt refenzierter, in einer HTML 
		 Tabellenzeile 
 		 Annahme: info[AX_Person] ist Kind innerhalb eines info[AX_Flurstueck]
         		  Baumes -->
         		  
	<tr>
		<!-- Ausgabe HTML Zellen mit generellen Flurstücksinformationen -->
		<xsl:apply-templates select="../../../.." mode="html_cells_flst"/>

		<!-- Ausgabe HTML Zellen mit Lagebezeichnungen zum Flurstücks -->
		<xsl:apply-templates select="../../../.." mode="html_cells_lage"/>
        
		<!-- Ausgabe HTML Zellen zur Buchungsstelle der Person -->
		<xsl:apply-templates select="../../.." mode="html_cells"/>
		<!-- Ausgabe HTML Zellen zum Buchungsblatt der Person -->
		<xsl:apply-templates select="../.." mode="html_cells"/>
		<!-- Ausgabe HTML Zellen mit Namensnummern zur Person -->
        <xsl:apply-templates select=".." mode="html_cells"/>
		<!-- Ausgabe HTML Zellen mit generellen Personeninformationen -->
        <xsl:apply-templates select="." mode="html_cells"/>
		<!-- Ausgabe HTML Zellen mit Ansschrift zur Person -->
        <xsl:apply-templates select="info[@class='AX_Anschrift']" mode="html_cells"/>
	</tr>
         		  
</xsl:template>

<xsl:template match="info[@class='AX_Person']" mode="html_cells">
	<!-- Ausgabe der Infos einer AX_Person als Zellen einer HTML Tabellenzeile -->
	
	<td><xsl:value-of select="@NachnameOderFirma"/></td>
	<td><xsl:value-of select="@Vorname"/></td>
	<td><xsl:value-of select="@Geburtsdatum"/></td>

</xsl:template>


<xsl:template match="info[@class='AX_Namensnummer']" mode="html_cells">
	<!-- Ausgabe der Infos einer AX_Namensnummer als Zellen einer HTML 
		 Tabellenzeile -->
	
	<td><xsl:value-of select="@laufendeNummer"/></td>
	<td><xsl:value-of select="@Anteil"/></td>

</xsl:template>

<xsl:template match="info[@class='AX_Anschrift']" mode="html_cells">
	<!-- Ausgabe der Infos einer AX_Anschrift als Zellen einer 
		 HTML Tabellenzeile -->
	
	<td><xsl:value-of select="@Strasse"/><xsl:text> </xsl:text><xsl:value-of select="@Hausnummer"/></td>
	<td><xsl:value-of select="@PostleitzahlPostzustellung"/></td>
	<td><xsl:value-of select="@Ort_Post"/></td>

</xsl:template>

<xsl:template match="info[@class='AX_Buchungsblatt']" mode="html_cells">
	<!-- Ausgabe der Infos eines AX_Buchungsblatt als Zellen einer 
		 HTML Tabellenzeile -->

	<td><xsl:value-of select="@Blattkennzeichen"/></td>
	<td><xsl:value-of select="@Blattart"/></td>
	
</xsl:template>


<xsl:template match="info[@class='AX_Buchungsstelle']" mode="html_cells">
	<!-- Ausgabe der Infos einer AX_Buchungsstelle als Zellen einer 
		 HTML Tabellenzeile -->

	<td><xsl:value-of select="@Buchungsart"/></td>
	<td><xsl:value-of select="@laufendeNummer"/></td>

</xsl:template>

</xsl:stylesheet>