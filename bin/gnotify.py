#!/usr/bin/python

import pynotify
import sys
import os.path
from optparse import OptionParser
import time

def notify(timeout, title, message):
    n = pynotify.Notification(title, message)
    n.set_timeout(timeout)
    n.show()
    time.sleep(timeout / 1000)
    n.close()

def main(argv):
    cmd = os.path.basename(argv[0])
    parser = OptionParser("Usage: %s [options] <title> [msg...]" % cmd)
    parser.add_option("-a", "--application", dest="app", help="application name")
    parser.add_option("-t", "--timeout", dest="timeout", help="timeout in miliseconds")
    (options, args) = parser.parse_args()
    if len(args) == 0:
        title =  'Notification'
        msg = ''
    else:
        title = args[0]
        msg= " ".join(args[1:])
    if options.app:
        app = options.app
    else:
        app = cmd
    if options.timeout:
        timeout = int(options.timeout)
    else:
        timeout = 0

    pynotify.init(app)
    notify(timeout, title, msg)

if __name__ == '__main__':
    main(sys.argv)
