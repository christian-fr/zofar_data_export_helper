*********************************************************************
*_______________ {{ project_name }} ___________
di "processing do file: history"

version 17

cap log close
log using `"${log_dir}log_history_`: di %tdCY-N-D daily("$S_DATE", "DMY")'.smcl"', append

di "global macros:"
di "do_dir: ${do_dir}"
di "log_dir: ${log_dir}"
di "data_dir: ${data_dir}"
di "csv_dir: ${csv_dir}"
di "version: ${version}"

assert "${version}" == "{{ project_version }}"


****************************************************************************
** Projekt/ Studie:        {{ project_name }}
** Projektname kurz
** (für Pfade/Dateinamen): {{ project_name_short }}
** Erstelldatum:           {{ timestamp_str }}
** History-Daten:          {{ history_csv_zip_file_modification_time_str }}
** Datensatz:              {{ data_csv_zip_file_modification_time_str }}
** Bearbeitet von:         {{ user }}
****************************************************************************

*_________________________________________________________________
** Do-File zur Aufbereitung der history-Daten
*__________________________________________________________________

*____________Daten importieren____________________
di "Versuche Datei '${csv_dir}history.csv' zu laden."
import delimited "${csv_dir}history.csv", delimiter(comma) bindquote(strict) clear


*____________Tester löschen____________________
foreach t of numlist 1/200 {
	quiet: drop if token=="tester`t'" | token=="part`t'"
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

{{ replace_pagenum }}

tab page if pagenum==.
* make sure that there are no cases with missing values on "pagenum"
*   (if the program returns here "assertion is false"
*    -> check the "history.csv" for pages that do not exist in the QML file )
assert _N == 0 if pagenum == .

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
	*__________Fragebogenseiten zu Modul zuordnen ____________________________
	*     (siehe auch weiter unten: "Boxplot Bearbeitungsdauer nach Modul")
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
cap confirm modul
if !_rc {
    	di `"variable "modul" exists"'
		collapse (sum) verwdauer (first) token modul pagenum          ///
		seiteneing (max) allmiss visit (mean) maxpage lastpage, ///
		by(participant_id page)
	}
	else {
		di `"variable "modul" does not exist, hence it is omitted from collapse"'
		collapse (sum) verwdauer (first) token pagenum    ///
		seiteneing (max) allmiss visit (mean) maxpage lastpage, ///
		by(participant_id page)
}


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



* Bearbeitungsdauer nach Modul
cap confirm variable width // assert that variable modul is present
if !_rc {
	di "variable 'modul' exists, processing"


*nach Modul
bysort participant_id modul: egen moduldauer=total(verwdauer)
label var moduldauer "Bearbeitungsdauer des Moduls pro Befragten"



cap drop moduldauer_minutes
gen moduldauer_minutes = moduldauer / 60
lab var moduldauer_minutes "Bearbeitungsdauer pro Modul in Minuten"

cap drop moduln
bysort modul: egen moduln=count(participant_id)
	table modul, contents(n moduln median time_modul min time_modul max time_modul)

    *_________Boxplot Bearbeitungsdauer nach Modul__________________________________
    *  (siehe oben: "Fragebogenseiten zu Modul zuordnen" muss zuvor erledigt werden)

        * Labels für Module vorbereiten
        qui levelsof(modul)

        local levelslist `r(levels)'

        cap drop modul_labeled
        gen modul_labeled = ""

        foreach modul_name in `"`levelslist'"' {
            qui levelsof participant_id if modul =="`modul_name'" // Anzahl Befragte im Modul
            local part_count : word count `r(levels)'

            qui levelsof page if modul =="`modul_name'" // Anzahl pages pro Modul (aus den history-Daten)
            local page_count : word count `r(levels)'

            replace modul_labeled=`"`modul_name' (n=`part_count', pages: `page_count')"' if modul ==`"`modul_name'"'
            di `"`modul_name' `page_count' `part_count'"'
        }


    graph hbox moduldauer_minutes, over(modul_labeled, label(labsize(vsmall))) nooutsides ///
        title("Bearbeitungsdauer nach Modul") ///
        note("Nacaps (cohort 2020, wave 2)") ///
        ytitle("Bearbeitungszeit in Minuten", size(small)) ///
        ylabel( , labsize(vsmall))

	graph save Graph "${out_dir}ResponseTime_nachModul.gph", replace
	graph export "${out_dir}ResponseTime_nachModul.png", as(png) replace

	
	}
	else {
		di as error "variable 'modul' does not exist, skipped processing" // error message
	}



*_______________________________________________________________
cap log close

log using `"${log_dir}log_history_abbrecher-verwdauer_`: di %tdCY-N-D daily("$S_DATE", "DMY")'.smcl"', append

*******************************************************************************
********************* Auswertungen Abbrüche und Verweildauern **********************

*________Anzahl der Abbrecher pro Seite___________
// table page, contents(n abbrecher mean dropoutrate n dropoutrate) format(%9.4f)
table page, stat(n abbrecher) stat(mean dropoutrate) stat(n dropoutrate) nformat(%9.4f)


quiet: tabout page using "${out_dir}testProject_abbrecher_${version}.xlsx", ///
	c(count abbrecher mean dropoutrate count dropoutrate) ///
	clab(Abbrecher Abbruchquote Seitenbesucher) ///
	replace sum ///
	f(0 4 0) ///
	style(xlsx) ///
	font(bold) dpcomma


*________Seitenverweildauer ____________________
tabstat verwdauer, statistics(mean median min max sd)

*________Seitenverweildauer nach Seite ____________________
table page, stat(n verwdauer) stat(mean verwdauer) stat(median verwdauer) stat(min verwdauer) stat(max verwdauer) nformat(%9.4f)

quiet: tabout page using "${out_dir}testProject_verwdauer_${version}.xlsx", ///
	c(count verwdauer mean verwdauer p50 verwdauer min verwdauer max verwdauer) ///
	clab(N mean med min max) ///
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
cap drop modul
cap drop modul_labeled
cap drop moduln
cap drop moduldauer
cap drop moduldauer_minutes
cap drop pagedauer*

rename verwdauer pagedauer

reshape wide pagedauer visit, i(participant_id) j(pagenum)

{{ label_visit }}
{{ label_pagedauer }}



*________gesamte Bearbeitungsdauer / Verweildauer pro Befragten________
///
cap drop dauer
egen dauer=rowtotal(pagedauer*)

order participant_id token dauer maxpage lastpage anzseiten dauer_mn dauer_med dauer_min dauer_max dauer_sd


*________Variablen beschriften______________________
*_______ [1] Seiten (Verweildauern mit page-ID)
{{ label_page_str }}


{{ label_maxpage_str }}
label val maxpage maxpagelb

*_______________________________________________________________
cap log close
log using `"${log_dir}log_history_verweildauer_`: di %tdCY-N-D daily("$S_DATE", "DMY")'.smcl"', append

*************************************************************************
************************** Auswertungen *********************************
tabstat dauer, statistic(mean median min max sd)

*___________Datensatz speichern _______________
save "${data_dir}history_collapsed.dta", replace
log close