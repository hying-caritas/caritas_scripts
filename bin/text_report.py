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

re_dos_nl = re.compile('\r\n')

def dos2unix(fin, fout):
    for line in fin:
        nline = re_dos_nl.sub('\n', line)
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

def gen_report(top_level_path, out_file_name):
    fout = file(out_file_name, 'wb')
    for dir_path, dir_names, file_names in os.walk(top_level_path):
        file_names = exclude_file_names(file_names)
        file_names = sort_files(dir_path, file_names)
        for file_name in file_names:
            full_file_name = os.path.join(dir_path, file_name)
            fout.write('----------------------------------------------------\n')
            fout.write('[[%s]]\n' % (full_file_name,))
            fout.write('____________________________________________________\n')
            try:
                fin = file(full_file_name)
            except IOError as e:
                if e.errno == 2: # file may be deleted during report generating
                    pass
                else:
                    raise
            dos2unix(fin, fout)

def test_gen_report():
    top_level_path = sys.argv[1];
    out_file_name = sys.argv[2]
    gen_report(top_level_path, out_file_name)

############################################################
# Inotify Watcher
############################################################

import pyinotify

watch_mask = pyinotify.IN_DELETE | pyinotify.IN_CREATE | \
    pyinotify.IN_CLOSE_WRITE

class WatchProcess(pyinotify.ProcessEvent):
    def __init__(self, top_level_path, out_file_name):
        pyinotify.ProcessEvent.__init__(self)
        self.top_level_path = top_level_path
        self.out_file_name = out_file_name
    def process_default(self, event):
        print '%08x: %s\n' % (event.mask, event.pathname)
        gen_report(self.top_level_path, self.out_file_name)

class Watcher(object):
    def __init__(self, top_level_path, out_file_name):
        gen_report(top_level_path, out_file_name)
        self.wm = pyinotify.WatchManager()
        proc = WatchProcess(top_level_path, out_file_name)
        self.notifier = pyinotify.ThreadedNotifier(self.wm, proc)
        self.notifier.start()
        self.wdd = self.wm.add_watch(top_level_path, watch_mask, rec=True)

def test_watch():
    top_level_path = sys.argv[1]
    out_file_name = sys.argv[2]
    watcher = Watcher(top_level_path, out_file_name)
    signal.pause()

if __name__ == '__main__':
    test_watch()
