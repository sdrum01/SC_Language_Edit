# SCLanguageEdit
Helper for Translation Safecontrol Files

#########################################################
##  Translation Helper for Safecontrol Language Files  ##
##                                                     ##
##                  Gunnebo Markersdorf                ##
##  11:28 08.03.2016                                   ##
#########################################################

Deutsch:

Das Tool ist ein kleiner Übersetzungshelfer mit Mergefunktion, damit man die Sprachdateien immer aktuell halten können.
Mit Click auf die oberen beiden Input-Felder wird die vollständige Quelldatei (Basis Englisch), dann die zu übersetzende Zieldatei geladen.
Während des Ladens der Zieldatei werden die Werte der Schlüssel (Key) und Unterschlüssel (Subkey) richtig zugeordnet.
In diese wird nicht geschrieben wird, es wird nur der Inhalt grafisch verglichen.
Der Inhalt der beiden Dateien wird in Tabelarischer Form dargestellt mit folgender Spaltenformatierung:

- Hauptschlüssel
- Unterschlüssel
- Wert der Originaldatei
- Wert der zu übersetzenden Datei (EDITIERBAR)
- Zeilennummer

Mit „Merge“ kann man alle leeren Werte und nicht existierenden Schlüssel von der Quelle zum Ziel kopieren, die schon übersetzten Werte werden nicht angefasst.
Das ist Hilfreich, wenn zuerst ohne Übersetzung überhaupt ein sinnvolles Wort in SAfecontrol angezeigt werden soll (dann in englisch)

Die zu übersetzenden Felder werden farbig dargestellt:
- Rote Felder : Leerer Wert
- Gelbe Felder: Identischer Inhalt wie die Quelldatei (noch nicht übersetzt).

Diese Felder sind editierbar.

Benutzung: 
mit ENTER (RETURN) oder den Pfeil hoch-runter Tasten kann ins nächste Feld gesprungen werden.
Mit dem aktivieren der Checkbox  "filter empty or equal" werden nur die wichtigen und zu übersetzenden Felder gezeigt, der Rest wird ausgeblendet.
Die Funktion "Search" blendet nur die Zeilen ein, wo der gesuchte Wert im Suchfeld auch vorkommt. Dabei wird case-insenstive gesucht, also ist es egal ob A oder a.
Mit Save wird eine Kopie der Zieldatei erstellt im Muster language_new.xxx.
Die Datei wird im Format der zu übersetzenden Datei gespeichert (das UTF-8 oder ANSI Format wird übernommen).

Es gibt die Möglichkeit, eine CSV aus der Queldatei zu exportieren mit Menu "File > Export Sourcefile to CSV" und 
eine übersetzte CSV Datei im selben Format zu importieren mit Menu "File > Import CSV to Destination"

##########################################################################################

English:
The tool is a small translation helper with merge functionality.
By clicking on the top input fields the complete source-file (basic in English) will load.
During loading of the translatable target file (destination) the Key's and Subkey's will be assigned on the correct position.
The content will be compared in a list view, which is editable in the translation field.
Structure of the columns of the table:

- KEY
- SUBKEY
- Value of original language
- Value of translated language (EDITABLE)
- line number

The translatable fields are shown in color:
- red fields: empty values
- yellow fields: equal values like original language (untranslated)

Those fields are editable.

usage: 
Jump into next field by clicking of RETURN or arrow up/down Keys.
activate the Checkbox "filter empty or equal" to show only the untranslated values.
The Input Field "search" is searching for the value case-insensitiv. All found lines will be displayed.
"Save" generated a new file with Structure language_new.xxx.
The Format of the Textfile (UTF-8 or ANSI) is the same like the destination file.

Its possible to Export the Sourcefile as CSV File via Menu "File > Export Sourcefile to CSV"
Its possible to Import a translated CSV File in teh same Format like the export CSV via Menu "File > Import CSV to Destination"


################ HISTORY ###############

V1.0.1.2
First Release

V 1.0.2.1
Drag'n'Drop possible of files from filemanager

V1.2.1.0  13/09/22
possible to Export and Import translated files from/to CSV, 
small cleanup and bugfixes
