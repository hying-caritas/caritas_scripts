#!/usr/bin/python

import re
import urllib

MYIP_URL="http://ipdetect.dnspark.com/"
sre_ip = r"([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})"
sre_myip = r"Current Address: " + sre_ip

def get_my_ip():
    f = urllib.urlopen(MYIP_URL)
    c = f.read()
    m = re.search(sre_ip, c)
    return m.group(1)

if __name__ == '__main__':
    print get_my_ip()
