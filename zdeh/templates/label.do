*********************************************************************
*_______________ {{ project_name }} ___________

version 17

global version "{{ project_version }}"

global workdir "{{ project_output_parent_dir }}\"

global orig "${workdir}orig\\${version}\"
global out "${workdir}lieferung\{{ project_name_short }}_export_\${version}\"
global doc "${workdir}doc\"

cd "${workdir}doc"
cap log close
log using log_label_`: di %tdCY-N-D daily("$S_DATE", "DMY")', append


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

{{ data_label_str }}

log close

*___________Datensatz speichern _______________
save "${data_dir}data_labeled.dta", replace