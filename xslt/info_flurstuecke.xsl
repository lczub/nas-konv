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
	       Flurstücken (AX_Flurstuecke) -> temp. XML Bäume
	 aus NAS Dateien, Stand GeoInfoDok Version 6.0

	 Dieses StyleSheet sollte nicht direkt aufgerufen werden, sondern 
	 mittels xml:import von anderen NAS-KONV StyleSheets eingebunden werden. 
	 ******************************************************************** -->

<xsl:stylesheet version="1.1" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:adv="http://www.adv-online.de/namespaces/adv/gid/6.0" 
	xmlns:gml="http://www.opengis.net/gml/3.2"
	xmlns:xlink="http://www.w3.org/1999/xlink">


<!-- =======================================================================
	 Key Definitionen zum Verfolgen von Verweisen zwischen NAS Datensätzen
 	 ======================================================================= -->

<!-- KEY-Definition für Zugriff auf AX_LagebezeichnungOhneHausnummer über gml:identifier -->
<xsl:key name="lage_ohne_Hsnr" match="//adv:AX_LagebezeichnungOhneHausnummer" use="gml:identifier"/>

<!-- KEY-Definition für Zugriff auf AX_LagebezeichnungMitHausnummer über gml:identifier -->
<xsl:key name="lage_mit_Hsnr" match="//adv:AX_LagebezeichnungMitHausnummer" use="gml:identifier"/>

<!-- KEY-Definition für Zugriff auf AX_LagebezeichnungKatalogeintrag über schluesselFesamt -->
<xsl:key name="lage_katalog" match="//adv:AX_LagebezeichnungKatalogeintrag" use="adv:schluesselGesamt"/>

<!-- KEY-Definition für Zugriff auf AX_Gemarkung über schluessel/AX_Gemarkung_Schluessel -->
<xsl:key name="gemarkung" match="//adv:AX_Gemarkung" use="adv:schluessel"/>

<!-- KEY-Definition für Zugriff auf AX_Gemarkung über gemeindekennzeichen/AX_Gemeindekennzeichen -->
<xsl:key name="gemeinde" match="//adv:AX_Gemeinde" use="adv:gemeindekennzeichen"/>

<!-- KEY-Definition für Zugriff auf AX_Buchungsstelle über gml:identifier -->
<xsl:key name="buchungsstelle" match="//adv:AX_Buchungsstelle" use="gml:identifier"/>

<!-- KEY-Definition für Zugriff auf AX_Buchungsblatt über gml:identifier -->
<xsl:key name="buchungsblatt" match="//adv:AX_Buchungsblatt" use="gml:identifier"/>

<!-- KEY-Definition für Zugriff auf AX_Person über gml:identifier -->
<xsl:key name="person" match="//adv:AX_Person" use="gml:identifier"/>

<!-- KEY-Definition für Zugriff auf AX_Anschrift über gml:identifier -->
<xsl:key name="anschrift" match="//adv:AX_Anschrift" use="gml:identifier"/>

<!-- KEY-Definition für Zugriff auf AX_Namensnummer, die ein Buchungsblatt
     über dessen ID referenzieren -->
<xsl:key name="namensnr_zu_blatt" match="//adv:AX_Namensnummer" use="adv:istBestandteilVon/@xlink:href"/>

<!-- =======================================================================
	 Functionen (unter XSLT 1.0 nur "named" Templates untertsützt) 
 	 ======================================================================= -->
 	 
<xsl:template name="lageSchluesselGesamt">
	<!-- Berechnung des Attributes adv:schluesselGesamt aus 
		 adv:AX_VerschluesselteLagebezeichnung für die Suche eines passendenden
		 adv:AX_LagebezeichnungKatalogeintrag Satzes ( KEY lage_katalog).
		 
		 Im Parameter ax_vlb wird ein AX_VerschluesselteLagebezeichnung Satz
		 erwartet.
		 
		 Eine KEY Definition direkt mit adv:AX_VerschluesselteLagebezeichnung 
		 analog zum KEY gemeinde und gemarkung hat aus ungeklaren Gründen nicht
		 funktioniert -->
	<xsl:param name="ax_vlb" required="yes"/>
	<xsl:value-of select="concat($ax_vlb/adv:land, $ax_vlb/adv:regierungsbezirk,
								 $ax_vlb/adv:kreis, $ax_vlb/adv:gemeinde,
								 $ax_vlb/adv:lage)"/>
</xsl:template>

<!-- =======================================================================
	 Templates zum Aufbau der temp. XML Struktur mit Infos zu Flurstücken 
 	 ======================================================================= -->

