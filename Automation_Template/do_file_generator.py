#!"C:\Program Files\IBM\SPSS\Statistics\26\Python3\python.exe"
__version__ = "0.0.2"
__author__ = "Christian Friedrich"
__license__ = "MIT"
__copyright__ = "2021, Christian Friedrich"
__status__ = "Prototype"

import time
import os
import sys
import argparse
from tkinter import filedialog
import shutil
import xml
from xml.etree import ElementTree


def timestamp(time_localtime_object: time.localtime = None) -> str:
    if time_localtime_object is None:
        t = time.localtime()

    else:
        t = time_localtime_object

    return time.strftime('%Y-%m-%d_%H-%M-%S', t)


# parser = argparse.ArgumentParser(description='Process the projectname.')
# parser.add_argument('projectname', action='store', type=str, help='projectname as a string')
#
# args = parser.parse_args()
# projectname = args.projectname.strip()


print(' ╔═════════════════════════════════════╗')
print(' ║  Zofar Automation - Datenlieferung  ║')
print(' ╚═════════════════════════════════════╝\n\n\n')

while True:
    projectname = input('Bitte Projektnamen angeben: ').strip()
    if projectname != '':
        break

str_of_chars_to_replace = '''"'!?,.;:*\\& '''

projectname_short = projectname
for char in str_of_chars_to_replace:
    projectname_short = projectname_short.replace(char, '_')
print()
print('Projektname_kurz: "{0}"'.format(projectname_short))
print()

user = input('Bearbeiter*in (default is "Andrea Schulze"): ') or "Andrea Schulze"
print('\n')
print('Bearbeiter*in: "{0}"'.format(user))
print('Projektname:   "{0}"'.format(projectname))
print('Projektname_kurz: "{0}"'.format(projectname_short))

print('\n')

# select zip file with export data
input('Bitte ZIP-Datei, die den Datenexport beinhaltet, auswählen.\n(weiter mit Enter)')

initial_input_dir = r'P:\Zofar\Automation_Input'

if not os.path.exists(initial_input_dir):
    initial_input_dir = os.path.split(os.getcwd())[0]

zipfile = os.path.normpath(filedialog.askopenfilename(initialdir=initial_input_dir,
                                                      filetypes=(('zip files', '*.zip'), ('all files', '*.*')),
                                                      title='Bitte ZIP-Datei, die den Datenexport beinhaltet, auswählen.'))

print('\n')
print('Dateiname: "{0}"'.format(os.path.split(zipfile)[1]))
print('\n')

version = input('Bitte Versionsnummer eingeben: ')

# select base dir
input('Bitte das Oberverzeichnis auswählen, innerhalb dessen das Projekt\nangelegt werden soll. (weiter mit Enter)')

initial_output_dir = r'P:\Zofar\Automation_Output'

if not os.path.exists(initial_output_dir):
    initial_output_dir = os.path.split(os.getcwd())[0]

project_base_dir = os.path.join(os.path.normpath(
    filedialog.askdirectory(initialdir=initial_output_dir, title='Bitte Oberverzeichnis auswählen.')),
    projectname_short)

# create folder structure
project_orig_dir = os.path.normpath(os.path.join(project_base_dir, 'orig'))
project_doc_dir = os.path.normpath(os.path.join(project_base_dir, 'doc'))
project_lieferung_dir = os.path.normpath(os.path.join(project_base_dir, 'lieferung'))

print('md {0}'.format(project_orig_dir))
return_md_orig = os.system('md {0}'.format(project_orig_dir))
if return_md_orig == 1:
    print('Verzeichnis "{0}" existiert bereits.'.format(project_orig_dir))

print('md {0}'.format(project_doc_dir))
return_md_doc = os.system('md {0}'.format(project_doc_dir))
if return_md_doc == 1:
    print('Verzeichnis "{0}" existiert bereits.'.format(project_doc_dir))

print('md {0}'.format(project_lieferung_dir))
return_md_lieferung = os.system('md {0}'.format(project_lieferung_dir))
if return_md_lieferung == 1:
    print('Verzeichnis "{0}" existiert bereits.'.format(project_lieferung_dir))

# unzip zip file with export data

shutil.copy(zipfile, project_orig_dir)

project_orig_version_dir = os.path.join(project_orig_dir, version)
os.mkdir(project_orig_version_dir)

project_lieferung_version_dir = os.path.join(project_lieferung_dir, '{0}_export_{1}'.format(projectname_short, version))
os.mkdir(project_lieferung_version_dir)

