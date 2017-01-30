#!/usr/bin/env python
#TAGS: ebook

import sys
import re

res_quote1 = r'\\([0-7]{1,3})'
res_quote2 = r'\\([abtnvfr\\])'

quote2_dic = {
    'a' : '\a',
    'b' : '\b',
    't' : '\t',
    'n' : '\n',
    'v' : '\v',
    'f' : '\f',
    'r' : '\r',
    '\\' : '\\',
    }

re_quote1 = re.compile(res_quote1)
re_quote2 = re.compile(res_quote2)

def replace1(m):
    return chr(int(m.group(1), 8))

def replace2(m):
    return quote2_dic[m.group(1)]

def unquote(s):
    s = re_quote1.sub(replace1, s)
    s = re_quote2.sub(replace2, s)
    return s

def unquote_stream(istrm, ostrm):
    for l in istrm:
        l = unquote(l)
        ostrm.write(l)

if __name__ == '__main__':
    unquote_stream(sys.stdin, sys.stdout)
