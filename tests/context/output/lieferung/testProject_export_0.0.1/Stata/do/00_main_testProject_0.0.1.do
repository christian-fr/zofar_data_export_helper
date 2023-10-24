*********************************************************************
*_______________ testProject ___________

pause on
set graphics off

clear all

version 17

global version "0.0.1"

global initial_dir "`c(pwd)'"
di "`c(pwd)'"

cd ../..

global root_dir "`c(pwd)'"
global do_dir "${root_dir}/Stata/do/"
global log_dir "${root_dir}/Stata/log/"
global data_dir "${root_dir}/Stata/data/"
global out_dir "${root_dir}/Stata/out/"
global label_do_dir "${root_dir}/Stata/label/"
global csv_dir "${root_dir}/csv/"
cd "${initial_dir}"
a

cap log close
log using `"${log_dir}log_main_`: di %tdCY-N-D daily("$S_DATE", "DMY")'"', append



****************************************************************************
** Projekt/ Studie:        testProject
** Projektname kurz
** (für Pfade/Dateinamen): testProject
** Erstelldatum:           2023-10-23_13-19-17
** History-Daten:          2023-10-20_12-39-52
** Datensatz:              2023-10-20_12-39-52
** Bearbeitet von:         Test User
****************************************************************************

*________________________________________________________________
** Master-Do-File zur Datenaufbereitung
do "${do_dir}label/data.do"
use "${csv_dir}arbeitsdaten.dta", clear
save "${data_dir}arbeitsdaten.dta", replace
include "${do_dir}01_history_testProject_0.0.1.do"
include "${do_dir}02_response_testProject_0.0.1.do"
include "${do_dir}03_kontrolle_testProject_0.0.1.do"

