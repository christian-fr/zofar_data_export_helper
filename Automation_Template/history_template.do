*********************************************************************
*_______________ XXX__PROJECTNAME__XXX ___________
global version "XXX__VERSION__XXX"

/*
	XXXXXXXX
	global workdir "P:\Zofar\NACAPS\Nacaps2020-1\"	
	XXXXXXXX
*/

global orig "${workdir}orig\\${version}\"
global out "${workdir}lieferung\XXX__PROJECTNAME_SHORT__XXX_export_\${version}\"


****************************************************************************
** Projekt/ Studie:         XXX__PROJECTNAME__XXX
** Projektname kurz 
** (für Pfade/Dateinamen):  XXX__PROJECTNAME_SHORT__XXX
** Bearbeitet von:          XXX__USER__XXX
** Erstelldatum:            XXX__TIMESTAMP__XXX
** Datensatz:               XXX__TIMESTAMPHISTORY__XXX
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
	XXXXXXXXXXX
	gen double seiteneing=clock(timestamp, "YMDhms", 2020)
	XXXXXXXXXXX
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
collapse (sum) verwdauer (first) token modul pagenum seiteneing (max) allmiss visit (mean) maxpage lastpage, by(participant_id page)


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
log using "${data}XXX__PROJECTNAME_SHORT__XXX_abbrecher-verwdauer.smcl", replace 

*******************************************************************************
********************* Auswertungen Abbrüche und Verweildauern **********************

*________Anzahl der Abbrecher pro Seite___________
table page, contents(n abbrecher mean dropoutrate n dropoutrate) format(%9.4f)


quiet: tabout page using "${workdir}doc\XXX__PROJECTNAME_SHORT__XXX_abbrecher.xls", ///
	c(count abbrecher mean dropoutrate count dropoutrate) ///
	replace sum ///
	f(0 4 0) ///
	style(xlsx) ///
	font(bold) dpcomma
	

*________Seitenverweildauer ____________________
tabstat verwdauer, statistics(mean median min max sd)

*________Seitenverweildauer nach Seite ____________________
table page, contents(n verwdauer mean verwdauer med verwdauer min verwdauer max verwdauer) format(%9.4f)

quiet: tabout page using "${workdir}doc\XXX__PROJECTNAME_SHORT__XXX_verwdauer.xls", ///
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
drop seiteneing page allmiss abbrecher visitor dropout dropoutrate modul
rename verwdauer p

reshape wide p visit, i(participant_id) j(pagenum)


*________gesamte Bearbeitungsdauer / Verweildauer pro Befragten________
egen dauer=rowtotal(p0-p157)

order participant_id token dauer maxpage lastpage anzseiten dauer_mn dauer_med dauer_min dauer_max dauer_sd


