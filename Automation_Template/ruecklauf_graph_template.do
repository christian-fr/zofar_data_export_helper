*********************************************************************
*_______________ XXX__PROJECTNAME__XXX ___________
*
* Bearbeitet von: XXX__USER__XXX
*
global version "XXX__VERSION__XXX"

global workdir "P:\Zofar\NACAPS\XXX__PROJECTNAME_SHORT__XXX_export_\\"	

global orig "${workdir}orig\\${version}\"
global out "${workdir}lieferung\XXX__PROJECTNAME_SHORT__XXX_export_\${version}\"

*____________Daten importieren____________________
import delimited "${orig}data.csv", delimiter(comma) bindquote(strict) clear 
foreach n of numlist 1/200 {
	drop if token=="tester`n'"
	drop if token=="part`n'"
}

*_________Zeitstempel in numerische Variable umwandeln_______
gen double contact= clock(firstcontact, "DM20Y hm")
format contact %-tc

*________timestamp konvertieren________
gen str ts = substr(firstcontact, 1 , 8)

gen double date = date(ts, "DM20Y")
format date %-td
sort date
egen day=group(date)

sort date
by date: gen teiln=_N
gen finished1= 1 if finished==1
by date: egen fin= count(finished1)
drop finished1
summarize teiln fin

display %18.0f date("19feb2021", "DMY")
display %18.0f date("19april2021", "DMY")
display %18.0f date("03june2020", "DMY")


*************************************************************************

labmask day, values(date)

grstyle init
grstyle set legend 2, inside


*************************************************************************

graph twoway line teiln fin day ,  ///
	 lpattern(dash) ///
	 lstyle(foreground) ///
	 title("Rücklauf während der Feldphase") ///
	 ytitle("number of respondents") ///
	 xtitle("field phase (in days)") ///
	 ylabel(0 500 1000 (1000) 6000, gmin angle(horizontal) labsize(vsmall)) ///
	 xlabel(0 5 10 15 20(10)50 58, labsize(small)) ///
	 legend(label(1 "first access") label(2 "finished")) ///
	 note("XXX__PROJECTNAME_SHORT__XXX")

graph save Graph "${doc}Rücklauf_Graph_day.gph", replace 
graph export "${doc}Rücklauf_Graph_day.png", as(png) replace 

graph twoway line teiln fin date ,  ///
	 lpattern(dash) ///
	 lstyle(foreground) ///
	 title("Rücklauf während der Feldphase") ///
	 ytitle("number of respondents") ///
	 xtitle("") ///
	 ylabel(0 500 1000 (1000) 6000, gmin angle(horizontal) labsize(vsmall)) ///
	 xlabel(22330 (10) 22389, angle(35) labsize(vsmall)) ///
	 legend(label(1 "first access") label(2 "finished")) ///
	 note("XXX__PROJECTNAME_SHORT__XXX")


graph save Graph "${doc}Rücklauf_Graph_date.gph", replace 
graph export "${doc}Rücklauf_Graph_date.png", as(png) replace 
