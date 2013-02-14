#!/usr/bin/env python
'''
gbkzip - unzip Windows zip file and convert gbk to utf8

author:    YUCOAT(yucoat^yucoat.com)
date:      2012-9-28
homepage:  www.yucoat.com
If you find any bug please contact me, thank you!

Huang Ying:
 - define function
 - use gbk encoding
'''
import os
import sys
import zipfile

def gbkunzip(zip_fn)
    try:
        zip_obj = zipfile.ZipFile(zip_fn, 'r')
    except IOError as e:
        print e.strerror
        exit(1)

    for name in zip_obj.namelist():
        name_utf8 = name.decode('gbk')
        path = os.path.dirname(name_utf8)

        if (not os.path.exists(path)) and path:
            os.makedirs(path)
        #Start Exacting
        filedata = zip_obj.read(name)
        if not os.path.exists(name_utf8):
            tmp = open(name_utf8, 'w')
            tmp.write(filedata)
            tmp.close()
        print 'Exacting %s ... done!'% (name_utf8)
    zip_obj.close()

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print 'Usage: gbkzip <zipfile.zip>'
        exit(1)
    gbkunzip(sys.argv[1])
