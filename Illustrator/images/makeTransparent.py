import os, sys, Image

fName = sys.argv[1]
im = Image.open(fName)
im = im.convert("RGBA")
pixdata = im.load()

# Make the white pixels transparent
for y in xrange(im.size[1]):
    for x in xrange(im.size[0]):
        if pixdata[x, y] == (255, 255, 255, 255):
            pixdata[x, y] = (255, 255, 255, 0)
            
im.save(fName)