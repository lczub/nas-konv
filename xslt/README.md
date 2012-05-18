Von NAS-KONV bereitgestellte XSLT Konvertierungen
=================================================

Aktuell bereitgestellte XSLT 1.0 (_exsl) und 1.1 Konvertierungen
----------------------------------------------------------------

* nasconv_aufnahmepunkte(_exsl):
  Liste der AX_Aufnahmepunkt und ihnen zugeordneter AX_PunktortAU Datensätze
* nasconv_flurstuecke(_exsl):
  Liste der AX_Flurstück und ihnen zugeordneter AX_Buchungsblatt und AX_Person Datensätze
  Die vom Flurstück über das Grundbuchblatt referenzierten Personen werden in einer Tabellenzelle aggregiert
* nasconv_flurstuecke_personen(_exsl):
  Liste der AX_Flurstück und ihnen zugeordneter AX_Buchungsblatt und AX_Person Datensätze
  Pro Person, die vom Flurstück über das Grundbuchblatt referenziert wird, wird eine Tabellenzeile erzeugt
  
Aktuell bereitgestellte XSLT 2.0 Konvertierungen
------------------------------------------------

* nasconv_flurstuecke_gruppiert:
  Liste der AX_Flurstück und ihnen zugeordneter AX_Buchungsblatt und AX_Person Datensätze, gruppiert nach Gemarkung - Flur in separaten Tabellen.
