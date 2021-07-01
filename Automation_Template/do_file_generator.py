#!"C:\Program Files\IBM\SPSS\Statistics\26\Python3\python.exe"
__version__ = "0.0.3"
__author__ = "Christian Friedrich, Andrea Schulze"
__license__ = "MIT"
__copyright__ = "2021, Christian Friedrich, Andrea Schulze"
__status__ = "Prototype"

import time
import os
import sys
import argparse
from tkinter import filedialog, Tk
import shutil
import xml
from xml.etree import ElementTree
import logging
import argparse

parser = argparse.ArgumentParser(description='Optionally set the debug flag for verbose output and debug logging.')
parser.add_argument('--debug', action='store_true', help='enable verbose output and debug logging')
parser.add_argument('--local', action='store_true', help='set paths to local environment')

args = parser.parse_args()

# assert that optional debug flag is of boolean type
assert isinstance(args.debug, bool)
# set flag for debug
flag_debug = args.debug

# assert that optional debug flag is of boolean type
assert isinstance(args.local, bool)
# set flag for debug
flag_local = args.local




# file search algorithm - return list of found files within given path, with absolute paths
def find_all(name: str, path: str) -> list:
    result = []
    for root, dirs, files in os.walk(path):
        if name in files:
            result.append(os.path.join(root, name))
    return result


# return a timestamp string
def timestamp(time_localtime_object: time.localtime = None) -> str:
    if time_localtime_object is None:
        t = time.localtime()

    else:
        t = time_localtime_object

    return time.strftime('%Y-%m-%d_%H-%M-%S', t)


def startup_logger(logger: logging.Logger, log_level=logging.DEBUG):
    """
    CRITICAL: 50, ERROR: 40, WARNING: 30, INFO: 20, DEBUG: 10, NOTSET: 0
    """
    logging.basicConfig(level=log_level)
    fh = logging.FileHandler("{0}.log".format('log_' + __name__))
    fh.setLevel(log_level)
    fh_format = logging.Formatter('%(name)s\t%(module)s\t%(funcName)s\t%(asctime)s\t%(lineno)d\t'
                                  '%(levelname)-8s\t%(message)s')
    fh.setFormatter(fh_format)
    logger.addHandler(fh)


# parser = argparse.ArgumentParser(description='Process the projectname.')
# parser.add_argument('projectname', action='store', type=str, help='projectname as a string')
#
# args = parser.parse_args()
# projectname = args.projectname.strip()


# start logger
my_logger = logging.getLogger('debug')

if not flag_debug:
    startup_logger(logger=my_logger, log_level=logging.INFO)
    my_logger.info('starting up program')
else:
    startup_logger(logger=my_logger, log_level=logging.DEBUG)
    my_logger.info('starting up program')
    my_logger.debug('"flag_debug" is set to True!')

if flag_local:
    my_logger.info('"flag_local" is set to True! does not work on the server!')


time.sleep(.2)

print(' ╔═════════════════════════════════════╗')
print(' ║  Zofar Automation - Datenlieferung  ║')
print(' ╚═════════════════════════════════════╝\n\n\n')

print('authors: {0}'.format(__author__))
print('version: {0}'.format(__version__))
print('license: {0}\n\n'.format(__license__))

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

root = Tk()
zipfile = os.path.normpath(filedialog.askopenfilename(initialdir=initial_input_dir,
                                                      filetypes=(('zip files', '*.zip'), ('all files', '*.*')),
                                                      title='Bitte ZIP-Datei, die den Datenexport beinhaltet, auswählen.'))
root.withdraw()

print('\n')
print('Dateiname: "{0}"'.format(os.path.split(zipfile)[1]))
print('\n')

version = input('Bitte Versionsnummer eingeben: ')

# select base dir
input('Bitte das Oberverzeichnis auswählen, innerhalb dessen das Projekt\nangelegt werden soll. (weiter mit Enter)')

initial_output_dir = r'P:\Zofar\Automation_Output'

if not os.path.exists(initial_output_dir):
    initial_output_dir = os.path.split(os.getcwd())[0]

# set project_base_dir
project_base_dir = os.path.join(os.path.normpath(
    filedialog.askdirectory(initialdir=initial_output_dir, title='Bitte Oberverzeichnis auswählen.')),
    projectname_short)

