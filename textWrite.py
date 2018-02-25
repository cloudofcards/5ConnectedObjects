# Note: As of today, the hat needed for the PaPirus is not compatible with
# the GrovePi+ hat. Both work independently. You may choose to use either
# one depending on your project. Further compatibility may come...

#!/usr/bin/env python
from papirus import PapirusTextPos
import sys
text = PapirusTextPos()
text.AddText(sys.argv[1], Id="Top", font_path='/home/pi/processing/sketchbook/fonts/NeueHaasUnicaPro-Bold.ttf')
#print sys.argv[1]

# instantiate writer
text = PapirusTextPos()

#Write text (see README.MD of repo for more examples)
#AddText(*text, x, y, id, font_path, size)#
#text.AddText("your text", Id="Top", font_path='/home/pi/processing/sketchbook/fonts/NeueHaasUnicaPro-Light.ttf')
#text.AddText(sys.argv[1], Id="Top", font_path='/home/pi/processing/sketchbook/fonts/NeueHaasUnicaPro-Bold.ttf')
#text.AddText("your text", 15, 15, Id="Start", font_path='/home/pi/processing/sketchbook/fonts/NeueHaasUnicaPro-Bold.ttf', size=36)
