*********************************************************************
*_______________ XXX__PROJECTNAME__XXX ___________

version 17

global version "XXX__VERSION__XXX"

global workdir "XXX__PROJECT_BASE_DIR__XXX\"

global orig "${workdir}orig\\${version}\"
global out "${workdir}lieferung\XXX__PROJECTNAME_SHORT__XXX_export_\${version}\"
global doc "${workdir}doc\"

cd "${workdir}doc"
cap log close
log using log_history`: di %tdCY-N-D daily("$S_DATE", "DMY")', append



****************************************************************************
** Projekt/ Studie:        XXX__PROJECTNAME__XXX
** Projektname kurz
** (für Pfade/Dateinamen): XXX__PROJECTNAME_SHORT__XXX
** Erstelldatum:           XXX__TIMESTAMP__XXX
** History-Daten:          XXX__TIMESTAMPHISTORY__XXX
** Datensatz:              XXX__TIMESTAMPDATASET__XXX
** Bearbeitet von:         XXX__USER__XXX
****************************************************************************

*_________________________________________________________________
** Do-File zur Aufbereitung der history-Daten
*__________________________________________________________________

*____________Daten importieren____________________
// mit Postleitzahlen als String-Variablen
import delimited "${orig}history.csv", delimiter(comma) bindquote(strict) clear 


*____________Tester löschen____________________
foreach t of numlist 1/200 {
	quiet: drop if token=="tester`t'"
	quiet: drop if token=="part`t'"
}

*_________Zeitstempel in numerische Variable umwandeln_______
gen double seiteneing=clock(timestamp, "YMDhms")

format seiteneing %-tc
label var seiteneing "Zeitstempel für Seiteneingang"

*________Berechnung der Verweildauer pro Seite (in Sekunden)____
//Achtung: automatischer SessionTimeout i.d.R. nach einer halben Stunde
sort participant_id seiteneing, stable
gen verwdauer= seiteneing[_n+1]-seiteneing if participant_id==participant_id[_n+1]

replace verwdauer= verwdauer/1000

label var verwdauer "Verweildauer pro Seite in Sekunden"

tabstat verwdauer, statistics(mean median min max sd)
//Korrektur der Verweildauer auf max. 30 Minuten (1800 Sekunden) pro Seitenbesuch
replace verwdauer=1800 if verwdauer>1800 & verwdauer!=.

*__________Fragebogenseiten nummerieren___________
// Seitennummerierung nach Reihenfolge im Fragebogen (QML)
gen pagenum=.

XXX__REPLACE_PAGENUM__XXX

tab page if pagenum==.

label var pagenum "Fragebogenseite"
tab pagenum, miss
tab page if pagenum==.
*tab page pagenum


*__________maximaler Fragebogenfortschritt___________
sort participant_id id, stable
by participant_id: egen maxpage = max(pagenum)
label var maxpage "maximaler Fortschritt im Fragebogen"


*__________letzte Fragebogenseite___________
sort participant_id id, stable
by participant_id: gen last = pagenum if participant_id!=participant_id[_n+1]
by participant_id: egen lastpage = max(last)
label var lastpage "letzte gesehene Fragebogenseite"
drop last


*______Seitenaufrufe pro Seite pro Befragten im Verlauf der Befragung_________
sort participant_id pagenum, stable
by participant_id pagenum: gen visit=_N
label var visit "Anzahl des Seitenaufrufes im Verlauf der Befragung"


	/*
	*__________Fragebogenseiten zu Modul zuordnen ___________
	gen modul=""
	replace modul="A" if page=="AXX01"
	replace modul="B" if page=="BXX01"
	replace modul="C" if page=="CXX01"

	label var modul "Fragenmodul"
	*/

*_______überflüssige Variablen löschen_________
drop id timestamp

*************************************************************************
*************************************************************************
****** Datensatz umwandeln in ein breites Format mit aggregierten Daten **

*________Datensatz aggregieren____________________
// Datensatz reduzieren auf eine Zeile pro Befragten und Fragebogenseite
// !Achtung: bei mehrmaligem Laden einer Seite wird der Verbleib summiert!
bysort participant_id page: gen allmiss=mi(verwdauer)

*** Datensatz reduzieren
collapse (sum) verwdauer (first) token /* modul */ pagenum seiteneing (max) allmiss visit (mean) maxpage lastpage, by(participant_id page)


//Korrektur des automatischen Ersetzens von fehlenden Werten mit 0 
replace verwdauer=. if  allmiss




*************************************************************************
*************************************************************************
****** Indikatoren berechnen **

*________Anzahl der Besucher pro Seite___________
bysort pagenum: gen visitor= _N
label var visitor "Anzahl der Besucher pro Seite (ohne doppelte Besuche)"

*________Anzahl der Abbrecher pro Seite___________
bysort pagenum lastpage: egen abbrecher= count(participant_id) if pagenum==lastpage
label var abbrecher "Anzahl der Abbrecher pro Seite (mit lastpage)"

