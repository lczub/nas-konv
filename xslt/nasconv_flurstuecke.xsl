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
	       Flurstücken (AX_Flurstuecke) -> HTML
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
<!-- Regeln Erzeugung temp. Infobäume mit Flurstücksdaten einbinden -->	
<xsl:import href="info_flurstuecke.xsl"/>
<!-- Allgemeine Regeln und Lesen nas_file Struktur einbinden -->
<xsl:import href="nasconv_general.xsl"/>


<!-- ==========================================================
	 HTML spezifische Templates zur Ausgabe von Flurstücken
 	 ========================================================== -->

<xsl:template name="def-tabelle-flst">
	<!-- Definition der Tabelle zur Ausgabe von Flurstuecken -->
	
	<tr bgcolor="#9acd32">
		<th>Gemarkung</th><th>Gemarkungsname</th><th>Flur</th>
		<th>Flst-Nr</th><th>Kennzeichen</th>
		<th>amtliche Fläche</th>
		<th>Gemeinde</th>
		<th>Gemeindename</th>
		<th>Lagebezeichnung</th>
		<th>Lagebez. mit Hsnr</th>
		<th>Buchungsstelle u. -blatt</th>
		<th>Personen</th>
	</tr>
		
</xsl:template>

<xsl:template match="/adv:*">
	<!-- Suche nach Knoten AX_Flurstueck und Ausgabe als Tabellenblock -->
	
	<h3>Liste der Flurstücke</h3>
	
	<!--  Start Ausgabe Flurstückstabelle -->
	<table border="1">
		<xsl:call-template name="def-tabelle-flst"/>
		
		<!-- Ausgabe der einzelnen AX_Flurstuecke -->
		<xsl:apply-templates select="//adv:AX_Flurstueck" mode="html"> 
			<!--  Sortierung der Flurstuecke nach Gemarkung, Flur, Flstnr -->
			<xsl:sort select="adv:flurstueckskennzeichen"/>			 
		</xsl:apply-templates>
						
	<!--  Ende Flurstückstabelle -->
	</table>
   	
</xsl:template> 

<xsl:template match="adv:AX_Flurstueck" mode="html">
	<!-- Aufsammeln der Infos eines AX_Flurstueck und HTML Ausgabe anstossen 
		 Pro Flurstück wird eine Tabellenzeile erzeugt -->
	
	<!-- Infos des AX_Flurstueck aufsammeln -->
	<xsl:variable name="flst_info">
			<xsl:apply-templates select="." mode="info"/>
	</xsl:variable>

	<!-- HTML Ausgabe anstossen, pro Flurstück eine Tabellenzeile -->
	<xsl:apply-templates select="$flst_info/info" mode="html"/>
	
	
</xsl:template>

<xsl:template match="info[@class='AX_Flurstueck']" mode="html">
	<!-- Ausgabe der Infos eines AX_Flurstueck in einer HTML Tabellenzeile 
		 Pro Flurstück wird eine Tabellenzeile erzeugt -->

	<tr>
		<!-- Ausgabe HTML Zellen mit generellen Flurstücksinformationen -->
		<xsl:apply-templates select="." mode="html_cells_flst"/>

		<!-- Ausgabe HTML Zellen mit Lagebezeichnungen zum Flurstücks -->
		<xsl:apply-templates select="." mode="html_cells_lage"/>
        
		<!-- HTML Ausgabe des Buchungsblatt in einer Tabellenzelle anstossen -->
		<td><xsl:apply-templates select="info[@class='AX_Buchungsstelle']" mode="html_compact"/></td>
		<!-- HTML Ausgabe aller Personendaten in einer Tabellenzelle -->
        <td><xsl:apply-templates select=".//info[@class='AX_Person']" mode="html_compact"/></td>
	</tr>
</xsl:template>

<xsl:template match="info[@class='AX_Flurstueck']" mode="html_cells_flst">
	<!-- Ausgabe der generellen Infos eines AX_Flurstueck als Zellen einer 
		 HTML Tabellenzeile -->

	<td><xsl:value-of select="@GemarkungsSchluessel"/></td>
	<td><xsl:value-of select="@Gemarkungsname"/></td>
    <td><xsl:value-of select="@Flur"/></td>
    <td><xsl:value-of select="@FlstNr"/></td>
    <td><xsl:value-of select="@Kennzeichen"/></td>
    <td><xsl:value-of select="@amtlicheFlaeche"/></td>
    <td><xsl:value-of select="@GemeindeKennzeichen"/></td>
    <td><xsl:value-of select="@Gemeindename"/></td>
        
</xsl:template>

