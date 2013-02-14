#!/usr/bin/python

import pynotify
import sys

def notify(title="Notify", message=""):
    n = pynotify.Notification(title, message)
    n.show()


if __name__ == '__main__':
    pynotify.init("cli notify")
    if len(sys.argv) > 1:
        title = sys.argv[1]
        msg = " ".join(sys.argv[2:])
        notify(title, msg)
    else:
        notify()