*________Variablen beschriften______________________
*_______ [1] Seiten (Verweildauern mit page-ID)
label var p0 "Verweildauer auf index (in Sekunden)"
label var p1 "Verweildauer auf offer (in Sekunden)"
label var p2 "Verweildauer auf A01 (in Sekunden)"
label var p3 "Verweildauer auf A02 (in Sekunden)"
label var p4 "Verweildauer auf A03 (in Sekunden)"
label var p5 "Verweildauer auf A04 (in Sekunden)"
label var p6 "Verweildauer auf A05 (in Sekunden)"
label var p7 "Verweildauer auf A06 (in Sekunden)"
label var p8 "Verweildauer auf A07 (in Sekunden)"
label var p9 "Verweildauer auf A08 (in Sekunden)"
label var p10 "Verweildauer auf A09 (in Sekunden)"
label var p11 "Verweildauer auf A10 (in Sekunden)"
label var p12 "Verweildauer auf A11 (in Sekunden)"
label var p13 "Verweildauer auf A12 (in Sekunden)"
label var p14 "Verweildauer auf A13 (in Sekunden)"
label var p15 "Verweildauer auf A14 (in Sekunden)"
label var p16 "Verweildauer auf A15 (in Sekunden)"
label var p17 "Verweildauer auf A16 (in Sekunden)"
label var p18 "Verweildauer auf A17 (in Sekunden)"
label var p19 "Verweildauer auf A18 (in Sekunden)"
label var p20 "Verweildauer auf A19 (in Sekunden)"
label var p21 "Verweildauer auf A20 (in Sekunden)"
label var p22 "Verweildauer auf A21 (in Sekunden)"
label var p23 "Verweildauer auf A22 (in Sekunden)"
label var p24 "Verweildauer auf A23 (in Sekunden)"
label var p25 "Verweildauer auf A24 (in Sekunden)"
label var p26 "Verweildauer auf A25 (in Sekunden)"
label var p27 "Verweildauer auf A26 (in Sekunden)"
label var p28 "Verweildauer auf A27 (in Sekunden)"
label var p29 "Verweildauer auf A28 (in Sekunden)"
label var p30 "Verweildauer auf A29 (in Sekunden)"
label var p31 "Verweildauer auf A30 (in Sekunden)"
label var p32 "Verweildauer auf A31 (in Sekunden)"
label var p33 "Verweildauer auf A32 (in Sekunden)"
label var p34 "Verweildauer auf A33 (in Sekunden)"
label var p35 "Verweildauer auf A34 (in Sekunden)"
label var p36 "Verweildauer auf A35 (in Sekunden)"
label var p37 "Verweildauer auf A36 (in Sekunden)"
label var p38 "Verweildauer auf A37 (in Sekunden)"
label var p39 "Verweildauer auf A38 (in Sekunden)"
label var p40 "Verweildauer auf A39 (in Sekunden)"
label var p41 "Verweildauer auf A40 (in Sekunden)"
label var p42 "Verweildauer auf A41 (in Sekunden)"
label var p43 "Verweildauer auf A42 (in Sekunden)"
label var p44 "Verweildauer auf A43 (in Sekunden)"
label var p45 "Verweildauer auf A44 (in Sekunden)"
label var p46 "Verweildauer auf A45 (in Sekunden)"
label var p47 "Verweildauer auf A46 (in Sekunden)"
label var p48 "Verweildauer auf A47 (in Sekunden)"
label var p49 "Verweildauer auf A48 (in Sekunden)"
label var p50 "Verweildauer auf B01 (in Sekunden)"
label var p51 "Verweildauer auf B02 (in Sekunden)"
label var p52 "Verweildauer auf B03 (in Sekunden)"
label var p53 "Verweildauer auf B04 (in Sekunden)"
label var p54 "Verweildauer auf B05 (in Sekunden)"
label var p55 "Verweildauer auf B06 (in Sekunden)"
label var p56 "Verweildauer auf B07 (in Sekunden)"
label var p57 "Verweildauer auf B08 (in Sekunden)"
label var p58 "Verweildauer auf B10 (in Sekunden)"
label var p59 "Verweildauer auf B11 (in Sekunden)"
label var p60 "Verweildauer auf B12 (in Sekunden)"
label var p61 "Verweildauer auf B13 (in Sekunden)"
label var p62 "Verweildauer auf B14 (in Sekunden)"
label var p63 "Verweildauer auf B15 (in Sekunden)"
label var p64 "Verweildauer auf B16 (in Sekunden)"
label var p65 "Verweildauer auf B17 (in Sekunden)"
label var p66 "Verweildauer auf B18 (in Sekunden)"
label var p67 "Verweildauer auf B19 (in Sekunden)"
label var p68 "Verweildauer auf B20 (in Sekunden)"
label var p69 "Verweildauer auf B21 (in Sekunden)"
label var p70 "Verweildauer auf B22 (in Sekunden)"
label var p71 "Verweildauer auf B23 (in Sekunden)"
label var p72 "Verweildauer auf B24 (in Sekunden)"
label var p73 "Verweildauer auf B25 (in Sekunden)"
label var p74 "Verweildauer auf B26 (in Sekunden)"
label var p75 "Verweildauer auf B27 (in Sekunden)"
label var p76 "Verweildauer auf B28 (in Sekunden)"
label var p77 "Verweildauer auf B29 (in Sekunden)"
label var p78 "Verweildauer auf B30 (in Sekunden)"
label var p79 "Verweildauer auf B31 (in Sekunden)"
label var p80 "Verweildauer auf B32 (in Sekunden)"
label var p81 "Verweildauer auf B33 (in Sekunden)"
label var p82 "Verweildauer auf B34 (in Sekunden)"
label var p83 "Verweildauer auf B35 (in Sekunden)"
label var p84 "Verweildauer auf B36 (in Sekunden)"
label var p85 "Verweildauer auf B37 (in Sekunden)"
label var p86 "Verweildauer auf B38 (in Sekunden)"
label var p87 "Verweildauer auf B39 (in Sekunden)"
label var p88 "Verweildauer auf B40 (in Sekunden)"
label var p89 "Verweildauer auf B41 (in Sekunden)"
label var p90 "Verweildauer auf B42 (in Sekunden)"
label var p91 "Verweildauer auf B43 (in Sekunden)"
label var p92 "Verweildauer auf B44 (in Sekunden)"
label var p93 "Verweildauer auf B45 (in Sekunden)"
label var p94 "Verweildauer auf B46 (in Sekunden)"
label var p95 "Verweildauer auf B47 (in Sekunden)"
label var p96 "Verweildauer auf B48 (in Sekunden)"
label var p97 "Verweildauer auf B49 (in Sekunden)"
label var p98 "Verweildauer auf B50 (in Sekunden)"
label var p99 "Verweildauer auf B51 (in Sekunden)"
label var p100 "Verweildauer auf B52 (in Sekunden)"
label var p101 "Verweildauer auf B53 (in Sekunden)"
label var p102 "Verweildauer auf B54 (in Sekunden)"
label var p103 "Verweildauer auf B55 (in Sekunden)"
label var p104 "Verweildauer auf B56 (in Sekunden)"
label var p105 "Verweildauer auf B57 (in Sekunden)"
label var p106 "Verweildauer auf B58 (in Sekunden)"
label var p107 "Verweildauer auf B59 (in Sekunden)"
label var p108 "Verweildauer auf B60 (in Sekunden)"
label var p109 "Verweildauer auf B61 (in Sekunden)"
label var p110 "Verweildauer auf C01 (in Sekunden)"
label var p111 "Verweildauer auf C02 (in Sekunden)"
label var p112 "Verweildauer auf C03 (in Sekunden)"
label var p113 "Verweildauer auf C04 (in Sekunden)"
label var p114 "Verweildauer auf C05 (in Sekunden)"
label var p115 "Verweildauer auf C06 (in Sekunden)"
label var p116 "Verweildauer auf C07 (in Sekunden)"
label var p117 "Verweildauer auf C08 (in Sekunden)"
label var p118 "Verweildauer auf C09 (in Sekunden)"
label var p119 "Verweildauer auf C10 (in Sekunden)"
label var p120 "Verweildauer auf C11 (in Sekunden)"
label var p121 "Verweildauer auf C12 (in Sekunden)"
label var p122 "Verweildauer auf C13 (in Sekunden)"
label var p123 "Verweildauer auf C14 (in Sekunden)"
label var p124 "Verweildauer auf C15 (in Sekunden)"
label var p125 "Verweildauer auf C16 (in Sekunden)"
label var p126 "Verweildauer auf C17 (in Sekunden)"
label var p127 "Verweildauer auf C18 (in Sekunden)"
label var p128 "Verweildauer auf C19 (in Sekunden)"
label var p129 "Verweildauer auf C20 (in Sekunden)"
label var p130 "Verweildauer auf C21 (in Sekunden)"
label var p131 "Verweildauer auf C22 (in Sekunden)"
label var p132 "Verweildauer auf C23 (in Sekunden)"
label var p133 "Verweildauer auf C24 (in Sekunden)"
label var p134 "Verweildauer auf C25 (in Sekunden)"
label var p135 "Verweildauer auf C26 (in Sekunden)"
label var p136 "Verweildauer auf C27 (in Sekunden)"
label var p137 "Verweildauer auf C28 (in Sekunden)"
label var p138 "Verweildauer auf C29 (in Sekunden)"
label var p139 "Verweildauer auf C30 (in Sekunden)"
label var p140 "Verweildauer auf C31 (in Sekunden)"
label var p141 "Verweildauer auf C32 (in Sekunden)"
label var p142 "Verweildauer auf C33 (in Sekunden)"
label var p143 "Verweildauer auf C34 (in Sekunden)"
label var p144 "Verweildauer auf C35 (in Sekunden)"
label var p145 "Verweildauer auf C36 (in Sekunden)"
label var p146 "Verweildauer auf D01 (in Sekunden)"
label var p147 "Verweildauer auf D02 (in Sekunden)"
label var p148 "Verweildauer auf D03 (in Sekunden)"
label var p149 "Verweildauer auf D04 (in Sekunden)"
label var p150 "Verweildauer auf D05 (in Sekunden)"
label var p151 "Verweildauer auf D06 (in Sekunden)"
label var p152 "Verweildauer auf E01 (in Sekunden)"
*label var p153 "Verweildauer auf E02 (in Sekunden)"
label var p154 "Verweildauer auf E03 (in Sekunden)"
label var p155 "Verweildauer auf cancel1 (in Sekunden)"
label var p156 "Verweildauer auf cancel2 (in Sekunden)"
label var p157 "Verweildauer auf end (in Sekunden)"

 
label define maxpagelb 0 "index" 1 "offer" 2 "A01" 3 "A02" 4 "A03" 5 "A04" 6 "A05" 7 "A06" 8 "A07" 9 "A08" 10 "A09" 11 "A10" 12 "A11" 13 "A12" 14 "A13" 15 "A14" 16 "A15" 17 "A16" 18 "A17" 19 "A18" 20 "A19" 21 "A20" 22 "A21" 23 "A22" 24 "A23" 25 "A24" 26 "A25" 27 "A26" 28 "A27" 29 "A28" 30 "A29" 31 "A30" 32 "A31" 33 "A32" 34 "A33" 35 "A34" 36 "A35" 37 "A36" 38 "A37" 39 "A38" 40 "A39" 41 "A40" 42 "A41" 43 "A42" 44 "A43" 45 "A44" 46 "A45" 47 "A46" 48 "A47" 49 "A48" 50 "B01" 51 "B02" 52 "B03" 53 "B04" 54 "B05" 55 "B06" 56 "B07" 57 "B08" 58 "B10" 59 "B11" 60 "B12" 61 "B13" 62 "B14" 63 "B15" 64 "B16" 65 "B17" 66 "B18" 67 "B19" 68 "B20" 69 "B21" 70 "B22" 71 "B23" 72 "B24" 73 "B25" 74 "B26" 75 "B27" 76 "B28" 77 "B29" 78 "B30" 79 "B31" 80 "B32" 81 "B33" 82 "B34" 83 "B35" 84 "B36" 85 "B37" 86 "B38" 87 "B39" 88 "B40" 89 "B41" 90 "B42" 91 "B43" 92 "B44" 93 "B45" 94 "B46" 95 "B47" 96 "B48" 97 "B49" 98 "B50" 99 "B51" 100 "B52" 101 "B53" 102 "B54" 103 "B55" 104 "B56" 105 "B57" 106 "B58" 107 "B59" 108 "B60" 109 "B61" 110 "C01" 111 "C02" 112 "C03" 113 "C04" 114 "C05" 115 "C06" 116 "C07" 117 "C08" 118 "C09" 119 "C10" 120 "C11" 121 "C12" 122 "C13" 123 "C14" 124 "C15" 125 "C16" 126 "C17" 127 "C18" 128 "C19" 129 "C20" 130 "C21" 131 "C22" 132 "C23" 133 "C24" 134 "C25" 135 "C26" 136 "C27" 137 "C28" 138 "C29" 139 "C30" 140 "C31" 141 "C32" 142 "C33" 143 "C34" 144 "C35" 145 "C36" 146 "D01" 147 "D02" 148 "D03" 149 "D04" 150 "D05" 151 "D06" 152 "E01" 153 "E02" 154 "E03" 155 "cancel1" 156 "cancel2" 157 "end"

