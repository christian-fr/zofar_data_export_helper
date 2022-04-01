import zipfile
import os
from pathlib import Path
import shutil

import time
time_str = time.strftime("%Y%m%d-%H%M%S")

deployment_destination_path = Path('Y:\\')


current_dir = os.path.split(__file__)[0]
project_path_to_be_deployed = Path(current_dir, 'Automation_Template')

list_of_files_to_be_deployed = [Path(project_path_to_be_deployed, file) for file in os.listdir(project_path_to_be_deployed)]


print('creating archive')
zip_file_path = Path(current_dir, f'Automation_Template_{time_str}.zip')
zf = zipfile.ZipFile(zip_file_path, mode='w')


try:
    print('adding README.txt')
    for file in list_of_files_to_be_deployed:
        zf.write(file)

finally:
    print('closing')
    zf.close()

shutil.copy(zip_file_path, deployment_destination_path)