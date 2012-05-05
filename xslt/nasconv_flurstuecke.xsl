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
<!-- Allgemeine Regeln und Lesen nas_file Struktur einbinden -->
<xsl:import href="nasconv_general.xsl"/>	



<!-- =======================================================================
	 Templates zum Aufbau der temp. XML Struktur mit Infos zu Aufnahmepunkte 
 	 ======================================================================= -->

<xsl:template match="adv:AX_Flurstueck" mode="info">
	<!-- Infobaum eines AX_Flurstueck erstellen incl. durch 
		 - Join 'zeigtAuf' referenzierter AX_LagebezeichnungOhneHausnummer
		 - Join 'weistAuf' referenzierter AX_LagebezeichnungMitHausnummer
		 - Join 'istGebucht' referenzierter AX_Buchungsstelle und hiervon
		   referenziertem  AX_Buchungsblatt -> AX_Person  -->
	<xsl:variable name="objid"><xsl:value-of select="gml:identifier"/></xsl:variable>
	<info>
		<xsl:attribute name="class">
			<xsl:value-of select="local-name()"/>
		</xsl:attribute>
        <xsl:attribute name="Identifier">
        	<xsl:value-of select="$objid"/>
        </xsl:attribute>
        <xsl:attribute name="Land">
        	<xsl:value-of select="adv:gemarkung/*/adv:land"/>
        </xsl:attribute>
        <xsl:attribute name="Gemarkung">
        	<xsl:value-of select="adv:gemarkung/*/adv:gemarkungsnummer"/>
        </xsl:attribute>
        <xsl:attribute name="Stelle">
        	<xsl:value-of select="adv:zustaendigeStelle/*/adv:stelle"/>
        </xsl:attribute>
        <xsl:attribute name="Flur">
        	<xsl:value-of select="adv:flurnummer"/>
        </xsl:attribute>
        <xsl:attribute name="Zaehler">
        	<xsl:value-of select="adv:flurstuecksnummer/*/adv:zaehler"/>
        </xsl:attribute>
        <xsl:attribute name="Nenner">
        	<xsl:value-of select="adv:flurstuecksnummer/*/adv:nenner"/>
        </xsl:attribute>
        <xsl:attribute name="amtlicheFlaeche">
        	<xsl:value-of select="adv:amtlicheFlaeche"/>
        </xsl:attribute>
        <xsl:apply-templates select="adv:zeigtAuf|adv:weistAuf" mode="info"/>
		<xsl:apply-templates select="adv:istGebucht" mode="info"/>
	</info>
</xsl:template>

<!-- KEY-Definition für Zugriff auf AX_LagebezeichnungOhneHausnummer über gml:identifier -->
<xsl:key name="lage_ohne_Hsnr" match="//adv:AX_LagebezeichnungOhneHausnummer" use="gml:identifier"/>

<xsl:template match="adv:zeigtAuf" mode="info">
	<!-- Ermittlung der vom AX_Flurstueck referenzierten AX_LagebezeichnungOhneHausnummer 
		 und Aufbau des Infobaumes -->
	
	<xsl:variable name="lage" select="key('lage_ohne_Hsnr', @xlink:href)"/>
   	<xsl:apply-templates select="$lage" mode="info"/>
	
</xsl:template>

<xsl:template match="adv:AX_LagebezeichnungOhneHausnummer" mode="info">
	<!-- Infobaum einer AX_LagebezeichnungOhneHausnummer erstellen -->
	
	<info>
		<xsl:attribute name="class">
			<xsl:value-of select="local-name()"/>
		</xsl:attribute>
		
		<xsl:choose>
			<xsl:when test=".//adv:AX_VerschluesselteLagebezeichnung">
				<!-- Ausgabe der verschluesselten Lagebezeichnung -->
				<xsl:attribute name="Schluessel">
					<xsl:value-of select=".//adv:AX_VerschluesselteLagebezeichnung"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<!-- Ausgabe der unverschluesselten Lagebezeichnung -->
				<xsl:attribute name="Bezeichnung">
					<xsl:value-of select=".//adv:unverschluesselt"/>
				</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
		
	</info>
	
</xsl:template>

