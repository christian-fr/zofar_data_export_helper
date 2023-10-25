*********************************************************************
*_______________ testProject ___________
di "processing do file: history"

version 17

cap log close
log using `"${log_dir}log_history_`: di %tdCY-N-D daily("$S_DATE", "DMY")'.smcl"', append

di "processing: response do file"
di "global macros:"
di "do_dir: ${do_dir}"
di "log_dir: ${log_dir}"
di "data_dir: ${data_dir}"
di "csv_dir: ${csv_dir}"
di "version: ${version}"

assert "${version}" == "0.0.1"

****************************************************************************
** Projekt/ Studie:        testProject
** Projektname kurz
** (für Pfade/Dateinamen): testProject
** Erstelldatum:           2023-10-23_13-19-17
** History-Daten:          2023-10-20_12-39-52
** Datensatz:              2023-10-20_12-39-52
** Bearbeitet von:         Test User
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

replace pagenum=0 if page=="index"
replace pagenum=1 if page=="F00"
replace pagenum=2 if page=="F01"
replace pagenum=3 if page=="F02_SHK"
replace pagenum=4 if page=="F03"
replace pagenum=5 if page=="F04a"
replace pagenum=6 if page=="F04"
replace pagenum=7 if page=="F05"
replace pagenum=8 if page=="F06"
replace pagenum=9 if page=="F07"
replace pagenum=10 if page=="F08"
replace pagenum=11 if page=="F09"
replace pagenum=12 if page=="F10"
replace pagenum=13 if page=="F11"
replace pagenum=14 if page=="F12"
replace pagenum=15 if page=="F13"
replace pagenum=16 if page=="F14"
replace pagenum=17 if page=="F15"
replace pagenum=18 if page=="F16"
replace pagenum=19 if page=="F17"
replace pagenum=20 if page=="F18"
replace pagenum=21 if page=="F19"
replace pagenum=22 if page=="F21"
replace pagenum=23 if page=="F22"
replace pagenum=24 if page=="F23"
replace pagenum=25 if page=="F24"
replace pagenum=26 if page=="F26"
replace pagenum=27 if page=="F27"
replace pagenum=28 if page=="F28"
replace pagenum=29 if page=="F29"
replace pagenum=30 if page=="F30"
replace pagenum=31 if page=="F31"
replace pagenum=32 if page=="F32"
replace pagenum=33 if page=="F33"
replace pagenum=34 if page=="F34"
replace pagenum=35 if page=="F35"
replace pagenum=36 if page=="F36"
replace pagenum=37 if page=="F37"
replace pagenum=38 if page=="F38"
replace pagenum=39 if page=="F39"
replace pagenum=40 if page=="F40"
replace pagenum=41 if page=="F41"
replace pagenum=42 if page=="F42"
replace pagenum=43 if page=="F43"
replace pagenum=44 if page=="F44"
replace pagenum=45 if page=="F45"
replace pagenum=46 if page=="F46"
replace pagenum=47 if page=="F47"
replace pagenum=48 if page=="F48"
replace pagenum=49 if page=="F49"
replace pagenum=50 if page=="F50"
replace pagenum=51 if page=="F51"
replace pagenum=52 if page=="F52"
replace pagenum=53 if page=="F53"
replace pagenum=54 if page=="F54"
replace pagenum=55 if page=="F55"
replace pagenum=56 if page=="F56"
replace pagenum=57 if page=="F57"
replace pagenum=58 if page=="F58"
replace pagenum=59 if page=="F59"
replace pagenum=60 if page=="F60"
replace pagenum=61 if page=="F61"
replace pagenum=62 if page=="F62"
replace pagenum=63 if page=="F63"
replace pagenum=64 if page=="F64a"
replace pagenum=65 if page=="F64b"
replace pagenum=66 if page=="F64c"
replace pagenum=67 if page=="F65"
replace pagenum=68 if page=="F66"
replace pagenum=69 if page=="F67"
replace pagenum=70 if page=="F68"
replace pagenum=71 if page=="F69"
replace pagenum=72 if page=="F70"
replace pagenum=73 if page=="F71"
replace pagenum=74 if page=="F72"
replace pagenum=75 if page=="F73"
replace pagenum=76 if page=="F75"
replace pagenum=77 if page=="cancel"
replace pagenum=78 if page=="end"


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