bysort pagenum: egen dropout= max(abbrecher)
label var dropout "Anzahl der Abbrecher pro Seite (mit lastpage) [Konstante]"

*________Abbruchquote_____________________________
bysort pagenum: gen dropoutrate= dropout/visitor
label var dropoutrate "Abbruchquote (Anz. Abbrecher im Verhältn. zu Seitenbesucher)"

*________Anzahl der besuchten Seiten pro Befragten___________
bysort participant_id: gen anzseiten= _N 
label var anzseiten "Anzahl der besuchten Seiten pro Befragten"

*________Durchschnittliche Bearbeitungsdauer___________
egen dauer_mn=mean(verwdauer)
label var dauer_mn "Verweildauer: arithmetisches Mittel"

egen dauer_med=median(verwdauer)
label var dauer_med "Verweildauer: Median"

egen dauer_min=min(verwdauer)
label var dauer_min "Verweildauer: Minimum"

egen dauer_max=max(verwdauer)
label var dauer_max "Verweildauer: Maximum"

egen dauer_sd=sd(verwdauer)
label var dauer_sd "Verweildauer: Standardabweichung"


*_______________________________________________________________
cap log close
log using "${doc}XXX__PROJECTNAME_SHORT__XXX_abbrecher-verwdauer_${version}.smcl", append

*******************************************************************************
********************* Auswertungen Abbrüche und Verweildauern **********************

*________Anzahl der Abbrecher pro Seite___________
// table page, contents(n abbrecher mean dropoutrate n dropoutrate) format(%9.4f)
table page, stat(n abbrecher) stat(mean dropoutrate) stat(n dropoutrate) nformat(%9.4f)


quiet: tabout page using "XXX__PROJECTNAME_SHORT__XXX_abbrecher_${version}.xls", ///
	c(count abbrecher mean dropoutrate count dropoutrate) ///
	replace sum ///
	f(0 4 0) ///
	style(xlsx) ///
	font(bold) dpcomma
	

*________Seitenverweildauer ____________________
tabstat verwdauer, statistics(mean median min max sd)

*________Seitenverweildauer nach Seite ____________________
table page, stat(n verwdauer) stat(mean verwdauer) stat(median verwdauer) stat(min verwdauer) stat(max verwdauer) nformat(%9.4f)

quiet: tabout page using "XXX__PROJECTNAME_SHORT__XXX_verwdauer_${version}.xls", ///
	c(count verwdauer mean verwdauer p50 verwdauer min verwdauer max verwdauer) ///
	replace sum ///
	f(0 2 2) ///
	style(xlsx) ///
	font(bold) dpcomma

log close

*******************************************************************************
*******************************************************************************
*________Datensatz umwandeln: breites Format____
// jede Befragte eine Zeile, jede Seite eine Variable,  Verweildauer in den Zellen
*________überflüssige Variablen löschen___________
drop seiteneing page allmiss abbrecher visitor dropout dropoutrate /* modul*/
rename verwdauer p

reshape wide p visit, i(participant_id) j(pagenum)


*________gesamte Bearbeitungsdauer / Verweildauer pro Befragten________
/// 
XXX__DAUER__XXX

order participant_id token dauer maxpage lastpage anzseiten dauer_mn dauer_med dauer_min dauer_max dauer_sd


*________Variablen beschriften______________________
*_______ [1] Seiten (Verweildauern mit page-ID)
XXX__PAGE_LABEL__XXX


XXX__MAXPAGE_LABEL__XXX
label val maxpage maxpagelb

*_______________________________________________________________
cap log close
log using "XXX__PROJECT_DOC_DIR__XXX\XXX__PROJECTNAME_SHORT__XXX_verweildauer_${version}.smcl", append

*************************************************************************
************************** Auswertungen *********************************
tabstat dauer, statistic(mean median min max sd)

*Verweildauer bei abgeschlossenen Fragebögen
XXX__TABSTAT_VERWEILDAUER_FINISHED__XXX

*tabstat dauer if maxpage==157, statistic(mean median min max sd) 
*tabstatout dauer, s(n mean median min max sd) replace


*_______________________Verweildauer pro Seite__________________
*** Verweildauer pro Seite, wenn visit==1 um Summierung herauszurechnen
/*foreach n of numlist 0/152 {
 	tabstat p`n' if visit`n'==1, stat(mean min max sd med)
 	}
*/ 

/*
*XXXXXXXXX ToDo: varlist generieren lassen XXXXXXXXX
local num "0" "1" "2"
local varlist p`num'
*local varlist "p0 p1 p2"
local varlist "p0" "p1" "p2"
tabstat `varlist', statistic(n mean median min max sd) ///
	col(stat) ///
	format(%9.3g)  ///
	tf(table)
*/

log close

*___________Datensatz speichern _______________
save "${out}history_collapsed.dta", replace