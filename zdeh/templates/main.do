*********************************************************************
*_______________ {{ project_name }} ___________
set graphics off
set more off

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

cap log close
log using `"${log_dir}log_main_`: di %tdCY-N-D daily("$S_DATE", "DMY")'"', append
di "`c(pwd)'"

****************************************************************************
** Projekt/ Studie:        {{ project_name }}
** Projektname kurz
** (für Pfade/Dateinamen): {{ project_name_short }}
** Erstelldatum:           {{ timestamp_str }}
** History-Daten:          {{ history_csv_zip_file_modification_time_str }}
** Datensatz:              {{ data_csv_zip_file_modification_time_str }}
** Bearbeitet von:         {{ user }}
****************************************************************************

*________________________________________________________________
** Master-Do-File zur Datenaufbereitung
{{ do_files }}
