*********************************************************************
*_______________ XXX__PROJECTNAME__XXX ___________

version 17

global version "XXX__VERSION__XXX"

//global workdir "P:\Zofar\NACAPS\XXX__PROJECTNAME__XXX\"	
di "`c(pwd)'"

cd ..
global root "`c(pwd)'"

// global orig "${root}\orig\\${version}\"
// global out "${root}\lieferung\XXX__PROJECTNAME_SHORT__XXX_export_\${version}\"
// global doc "${root}\doc\"


****************************************************************************
** Projekt/ Studie:        XXX__PROJECTNAME__XXX
** Projektname kurz
** (für Pfade/Dateinamen): XXX__PROJECTNAME_SHORT__XXX
** Erstelldatum:           XXX__TIMESTAMP__XXX
** History-Daten:          XXX__TIMESTAMPHISTORY__XXX
** Datensatz:              XXX__TIMESTAMPDATASET__XXX
** Bearbeitet von:         XXX__USER__XXX
****************************************************************************

*________________________________________________________________
** Master-Do-File zur Datenaufbereitung

