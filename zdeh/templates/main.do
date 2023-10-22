    *********************************************************************
*_______________ {{ project_name }} ___________

version 17

global version "{{ project_version }}"

di "`c(pwd)'"

cd ..
global root "`c(pwd)'"

// global orig "${root}\orig\\${version}\"
// global out "${root}\lieferung\{{ project_name_short }}_export_\${version}\"
// global doc "${root}\doc\"


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