my_logger.debug('project_base_dir = "{0}"'.format(project_base_dir))

# create folder structure
project_orig_dir = os.path.normpath(os.path.join(project_base_dir, 'orig'))
project_doc_dir = os.path.normpath(os.path.join(project_base_dir, 'doc'))
project_lieferung_dir = os.path.normpath(os.path.join(project_base_dir, 'lieferung'))

my_logger.debug('project_orig_dir = "{0}"'.format(project_orig_dir))
my_logger.debug('project_doc_dir = "{0}"'.format(project_doc_dir))
my_logger.debug('project_lieferung_dir = "{0}"'.format(project_lieferung_dir))

# creating "orig" subdirectory - using "os.system('md ...')" instead of os.mkdir because it automatically creates
#  more than one level of subfolders if needed
my_logger.debug('md {0}'.format(project_orig_dir))
return_md_orig = os.system('md {0}'.format(project_orig_dir))
if return_md_orig == 1:
    print('Verzeichnis "{0}" existiert bereits.'.format(project_orig_dir))

# creating "doc" subdirectory - using "os.system('md ...')" instead of os.mkdir because it automatically creates
#  more than one level of subfolders if needed
my_logger.debug('md {0}'.format(project_doc_dir))
return_md_doc = os.system('md {0}'.format(project_doc_dir))
if return_md_doc == 1:
    print('Verzeichnis "{0}" existiert bereits.'.format(project_doc_dir))

# creating "lieferung" subdirectory - using "os.system('md ...')" instead of os.mkdir because it automatically creates
#  more than one level of subfolders if needed
my_logger.debug('md {0}'.format(project_lieferung_dir))
return_md_lieferung = os.system('md {0}'.format(project_lieferung_dir))
if return_md_lieferung == 1:
    print('Verzeichnis "{0}" existiert bereits.'.format(project_lieferung_dir))

# copy zip file with export data to project_orig_dir
shutil.copy(zipfile, project_orig_dir)
my_logger.debug('zip file "{0}" copied to "{1}"'.format(zipfile, project_orig_dir))

# set string variable for project_orig_version_dir (directory has yet to be created)
project_orig_version_dir = os.path.join(project_orig_dir, version)
my_logger.debug('project_orig_version_dir = "{0}"'.format(project_orig_version_dir))

# create a folder project_orig_version_dir  - using "os.mkdir()" because top folder has been created in the last
#  step
os.mkdir(project_orig_version_dir)
my_logger.debug('os.mkdir({0})'.format(project_doc_dir))

# set string variable for project_lieferung_version_dir (directory has yet to be created)
project_lieferung_version_dir = os.path.join(project_lieferung_dir, '{0}_export_{1}'.format(projectname_short, version))
my_logger.debug('project_lieferung_version_dir = "{0}"'.format(project_lieferung_version_dir))

# create a folder project_lieferung_version_dir  - using "os.mkdir()" because top folder has been created in the last
#  step
os.mkdir(project_lieferung_version_dir)
my_logger.debug('os.mkdir({0})'.format(project_lieferung_version_dir))

print('\n')
print('zipfile: {0}'.format(zipfile))
print('project_base_dir: {0}'.format(project_base_dir))

# create variable "return_code" to store the return code of the 7zip archive unpacking command
# a return_code of 0 means the unzip operation has been successful

# set return_code to an initial value other than 0 (just to already have the variable before starting the loop)
return_code = -1

print('\n' * 3)
print(' ******************************')
print('*******************************')
print('******    7-Zip             ***')


# start the while loop: it will loop until the return_code == 0 (so when a wrong password has been entered, it will
#  just start the unzipping again and also prompt for the password again
#  we are using the "counter" variable to make sure that we do a maximum of 10 loops

# set counter variable to initial value
counter = 0

