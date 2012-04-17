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

<xsl:template name="def-tabelle-flst">
	<!-- Definition der Tabelle zur Ausgabe von Flurstuecken -->
	
	<tr bgcolor="#9acd32">
		<th>Gemarkung</th><th>Flur</th>
		<th>Flst-Nr</th><th>Identifier</th>
		<th>amtliche Fläche</th>
		<th>Lagebezeichnung</th>
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
		<xsl:apply-templates select="//adv:AX_Flurstueck"> 
			<!--  Sortierung der Flurstuecke nach Gemarkung, Flur, Flstnr -->
			<xsl:sort select="adv:gemarkung/*/adv:gemarkungsnummer"/>			 
			<xsl:sort select="adv:flurnummer"/>			 
			<xsl:sort select="adv:flurstuecksnummer/*/adv:zaehler"/>			 
			<xsl:sort select="adv:flurstuecksnummer/*/adv:nenner"/>			 
		</xsl:apply-templates>
						
	<!--  Ende Flurstückstabelle -->
	</table>
   	
</xsl:template> 

<xsl:template match="adv:AX_Flurstueck">
	<!-- Ausgabe Sachdaten zu AX_Flurstueck -->
	<xsl:variable name="objid"><xsl:value-of select="gml:identifier"/></xsl:variable>
	<tr>
        <td><xsl:value-of select="adv:gemarkung/*/adv:land"/> -
        	<xsl:value-of select="adv:gemarkung/*/adv:gemarkungsnummer"/></td>
        <td><xsl:value-of select="adv:flurnummer"/></td>
        <td><xsl:value-of select="adv:flurstuecksnummer/*/adv:zaehler"/> /
        	<xsl:value-of select="adv:flurstuecksnummer/*/adv:nenner"/></td>
        <td><xsl:value-of select="$objid"/></td>
        <td><xsl:value-of select="adv:amtlicheFlaeche"/></td>
        <td><xsl:apply-templates select="adv:zeigtAuf|adv:weistAuf"/></td>
        <td><xsl:apply-templates select="adv:istGebucht" mode="blatt"/></td>
        <td><xsl:apply-templates select="adv:istGebucht" mode="person"/></td>
	</tr>
</xsl:template>


<!-- KEY-Definition für Zugriff auf AX_LagebezeichnungOhneHausnummer über gml:identifier -->
<xsl:key name="lage_ohne_Hsnr" match="//adv:AX_LagebezeichnungOhneHausnummer" use="gml:identifier"/>

<xsl:template match="adv:zeigtAuf">
	<!-- Ermittlung und Ausgabe AX_LagebezeichnungOhneHausnummer  -->
	<xsl:variable name="lagebez" select="key('lage_ohne_Hsnr', @xlink:href)//adv:AX_Lagebezeichnung"/>
	<xsl:variable name="lagekey" select="$lagebez//adv:AX_VerschluesselteLagebezeichnung"/>
	<xsl:choose>
		<xsl:when test="$lagekey">
			<!-- Ausgabe der verschluesselten Lagebezeichnung -->
			<xsl:value-of select="$lagekey"/>
		</xsl:when>
		<xsl:otherwise>
			<!-- Ausgabe der unverschluesselten Lagebezeichnung -->
			<xsl:value-of select="$lagebez/adv:unverschluesselt"/>
		</xsl:otherwise>
	</xsl:choose>
	<!-- Ausgabe Zeilenumbruch -->
	<br />        

</xsl:template>

<!-- KEY-Definition für Zugriff auf AX_LagebezeichnungMitHausnummer über gml:identifier -->
<xsl:key name="lage_mit_Hsnr" match="//adv:AX_LagebezeichnungMitHausnummer" use="gml:identifier"/>

<xsl:template match="adv:weistAuf">
	<!-- Ermittlung und Ausgabe AX_LagebezeichnungMitHausnummer  -->
	<xsl:variable name="lage" select="key('lage_mit_Hsnr', @xlink:href)"/>

	<!-- Ausgabe der verschluesselten Lagebezeichnung -->
	<xsl:value-of select="$lage//adv:AX_VerschluesselteLagebezeichnung"/>
	<!--  Ausgabe der Hausnummer -->
	<xsl:text> HsNr </xsl:text>
	<xsl:value-of select="$lage//adv:hausnummer"/>
	<!-- Ausgabe Zeilenumbruch -->
	<br />        

