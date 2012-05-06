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
	       Aufnahmepunkten (AX_Aufnahmepunkt) -> temp. XML Bäume
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
	 Templates zum Aufbau der temp. XML Struktur mit Infos zu Aufnahmepunkte 
 	 ======================================================================= -->

<xsl:template match="adv:AX_Aufnahmepunkt|adv:AX_Sicherungspunkt" mode="info">
	<!-- Infobaum mit Sachdaten zu AX_Aufnahmepunkt oder AX_Sicherungspunkt
		 und zugehörigen Punktorten -->
	<xsl:variable name="objid"><xsl:value-of select="gml:identifier"/></xsl:variable>
	<info>
		<xsl:attribute name="class">
			<xsl:value-of select="local-name()"/>
		</xsl:attribute>
        <xsl:attribute name="Punktkennung">
        	<xsl:value-of select="adv:punktkennung"/>
        </xsl:attribute>
        <xsl:attribute name="Stelle">
        	<xsl:value-of select="adv:zustaendigeStelle/*/adv:land"/> -	<xsl:value-of select="adv:zustaendigeStelle/*/adv:stelle"/>
        </xsl:attribute>
        <xsl:attribute name="Vermarkung">
        	<xsl:value-of select="adv:vermarkung_Marke"/>
        </xsl:attribute>
        <xsl:attribute name="Identifier">
        	<xsl:value-of select="$objid"/>
        </xsl:attribute>
        <xsl:apply-templates select="//adv:*[adv:istTeilVon/@xlink:href=$objid]" mode="info"/>
	</info>
</xsl:template>

<xsl:template match="adv:AX_PunktortAU" mode="info">
	<!-- Infobaum mit Koordinaten und Bezugsystem eines AX_PunktortAU -->
	
	<info>
		<xsl:attribute name="class">
			<xsl:value-of select="local-name()"/>
		</xsl:attribute>
		<xsl:attribute name="Position">
			<xsl:value-of select="adv:position/gml:Point/gml:pos"/>
        </xsl:attribute>
        <xsl:attribute name="Bezugssystem">
			<xsl:value-of select="adv:position//@srsName[1]"/>
        </xsl:attribute>
	</info>
	
</xsl:template>

</xsl:stylesheet>