<xsl:template match="adv:AX_Flurstueck" mode="info">
	<!-- Infobaum eines AX_Flurstueck erstellen incl. durch 
		 - Join 'zeigtAuf' referenzierter AX_LagebezeichnungOhneHausnummer
		 - Join 'weistAuf' referenzierter AX_LagebezeichnungMitHausnummer
		 - Join 'istGebucht' referenzierter AX_Buchungsstelle und hiervon
		   referenziertem  AX_Buchungsblatt -> AX_Person  -->
	<xsl:variable name="objid" select="gml:identifier"/>
	<xsl:variable name="landid" select="adv:gemarkung/*/adv:land"/>
	<xsl:variable name="gmkid" select="adv:gemarkung/*/adv:gemarkungsnummer"/>
	<xsl:variable name="zaehler" select="adv:flurstuecksnummer/*/adv:zaehler"/>
	<xsl:variable name="nenner" select="adv:flurstuecksnummer/*/adv:nenner"/>
	<info>
		<xsl:attribute name="class">
			<xsl:value-of select="local-name()"/>
		</xsl:attribute>
        <xsl:attribute name="Identifier">
        	<xsl:value-of select="$objid"/>
        </xsl:attribute>
        <xsl:attribute name="Kennzeichen">
        	<xsl:value-of select="adv:flurstueckskennzeichen"/>
        </xsl:attribute>
        <xsl:attribute name="Land">
        	<xsl:value-of select="$landid"/>
        </xsl:attribute>
        <xsl:attribute name="Gemarkung">
        	<xsl:value-of select="$gmkid"/>
        </xsl:attribute>
        <xsl:attribute name="GemarkungsSchluessel">
        	<xsl:value-of select="adv:gemarkung"/>
        </xsl:attribute>
        <xsl:attribute name="Gemarkungsname">
        	<xsl:value-of select="key('gemarkung', adv:gemarkung)/adv:bezeichnung"/>
        </xsl:attribute>
        
        <xsl:attribute name="Stelle">
        	<xsl:value-of select="adv:zustaendigeStelle/*/adv:stelle"/>
        </xsl:attribute>
        <xsl:attribute name="Flur">
        	<xsl:value-of select="adv:flurnummer"/>
        </xsl:attribute>
        <xsl:attribute name="Zaehler">
        	<xsl:value-of select="$zaehler"/>
        </xsl:attribute>
        <xsl:attribute name="Nenner">
        	<xsl:value-of select="$nenner"/>
        </xsl:attribute>
        <xsl:attribute name="FlstNr">
        	<xsl:value-of select="$zaehler"/>
        	<xsl:if test="$nenner!=''"> / <xsl:value-of select="$nenner" /></xsl:if>
        </xsl:attribute>
        <xsl:attribute name="amtlicheFlaeche">
        	<xsl:value-of select="adv:amtlicheFlaeche"/>
        </xsl:attribute>
        <xsl:attribute name="GemeindeKennzeichen">
        	<xsl:value-of select="adv:gemeindezugehoerigkeit"/>
        </xsl:attribute>
        <xsl:attribute name="Gemeindename">
        	<xsl:value-of select="key('gemeinde', adv:gemeindezugehoerigkeit)/adv:bezeichnung"/>
        </xsl:attribute>
        
        
        <!-- Ermittlung der referenzierten AX_LagebezeichnungOhneHausnummer -->
		<xsl:apply-templates select="key('lage_ohne_Hsnr', adv:zeigtAuf/@xlink:href)" mode="info"/>	
		<!-- Ermittlung der referenzierten AX_LagebezeichnungMitHausnummer -->	        	 
        <xsl:apply-templates select="key('lage_mit_Hsnr', adv:weistAuf/@xlink:href)" mode="info"/>
        <!-- Ermittlung der referenzierten AX_Buchungsstelle -->
		<xsl:apply-templates select="key('buchungsstelle', adv:istGebucht/@xlink:href)" mode="info"/>
		
	</info>
</xsl:template>

<xsl:template match="adv:AX_LagebezeichnungOhneHausnummer" mode="info">
	<!-- Infobaum einer AX_LagebezeichnungOhneHausnummer erstellen -->
	
	<info>
		<xsl:attribute name="class">
			<xsl:value-of select="local-name()"/>
		</xsl:attribute>
		<!-- Ausgabe der verschluesselten Lagebezeichnung -->
		<xsl:attribute name="Schluessel">
			<xsl:value-of select=".//adv:AX_VerschluesselteLagebezeichnung"/>
		</xsl:attribute>
		<xsl:attribute name="Bezeichnung">
			<xsl:apply-templates select=".//adv:AX_Lagebezeichnung" mode="info"/>
		</xsl:attribute>
	</info>
	
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
		<xsl:attribute name="Bezeichnung">
			<xsl:apply-templates select=".//adv:AX_Lagebezeichnung" mode="info"/>
		</xsl:attribute>
		<xsl:attribute name="HsNr">
  			<xsl:value-of select="adv:hausnummer"/>
		</xsl:attribute>
	</info>