label val maxpage maxpagelb

*_______________________________________________________________
log using "${out}XXX__PROJECTNAME_SHORT__XXX_verweildauer.smcl", replace 

*************************************************************************
************************** Auswertungen *********************************


tabstat dauer, statistic(mean median min max sd)
*Verweildauer bei abgeschlossenen Fragebögen
tabstat dauer if maxpage==157, statistic(mean median min max sd) 


*_______________________Verweildauer pro Seite__________________
foreach n of numlist 0/152 {
	tabstat p`n' if visit`n'==1, stat(mean min max sd med)
	}

foreach n of numlist 154/157 {
	tabstat p`n' if visit`n'==1, stat(mean min max sd med)
	}

	
local seiten "p0 p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11 p12 p13 p14 p15 p16 p17 p18 p19 p20 p21 p22 p23 p24 p25 p26 p27 p28 p29 p30 p31 p32 p33 p34 p35 p36 p37 p38 p39 p40 p41 p42 p43 p44 p45 p46 p47 p48 p49 p50 p51 p52 p53 p54 p55 p56 p57 p58 p59 p60 p61 p62 p63 p64 p65 p66 p67 p68 p69 p70 p71 p72 p73 p74 p75 p76 p77 p78 p79 p80 p81 p82 p83 p84 p85 p86 p87 p88 p89 p90 p91 p92 p93 p94 p95 p96 p97 p98 p99 p100 p101 p102 p103 p104 p105 p106 p107 p108 p109 p110 p111 p112 p113 p114 p115 p116 p117 p118 p119 p120 p121 p122 p123 p124 p125 p126 p127 p128 p129 p130 p131 p132 p133 p134 p135 p136 p137 p138 p139 p140 p141 p142 p143 p144 p145 p146 p147 p148 p149 p150 p151 p152 p154 p155 p156 p157"
tabstat `seiten', stat(mean min max sd med)

log close

*___________Datensatz speichern _______________
save "${data}history_collapsed.dta", replace