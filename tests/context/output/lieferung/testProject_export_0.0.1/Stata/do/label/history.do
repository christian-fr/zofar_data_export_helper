****************************************************************************
// Dieses Skript wurde erzeugt vom Zofar Online Survey System
// Es dient lediglich als Beispiel und sollte ggf. den eigenen Bedürfnissen angepasst werden.
// Das Skript wurde für Stata 14 erstellt.
// Eine Kompatibilität mit älteren Stata-Versionen kann nicht gewährleistet werden.
****************************************************************************
** Projekt/ Studie: build_sachseneval
** Erstellung: automatische Erstellung durch Zofar
** Erstelldatum: 20.10.2023 12:39:52
** Rohdaten: history.csv 
** Datensatz-Ergebnis: 
************** 1: history-arbeitsdaten.dta
************** 2: history-wide.dta
************** 3: history-wide-collapse.dta
** Log File:   history-aufbereitung.smcl
*************************************************************************
*************************************************************************

version 14						// Festlegung der Stata-Version
set more off					// Anzeige wird nicht unterbrochen
clear							// löscht die Daten im Memory

log using history-datenaufbereitung.smcl, replace	// Log-file erstellen

*________Rohdaten importieren___________________
import delimited "..\..\csv\history.csv", bindquote(strict) clear			//Achtung! Pfad gilt nur für die aktuelle Ordnerstruktur und muss evtl. angepasst werden!


*_________Zeitstempel in numerische Variable umwandeln_______
gen double seiteneing=clock(timestamp, "YMDhms", 2020)
format seiteneing %-tc
label var seiteneing "Zeitstempel für Seiteneingang"


*________Berechnung der Verweildauer pro Seite (in Millisekunden)____
//Achtung: automatischer SessionTimeout i.d.R. nach einer halben Stunde
sort participant_id id, stable
gen verwdauer = seiteneing[_n+1]-seiteneing if participant_id==participant_id[_n+1]
label var verwdauer "Verweildauer pro Seite in Millisekunden"


*__________Fragebogenseiten nummerieren___________
// Alle Seiten mit nichtnumerischer Bezeichnung (zusätzlich zu "index" und "end")
// müssen manuell nachkodiert werden (siehe replace-command)
destring page, gen(seitennr) ignore("page") force
replace seitennr= 0 if page=="index"
replace seitennr= 1000 if page=="end"
label var seitennr "Fragebogenseite"


*__________Seiten der Befragten nummerieren______
sort participant_id id, stable
by participant_id: gen seitenaufr_nr=_n
label var seitenaufr_nr "Nummer des Seitenaufrufes im Verlauf der Befragung"


*_______überflüssige Variablen löschen_________
drop id timestamp


*__________Arbeitsdatensatz speichern_____________
save "..\..\csv\history-arbeitsdaten.dta", replace


*************************************************************************
*************************************************************************
************ Datensatz umwandeln in ein breites Format ******************
// Datensatz zeigt individuelle Verläufe der Personen durch den Fragebogen
use "..\..\csv\history-arbeitsdaten.dta", clear


*________überflüssige Variablen löschen___________
drop seitennr


*___________reshape ohne collapse_________________
reshape wide seiteneing verwdauer page, i(participant_id token) j(seitenaufr_nr)


*________Datensatz speichern___________
save "..\..\csv\history-wide.dta", replace


*************************************************************************
*************************************************************************
****** Datensatz umwandeln in ein breites Format mit aggregierten Daten **
// Datensatz zeigt Verbleibdauer auf jeder Seite 
// Variablen enthalten Informationen über den Verbleib auf den Seiten
// !Achtung: bei mehrmaligem Laden der Seite wird der Verbleib summiert!
// Variablennummern entsprechen Seitennummern, mit folgenden Ausnahmen: 
// 				0: 		index
//				1000:	end
//				...

use "..\..\csv\history-arbeitsdaten.dta", clear

*________Datensatz aggregieren____________________
// Aufsummieren der Verweildauer bei mehrmaligem Besuch der Seite
collapse (sum) verwdauer (first) token seitennr seiteneing anzseitenaufr (last) seitenaufr_nr, by(participant_id page)

*________überflüssige Variablen löschen___________
drop seitenaufr_nr page seiteneing

rename verwdauer verw_page

reshape wide verw_page, i(participant_id token) j(seitennr)

*________Datensatz speichern___________
save "..\..\csv\history-wide-collapse.dta", replace

log close

