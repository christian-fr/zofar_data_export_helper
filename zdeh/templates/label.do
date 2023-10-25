*********************************************************************
*_______________ {{ project_name }} ___________
di "processing do file: label"

version 17

cap log close
log using `"${log_dir}log_label_`: di %tdCY-N-D daily("$S_DATE", "DMY")'.smcl"', append

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
** Do-File zum Labeln des Datensatzes
*__________________________________________________________________

use "${data_dir}data_unlabeled.dta", clear

{{ data_label_str }}

log close

*___________Datensatz speichern _______________
save "${data_dir}data_labeled.dta", replace