</xsl:template>

<xsl:template match="adv:AX_Lagebezeichnung" mode="info">
	<!-- Ermittelt aus einem AX_Lagebezeichnung Satz die Bezeichnung
		 Dies liegt entweder direkt im Element unverschluesselt vor, oder 
		 verschluesselt im Element AX_VerschluesselteLagebezeichnung. 
		 Die Bezeichnung findet sich dann in einem 
		 AX_LagebezeichnungKatalogeintrag Satz.  -->
		 
	<xsl:choose>
		<xsl:when test="adv:verschluesselt">
			<!-- Ausgabe der verschluesselten Lagebezeichnung -->
			<xsl:variable name="lageid">
				<xsl:call-template name="lageSchluesselGesamt">
					<xsl:with-param name="ax_vlb" 
						select="adv:verschluesselt/adv:AX_VerschluesselteLagebezeichnung"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:value-of select="key('lage_katalog', $lageid)/adv:bezeichnung"/>
		</xsl:when>
		<xsl:otherwise>
			<!-- Ausgabe der unverschluesselten Lagebezeichnung -->
			<xsl:value-of select="adv:unverschluesselt"/>
		</xsl:otherwise>
	</xsl:choose>		 
</xsl:template>

<xsl:template match="adv:AX_Buchungsstelle" mode="info">
	<!-- Infobaum einer AX_Buchungsstelle erstellen incl. durch Join 
		 'istBestandteilVon' referenziertem AX_Buchungsblatt -->
	
	<info>
		<xsl:attribute name="class">
			<xsl:value-of select="local-name()"/>
		</xsl:attribute>

        <xsl:attribute name="Buchungsart">
        	<xsl:value-of select="adv:buchungsart"/>
        </xsl:attribute>
        <xsl:attribute name="laufendeNummer">
        	<xsl:value-of select="adv:laufendeNummer"/>
        </xsl:attribute>
		<xsl:if test="adv:anteil">
			<xsl:attribute name="Anteil">
				<xsl:apply-templates select="adv:anteil/adv:AX_Anteil" mode="info"/>
			</xsl:attribute>
			<xsl:attribute name="AnteilZaehler">
				<xsl:apply-templates select="adv:anteil/adv:AX_Anteil/adv:zaehler" mode="info"/>
			</xsl:attribute>
			<xsl:attribute name="AnteilNenner">
				<xsl:apply-templates select="adv:anteil/adv:AX_Anteil/adv:nenner" mode="info"/>
			</xsl:attribute>
			<xsl:attribute name="NrAufteilungsplan">
				<xsl:apply-templates select="adv:nummerImAufteilungsplan" mode="info"/>
			</xsl:attribute>
		</xsl:if>
	
		<!-- Ermittlung des referenzierten AX_Buchungsblatt -->
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
        
       	<!-- Ermittlung der AX_Namensnummern, die dieses Buchungsblatt über die
       	     dessen ID referenzieren -->
		<xsl:apply-templates select="key('namensnr_zu_blatt', $objid)" mode="info"/>
	</info>
	
</xsl:template>

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
		<xsl:attribute name="Nummer">
			<xsl:value-of select="adv:nummer"/>
		</xsl:attribute>
		<xsl:if test="adv:anteil">
			<xsl:attribute name="Anteil">
				<xsl:apply-templates select="adv:anteil/adv:AX_Anteil" mode="info"/>
			</xsl:attribute>
			<xsl:attribute name="AnteilZaehler">
				<xsl:apply-templates select="adv:anteil/adv:AX_Anteil/adv:zaehler" mode="info"/>
			</xsl:attribute>
			<xsl:attribute name="AnteilNenner">
				<xsl:apply-templates select="adv:anteil/adv:AX_Anteil/adv:nenner" mode="info"/>
			</xsl:attribute>
		</xsl:if>

		<!-- Ermittlung referenzierter Person -->
		<xsl:apply-templates select="key('person', adv:benennt/@xlink:href)" mode="info"/>
	</info>
	
</xsl:template>

<xsl:template match="adv:AX_Anteil" mode="info">
	<!-- Ermittelt für Infobaum Bruchstrichdarstellung des AX_Anteil  -->
		 
	<xsl:value-of select="concat(substring-before(adv:zaehler, '.'), ' / ', 
								 substring-before(adv:nenner, '.'))"/>
</xsl:template>



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

</xsl:stylesheet>


