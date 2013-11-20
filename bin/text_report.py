#!/usr/bin/env python

import sys
import os
import os.path
import re
import signal

############################################
# Report Generator
############################################

file_name_includes = [
    '\.txt$',
    '\.muse$',
]

re_file_name_includes = [re.compile(pat) for pat in file_name_includes]

file_name_excludes = [
    '~$',
    '\.bak$',
    '^\.#',
]

re_file_name_excludes = [re.compile(pat) for pat in file_name_excludes]

re_pattern = None

re_dos_nl = re.compile('\r\n')

def write_file(full_file_name, fout):
    fin = open_file(full_file_name)
    if not fin:
        return
    fout.write('----------------------------------------------------\n')
    fout.write('[[%s]]\n' % (full_file_name,))
    fout.write('____________________________________________________\n')

    for line in fin:
        nline = re_dos_nl.sub('\n', line)
        if re_pattern:
            if re_pattern.search(nline):
                fout.write(nline)
        else:
            fout.write(nline)

def exclude_file_names(file_names):
    efns = []
    for fn in file_names:
        for re_include in re_file_name_includes:
            if re_include.search(fn):
                efns.append(fn)
                break
    return efns;
    # exclude logic, for backup
    efns = []
    for fn in file_names:
        excluded = False
        for re_exclude in re_file_name_excludes:
            if re_exclude.search(fn):
                excluded = True
                break
        if not excluded:
            efns.append(fn)
    return efns

def sort_files(dir_path, file_names):
    path_names = [(os.path.join(dir_path, fn), fn) for fn in file_names]
    m_fns = [(os.stat(path).st_mtime, fn) for path, fn in path_names]
    m_fns.sort(reverse = True)
    sfns = [m_fn[1] for m_fn in m_fns]
    return sfns

def open_file(file_name):
    try:
        fin = file(file_name)
    except IOError as e:
        if e.errno == 2: # file may be deleted during report generating
            return None
        else:
            raise
    return fin

def filter_file(file_name):
    if re_pattern is None:
        return True
    fin = open_file(file_name)
    for line in fin:
        if re_pattern.search(line):
            return True
    return False

def gen_report(top_level_path, out_file_name):
    fout = file(out_file_name, 'wb')
    for dir_path, dir_names, file_names in os.walk(top_level_path):
        file_names = exclude_file_names(file_names)
        file_names = sort_files(dir_path, file_names)
        for file_name in file_names:
            full_file_name = os.path.join(dir_path, file_name)
            if filter_file(full_file_name):
                write_file(full_file_name, fout)

def main():
    global re_pattern
    if len(sys.argv) == 4:
        re_pattern = re.compile(sys.argv[3])
    top_level_path = sys.argv[1]
    out_file_name = sys.argv[2]
    gen_report(top_level_path, out_file_name)

if __name__ == '__main__':
    main()
