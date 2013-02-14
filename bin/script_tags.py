#!/usr/bin/python

import sys
import re
from optparse import OptionParser
import os
import os.path
import tempfile

res_magic_line = r'^#!/.*(?:sh|python)\s*$'
res_tags_line = r'^#TAGS: (.*)$'
res_empty_tag = r'^\s*$'
re_magic_line = re.compile(res_magic_line)
re_tags_line = re.compile(res_tags_line)
re_empty_tag = re.compile(res_empty_tag)

def err_exit(str):
    sys.stdout.flush()
    sys.stderr.write('\n\nERROR!!! %s' % (str,))
    sys.exit(-1)

def parse_stags(stags):
    rtags = stags.split(',')
    tags = []
    for rtag in rtags:
        rtag = rtag.strip()
        if not re_empty_tag.match(rtag):
            tags.append(rtag)
    return tags

def parse_tags(f):
    # #!/xxx magic line
    l = f.readline()
    if not re_magic_line.match(l):
        err_exit("Not a shell or python script!\n")
    l = f.readline()
    m = re_tags_line.match(l)
    if m:
        stags = m.group(1)
    else:
        stags = ''
    return parse_stags(stags)

def tags_to_str(tags):
    return ', '.join(tags)

def write_tags(inf, outf, tags):
    # #!/xxx magic line
    l = inf.readline()
    outf.write(l)
    stags = tags_to_str(tags)
    stags_line = '#TAGS: %s\n' % (stags,)
    outf.write(stags_line)
    # may be tags line
    l = inf.readline()
    if not re_tags_line.match(l):
        outf.write(l)
    for l in inf:
        outf.write(l)

def mktemp(in_fn):
    stat = os.stat(in_fn)
    stemp = tempfile.mkstemp()
    os.close(stemp[0])
    tmp_fn = stemp[1]
    os.chmod(tmp_fn, stat.st_mode)
    os.chown(tmp_fn, stat.st_uid, stat.st_gid)
    return tmp_fn

def get_tags(in_fn):
    tags = parse_tags(file(in_fn))
    print tags_to_str(tags)

def add_tag(in_fn, out_fn, tag):
    tags = parse_tags(file(in_fn))
    tmp_fn = mktemp(in_fn)
    if tag not in tags:
        tags.append(tag)
    write_tags(file(in_fn), file(tmp_fn, 'w'), tags)
    os.rename(tmp_fn, out_fn)

def set_tags(in_fn, out_fn, stags):
    # check input file
    parse_tags(file(in_fn))
    tags = parse_stags(stags)
    tmp_fn = mktemp(in_fn)
    write_tags(file(in_fn), file(tmp_fn, 'w'), tags)
    os.rename(tmp_fn, out_fn)

def find_tags(in_fn, stags):
    tags = parse_stags(stags)
    in_tags = parse_tags(file(in_fn))
    for tag in tags:
        if tag not in in_tags:
            return
    print in_fn

def main():
    cmd = os.path.basename(sys.argv[0])
    parser = OptionParser("Usage: %s [options] <input file>" % (cmd,))
    parser.add_option("-o", "--output", dest="output", help="output file")
    parser.add_option("-a", "--add", metavar='TAG', dest="add", help="add tag")
    parser.add_option("-s", "--set", metavar='TAGS', dest="set",
                      help="set tags")
    parser.add_option("-f", "--find", metavar='TAGS', dest="find",
                      help="find tags")
    (options, args) = parser.parse_args()
    if len(args) == 0 :
        parser.print_help()
        sys.exit(-1)
    elif len(args) > 1 and options.output:
        err_exit('Cannot output to one file for multiple input files!\n')

    for in_fn in args:
        if options.output:
            out_fn = options.output
        else:
            out_fn = in_fn

        if options.add:
            add_tag(in_fn, out_fn, options.add)
        elif options.set:
            set_tags(in_fn, out_fn, options.set)
        elif options.find:
            find_tags(in_fn, options.find)
        else:
            if len(args) > 1:
                print '%s:' % (in_fn,),
            get_tags(in_fn)

def test():
    write_tags(sys.stdin, sys.stdout, ['hehe', 'lala'])

if __name__ == '__main__':
    main()
