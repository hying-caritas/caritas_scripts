#!/bin/bash

set -e

ddjvu -format=tiff -page=1 "$1" a.ppm
convert a.ppm a.png
rm a.ppm