<!-- KEY-Definition für Zugriff auf AX_LagebezeichnungMitHausnummer über gml:identifier -->
<xsl:key name="lage_mit_Hsnr" match="//adv:AX_LagebezeichnungMitHausnummer" use="gml:identifier"/>

<xsl:template match="adv:weistAuf" mode="info">
	<!-- Ermittlung der vom AX_Flurstueck referenzierten AX_LagebezeichnungMitHausnummer 
		 und Aufbau des Infobaumes  -->
	<xsl:variable name="lage" select="key('lage_mit_Hsnr', @xlink:href)"/>
   	<xsl:apply-templates select="$lage" mode="info"/>

</xsl:template>

<xsl:template match="adv:AX_LagebezeichnungMitHausnummer" mode="info">
	<!-- Infobaum einer AX_LagebezeichnungMitHausnummer erstellen -->
	
	<info>
		<xsl:attribute name="class">
			<xsl:value-of select="local-name()"/>
		</xsl:attribute>
		<!-- Ausgabe der verschluesselten Lagebezeichnung -->
		<xsl:attribute name="Schluessel">
			<xsl:value-of select=".//adv:AX_VerschluesselteLagebezeichnung"/>
		</xsl:attribute>
		<xsl:attribute name="HsNr">
  			<xsl:value-of select="adv:hausnummer"/>
		</xsl:attribute>
	</info>

</xsl:template>

<!-- KEY-Definition für Zugriff auf AX_Buchungsstelle über gml:identifier -->
<xsl:key name="buchungsstelle" match="//adv:AX_Buchungsstelle" use="gml:identifier"/>

<!-- KEY-Definition für Zugriff auf AX_Buchungsblatt über gml:identifier -->
<xsl:key name="buchungsblatt" match="//adv:AX_Buchungsblatt" use="gml:identifier"/>

<xsl:template match="adv:istGebucht" mode="info">
	<!-- Ermittlung der vom AX_Flurstueck referenzierten AX_Buchungsstelle und 
		 Aufbau des Infobaumes -->

	<xsl:variable name="stelle" select="key('buchungsstelle', @xlink:href)"/>
   	<xsl:apply-templates select="$stelle" mode="info"/>
	
</xsl:template>

<xsl:template match="adv:AX_Buchungsstelle" mode="info">
	<!-- Infobaum einer AX_Buchungsstelle erstellen incl. durch Join 
		 'istBestandteilVon' referenziertem AX_Buchungsblatt -->
	
	<info>
		<xsl:attribute name="class">
			<xsl:value-of select="local-name()"/>
		</xsl:attribute>

        <xsl:attribute name="laufendeNummer">
        	<xsl:value-of select="adv:laufendeNummer"/>
        </xsl:attribute>
	
		<!-- Ermittlung des vom AX_Buchungsstelle referenzierten 
			 AX_Buchungsblatt und Aufbau des Infobaumes -->
		<xsl:variable name="blatt" select="key('buchungsblatt', adv:istBestandteilVon/@xlink:href)"/>
	   	<xsl:apply-templates select="$blatt" mode="info"/>
	</info>
	
</xsl:template>

<xsl:template match="adv:AX_Buchungsblatt" mode="info">
	<!-- Infobaum eines AX_Buchungsblatt erstellen incl. durch Join 
		 'istBestandteilVon' referenzierter AX_Namensnummern -->
	
	<xsl:variable name="objid"><xsl:value-of select="gml:identifier"/></xsl:variable>
	<info>
		<xsl:attribute name="class">
			<xsl:value-of select="local-name()"/>
		</xsl:attribute>
        <xsl:attribute name="Identifier">
        	<xsl:value-of select="$objid"/>
        </xsl:attribute>

        <xsl:attribute name="Blattkennzeichen">
        	<xsl:value-of select="adv:buchungsblattkennzeichen"/>
        </xsl:attribute>
        <xsl:attribute name="Blattart">
        	<xsl:value-of select="adv:blattart"/>
        </xsl:attribute>
        
       	<!-- Ermittlung der AX_Namensnummern, die das Buchungsblatt über die ID 
       		 referenzieren und Aufbau des Infobaumes -->
		<xsl:apply-templates select="//adv:AX_Namensnummer[adv:istBestandteilVon/@xlink:href=$objid]" mode="info"/>
	</info>
	
