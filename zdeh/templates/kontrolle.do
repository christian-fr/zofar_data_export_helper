*********************************************************************
*_______________ {{ projectname }} ___________

version 17

global version "{{ version }}"
global workdir "{{ project_base_dir }}\"
global orig "${workdir}orig\\${version}\"
global out "${workdir}lieferung\{{ projectname_short }}_export_\${version}\"

cd "${workdir}doc"
cap log close
log using log_kontrolle`: di %tdCY-N-D daily("$S_DATE", "DMY")', append


****************************************************************************
** Projekt/ Studie:        {{ projectname }}
** Projektname kurz
** (für Pfade/Dateinamen): {{ projectname_short }}
** Erstelldatum:           {{ timestamp_str }}
** History-Daten:          {{ history_csv_zip_file_modification_time_str }}
** Datensatz:              {{ data_csv_zip_file_modification_time_str }}
** Bearbeitet von:         {{ user }}
****************************************************************************


*____________Daten importieren____________________
{{ data_import }}


*******************************************************************************
******** Test: 1. Variablen enthalten ausschließlich Missing-Werte ************
********       bzw. 2. gar keine Missing-Werte 			***************
// Anzeigen von Variablen, die nur Missing-Werte enthalten
* Nur numerische Varisblen einbeziehen
quiet: ds, has(type int byte float) 
local numeric "`r(varlist)'"
* ohne Systemvariablen (Token, id etc.)
local sysvar "id token"
local numvar: list numeric - sysvar
*tab1 `numvar'
* Anzahl der Beobachtungen zum Vergleich
local obs = _N
foreach var of varlist `numvar'  {
	quiet: count if `var'==-9990
	local 9990 "`r(N)'"
	quiet: count if `var'==-9991
	local 9991 "`r(N)'"
	quiet: count if `var'==-9992
	local 9992 "`r(N)'"
	quiet: count if `var'==-9993
	local 9993 "`r(N)'"
	quiet: count if `var'==-9995
	local 9995 "`r(N)'"
	* nur Missing-Werte - getrennt
	tab `var' if `9990'==`obs' | `9991'==`obs' | `9992'==`obs' | `9993'==`obs' | `9995'==`obs' 
	* nur Missing-Werte insgesamt
	tab `var' if `obs'==`9990' + `9991' +`9992' + `9993' + `9995'
	* keine Missing-Werte
	tab `var' if 0 ==`9990' + `9991' +`9992' + `9993' + `9995'
	}

	
******** nicht benutzte Variablen löschen *********
*drop 

*____________Fälle löschen ____________________
*** Tester
foreach n of numlist 1/200 {
 quiet: drop if token=="tester`n'"
 quiet: drop if token=="part`n'"
 }
	
*******************************************************************************


*____________Paradaten ________________________________


cap confirm variable width // assert that variable width is present
if !_rc {
	di "variable width exists"
	tostring width, generate(width_t)
	cap confirm variable height // assert that variable height is present
	if !_rc {
		di "variable height exists"
		tostring height, generate(height_t)

		gen screen=height_t + "x" + width_t
		label var screen "Bildschirmgröße: Höhe x Breite"

		tab1 jscheck ismobile screen, miss

		tab1 width height if screen==""

		tabout screen using "${out}doc\screen-size.xls", dpcomma oneway replace cells(col)
	}
	else {
		di as error "variable height does not exist" // error message
	}
}
else {
	di as error "variable width does not exist" // error message
	cap confirm variable height
	if !_rc {
		di "variable height exists" // debug message
	}
	else {
		di as error "variable height does not exist" // error message
	}
}


*drop url jscheck ismobile width height screen width_t height_t


*____________Daten exportieren____________________
save "${out}csv\data.dta", replace
*export delimited using "${out}csv\data.csv", replace
log close