</xsl:template>


<!-- KEY-Definition für Zugriff auf AX_Buchungssteelle über gml:identifier -->
<xsl:key name="buchungsstelle" match="//adv:AX_Buchungsstelle" use="gml:identifier"/>

<!-- KEY-Definition für Zugriff auf AX_Buchungsblatt über gml:identifier -->
<xsl:key name="buchungsblatt" match="//adv:AX_Buchungsblatt" use="gml:identifier"/>

<xsl:template match="adv:istGebucht" mode="blatt">
	<!-- Ermittlung und Ausgabe AX_Buchungsstelle + AX_Buchungsblatt -->

	<!-- Ermittlung Buchungsstelle und Ausgabe laufende Nummer  -->
	<xsl:variable name="stelle" select="key('buchungsstelle', @xlink:href)"/>
	<xsl:value-of select="$stelle//adv:laufendeNummer"/>
	
	<!-- Ermittlung Buchungsblatt und Ausgabe Kennzeichen + Blattart-->
	<xsl:variable name="blatt" select="key('buchungsblatt', $stelle/adv:istBestandteilVon/@xlink:href)"/>
	<xsl:text> - </xsl:text>
	<xsl:value-of select="$blatt//adv:buchungsblattkennzeichen"/>
	<xsl:text> Art </xsl:text>
	<xsl:value-of select="$blatt//adv:blattart"/>
	
	<!-- Ausgabe Zeilenumbruch -->
	<br />        

</xsl:template>

<xsl:template match="adv:istGebucht" mode="person">
	<!-- Ermittlung der AX_Namensnummern, die das Buchungssblatt referenzieren -->

	<!-- Ermittlung Buchungsstelle und ID des Buchungsblattes -->
	<xsl:variable name="stelle" select="key('buchungsstelle', @xlink:href)"/>
	<xsl:variable name="blattid" select="$stelle/adv:istBestandteilVon/@xlink:href"/>
	
	<!-- Ermittlung der Namensnummern, die das Buchungsblatt über die ID referenzieren -->
	<xsl:apply-templates select="//adv:AX_Namensnummer[adv:istBestandteilVon/@xlink:href=$blattid]"/>

</xsl:template>

<!-- KEY-Definition für Zugriff auf AX_Person über gml:identifier -->
<xsl:key name="person" match="//adv:AX_Person" use="gml:identifier"/>

<xsl:template match="adv:AX_Namensnummer">
	<!-- Ausgabe Attribute zur Namensnummer + Ermittlung der referenzierten Person -->
	
	<!--  Ausgabe Attribte Namensnumer -->
	<xsl:value-of select="adv:laufendeNummerNachDIN1421"/>
	<xsl:text> </xsl:text>

	<!-- Ermittlung referenzierte Person -->
	<xsl:apply-templates select="key('person', adv:benennt/@xlink:href)"/>
	
	<!-- Ausgabe Zeilenumbruch -->
	<br />        

</xsl:template>

<!-- KEY-Definition für Zugriff auf AX_Anschrift über gml:identifier -->
<xsl:key name="anschrift" match="//adv:AX_Anschrift" use="gml:identifier"/>


<xsl:template match="adv:AX_Person">
	<!-- Ausgabe Attribute zur AX_Person + Ermittlung der Anschrift -->
	
	<xsl:value-of select="adv:nachnameOderFirma"/>
	<xsl:text>, </xsl:text>
	<xsl:value-of select="adv:vorname"/>
	<xsl:text>, </xsl:text>
	<xsl:value-of select="adv:geburtsdatum"/>

	<!-- Ermittlung der zugehörigen Anschriften -->
	<xsl:apply-templates select="key('anschrift', adv:hat/@xlink:href)"/>

</xsl:template>

<xsl:template match="adv:AX_Anschrift">
	<!-- Ausgabe Attribute zur AX_Anschrift -->
	
	<xsl:text> - </xsl:text>
	<xsl:value-of select="adv:strasse"/>
	<xsl:text> </xsl:text>
	<xsl:value-of select="adv:hausnummer"/>
	<xsl:text>, </xsl:text>
	<xsl:value-of select="adv:postleitzahlPostzustellung"/>
	<xsl:text> </xsl:text>
	<xsl:value-of select="adv:ort_Post"/>

</xsl:template>


</xsl:stylesheet>