cap label var visit0 "Anzahl Aufrufe von index"
cap label var visit0 "Anzahl Aufrufe von F00"
* ToDo *
* MAGIC! *



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


*________gesamte Bearbeitungsdauer / Verweildauer pro Befragten________
///
cap drop dauer
egen dauer=rowtotal(pagedauer*)

order participant_id token dauer maxpage lastpage anzseiten dauer_mn dauer_med dauer_min dauer_max dauer_sd


*________Variablen beschriften______________________
*_______ [1] Seiten (Verweildauern mit page-ID)
cap label var pagedauer0 "Verweildauer auf index (in Sekunden)"
cap label var pagedauer1 "Verweildauer auf F00 (in Sekunden)"
cap label var pagedauer2 "Verweildauer auf F01 (in Sekunden)"
cap label var pagedauer3 "Verweildauer auf F02_SHK (in Sekunden)"
cap label var pagedauer4 "Verweildauer auf F03 (in Sekunden)"
cap label var pagedauer5 "Verweildauer auf F04a (in Sekunden)"
cap label var pagedauer6 "Verweildauer auf F04 (in Sekunden)"
cap label var pagedauer7 "Verweildauer auf F05 (in Sekunden)"
cap label var pagedauer8 "Verweildauer auf F06 (in Sekunden)"
cap label var pagedauer9 "Verweildauer auf F07 (in Sekunden)"
cap label var pagedauer10 "Verweildauer auf F08 (in Sekunden)"
cap label var pagedauer11 "Verweildauer auf F09 (in Sekunden)"
cap label var pagedauer12 "Verweildauer auf F10 (in Sekunden)"
cap label var pagedauer13 "Verweildauer auf F11 (in Sekunden)"
cap label var pagedauer14 "Verweildauer auf F12 (in Sekunden)"
cap label var pagedauer15 "Verweildauer auf F13 (in Sekunden)"
cap label var pagedauer16 "Verweildauer auf F14 (in Sekunden)"
cap label var pagedauer17 "Verweildauer auf F15 (in Sekunden)"
cap label var pagedauer18 "Verweildauer auf F16 (in Sekunden)"
cap label var pagedauer19 "Verweildauer auf F17 (in Sekunden)"
cap label var pagedauer20 "Verweildauer auf F18 (in Sekunden)"
cap label var pagedauer21 "Verweildauer auf F19 (in Sekunden)"
cap label var pagedauer22 "Verweildauer auf F21 (in Sekunden)"
cap label var pagedauer23 "Verweildauer auf F22 (in Sekunden)"
cap label var pagedauer24 "Verweildauer auf F23 (in Sekunden)"
cap label var pagedauer25 "Verweildauer auf F24 (in Sekunden)"
cap label var pagedauer26 "Verweildauer auf F26 (in Sekunden)"
cap label var pagedauer27 "Verweildauer auf F27 (in Sekunden)"
cap label var pagedauer28 "Verweildauer auf F28 (in Sekunden)"
cap label var pagedauer29 "Verweildauer auf F29 (in Sekunden)"
cap label var pagedauer30 "Verweildauer auf F30 (in Sekunden)"
cap label var pagedauer31 "Verweildauer auf F31 (in Sekunden)"
cap label var pagedauer32 "Verweildauer auf F32 (in Sekunden)"
cap label var pagedauer33 "Verweildauer auf F33 (in Sekunden)"
cap label var pagedauer34 "Verweildauer auf F34 (in Sekunden)"
cap label var pagedauer35 "Verweildauer auf F35 (in Sekunden)"
cap label var pagedauer36 "Verweildauer auf F36 (in Sekunden)"
cap label var pagedauer37 "Verweildauer auf F37 (in Sekunden)"
cap label var pagedauer38 "Verweildauer auf F38 (in Sekunden)"
cap label var pagedauer39 "Verweildauer auf F39 (in Sekunden)"
cap label var pagedauer40 "Verweildauer auf F40 (in Sekunden)"
cap label var pagedauer41 "Verweildauer auf F41 (in Sekunden)"
cap label var pagedauer42 "Verweildauer auf F42 (in Sekunden)"
cap label var pagedauer43 "Verweildauer auf F43 (in Sekunden)"
cap label var pagedauer44 "Verweildauer auf F44 (in Sekunden)"
cap label var pagedauer45 "Verweildauer auf F45 (in Sekunden)"
cap label var pagedauer46 "Verweildauer auf F46 (in Sekunden)"
cap label var pagedauer47 "Verweildauer auf F47 (in Sekunden)"
cap label var pagedauer48 "Verweildauer auf F48 (in Sekunden)"
cap label var pagedauer49 "Verweildauer auf F49 (in Sekunden)"
cap label var pagedauer50 "Verweildauer auf F50 (in Sekunden)"
cap label var pagedauer51 "Verweildauer auf F51 (in Sekunden)"
cap label var pagedauer52 "Verweildauer auf F52 (in Sekunden)"
cap label var pagedauer53 "Verweildauer auf F53 (in Sekunden)"
cap label var pagedauer54 "Verweildauer auf F54 (in Sekunden)"
cap label var pagedauer55 "Verweildauer auf F55 (in Sekunden)"
cap label var pagedauer56 "Verweildauer auf F56 (in Sekunden)"
cap label var pagedauer57 "Verweildauer auf F57 (in Sekunden)"
cap label var pagedauer58 "Verweildauer auf F58 (in Sekunden)"
cap label var pagedauer59 "Verweildauer auf F59 (in Sekunden)"
cap label var pagedauer60 "Verweildauer auf F60 (in Sekunden)"
cap label var pagedauer61 "Verweildauer auf F61 (in Sekunden)"
cap label var pagedauer62 "Verweildauer auf F62 (in Sekunden)"
cap label var pagedauer63 "Verweildauer auf F63 (in Sekunden)"
cap label var pagedauer64 "Verweildauer auf F64a (in Sekunden)"
cap label var pagedauer65 "Verweildauer auf F64b (in Sekunden)"
cap label var pagedauer66 "Verweildauer auf F64c (in Sekunden)"
cap label var pagedauer67 "Verweildauer auf F65 (in Sekunden)"
cap label var pagedauer68 "Verweildauer auf F66 (in Sekunden)"
cap label var pagedauer69 "Verweildauer auf F67 (in Sekunden)"
cap label var pagedauer70 "Verweildauer auf F68 (in Sekunden)"
cap label var pagedauer71 "Verweildauer auf F69 (in Sekunden)"
cap label var pagedauer72 "Verweildauer auf F70 (in Sekunden)"
cap label var pagedauer73 "Verweildauer auf F71 (in Sekunden)"
cap label var pagedauer74 "Verweildauer auf F72 (in Sekunden)"
cap label var pagedauer75 "Verweildauer auf F73 (in Sekunden)"
cap label var pagedauer76 "Verweildauer auf F75 (in Sekunden)"
cap label var pagedauer77 "Verweildauer auf cancel (in Sekunden)"
cap label var pagedauer78 "Verweildauer auf end (in Sekunden)"