print('zipfile: {0}'.format(zipfile))
print('project_base_dir: {0}'.format(project_base_dir))
return_code = -1

print('\n' * 3)
print(' ******************************')
print('*******************************')
print('******    7-Zip             ***')
while return_code != 0:
    return_code = os.system(
        r'"C:\Program Files\7-Zip\7z.exe" x {0} -o{1}'.format(zipfile, project_lieferung_version_dir))
print('*                            **')
print('*******************************')
print('****************************** ')
print('\n' * 3)

# check if "output" folder is present:
lieferung_output_path = os.path.normpath(os.path.join(project_lieferung_version_dir, 'output'))

if os.path.exists(os.path.join(lieferung_output_path)):
    # move recursively all subfolders to lieferung version folder
    for dir in os.listdir(lieferung_output_path):
        shutil.move(os.path.join(os.path.join(lieferung_output_path, dir)), project_lieferung_version_dir)

    # delete (now empty) output folder
    try:
        if len(os.listdir(lieferung_output_path)) == 0:
            time.sleep(2)
            os.remove(lieferung_output_path)
        else:
            print(
                '\n\nFolder "{0}" is not empty and has not been deleted - please check and clean up manually.\n\n'.format(
                    lieferung_output_path))
    except PermissionError:
        print(
            '\n\nNo access permission to Folder "{0}" - it therefore has not been deleted, please check and clean up manually.\n\n'.format(
                lieferung_output_path))


# file search algorith
def find_all(name: str, path: str) -> list:
    result = []
    for root, dirs, files in os.walk(path):
        if name in files:
            result.append(os.path.join(root, name))
    return result


# look for xml file within project_lieferung_version_dir
list_of_questionnaire_xml_files = find_all(name='questionnaire.xml', path=project_lieferung_version_dir)

print(list_of_questionnaire_xml_files)

# check if returned file list has exactly one match
if len(list_of_questionnaire_xml_files) == 1:
    xmlfile = list_of_questionnaire_xml_files[0]

# if there are less or more than one match, display a filedialog to manually choose a file
else:
    # read xml file
    input('Bitte die XML-Datei des Fragebogens auswählen. (Weiter mit ENTER)')

    xml_file_initial_path = os.path.join(project_lieferung_version_dir, version, 'output', 'instruction', 'QML')

    if os.path.exists(xml_file_initial_path):
        print(xml_file_initial_path + ' exists.')
    else:
        print(xml_file_initial_path + ' does not exist.')
        xml_file_initial_path = project_lieferung_version_dir

    xmlfile = os.path.normpath(filedialog.askopenfilename(initialdir=xml_file_initial_path,
                                                          filetypes=(('xml files', '*.xml'), ('all files', '*.*')),
                                                          title='Bitte XML-Datei des Fragebogens auswählen.'))

page_list = []
if not os.path.isfile(xmlfile):
    print('Keine XML-Datei ausgewählt! Seitenreihenfolge kann \nnicht bestimmt werden.')
else:
    try:
        # create page list
        x = ElementTree.parse(source=xmlfile)
        for element in x.iter():
            if element.tag == '{http://www.his.de/zofar/xml/questionnaire}page':
                if hasattr(element, 'attrib'):
                    if 'uid' in element.attrib:
                        page_list.append(element.attrib['uid'])

        print('Seitenreihenfolge:')
        print(page_list)

    except xml.etree.ElementTree.ParseError:
        print('XML Datei ist nicht lesbar, wird übersprungen.\n\n')
        xmlfile = ''

# look for history.csv.zip file within project_lieferung_version_dir
list_of_history_csv_zip_files = find_all(name='history.csv.zip', path=project_lieferung_version_dir)

print(list_of_history_csv_zip_files)

# load history.csv.zip file and read modification time

# check if returned file list has exactly one match
if len(list_of_history_csv_zip_files) == 1:
    history_csv_zip_file_str = list_of_history_csv_zip_files[0]

# if there are less or more than one match, display a filedialog to manually choose a file
else:
    input('Bitte die history.csv.zip-Datei auswählen. (Weiter mit ENTER)')

    csv_zip_files_initial_path = os.path.join(project_lieferung_version_dir, 'output', 'csv')
    if os.path.isfile(csv_zip_files_initial_path):
        print(csv_zip_files_initial_path + ' exists.')
    else:
        print(csv_zip_files_initial_path + ' does not exist.')
        csv_zip_files_initial_path = project_orig_version_dir

    history_csv_zip_file_str = os.path.normpath(filedialog.askopenfilename(initialdir=csv_zip_files_initial_path,
                                                                           filetypes=(
                                                                               ('history.csv.zip file',
                                                                                'history.csv.zip'),
                                                                               ('all files', '*.*')),
                                                                           title='Bitte die history.csv.zip-Datei auswählen.'))

