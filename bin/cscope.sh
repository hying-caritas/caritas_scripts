#!/bin/bash

set -e

find * -type f -name '*.[hcS]' > cscope.files
find * -type f -name '*.cpp' >> cscope.files
exec cscope -b