<xsl:template match="info[@class='AX_Flurstueck']" mode="html_cells_lage">
	<!-- Ausgabe der Lagebezeichnungen eines AX_Flurstueck als Zellen einer 
		 HTML Tabellenzeile -->

	<!-- HTML Ausgabe der Lagebezeichnungen ohne Hsnr in einer Tabellenzelle anstossen -->
	<td>
		<xsl:apply-templates select="info[@class='AX_LagebezeichnungOhneHausnummer']" mode="html_compact"/>
	</td>
	<!-- HTML Ausgabe der Lagebezeichnungen mit Hsnr in einer Tabellenzelle anstossen -->
	<td>
		<xsl:apply-templates select="info[@class='AX_LagebezeichnungMitHausnummer']" mode="html_compact"/>
	</td>

</xsl:template>


<xsl:template match="info[@class='AX_LagebezeichnungOhneHausnummer']" mode="html_compact">
	<!-- Ausgabe der Infos einer AX_LagebezeichnungOhneHausnummer als Teil einer
		 HTML Tabellenzelle -->
	
	<xsl:choose>
		<xsl:when test="@Bezeichnung != ''">
			<xsl:value-of select="@Bezeichnung"/>
		</xsl:when>
		<xsl:otherwise>
			(<xsl:value-of select="@Schluessel"/>)
		</xsl:otherwise>
	</xsl:choose>
	<br />
</xsl:template>

<xsl:template match="info[@class='AX_LagebezeichnungMitHausnummer']" mode="html_compact">
	<!-- Ausgabe der Infos eines AX_LagebezeichnungMitHausnummer als Teil einer
		 HTML Tabellenzelle -->
	
	<xsl:choose>
		<xsl:when test="@Bezeichnung != ''">
			<xsl:value-of select="@Bezeichnung"/>
		</xsl:when>
		<xsl:otherwise>
			(<xsl:value-of select="@Schluessel"/>)
		</xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:value-of select="@HsNr"/>
	<br />
</xsl:template>


<xsl:template match="info[@class='AX_Buchungsstelle']" mode="html_compact">
	<!-- Ausgabe der Infos einer AX_Buchungsstelle und referenziertem 
	     AX_Buchungsblattblatt als Teil einer HTML Tabellenzelle -->

	<!-- Ausgabe laufende Nummer der übergeordneten Buchungsstelle -->
	<xsl:value-of select="@laufendeNummer"/>
	
	<!-- Ausgabe Kennzeichen + Blattart des Buchungsblatt -->
	<xsl:text> - </xsl:text>
	<xsl:apply-templates select="info[@class='AX_Buchungsblatt']" mode="html_compact"/>

	<!-- Ausgabe Zeilenumbruch -->
	<br />        

</xsl:template>

<xsl:template match="info[@class='AX_Buchungsblatt']" mode="html_compact">
	<!-- Ausgabe der Infos eines AX_Buchungsblatt als Teil einer HTML 
		 Tabellenzelle -->

	<!-- Ausgabe Kennzeichen + Blattart des Buchungsblatt -->
	<xsl:value-of select="@Blattkennzeichen"/>
	<xsl:text> Art </xsl:text>
	<xsl:value-of select="@Blattart"/>
	
</xsl:template>

<xsl:template match="info[@class='AX_Person']" mode="html_compact">
	<!-- Ausgabe der Infos einer AX_Person mit AX_Anschrift und AX_Namensnummer 
		 als Teil einer HTML Tabellenzelle 
		 Annahme: info[AX_Person] ist Kind innerhalb eines info[AX_Flurstueck]
		          Baumes -->
	
	<!--  Ausgabe Attribute Namensnumer -->
	<xsl:value-of select="../@laufendeNummer"/>
	<xsl:text> </xsl:text>
	
	<!--  Ausgabe Attribute Person -->
	<xsl:value-of select="@NachnameOderFirma"/>
	<xsl:text>, </xsl:text>
	<xsl:value-of select="@Vorname"/>
	<xsl:text>, </xsl:text>
	<xsl:value-of select="@Geburtsdatum"/>
	
	<!-- Ausgabe der zugehörigen Anschriften -->
	<xsl:text> - </xsl:text>
	<xsl:apply-templates select="info[@class='AX_Anschrift']" mode="html_compact"/>
	
	<!-- Ausgabe Zeilenumbruch -->
	<br />        

</xsl:template>

<xsl:template match="info[@class='AX_Anschrift']" mode="html_compact">
	<!-- Ausgabe der Infos einer AX_Anschrift -->
	
	<!-- Ermittlung der zugehörigen Anschriften -->
	<xsl:value-of select="@Strasse"/>
	<xsl:text> </xsl:text>
	<xsl:value-of select="@Hausnummer"/>
	<xsl:text>, </xsl:text>
	<xsl:value-of select="@PostleitzahlPostzustellung"/>
	<xsl:text> </xsl:text>
	<xsl:value-of select="@Ort_Post"/>

</xsl:template>


</xsl:stylesheet>