csv_zip_files_folder_str = os.path.normpath(os.path.split(history_csv_zip_file_str)[0])
if not os.path.isfile(history_csv_zip_file_str):
    input('Keine history.csv.zip-Datei geladen. Manuelle Eingabe \ndes Timestamps (kann leer gelassen werden): ')
else:
    history_csv_zip_file_modification_localtime = time.localtime(os.path.getmtime(history_csv_zip_file_str))
    history_csv_zip_file_modification_time_str = timestamp(history_csv_zip_file_modification_localtime)
    history_csv_zip_return_code = os.system(
        r'"C:\Program Files\7-Zip\7z.exe" e {0} -o{1}'.format(history_csv_zip_file_str, project_orig_version_dir))
    if history_csv_zip_return_code != 0:
        print('\nKonnte ZIP-Datei {0} nicht entpacken.\n'.format(history_csv_zip_file_str))
    else:
        print('\nZIP-Datei {0} erfolgreich entpackt.\n'.format(history_csv_zip_file_str))
        try:
            shutil.move(history_csv_zip_file_str, project_orig_version_dir)
        except PermissionError:
            print(
                '\n\nNo access permission to file "{0}" - it therefore has not been deleted.\nPlease move it manually to "{1}".\n\n'.format(
                    history_csv_zip_file_str, project_orig_version_dir))

# load data.csv.zip file and read modification time
# look for history.csv.zip file within project_lieferung_version_dir
list_of_data_csv_zip_files = find_all(name='data.csv.zip', path=project_lieferung_version_dir)

print(list_of_data_csv_zip_files)

# load history.csv.zip file and read modification time

# check if returned file list has exactly one match
if len(list_of_data_csv_zip_files) == 1:
    data_csv_zip_file_str = list_of_data_csv_zip_files[0]

# if there are less or more than one match, display a filedialog to manually choose a file
else:
    input('Bitte die data.csv.zip-Datei auswählen. (Weiter mit ENTER)')
    data_csv_zip_file_str = os.path.normpath(
        filedialog.askopenfilename(initialdir=csv_zip_files_initial_path, filetypes=(
            ('data.csv.zip file', 'data.csv.zip'), ('all files', '*.*')),
                                   title='Bitte die data.csv.zip-Datei auswählen.'))

if not os.path.isfile(data_csv_zip_file_str):
    input('Keine data.csv.zip-Datei geladen. Manuelle Eingabe des \nTimestamps (kann leer gelassen werden): ')
else:
    data_csv_zip_file_modification_localtime = time.localtime(os.path.getmtime(data_csv_zip_file_str))
    data_csv_zip_file_modification_time_str = timestamp(data_csv_zip_file_modification_localtime)
    data_csv_zip_return_code = os.system(
        r'"C:\Program Files\7-Zip\7z.exe" e {0} -o{1}'.format(data_csv_zip_file_str, project_orig_version_dir))
    if data_csv_zip_return_code != 0:
        print('\nKonnte ZIP-Datei {0} nicht entpacken.\n'.format(data_csv_zip_file_str))
    else:
        print('\nZIP-Datei {0} erfolgreich entpackt.\n'.format(data_csv_zip_file_str))
        try:
            shutil.move(data_csv_zip_file_str, project_orig_version_dir)
        except PermissionError:
            print(
                '\n\nNo access permission to file "{0}" - it therefore has not been deleted.\nPlease move it manually to "{1}".\n\n'.format(
                    data_csv_zip_file_str, project_orig_version_dir))

# ##########################
# # set paths of templates
# ##########################

master_do_file_template_path = r'P:\Zofar\Automation_Template\master_template.do'
history_do_file_template_path = r'P:\Zofar\Automation_Template\history_template.do'
response_do_file_template_path = r'P:\Zofar\Automation_Template\ruecklauf_graph_template.do'

master_do_file_path = os.path.normpath(
    os.path.join(project_doc_dir, '00_master_' + projectname_short + '_' + version + '.do'))
