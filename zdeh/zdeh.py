#!"C:\Program Files\IBM\SPSS\Statistics\26\Python3\python.exe"
__version__ = "0.0.4"
__author__ = "Christian Friedrich, Andrea Schulze"
__status__ = "Prototype"

import re
import time
import os
import sys
import uuid
from pathlib import Path
from tkinter import filedialog, Tk
import shutil
import xml
from typing import Optional, Union, Dict, Set
from xml.etree import ElementTree
import argparse
from collections import defaultdict
import csv
from jinja2 import Environment, PackageLoader, select_autoescape, UndefinedError, make_logging_undefined, \
    Undefined, meta, Template
import logging
from zdeh.util import unzip_folder, timestamp, startup_logger

UUID = uuid.uuid4().hex

LOGGER = logging.getLogger('__name__')


def handle_exception(exc_type, exc_value, exc_traceback):
    if issubclass(exc_type, KeyboardInterrupt):
        sys.__excepthook__(exc_type, exc_value, exc_traceback)
        return
    LOGGER.critical("Uncaught exception", exc_info=(exc_type, exc_value, exc_traceback))


def render_dofile(env: Environment, template: Template, var_dict: Dict[str, str], do_file_path: Path,
                  encoding: str = 'utf-8') -> None:
    try:
        assert not missing_vars(env, var_dict, template)
    except AssertionError:
        raise AssertionError(f'Missing variables for {template.name}: ' +
                             str(sorted(list(missing_vars(env, var_dict, template)))))
    do_file_path.write_text(template.render(**var_dict), encoding=encoding)


def find_all_variables(env: Environment, template: Template) -> Set[str]:
    s = env.loader.get_source(env, template.name)
    r = env.parse(s[0])
    return meta.find_undeclared_variables(r)


def missing_vars(env: Environment, var_dict: Dict[str, str], template: Template) -> Set[str]:
    all_vars = find_all_variables(env, template)
    return all_vars.difference(var_dict.keys())


def find_all_files(name: str, path: Union[str, Path]) -> list:
    result = []
    for root_dir, dirs, files in os.walk(path):
        if name in files:
            result.append(os.path.join(root_dir, name))
    return result