label define maxpagelb 0 "index" 1 "F00" 2 "F01" 3 "F02_SHK" 4 "F03" 5 "F04a" 6 "F04" 7 "F05" 8 "F06" 9 "F07" 10 "F08" 11 "F09" 12 "F10" 13 "F11" 14 "F12" 15 "F13" 16 "F14" 17 "F15" 18 "F16" 19 "F17" 20 "F18" 21 "F19" 22 "F21" 23 "F22" 24 "F23" 25 "F24" 26 "F26" 27 "F27" 28 "F28" 29 "F29" 30 "F30" 31 "F31" 32 "F32" 33 "F33" 34 "F34" 35 "F35" 36 "F36" 37 "F37" 38 "F38" 39 "F39" 40 "F40" 41 "F41" 42 "F42" 43 "F43" 44 "F44" 45 "F45" 46 "F46" 47 "F47" 48 "F48" 49 "F49" 50 "F50" 51 "F51" 52 "F52" 53 "F53" 54 "F54" 55 "F55" 56 "F56" 57 "F57" 58 "F58" 59 "F59" 60 "F60" 61 "F61" 62 "F62" 63 "F63" 64 "F64a" 65 "F64b" 66 "F64c" 67 "F65" 68 "F66" 69 "F67" 70 "F68" 71 "F69" 72 "F70" 73 "F71" 74 "F72" 75 "F73" 76 "F75" 77 "cancel" 78 "end" 
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