while return_code != 0:
    my_logger.debug('counter: "{0}"'.format(counter))
    my_logger.debug(r'''running: """os.system(r'"C:\Program Files\7-Zip\7z.exe" x {0} -o{1}"""'''.format(zipfile, project_lieferung_version_dir))
    return_code = os.system(
        r'"C:\Program Files\7-Zip\7z.exe" x {0} -o{1}'.format(zipfile, project_lieferung_version_dir))
    my_logger.debug('return code: "{0}"'.format(return_code))

    counter += 1
    if counter == 10:
        my_logger.info(
            r'''Could not successfully run: """os.system(r'"C:\Program Files\7-Zip\7z.exe" x {0} -o{1}"""'''.format(
                zipfile, project_lieferung_version_dir))
        my_logger.info('Exiting this program.')
        sys.exit(r'''Could not successfully run: """os.system(r'"C:\Program Files\7-Zip\7z.exe" x {0} -o{1}"""'''.format(
                zipfile, project_lieferung_version_dir))


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

# look for xml file within project_lieferung_version_dir
list_of_questionnaire_xml_files = find_all(name='questionnaire.xml', path=project_lieferung_version_dir)

print(list_of_questionnaire_xml_files)

# check if returned file list has exactly one match
if len(list_of_questionnaire_xml_files) == 1:
    xmlfile = list_of_questionnaire_xml_files[0]


# if there are less or more than one match, display a filedialog to manually choose a file
else:
    # read xml file
    input('Es wird nach der XML-Datei des Fragebogens gesucht ... ... ...')

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

# if flag_debug is not set
if not flag_local:
    master_do_file_template_path = r'P:\Zofar\Automation_Template\master_template.do'
    history_do_file_template_path = r'P:\Zofar\Automation_Template\history_template.do'
    response_do_file_template_path = r'P:\Zofar\Automation_Template\ruecklauf_graph_template.do'
    kontrolle_do_file_template_path = r'P:\Zofar\Automation_Template\kontrolle_template.do'


# if flag_debug is set
else:
    master_do_file_template_path = r'C:\Users\friedrich\PycharmProjects\zofar_data_export_helper\Automation_Template\master_template.do'
    history_do_file_template_path = r'C:\Users\friedrich\PycharmProjects\zofar_data_export_helper\Automation_Template\history_template.do'
    response_do_file_template_path = r'C:\Users\friedrich\PycharmProjects\zofar_data_export_helper\Automation_Template\ruecklauf_graph_template.do'
    kontrolle_do_file_template_path = r'C:\Users\friedrich\PycharmProjects\zofar_data_export_helper\Automation_Template\kontrolle_template.do'

my_logger.debug('master_do_file_template_path = "{0}"'.format(master_do_file_template_path))
my_logger.debug('history_do_file_template_path = "{0}"'.format(history_do_file_template_path))
my_logger.debug('response_do_file_template_path = "{0}"'.format(response_do_file_template_path))

master_do_file_path = os.path.normpath(
    os.path.join(project_doc_dir, '00_master_' + projectname_short + '_' + version + '.do'))
history_do_file_path = os.path.normpath(
    os.path.join(project_doc_dir, '01_history_' + projectname_short + '_' + version + '.do'))
response_do_file_path = os.path.normpath(
    os.path.join(project_doc_dir, '02_response_' + projectname_short + '_' + version + '.do'))
kontrolle_do_file_path = os.path.normpath(
    os.path.join(project_doc_dir, '03_kontrolle_' + projectname_short + '_' + version + '.do'))


my_logger.debug('master_do_file_path = "{0}"'.format(master_do_file_path))
my_logger.debug('history_do_file_path = "{0}"'.format(history_do_file_path))
my_logger.debug('response_do_file_path = "{0}"'.format(response_do_file_path))
my_logger.debug('kontrolle_do_file_path = "{0}"'.format(kontrolle_do_file_path))

# ##################
# # HISTORY DOFILE
# ##################

# load history dofile template
my_logger.debug('load history dofile template')

history_dofile_str = ''
with open(history_do_file_template_path, 'r', encoding='utf-8') as file:
    history_dofile_str = file.read()

# generate STATA code for pagenum replacement
my_logger.debug('generate STATA code for pagenum replacement')
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
my_logger.debug('modifiy history dofile')

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
my_logger.debug('save history dofile as "{0}"'.format(history_do_file_path))
with open(history_do_file_path, 'w', encoding='utf-8') as file:
    file.write(history_dofile_str)

