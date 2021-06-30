*********************************************************************
*_______________ Nacaps 2020.1 ___________
global version "2021-04-22"
global workdir "P:\Zofar\NACAPS\Nacaps2020-1\\"	
global orig "${workdir}orig\\${version}\"
global out "${workdir}lieferung\Nacaps20-1_export_\${version}\"

cd "${workdir}doc"
cap log close
log using log_`: di %tdCY-N-D daily("$S_DATE", "DMY")', replace


****************************************************************************
** Projekt/ Studie: prod_nacaps20201
** Erstelldatum: 30.03.2021 11:47:58
** Datensatz: Tue Mar 30 11:47:58 CEST 2021
****************************************************************************
** Glossar Missing-Werte
** -9999 : voreingestellte Missing-Werte, insbesondere bei technischen Variablen
** -9992 : Item wurde gemäß Fragebogensteuerung nicht angezeigt oder befindet sich auf der Seite des Befragungsabbruches
** -9990 : Item wurde gesehen, aber nicht beantwortet
** -9991 : Seite, auf der sich das Item befindet, wurde gemäß Fragebogensteuerung oder aufgrund eines vorherigen Befragungsabbruches nicht besucht
** -9995 : Variable wurde nicht erhoben (-9992 oder -9991), jedoch für die Fragebogensteuerung verwendet
*************************************************************************
*************************************************************************

*____________Daten importieren____________________
// mit Postleitzahlen als String-Variablen
import delimited "${orig}data.csv", delimiter(comma) bindquote(strict) varnames(1) encoding(utf8) clear 


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
tostring width, generate(width_t)
tostring height, generate(height_t)

**** screen-size als text-variable erstellen
/*
*** funktioniert, ist aber sehr rechenintensiv
gen screen=""


forvalues w= 320/3840 {
forvalues h= 347/2560 {
quietly: replace screen= "`h'x`w'" if width==`w' & height==`h'
}
}
*/

gen screen=height + "x" + width
label var screen "Bildschirmgröße: Höhe x Breite"

tab1 jscheck ismobile screen, miss

tab1 width height if screen==""

tabout screen using "${out}doc\screen-size.xls", dpcomma oneway replace cells(col)

*drop url jscheck ismobile width height screen width_t height_t


*____________Daten exportieren____________________
save "${out}csv\data.dta", replace
*export delimited using "${out}csv\data.csv", replace
log close
