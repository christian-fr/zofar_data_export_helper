*********************************************************************
*_______________ {{ projectname }} ___________
*
****************************************************************************
** Projekt/ Studie:        {{ projectname }}
** Projektname kurz
** (für Pfade/Dateinamen): {{ projectname_short }}
** Erstelldatum:           {{ timestamp_str }}
** History-Daten:          {{ history_csv_zip_file_modification_time_str }}
** Datensatz:              {{ timestampdataset }}
** Bearbeitet von:         {{ user }}
****************************************************************************

version 17

global version "{{ version }}"

global workdir "{{ project_base_dir }}\"

global orig "${workdir}orig\\${version}\"
global out "${workdir}lieferung\{{ projectname_short }}_export_\${version}\"
global doc "${workdir}doc\"

cd "${workdir}doc"
cap log close
log using log_response`: di %tdCY-N-D daily("$S_DATE", "DMY")', append


*____________Daten importieren____________________
import delimited "${orig}data.csv", delimiter(comma) bindquote(strict) encoding("utf-8") clear
foreach n of numlist 1/200 {
	drop if token=="tester`n'"
	drop if token=="part`n'"
}

*_________Zeitstempel in numerische Variable umwandeln_______
gen double contact= clock(firstcontact, "DM20Y hm")
format contact %-tc

*________timestamp konvertieren________
gen str ts = substr(firstcontact, 1 , 10)

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



*************************************************************************

labmask day, values(date)

grstyle init
grstyle set legend 2, inside


*************************************************************************


qui sum teiln
local teiln_order_of_magnitude = floor(log10(r(max)))
local teiln_interval = 10^`teiln_order_of_magnitude'

local teiln_min = r(min) - mod(r(min), `teiln_interval')
local teiln_max = r(max) - mod(r(max), `teiln_interval') + `teiln_interval'

qui sum day
local day_min = r(min)
local day_max = r(max)
local day_range =  `day_max' - `day_min'


set scheme s2color

graph twoway line teiln fin day ,  ///
	graphregion(fcolor(white) lcolor(black)) ///
	lpattern(dash solid) ///
	lstyle(foreground) ///
	lcolor("75 75 75" "0 105 178") ///
	lwidth(medthin medthin) ///
	title("response during field phase", size(medium)) ///
	ytitle("number of respondents", size(small)) ///
	xtitle("field phase (in days)", size(small)) ///
	ylabel(`teiln_min' (`teiln_interval') `teiln_max', gmin angle(horizontal) labsize(vsmall)) ///
	xlabel(0 5 10 15 20(10)50 `day_range', labsize(small)) ///
	legend(label(1 "first access") label(2 "finished") col(1) rowgap(.5) forces size(vsmall)) ///
	note("Project: {{ projectname_short }}", size(tiny))


graph save Graph "${doc}Rücklauf_Graph_day.gph", replace
graph export "${doc}Rücklauf_Graph_day.png", as(png) replace

qui sum date
local date_min = r(min)
local date_max = r(max)
local date_range =  `date_max' - `date_min'
local date_range_order_of_magnitude = floor(log10(`date_range'))

**********************************
* modify this value to scale the ticks / label interval on the x-axis
* restriction: value has to be > 0!
*
local scale_value = 5 // set the value
di 1/`scale_value' // assert that the value is != 0
*
 **********************************


local date_range_interval = ceil(10^`date_range_order_of_magnitude'/`scale_value')

**********************************
* redeclare the local macro date_range_interval to directly
* set another ticks / label interval (uncomment the following line to do so)
// local date_range_interval = 10
*
 **********************************


graph twoway line teiln fin date ,  ///
	graphregion(fcolor(white) lcolor(black)) ///
	lpattern(dash solid) ///
	lstyle(foreground) ///
	lcolor("75 75 75" "0 105 178") ///
	lwidth(medthin medthin) ///
	title("response during field phase", size(medium)) ///
	ytitle("number of respondents") ///
	xtitle("") ///
	ylabel(`teiln_min' (`teiln_interval') `teiln_max', gmin angle(horizontal) labsize(vsmall)) ///
	xlabel(`date_min' (`date_range_interval') `date_max', angle(35) labsize(vsmall)) ///
	legend(label(1 "first access") label(2 "finished") size(vsmall)) ///
	note("Project: {{ projectname_short }}", size(tiny))


graph save Graph "${doc}Rücklauf_Graph_date.gph", replace 
graph export "${doc}Rücklauf_Graph_date.png", as(png) replace 

log close