my_logger.info('Created history do file: "{0}"'.format(history_do_file_path))

# ###################
# # RESPONSE DOFILE
# ###################

# load response dofile template
my_logger.debug('load response dofile template')
master_dofile = ''
with open(response_do_file_template_path, 'r', encoding='utf-8') as file:
    response_dofile_str = file.read()

# modify response dofile
my_logger.debug('modifiy response dofile')
response_dofile_str = response_dofile_str.replace('', '')
response_dofile_str = response_dofile_str.replace('XXX__PROJECTNAME_SHORT__XXX', projectname_short)
response_dofile_str = response_dofile_str.replace('XXX__PROJECTNAME__XXX', projectname)
response_dofile_str = response_dofile_str.replace('XXX__USER__XXX', user)
response_dofile_str = response_dofile_str.replace('XXX__VERSION__XXX', version)

# save response do file
my_logger.debug('save response dofile as "{0}"'.format(history_do_file_path))
with open(response_do_file_path, 'w', encoding='utf-8') as file:
    file.write(response_dofile_str)

my_logger.info('Created response do file: "{0}"'.format(response_do_file_path))

# ###################
# # KONTROLLE DOFILE
# ###################

# load kontrolle dofile template
my_logger.debug('load kontrolle dofile template')
kontrolle_dofile = ''
with open(kontrolle_do_file_template_path, 'r', encoding='utf-8') as file:
    kontrolle_dofile_str = file.read()

# modify kontrolle dofile
my_logger.debug('modifiy kontrolle dofile')
kontrolle_dofile_str = kontrolle_dofile_str.replace('', '')
kontrolle_dofile_str = kontrolle_dofile_str.replace('XXX__PROJECTNAME_SHORT__XXX', projectname_short)
kontrolle_dofile_str = kontrolle_dofile_str.replace('XXX__PROJECTNAME__XXX', projectname)
kontrolle_dofile_str = kontrolle_dofile_str.replace('XXX__USER__XXX', user)
kontrolle_dofile_str = kontrolle_dofile_str.replace('XXX__VERSION__XXX', version)

# save kontrolle do file
my_logger.debug('save response dofile as "{0}"'.format(history_do_file_path))
with open(kontrolle_do_file_path, 'w', encoding='utf-8') as file:
    file.write(kontrolle_dofile_str)

my_logger.info('Created kontrolle do file: "{0}"'.format(kontrolle_do_file_path))

# #################
# # MASTER DOFILE
# #################

# load master dofile template
my_logger.debug('load master dofile template')
master_dofile = ''
with open(master_do_file_template_path, 'r', encoding='utf-8') as file:
    master_dofile_str = file.read()

# modify master dofile
my_logger.debug('modifiy master dofile')

master_dofile_str = master_dofile_str.replace('XXX__PROJECTNAME_SHORT__XXX', projectname_short)
master_dofile_str = master_dofile_str.replace('XXX__PROJECTNAME__XXX', projectname)
master_dofile_str = master_dofile_str.replace('XXX__USER__XXX', user)
master_dofile_str = master_dofile_str.replace('XXX__VERSION__XXX', version)
master_dofile_str = master_dofile_str.replace('XXX__TIMESTAMP__XXX', timestamp_str)
master_dofile_str = master_dofile_str.replace('XXX__TIMESTAMPDATASET__XXX', data_csv_zip_file_modification_time_str)
master_dofile_str = master_dofile_str.replace('XXX__TIMESTAMPHISTORY__XXX', history_csv_zip_file_modification_time_str)

# add to run history do file
master_dofile_str += 'do {0}\n'.format(history_do_file_path)

# add to run response do file
master_dofile_str += 'do {0}\n'.format(response_do_file_path)

# add to run kontrolle do file
master_dofile_str += 'do {0}\n'.format(kontrolle_do_file_path)

# save master do file
my_logger.debug('save master dofile as "{0}"'.format(history_do_file_path))
with open(master_do_file_path, 'w', encoding='utf-8') as file:
    file.write(master_dofile_str)

my_logger.info('Created master do file: "{0}"'.format(master_do_file_path))

input('Programm beendet! (weiter mit ENTER)')
sys.exit()
