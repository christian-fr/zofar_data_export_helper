import difflib
import os
from hashlib import sha256, sha512
from pathlib import Path
from typing import List, Optional, Tuple
import filecmp
from util import flatten
# from zdeh.util import flatten


def sha512sum(in_file: Path) -> str:
    return sha512(in_file.read_bytes()).hexdigest()


def sha256sum(in_file: Path) -> str:
    return sha256(in_file.read_bytes()).hexdigest()


def diff_files(file1: Path, file2: Path) -> str:
    lines1 = file1.read_text(encoding='utf-8').split('\n')
    lines2 = file2.read_text(encoding='utf-8').split('\n')
    result = []
    for line in difflib.unified_diff(lines1, lines2, fromfile=str(file1), tofile=str(file2), lineterm=''):
        result.append(line)
        print(line)
    return '\n'.join(result)


def get_all_file_paths(input_dir: Path, ignore_prefixes: Optional[List[str]] = None,
                       relative: bool = False) -> List[Path]:
    if ignore_prefixes is None:
        result = flatten([[Path(d, f) for f in fl] for d, _, fl in os.walk(input_dir)])
    else:
        result = flatten(
            [[Path(d, f) for f in fl if
              not any([f.startswith(pr) for pr in ignore_prefixes]) and
              not any([os.path.split(d)[1].startswith(pr) for pr in ignore_prefixes])]
             for d, _, fl in os.walk(input_dir)])
    if relative:
        return [p.relative_to(input_dir) for p in result]
    else:
        return result


def diff_dirs(dir1: Path, dir2: Path, ignore_prefixes: Optional[List[str]] = None) -> \
        Tuple[List[Path], List[Path], List[Path], List[Tuple[Path, Path, Path, str]]]:
    files1 = get_all_file_paths(dir1, ignore_prefixes, relative=True)
    files2 = get_all_file_paths(dir2, ignore_prefixes, relative=True)

    files_only_in_1 = set(files1).difference(files2)
    files_only_in_2 = set(files2).difference(files1)

    files_in_both = set(files1).intersection(files2)

    result = f"# Files only in {str(dir1.absolute())}:\n" + '\n'.join(
        [str(p) for p in sorted(list(files_only_in_1)) or ["[None]"]])
    result += '\n\n' + '#' * 80 + '\n\n'
    result += f"# Files only in {str(dir2.absolute())}:\n" + '\n'.join(
        [str(p) for p in sorted(list(files_only_in_2)) or ["[None]"]])
    result += '\n\n' + '#' * 80 + '\n\n'

    files_identical = []
    file_diffs = []
    for p in files_in_both:
        full_path1 = Path(dir1.absolute(), p)
        full_path2 = Path(dir2.absolute(), p)
        if filecmp.cmp(full_path1, full_path2, shallow=False):
            files_identical.append(p)
        else:
            file_diffs.append((p, dir1, dir2, diff_files(full_path1, full_path2)))

    files_identical.sort()
    file_diffs.sort(key=lambda k: k[0])

    result += f"# Identical files in both directories:\n" + '\n'.join(
        [str(p) for p in files_identical or ["[None]"]])
    result += '\n\n' + '#' * 80 + '\n\n'

    return sorted(list(files_only_in_1)), sorted(list(files_only_in_2)), files_identical, file_diffs


if __name__ == '__main__':
    # create sha512 sums for test input & output data

    for folder in ['input', 'output']:
        files_list = get_all_file_paths(Path(f'tests/context/{folder}'), ignore_prefixes=['.old', '.gitignore'])
        sha_sum_data = '\n'.join(
            [f'{sha512sum(p)}  {str(p.relative_to(Path("tests", "context")))}' for p in files_list])
        Path('tests', 'context', f'{folder}.sha512').write_text(sha_sum_data, encoding='utf-8')

    _, _, _, file_diffs_list = diff_dirs(Path('tests/context/input/TestExport/TestExport'),
                                         Path('tests/context/output/testProject_export_0.0.1'),
                                         ignore_prefixes=['.gitignore', '.old'])

