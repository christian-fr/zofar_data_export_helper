import getpass
import os
import sys
import zipfile
from pathlib import Path


def flatten(ll: list):
    return [a for e in ll for a in e]


def unzip_folder(zip_file: Path, target_path: Path, overwrite: bool = False):
    if overwrite:
        target_path.mkdir(exist_ok=True, parents=True)
    elif not target_path.exists() or os.listdir(target_path) == 0:
        target_path.mkdir(parents=True)
    else:
        raise FileExistsError('Cannot unzip because target path exists: ' + str(target_path.absolute()))

    zf = zipfile.ZipFile(zip_file)
    for zinfo in zf.infolist():
        is_encrypted = zinfo.flag_bits & 0x1
        if is_encrypted:
            print(f'{zinfo.filename} is encrypted!')

    with zipfile.ZipFile(zip_file, "r") as zip_ref:
        encrypted = any([zinfo.flag_bits & 0x1 for zinfo in zf.infolist()])

        if not encrypted:
            zip_ref.extractall(target_path)
        else:
            password_str = getpass.getpass('Zip Passwort eingeben:')
            password_bytes = password_str.encode(sys.stdin.encoding)
            zip_ref.extractall(target_path, pwd=password_bytes)


def zip_folder(source_folder, output_path, debug_zofar_top_level: bool = False, overwrite: bool = False):
    if output_path.exists() and not overwrite:
        raise FileExistsError('Output file exists and "overwrite" not set to true: ' + str(output_path.absolute()))
    with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, _, files in os.walk(source_folder):
            for file in files:
                file_path = Path(root, file)
                archive_path = Path('_' if debug_zofar_top_level else '', file_path.relative_to(source_folder))
                zipf.write(file_path, archive_path)


if __name__ == '__main__':
    # zip the test export folder into a zip file
    zip_folder(Path('tests/context/input/TestExport'), Path('tests/context/input/testExport.zip'),
               debug_zofar_top_level=True, overwrite=True)
