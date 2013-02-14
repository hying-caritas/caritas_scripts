#!/usr/bin/python
#TAGS: onkyo, mp3

import zhutils.word.word2pinyin.pinyin as pinyin
import zhutils.word.fanjian.fanjian as fanjian
import sys

if len(sys.argv) >= 2:
    words_in = sys.argv[1]
else:
    words_in = sys.stdin.read()

def h2p(words_in):
    if not isinstance(words_in, unicode):
        words_in = words_in.decode("utf-8")

    words_pinyin = ''
    for w in words_in:
        if ord(w) > 127:
            w = fanjian.zh_simple(w)
            wp = pinyin.hanzi2pinyin(w).capitalize()
            if len(wp) == 1 and ord(wp) > 127:
                wp = '_'
        else:
            wp = w
        words_pinyin += wp
    return words_pinyin

sys.stdout.write(h2p(words_in))
