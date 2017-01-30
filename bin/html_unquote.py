#!/usr/bin/env python

import sys
import re

res_quote1 = r'&#(\d+);'
res_quote2 = r'&#([a-zA-Z0-9]+)'

re_quote1 = re.compile(res_quote1)
re_quote2 = re.compile(res_quote2)

def replace1(m):
    return unichr(int(m.group(1))).encode('utf-8')

def unquote(s):
    s = re_quote1.sub(replace1, s)
    return s

def quote(s):
    nca = ['&#%d;' % (ord(c),) for c in s]
    return "".join(nca)

def unquote_stream(istrm, ostrm):
    for l in istrm:
        l = unquote(l)
        ostrm.write(l)

if __name__ == '__main__':
    unquote_stream(sys.stdin, sys.stdout)
