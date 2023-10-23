import os
from unittest import TestCase
from zdeh.zdeh import main
from tempfile import TemporaryDirectory


class Test(TestCase):
    def setUp(self) -> None:
        self.output_dir = TemporaryDirectory()

    def tearDown(self) -> None:
        self.output_dir.cleanup()

    def test_main(self):
        main(debug=True, project_name='testProject', user='Test User', project_output_parent_dir=self.output_dir.name,
             project_version='0.0.1', input_zip_file="./context/input/TestExport.zip", test_flag=True)
        os.startfile(self.output_dir.name)
        self.fail()