def main(debug: bool = False, project_name: Optional[str] = None, user: Optional[str] = None,
         project_version: Optional[str] = None, input_zip_file: Union[str, Path, None] = None,
         project_output_parent_dir: Optional[str] = None, test_flag: bool = False):
    sys.excepthook = handle_exception

    if not debug:
        startup_logger(logger=LOGGER, log_level=logging.INFO, uuid_str=UUID)
        LOGGER.info('starting up program')
    else:
        startup_logger(logger=LOGGER, log_level=logging.DEBUG, uuid_str=UUID)
        LOGGER.info('starting up program')
        LOGGER.debug('"debug" is set to True!')

    logging_undefined = make_logging_undefined(logger=LOGGER, base=Undefined)

    env = Environment(
        loader=PackageLoader("zdeh"),
        autoescape=select_autoescape(),
        undefined=logging_undefined
    )
    var_dict = {}

    main_template = env.get_template("main.do")
    response_template = env.get_template("response.do")
    history_template = env.get_template("history.do")
    kontrolle_template = env.get_template("kontrolle.do")
    label_template = env.get_template("label.do")

    time.sleep(.2)

    print(' ╔═════════════════════════════════════╗')
    print(' ║  Zofar Automation - Datenlieferung  ║')
    print(' ╚═════════════════════════════════════╝' + '\n' * 3)

    LOGGER.debug('authors: {0}'.format(__author__))
    LOGGER.debug('project_version: {0}'.format(__version__))

    if project_name is None:
        while True:
            project_name = input('Bitte Projektnamen angeben: ').strip()
            if project_name != '':
                break

    var_dict["project_name"] = project_name

    str_of_chars_to_replace = '''"'!?,.;:*\\& '''

    project_name_short = project_name
    for char in str_of_chars_to_replace:
        project_name_short = project_name_short.replace(char, '_')
    var_dict["project_name_short"] = project_name_short

    LOGGER.debug('Projektname_kurz: "{0}"'.format(project_name_short))

    if user is None:
        default_user = "Christian Friedrich"
        user = input(f'Bearbeiter*in (default is "{default_user}"): ') or default_user
    var_dict["user"] = user

    LOGGER.debug('Bearbeiter*in: "{0}"'.format(user))
    LOGGER.debug('Projektname:   "{0}"'.format(project_name))
    LOGGER.debug('Projektname_kurz: "{0}"'.format(project_name_short))

    # select zip file with export data
    if input_zip_file is None:
        LOGGER.debug('Bitte ZIP-Datei, die den Datenexport beinhaltet, auswählen.\n(weiter mit Enter)')

        initial_input_dir = Path(r'..\Automation_Input')

        if not initial_input_dir.exists():
            initial_input_dir = os.path.split(os.getcwd())[0]

        root = Tk()
        input_zip_file = os.path.normpath(
            filedialog.askopenfilename(initialdir=initial_input_dir,
                                       filetypes=(('zip files', '*.zip'), ('all files', '*.*')),
                                       title='Bitte ZIP-Datei, die den Datenexport beinhaltet, auswählen.'))
        root.withdraw()

        LOGGER.debug('Dateiname: "{0}"'.format(os.path.split(input_zip_file)[1]))

        input_zip_file = input_zip_file

    if project_version is None:
        project_version = input('Bitte Versionsnummer eingeben: ')

    if project_output_parent_dir is None:
        # select base dir
        input('Bitte das Oberverzeichnis auswählen, innerhalb dessen das Projekt\n'
              'angelegt werden soll. (weiter mit Enter)')
        initial_output_dir = Path(r'P:\Zofar\Automation_Output')

        if not initial_output_dir.exists():
            initial_output_dir = os.path.split(os.getcwd())[0]

        # set project_output_parent_dir
        project_output_parent_dir = os.path.join(os.path.normpath(
            filedialog.askdirectory(initialdir=initial_output_dir, title='Bitte Oberverzeichnis auswählen.')),
            project_name_short)

    var_dict["project_output_parent_dir"] = project_output_parent_dir

    LOGGER.debug('project_output_parent_dir = "{0}"'.format(project_output_parent_dir))

    # create folder structure
    project_orig_version_dir = Path(project_output_parent_dir, 'orig', project_version)
    project_lieferung_dir = Path(os.path.normpath(os.path.join(project_output_parent_dir, 'lieferung')))
    [sub_dir.mkdir(exist_ok=True, parents=True) for sub_dir in [project_orig_version_dir, project_lieferung_dir]]

    var_dict["project_orig_version_dir"] = project_orig_version_dir.absolute()
    var_dict["project_lieferung_dir"] = project_lieferung_dir.absolute()

    for d in [project_orig_version_dir,
              project_lieferung_dir]:
        assert isinstance(d, Path)
        d.mkdir(exist_ok=True, parents=True)

    LOGGER.debug('project_orig_version_dir = "{0}"'.format(project_orig_version_dir))
    LOGGER.debug('project_lieferung_dir = "{0}"'.format(project_lieferung_dir))

    # creating "lieferung" subdirectory - using "os.system('md ...')" instead of os.mkdir because it automatically
    #  creates more than one level of subfolders if needed
    project_lieferung_dir.mkdir(parents=True, exist_ok=True)

    # copy zip file with export data to project_orig_dir
    shutil.copy(input_zip_file, project_orig_version_dir)
    # set readme file with timestamp
    Path(project_orig_version_dir, 'README.md').write_text(f'Created at: {timestamp()}', encoding='utf-8')
    LOGGER.debug('zip file "{0}" copied to "{1}"'.format(input_zip_file, project_orig_version_dir))

    # create a folder project_orig_version_dir  - using "os.mkdir()" because top folder has been created in the last
    if not os.path.exists(project_orig_version_dir):
        os.mkdir(project_orig_version_dir)

    # set string variable for project_lieferung_version_dir (directory has yet to be created)
    project_lieferung_version_dir = Path(os.path.join(project_lieferung_dir,
                                                      '{0}_export_{1}'.format(project_name_short, project_version)))
    [Path(project_lieferung_version_dir, 'Stata', d).mkdir(exist_ok=True, parents=True)
     for d in ["do", "out", "log", "data"]]

    LOGGER.debug('project_lieferung_version_dir = "{0}"'.format(project_lieferung_version_dir))

    # create a folder project_lieferung_version_dir  - using "os.mkdir()" because top folder has been created in the last
    #  step
    project_lieferung_version_dir.mkdir(exist_ok=True, parents=True)
    LOGGER.debug('os.mkdir({0})'.format(project_lieferung_version_dir))

    LOGGER.debug('input_zip_file: {0}'.format(input_zip_file))
    LOGGER.debug('project_output_parent_dir: {0}'.format(project_output_parent_dir))

    # create variable "return_code" to store the return code of the 7zip archive unpacking command
    # a return_code of 0 means the unzip operation has been successful

    # set return_code to an initial value other than 0 (just to already have the variable before starting the loop)
    return_code = -1

    # start the while loop: it will loop until the return_code == 0 (so when a wrong password has been entered, it will
    #  just start the unzipping again and also prompt for the password again
    #  we are using the "counter" variable to make sure that we do a maximum of 10 loops

    try:
        # set counter variable to initial value
        counter = 0
        unzip_folder(input_zip_file, project_lieferung_version_dir, overwrite=True)
        LOGGER.debug("Unzipping successful")
    except NotImplementedError:
        LOGGER.info("Unzipping unsuccessful, using 7z as fallback option.")
        while return_code != 0:
            LOGGER.debug('counter: "{0}"'.format(counter))
            cmd = f'"C:\\Program Files\\7-Zip\\7z.exe" x {input_zip_file} -o{project_lieferung_version_dir}'
            LOGGER.debug(f'running: {cmd}')
            return_code = os.system(cmd)
            LOGGER.debug('return code: "{0}"'.format(return_code))

            counter += 1
            if counter == 10:
                LOGGER.info(f'Could not successfully run: {cmd}')
                LOGGER.info('Exiting this program.')
                sys.exit(f'Could not successfully run: {cmd}')

    # move subfolders to appropriate levels
    # find "csv" subfolder
    csv_folders = [(w, d, f) for w, d, f in os.walk(project_lieferung_version_dir) if 'csv' in d]
    assert len(csv_folders) == 1
    csv_folder = Path(csv_folders[0][0], 'csv')
    # declare parent of "csv" folder to root_folder
    root_folder = csv_folder.parent
    if root_folder != project_lieferung_version_dir:
        # move subdirectories and files to project_lieferung_version_dir
        for directory in os.listdir(root_folder):
            shutil.move(Path(root_folder, directory), project_lieferung_version_dir)
        # check that old root_folder is empty
        assert len(os.listdir(root_folder)) == 0
        # delete old root_folder
        shutil.rmtree(root_folder)

    # look for xml file within project_lieferung_version_dir
    list_of_questionnaire_xml_files = find_all_files(name='questionnaire.xml', path=project_lieferung_version_dir)

    LOGGER.debug(list_of_questionnaire_xml_files)

    # check if returned file list has exactly one match
    if len(list_of_questionnaire_xml_files) == 1:
        xmlfile = list_of_questionnaire_xml_files[0]

    # if there are less or more than one match, display a filedialog to manually choose a file
    else:
        # read xml file
        input('Es wird nach der XML-Datei des Fragebogens gesucht ... ... ...')

        xml_file_initial_path = os.path.join(project_lieferung_version_dir, project_version, 'output', 'instruction',
                                             'QML')

        if os.path.exists(xml_file_initial_path):
            LOGGER.debug(xml_file_initial_path + ' exists.')
        else:
            print(xml_file_initial_path + ' does not exist.')
            xml_file_initial_path = project_lieferung_version_dir

        xmlfile = os.path.normpath(filedialog.askopenfilename(initialdir=xml_file_initial_path,
                                                              filetypes=(('xml files', '*.xml'), ('all files', '*.*')),
                                                              title='Bitte XML-Datei des Fragebogens auswählen.'))

    page_list = []
    if not os.path.isfile(xmlfile):
        LOGGER.debug('Keine XML-Datei ausgewählt! Seitenreihenfolge kann \nnicht bestimmt werden.')
    else:
        try:
            # create page list
            x = ElementTree.parse(source=xmlfile)
            for element in x.iter():
                if element.tag == '{http://www.his.de/zofar/xml/questionnaire}page':
                    if hasattr(element, 'attrib'):
                        if 'uid' in element.attrib:
                            page_list.append(element.attrib['uid'])

            LOGGER.debug('Seitenreihenfolge:' + str(page_list))

            zofar_var_dict = defaultdict(list)
            # create page list
            x = ElementTree.parse(source=xmlfile)
            for element in x.iter():
                if element.tag == '{http://www.his.de/zofar/xml/questionnaire}variables':
                    for child_element in element:
                        if child_element.tag == '{http://www.his.de/zofar/xml/questionnaire}variable':
                            if hasattr(child_element, 'attrib'):
                                if 'name' in child_element.attrib and 'type' in child_element.attrib:
                                    zofar_var_dict[child_element.attrib['type']].append(child_element.attrib['name'])

            LOGGER.debug('Variablentypen:' + str(zofar_var_dict))

        except xml.etree.ElementTree.ParseError:
            LOGGER.debug('XML Datei ist nicht lesbar, wird übersprungen.\n\n')

    # look for history.csv.zip file within project_lieferung_version_dir
    list_of_history_csv_zip_files = find_all_files(name='history.csv.zip', path=project_lieferung_version_dir)

    LOGGER.debug(list_of_history_csv_zip_files)

    # load history.csv.zip file and read modification time

    # check if returned file list has exactly one match
    if len(list_of_history_csv_zip_files) == 1:
        history_csv_zip_file_str = list_of_history_csv_zip_files[0]

    # if there are less or more than one match, display a filedialog to manually choose a file
    else:
        input('Bitte die history.csv.zip-Datei auswählen. (Weiter mit ENTER)')

        csv_zip_files_initial_path = os.path.join(project_lieferung_version_dir, 'output', 'csv')
        if os.path.isfile(csv_zip_files_initial_path):
            LOGGER.debug(csv_zip_files_initial_path + ' exists.')
        else:
            LOGGER.debug(csv_zip_files_initial_path + ' does not exist.')
            csv_zip_files_initial_path = project_orig_version_dir

        history_csv_zip_file_str = os.path.normpath(
            filedialog.askopenfilename(initialdir=csv_zip_files_initial_path,
                                       filetypes=(('history.csv.zip file',
                                                   'history.csv.zip'),
                                                  ('all files', '*.*')),
                                       title='Bitte die history.csv.zip-Datei auswählen.'))

    if not os.path.isfile(history_csv_zip_file_str):
        history_csv_zip_file_modification_time_str = input('Keine history.csv.zip-Datei geladen. Manuelle Eingabe \n'
                                                           'des Timestamps (kann leer gelassen werden): ')
    else:
        history_csv_zip_file_modification_localtime = time.localtime(os.path.getmtime(history_csv_zip_file_str))
        history_csv_zip_file_modification_time_str = timestamp(history_csv_zip_file_modification_localtime)

        unzip_folder(Path(history_csv_zip_file_str), Path(history_csv_zip_file_str).parent, overwrite=True)

    var_dict["history_csv_zip_file_modification_time_str"] = history_csv_zip_file_modification_time_str

    # load data.csv.zip file and read modification time
    # look for history.csv.zip file within project_lieferung_version_dir
    list_of_data_csv_zip_files = find_all_files(name='data.csv.zip', path=project_lieferung_version_dir)

    LOGGER.debug(list_of_data_csv_zip_files)

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

    list_of_csv_string_var_columns = []

    if not os.path.isfile(data_csv_zip_file_str):
        data_csv_zip_file_modification_time_str = input('Keine data.csv.zip-Datei geladen. Manuelle Eingabe des \n'
                                                        'Timestamps (kann leer gelassen werden): ')
    else:
        data_csv_zip_file_modification_localtime = time.localtime(os.path.getmtime(data_csv_zip_file_str))
        data_csv_zip_file_modification_time_str = timestamp(data_csv_zip_file_modification_localtime)

        unzip_folder(Path(data_csv_zip_file_str), Path(data_csv_zip_file_str).parent, overwrite=True)
        # ToDo: check if path is correct!
        LOGGER.debug('CSV header ist geladen, Variablennamen erfasst.')

        data_csv_file_str = os.path.join(project_lieferung_version_dir, 'csv', 'data.csv')
        LOGGER.debug('Lade CSV-Datei: {0}'.format(data_csv_file_str))

        with open(data_csv_file_str, encoding='utf-8') as csv_file:
            reader = csv.reader(csv_file)
            list_of_all_varnames = next(reader)

        LOGGER.debug('CSV header ist geladen, Variablennamen erfasst.')

        # check if zofar_var_dict does contain a key "string"
        if zofar_var_dict['string']:
            for index, varname in enumerate(list_of_all_varnames):
                if varname in zofar_var_dict['string']:
                    list_of_csv_string_var_columns.append(str(index + 1))
        LOGGER.debug(
            'Liste mit Spaltennummern für Stringvariablen wurde erstellt: ' + str(list_of_csv_string_var_columns))

    var_dict["data_csv_zip_file_modification_time_str"] = data_csv_zip_file_modification_time_str

    main_do_file_path, history_do_file_path, response_do_file_path, kontrolle_do_file_path, label_do_file_path = [
        Path(project_lieferung_version_dir, 'Stata', 'do',
             f'{i}'.zfill(2) + '_' + file_name + '_' + project_name_short + '_' + project_version + '.do') for
        i, file_name in
        enumerate(['main', 'history', 'response', 'kontrolle', 'label'])]

    LOGGER.debug('main_do_file_path = "{0}"'.format(main_do_file_path))
    LOGGER.debug('history_do_file_path = "{0}"'.format(history_do_file_path))
    LOGGER.debug('response_do_file_path = "{0}"'.format(response_do_file_path))
    LOGGER.debug('kontrolle_do_file_path = "{0}"'.format(kontrolle_do_file_path))

    # ##################
    # # HISTORY DOFILE
    # ##################

    # generate STATA code for pagenum replacement
    LOGGER.debug('generate STATA code for pagenum replacement')
    replace_pagenum_list = []
    label_visit_list = []
    label_pagedauer_list = []
    if page_list:
        for i in range(len(page_list)):
            replace_pagenum_list.append(f'replace pagenum={i} if page=="{page_list[i]}"')
            label_visit_list.append(f'cap label var visit{i} "Anzahl Aufrufe von {page_list[i]}"')
            label_pagedauer_list.append(f'cap label var pagedauer{i} "Verweildauer auf {page_list[i]} [s]"')
    else:
        LOGGER.debug('Es wurde zuvor keine XML-Datei ausgewählt oder es wurden \n'
                     'keine Pages gefunden. Platzhalter wird im History-Dofile eingefügt.\n')
        replace_pagenum_list.append('* XXXXXXXXXX Platzhalter für PAGENUM XXXXXXXXX')
        replace_pagenum_list.append('replace pagenum=0 if page=="index"')
        replace_pagenum_list.append('replace pagenum=1 if page=="offer"')

        label_visit_list.append(f'* XXXXXXXXXX Platzhalter für LABEL_VISIT XXXXXXXXX')
        label_visit_list.append(f'* cap label var visit0 "Anzahl Aufrufe von index"')
        label_visit_list.append(f'* cap label var visit1 "Anzahl Aufrufe von offer"')

        label_pagedauer_list.append(f'* XXXXXXXXXX Platzhalter für LABEL_PAGEDAUER XXXXXXXXX')
        label_pagedauer_list.append(f'* cap label var visit0 "Verweildauer auf index [s]"')
        label_pagedauer_list.append(f'* cap label var visit1 "Verweildauer auf offer [s]"')

    # generate STATA code for dauer generate
    dauer_str = 'egen dauer=rowtotal(p0-p{0})'.format(len(page_list) - 1)
    var_dict["dauer_str"] = dauer_str

    # replace strings in history_file
    LOGGER.debug('modifiy history dofile')

    timestamp_str = timestamp()
    var_dict["timestamp_str"] = timestamp_str

    # generate STATA code for labeling pages
    label_page_str = ''
    if page_list:
        for i in range(len(page_list)):
            label_page_str += 'cap label var p{0} "Verweildauer auf {1} (in Sekunden)"\n'.format(i, page_list[i])
        var_dict["label_page_str"] = label_page_str

    else:
        LOGGER.debug('Es wurde zuvor keine XML-Datei ausgewählt oder es wurden \n'
                     'keine Pages gefunden. Platzhalter wird im History-Dofile eingefügt.\n')
        replace_pagenum_list.append('* XXXXXXXXXX Platzhalter für PAGENUM XXXXXXXXX')
        replace_pagenum_list.append('label var p0 "Verweildauer auf index (in Sekunden)"')
        replace_pagenum_list.append('label var p1 "Verweildauer auf offer (in Sekunden)"')

    # generate STATA code for labeling maxpage
    label_maxpage_str = 'label define maxpagelb '
    if page_list:
        for i in range(len(page_list)):
            label_maxpage_str += '{0} "{1}" '.format(i, page_list[i])
        var_dict["label_maxpage_str"] = label_maxpage_str

    else:
        LOGGER.debug('Es wurde zuvor keine XML-Datei ausgewählt oder es wurden \n'
                     'keine Pages gefunden. Platzhalter wird im History-Dofile eingefügt.\n')
        replace_pagenum_list.append('label define maxpagelb 0 "index" 1 "offer"')

    replace_pagenum = '\n'.join(replace_pagenum_list)
    var_dict["replace_pagenum"] = replace_pagenum

    label_visit = '\n'.join(label_visit_list)
    var_dict['label_visit'] = label_visit
    label_pagedauer = '\n'.join(label_pagedauer_list)
    var_dict['label_pagedauer'] = label_pagedauer

    # generate STATA code for Tabout Verweildauer with finished questionnaires
    tabstat_verweildauer_finished_str = ('tabstatout dauer if maxpage=={0}, s(n mean median min max sd) '
                                         'tf(verwdauer_gesamt_nurBeendet) format(%9.4g) '
                                         'replace\n').format(len(page_list) - 1)

    var_dict["tabstat_verweildauer_finished_str"] = tabstat_verweildauer_finished_str

    # generate STATA code for dauer generate
    tabstat_verweildauer_str = ('foreach n of numlist 0/{0} {{\n	tabstat p\`n\' if visit\`n\'==1, '
                                'stat(n mean min max sd med)\n	}}').format(len(page_list) - 1)
    var_dict["tabstat_verweildauer_str"] = tabstat_verweildauer_str

    var_dict["project_version"] = project_version

    LOGGER.debug('save history dofile as "{0}"'.format(history_do_file_path))

    try:
        render_dofile(env, history_template, var_dict, history_do_file_path, 'utf-8')
    except UndefinedError as err:
        raise UndefinedError(err.message)

    LOGGER.info('Created history do file: "{0}"'.format(history_do_file_path))

    # ###################
    # # RESPONSE DOFILE
    # ###################

    # load response dofile template
    LOGGER.debug('load response dofile template')

    # modify response dofile
    LOGGER.debug('modifiy response dofile')
    response_dofile_str = response_template.render(**var_dict)

    # save response do file
    LOGGER.debug('save response dofile as "{0}"'.format(history_do_file_path))
    with open(response_do_file_path, 'w', encoding='utf-8') as file:
        file.write(response_dofile_str)

    LOGGER.info('Created response do file: "{0}"'.format(response_do_file_path))

    # ###################
    # # KONTROLLE DOFILE
    # ###################

    # modify kontrolle dofile
    LOGGER.debug('modifiy kontrolle dofile')

    data_import_str = ('* import delimited "${{orig}}\data.csv", bindquote(strict) encoding(utf8) delimiter(comma) '
                       'clear stringcols({0})\n').format(' '.join(list_of_csv_string_var_columns))

    var_dict["data_import_str"] = data_import_str

    # save kontrolle do file
    LOGGER.debug('save kontrolle dofile as "{0}"'.format(kontrolle_do_file_path))
    try:
        render_dofile(env, kontrolle_template, var_dict, kontrolle_do_file_path, 'utf-8')
    except UndefinedError as err:
        time.sleep(.1)
        raise UndefinedError(err.message)

    LOGGER.info('Created kontrolle do file: "{0}"'.format(kontrolle_do_file_path))

    # #################
    # # LABEL DOFILE
    # #################

    # modify label dofile
    LOGGER.debug('modifiy label dofile')

    data_do = Path(project_lieferung_version_dir, 'instruction', 'Stata', 'data.do').read_text('utf-8').split('\n')
    obsolete_stata_commands = ['import', 'version', 'save', 'clear', 'set']

    # comment out commands: import, version, save, clear,
    pattern_str = f'^(({")|(".join(obsolete_stata_commands)}))'
    data_label_str = '\t' + '\n\t'.join(
        # noinspection
        [re.sub(pattern_str, r'* \1', s) for s in data_do])

    var_dict['data_label_str'] = data_label_str

    # save kontrolle do file
    LOGGER.debug('save label dofile as "{0}"'.format(label_do_file_path))

    try:
        render_dofile(env, label_template, var_dict, label_do_file_path, 'utf-8')
    except UndefinedError as err:
        time.sleep(.1)
        raise UndefinedError(err.message)

    LOGGER.info('Created kontrolle do file: "{0}"'.format(kontrolle_do_file_path))

    # #################
    # # MAIN DOFILE
    # #################

    do_files_list = [history_do_file_path, response_do_file_path, kontrolle_do_file_path, label_do_file_path]
    if all([do_file.is_relative_to(main_do_file_path.parent) for do_file in do_files_list]):
        do_files = '\n'.join([f'include {do_file.relative_to(main_do_file_path.parent)}' for do_file in do_files_list])
    else:
        do_files = '\n'.join([f'include {do_file}' for do_file in do_files_list])
    var_dict["do_files"] = do_files

    LOGGER.info('processing main_template')
    try:
        render_dofile(env, main_template, var_dict, main_do_file_path, 'utf-8')
    except UndefinedError as err:
        raise UndefinedError(err.message)
    LOGGER.debug('list of csv string variable columns: {0}'.format(list_of_csv_string_var_columns))

    if not test_flag:
        input('Programm beendet! (weiter mit ENTER)')
        sys.exit()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Optionally set the debug flag for verbose output and debug logging.')
    parser.add_argument('--debug', action='store_true', help='enable verbose output and debug logging')
    parser.add_argument('--project_name', help='')
    parser.add_argument('--user', help='')
    parser.add_argument('--project_version', help='')
    parser.add_argument('--test_flag', action='store_true', help='')
    parser.add_argument('--input_zip_file', help='')
    parser.add_argument('--project_output_parent_dir', help='')

    args = parser.parse_args()

    main(**args.__dict__)
    sys.exit(0)
