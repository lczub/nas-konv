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
	 Templates zum Aufbau der temp. XML Struktur mit Infos zu Flurstücken 
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

		<!-- Ermittlung referenzierter Person -->
		<xsl:apply-templates select="key('person', adv:benennt/@xlink:href)" mode="info"/>
	</info>
	
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


