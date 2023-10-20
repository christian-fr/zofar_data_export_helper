    *********************************************************************
*_______________ {{ projectname }} ___________

version 17

global version "{{ version }}"

//global workdir "P:\Zofar\{{ projectname }}\"
di "`c(pwd)'"

cd ..
global root "`c(pwd)'"

// global orig "${root}\orig\\${version}\"
// global out "${root}\lieferung\{{ projectname_short }}_export_\${version}\"
// global doc "${root}\doc\"


****************************************************************************
** Projekt/ Studie:        {{ projectname }}
** Projektname kurz
** (für Pfade/Dateinamen): {{ projectname_short }}
** Erstelldatum:           {{ timestamp_str }}
** History-Daten:          {{ history_csv_zip_file_modification_time_str }}
** Datensatz:              {{ timestampdataset }}
** Bearbeitet von:         {{ user }}
****************************************************************************

*________________________________________________________________
** Master-Do-File zur Datenaufbereitung

