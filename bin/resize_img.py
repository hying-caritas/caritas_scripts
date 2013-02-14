#!/usr/bin/env python

import Image, ImageFilter
from math import floor
import sys

def fit_image(width, height, pwidth, pheight):
    '''
    Fit image in box of width pwidth and height pheight.
    @param width: Width of image
    @param height: Height of image
    @param pwidth: Width of box
    @param pheight: Height of box
    @return: scaled, new_width, new_height. scaled is True iff new_width and/or new_height is different from width or height.
    '''
    scaled = height > pheight or width > pwidth
    if height > pheight:
        corrf = pheight/float(height)
        width, height = floor(corrf*width), pheight
    if width > pwidth:
        corrf = pwidth/float(width)
        width, height = pwidth, floor(corrf*height)
    if height > pheight:
        corrf = pheight/float(height)
        width, height = floor(corrf*width), pheight

    return scaled, int(width), int(height)

def minify_image(img, minify_to, preserve_aspect_ratio=True):
    '''
    Minify image to specified size if image is bigger than specified
    size and return minified image, otherwise, original image is
    returned.

    :param img: Image data as Image object
    :param minify_to: A tuple (width, height) to specify target size
    :param preserve_aspect_ratio: whether preserve original aspect ratio
    '''
    owidth, oheight = img.size
    nwidth, nheight = minify_to
    if owidth <= nwidth * 1.1 and oheight <= nheight * 1.1:
        return (0, img)
    if preserve_aspect_ratio:
        scaled, nwidth, nheight = fit_image(owidth, oheight, nwidth, nheight)
    img = img.resize((nwidth, nheight), Image.ANTIALIAS)
    return (1, img)

def main(argv):
    img_fn=argv[1]
    if len(argv) = 2:
        nwidth=int(argv[2])
        nheight=nwidth
    elif len(argv) = 3:
        nwidth=int(argv[2])
        nheight=int(argv[3])
    else:
        nwidth = 1000
        height = 1000

    img = Image.open(img_fn)
    scaled, img = minify_image(img, (nwidth, nheight))
    if scaled:
        img.save(img_fn)

if __name__ == '__main__':
    main(sys.argv)