</xsl:template>

<!-- KEY-Definition für Zugriff auf AX_Person über gml:identifier -->
<xsl:key name="person" match="//adv:AX_Person" use="gml:identifier"/>

<xsl:template match="adv:AX_Namensnummer" mode="info">
	<!-- Infobaum einer AX_Namensnummer erstellen incl. durch Join 'benennt' 
		 referenzierter AX_Person -->
	<info>
		<xsl:attribute name="class">
			<xsl:value-of select="local-name()"/>
		</xsl:attribute>
		<xsl:attribute name="laufendeNummer">
			<xsl:value-of select="adv:laufendeNummerNachDIN1421"/>
		</xsl:attribute>

		<!-- Ermittlung referenzierter Person -->
		<xsl:apply-templates select="key('person', adv:benennt/@xlink:href)" mode="info"/>
	</info>
	
</xsl:template>

<!-- KEY-Definition für Zugriff auf AX_Anschrift über gml:identifier -->
<xsl:key name="anschrift" match="//adv:AX_Anschrift" use="gml:identifier"/>

<xsl:template match="adv:AX_Person" mode="info">
	<!-- Infobaum einer AX_Person erstellen incl. durch Join 'hat' 
		 referenzierter AX_Anschrift -->
	
	<xsl:variable name="objid"><xsl:value-of select="gml:identifier"/></xsl:variable>
	<info>
		<xsl:attribute name="class">
			<xsl:value-of select="local-name()"/>
		</xsl:attribute>
        <xsl:attribute name="Identifier">
        	<xsl:value-of select="$objid"/>
        </xsl:attribute>
        
        <xsl:attribute name="NachnameOderFirma">
        	<xsl:value-of select="adv:nachnameOderFirma"/>
        </xsl:attribute>
        <xsl:attribute name="Vorname">
        	<xsl:value-of select="adv:vorname"/>
        </xsl:attribute>
        <xsl:attribute name="Geburtsdatum">
			<xsl:value-of select="adv:geburtsdatum"/>
        </xsl:attribute>

		<!-- Ermittlung der zugehörigen Anschriften -->
		<xsl:apply-templates select="key('anschrift', adv:hat/@xlink:href)" mode="info"/>
	</info>

</xsl:template>

<xsl:template match="adv:AX_Anschrift" mode="info">
	<!-- Infobaum einer AX_Anschrift erstellen -->

	<info>
		<xsl:attribute name="class">
			<xsl:value-of select="local-name()"/>
		</xsl:attribute>
		<xsl:attribute name="Strasse">
			<xsl:value-of select="adv:strasse"/>
		</xsl:attribute>
		<xsl:attribute name="Hausnummer">
			<xsl:value-of select="adv:hausnummer"/>
		</xsl:attribute>
		<xsl:attribute name="PostleitzahlPostzustellung">
			<xsl:value-of select="adv:postleitzahlPostzustellung"/>
		</xsl:attribute>
		<xsl:attribute name="Ort_Post">
			<xsl:value-of select="adv:ort_Post"/>
		</xsl:attribute>
	</info>
	
</xsl:template>


<!-- ==========================================================
	 HTML spezifische Templates zur Ausgabe von Flurstücken
 	 ========================================================== -->

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
		<xsl:apply-templates select="//adv:AX_Flurstueck" mode="html"> 
			<!--  Sortierung der Flurstuecke nach Gemarkung, Flur, Flstnr -->
			<xsl:sort select="adv:gemarkung/*/adv:gemarkungsnummer"/>			 
			<xsl:sort select="adv:flurnummer"/>			 
			<xsl:sort select="adv:flurstuecksnummer/*/adv:zaehler"/>			 
			<xsl:sort select="adv:flurstuecksnummer/*/adv:nenner"/>			 
		</xsl:apply-templates>
						
	<!--  Ende Flurstückstabelle -->
	</table>
   	
</xsl:template> 

<xsl:template match="adv:AX_Flurstueck" mode="html">
	<!-- Aufsammeln der Infos eines AX_Flurstueck und HTML Ausgabe anstossen -->
	
	<!-- Infos des AX_Flurstueck aufsammeln -->
	<xsl:variable name="flst_info">
			<xsl:apply-templates select="." mode="info"/>
	</xsl:variable>

	<!-- HTML Ausgabe anstossen-->
	<xsl:apply-templates select="$flst_info/info" mode="html"/>
	
	