history_do_file_path = os.path.normpath(
    os.path.join(project_doc_dir, '01_history_' + projectname_short + '_' + version + '.do'))
response_do_file_path = os.path.normpath(
    os.path.join(project_doc_dir, '02_response_' + projectname_short + '_' + version + '.do'))

# ##################
# # HISTORY DOFILE
# ##################

# load history dofile template

history_dofile_str = ''
with open(history_do_file_template_path, 'r', encoding='utf-8') as file:
    history_dofile_str = file.read()

# generate STATA code for pagenum replacement
replace_pagenum_str = ''
if page_list:
    for i in range(len(page_list)):
        replace_pagenum_str += 'replace pagenum={0} if page=="{1}"\n'.format(i, page_list[i])

else:
    print(
        'Es wurde zuvor keine XML-Datei ausgewählt oder es wurden \nkeine Pages gefunden. Platzhalter wird im History-Dofile eingefügt.\n')
    replace_pagenum_str += '* XXXXXXXXXX Platzhalter für PAGENUM XXXXXXXXX\n'
    replace_pagenum_str += 'replace pagenum=0 if page=="index"\n'
    replace_pagenum_str += 'replace pagenum=1 if page=="offer"\n'

# replace strings in history_file
timestamp_str = timestamp()

history_dofile_str = history_dofile_str.replace('XXX__REPLACE_PAGENUM__XXX', replace_pagenum_str)
history_dofile_str = history_dofile_str.replace('XXX__VERSION__XXX', version)
history_dofile_str = history_dofile_str.replace('XXX__PROJECTNAME_SHORT__XXX', projectname_short)
history_dofile_str = history_dofile_str.replace('XXX__PROJECTNAME__XXX', projectname)
history_dofile_str = history_dofile_str.replace('XXX__USER__XXX', user)
history_dofile_str = history_dofile_str.replace('XXX__TIMESTAMP__XXX', timestamp_str)
history_dofile_str = history_dofile_str.replace('XXX__TIMESTAMPDATASET__XXX', data_csv_zip_file_modification_time_str)
history_dofile_str = history_dofile_str.replace('XXX__TIMESTAMPHISTORY__XXX',
                                                history_csv_zip_file_modification_time_str)

# save history do file
with open(history_do_file_path, 'w', encoding='utf-8') as file:
    file.write(history_dofile_str)

print(history_do_file_path)

# ###################
# # RESPONSE DOFILE
# ###################

# load response dofile template

master_dofile = ''
with open(response_do_file_template_path, 'r', encoding='utf-8') as file:
    response_dofile_str = file.read()

# modify response dofile
response_dofile_str = response_dofile_str.replace('', '')
response_dofile_str = response_dofile_str.replace('XXX__PROJECTNAME_SHORT__XXX', projectname_short)
response_dofile_str = response_dofile_str.replace('XXX__PROJECTNAME__XXX', projectname)
response_dofile_str = response_dofile_str.replace('XXX__USER__XXX', user)
response_dofile_str = response_dofile_str.replace('XXX__VERSION__XXX', version)

# save response do file
with open(response_do_file_path, 'w', encoding='utf-8') as file:
    file.write(response_dofile_str)

print(response_do_file_path)

# #################
# # MASTER DOFILE
# #################

# load master dofile template

master_dofile = ''
with open(master_do_file_template_path, 'r', encoding='utf-8') as file:
    master_dofile_str = file.read()

# modify master dofile

master_dofile_str = master_dofile_str.replace('XXX__PROJECTNAME_SHORT__XXX', projectname_short)
master_dofile_str = master_dofile_str.replace('XXX__PROJECTNAME__XXX', projectname)
master_dofile_str = master_dofile_str.replace('XXX__USER__XXX', user)
master_dofile_str = master_dofile_str.replace('XXX__VERSION__XXX', version)
master_dofile_str = master_dofile_str.replace('XXX__TIMESTAMP__XXX', timestamp_str)
master_dofile_str = master_dofile_str.replace('XXX__TIMESTAMPDATASET__XXX', data_csv_zip_file_modification_time_str)
master_dofile_str = master_dofile_str.replace('XXX__TIMESTAMPHISTORY__XXX', history_csv_zip_file_modification_time_str)

master_dofile_str += 'do {0}\n'.format(history_do_file_path)

# save master do file
with open(master_do_file_path, 'w', encoding='utf-8') as file:
    file.write(master_dofile_str)

print(master_do_file_path)

input('Programm beendet!')
