import os
from pathlib import Path
from unittest import TestCase
from tempfile import TemporaryDirectory
from zdeh.util import zip_folder
from zdeh.diff import diff_dirs
from zdeh.zdeh import main


# import collections
# collections.Callable = collections.abc.Callable


class Test(TestCase):
    def setUp(self) -> None:
        self.output_dir = TemporaryDirectory()
        self.input_dir = TemporaryDirectory()
        self.export_zip_file = Path(self.input_dir.name, 'testExport.zip')
        zip_folder(Path('.', 'context', 'input', 'TestExport'), self.export_zip_file,
                   debug_zofar_top_level=True)

    def tearDown(self) -> None:
        self.output_dir.cleanup()
        self.input_dir.cleanup()

    def test_main(self):
        main(debug=True, project_name='testProject', user='Test User', project_output_parent_dir=self.output_dir.name,
             project_version='0.0.1', input_zip_file=self.export_zip_file, test_flag=True)
        os.startfile(self.output_dir.name)

        input_path = Path('.', 'context', 'input')
        output_reference_path =  Path('.', 'context', 'output')
        output_lieferung_reference_path =  Path(output_reference_path, 'lieferung')
        output_project_path =  Path(self.output_dir.name)
        output_project_orig_path =  Path(output_project_path, 'orig')
        output_project_lieferung_path =  Path(output_project_path, 'lieferung')
        #output_project_lieferung_version_path = Path(output_project_lieferung_path, 'testProject_export_0.0.1')

        r = diff_dirs(output_project_lieferung_path,
                      output_lieferung_reference_path,
                      ignore_prefixes=['.old', '.gitignore'])
        if len(r[0]) != 0 or len(r[3]) != 0:
            print('\n\n'.join([s[2] for s in r[4]]))
            self.fail()