</xsl:template>

<xsl:template match="info[@class='AX_Flurstueck']" mode="html">
	<!-- Ausgabe der Infos eines AX_Flurstueck als HTML Tabellenzeile -->

	<xsl:variable name="objid"><xsl:value-of select="gml:identifier"/></xsl:variable>
	<tr>
		<td><xsl:value-of select="@Land"/> - <xsl:value-of select="@Gemarkung"/></td>
        <td><xsl:value-of select="@Flur"/></td>
        <td><xsl:value-of select="@Zaehler"/> / <xsl:value-of select="@Nenner"/></td>
        <td><xsl:value-of select="@Identifier"/></td>
        <td><xsl:value-of select="@amtlicheFlaeche"/></td>
		<!-- HTML Ausgabe der Lagebezeichnungen in einer Tabellenzelle anstossen -->
		<td>
			<xsl:apply-templates select="info[@class='AX_LagebezeichnungOhneHausnummer']" mode="html"/>
			<xsl:apply-templates select="info[@class='AX_LagebezeichnungMitHausnummer']" mode="html"/>
		</td>
		<!-- HTML Ausgabe des Buchungsblatt in einer Tabellenzelle anstossen -->
		<td><xsl:apply-templates select="info[@class='AX_Buchungsstelle']" mode="html"/></td>
		<!-- HTML Ausgabe der Personendaten in einer Tabellenzelle anstossen -->
        <td><xsl:apply-templates select=".//info[@class='AX_Person']" mode="html"/></td>
	</tr>
</xsl:template>

<xsl:template match="info[@class='AX_LagebezeichnungOhneHausnummer']" mode="html">
	<!-- Ausgabe der Infos einer AX_LagebezeichnungOhneHausnummer innerhalb 
		 einer HTML Tabellenzelle -->
	
	<xsl:value-of select="@Bezeichnung"/>
	<xsl:value-of select="@Schluessel"/>
	<br />
</xsl:template>

<xsl:template match="info[@class='AX_LagebezeichnungMitHausnummer']" mode="html">
	<!-- Ausgabe der Infos eines AX_LagebezeichnungMitHausnummer innerhalb einer
		 HTML Tabellenzelle -->
	
	<xsl:value-of select="@Schluessel"/>
	<xsl:text> HsNr </xsl:text>
	<xsl:value-of select="@HsNr"/>
	<br />
</xsl:template>


<xsl:template match="info[@class='AX_Buchungsstelle']" mode="html">
	<!-- Ausgabe der Infos einer AX_Buchungsstelle und referenziertem 
	     AX_Buchungsblattblatt innerhalb einer HTML Tabellenzelle -->

	<!-- Ausgabe laufende Nummer der übergeordneten Buchungsstelle -->
	<xsl:value-of select="@laufendeNummer"/>
	
	<!-- Ausgabe Kennzeichen + Blattart des Buchungsblatt -->
	<xsl:text> - </xsl:text>
	<xsl:apply-templates select="info[@class='AX_Buchungsblatt']" mode="html"/>

	<!-- Ausgabe Zeilenumbruch -->
	<br />        

</xsl:template>

<xsl:template match="info[@class='AX_Buchungsblatt']" mode="html">
	<!-- Ausgabe der Infos eines AX_Buchungsblatt innerhalb einer HTML 
		 Tabellenzelle -->

	<!-- Ausgabe Kennzeichen + Blattart des Buchungsblatt -->
	<xsl:value-of select="@Blattkennzeichen"/>
	<xsl:text> Art </xsl:text>
	<xsl:value-of select="@Blattart"/>
	
</xsl:template>

<xsl:template match="info[@class='AX_Person']" mode="html">
	<!-- Ausgabe der Infos einer AX_Person mit AX_Anschrift und AX_Namensnummer -->
	
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
	<xsl:apply-templates select="info[@class='AX_Anschrift']" mode="html"/>
	
	<!-- Ausgabe Zeilenumbruch -->
	<br />        

</xsl:template>

<xsl:template match="info[@class='AX_Anschrift']" mode="html">
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