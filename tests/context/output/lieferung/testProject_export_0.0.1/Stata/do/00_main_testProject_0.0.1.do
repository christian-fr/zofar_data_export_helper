*********************************************************************
*_______________ testProject ___________
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
** Projekt/ Studie:        testProject
** Projektname kurz
** (für Pfade/Dateinamen): testProject
** Erstelldatum:           2023-10-25_20-18-41
** History-Daten:          2023-10-25_20-18-41
** Datensatz:              2023-10-25_20-18-41
** Bearbeitet von:         Test User
****************************************************************************

*________________________________________________________________
** Master-Do-File zur Datenaufbereitung
include 01_history_testProject_0.0.1.do
include 02_response_testProject_0.0.1.do
include 03_kontrolle_testProject_0.0.1.do
include 04_label_testProject_0.0.1.do