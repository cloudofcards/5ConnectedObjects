import sys,time
sys.path.append("/home/pi/GrovePi/Software/Python/")
import grovepi

sensor=4
try:
    [temp,humidity]= grovepi.dht(sensor,0)
    print temp

except IOError:
    print"500"
