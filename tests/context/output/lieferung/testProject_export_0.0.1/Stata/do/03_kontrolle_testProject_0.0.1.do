*********************************************************************
*_______________ testProject ___________
di "processing do file: kontrolle"

version 17

cap log close
log using `"${log_dir}log_kontrolle_`: di %tdCY-N-D daily("$S_DATE", "DMY")'.smcl"', append

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
** Erstelldatum:           2023-10-25_20-18-41
** History-Daten:          2023-10-25_20-18-41
** Datensatz:              2023-10-25_20-18-41
** Bearbeitet von:         Test User
****************************************************************************


*____________Daten importieren____________________
* import delimited "${orig}\data.csv", bindquote(strict) encoding(utf8) delimiter(comma) clear stringcols(7 14 23 44 47 51 54 55 58 59 61 62 65 66 70 73 79 90 93 100 102 104 105 106 107 108 109 111 112 113 114 124 127 138 139 141 142 144 146 149 151 169 183 208 212 223 260 261 269 282 295 298 299 300 303 304 311 319)



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


cap drop url 
cap drop jscheck
cap drop ismobile
cap drop width
cap drop height
cap drop screen
cap drop width_t
cap drop height_t


*____________Daten exportieren____________________
*export delimited using "${data_dir}data_unlabeled.csv", replace

save "${data_dir}data_unlabeled.dta", replace

log close