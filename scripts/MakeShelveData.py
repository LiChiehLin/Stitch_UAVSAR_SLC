#!python
import os
import glob
import argparse
import shelve
import isce
from isceobj.Sensor import createSensor
from isceobj.Util import Poly1D
from isceobj.Planet.AstronomicalHandbook import Const

# Make data.bak, data.dat, data.dir files in the directory SLC/date/
# The output of this script should not be dependent on segments as the source script from ISCE does not take segment into acount in producing relevant files

# Parse the required files to the script
parser = argparse.ArgumentParser(description='Parse annotation, Doppler, segment and output directory')
parser.add_argument('--annotation','-a',type=str,required=True)
parser.add_argument('--doppler','-d',type=str,required=True)
parser.add_argument('--segment','-s',type=str,required=True)
parser.add_argument('--output','-o',type=str,required=True)
args = parser.parse_args()

metaFile = args.annotation
dopFile = args.doppler
stackSegment = args.segment
slcDir = args.output

# unpack (In unpackFrame_UAVSAR.py)
# Corresponding codes of createSensor can be found in Github: isce2/components/isceobj/Sensor/UAVSAR_Stack.py
# sub-function: extractDoppler
obj = createSensor('UAVSAR_STACK')
obj.configure()
obj.metadataFile = metaFile
obj.dopplerFile = dopFile
obj.segment_index = stackSegment
obj.parse()

pickName = os.path.join(slcDir, 'data')
with shelve.open(pickName) as db:
    db['frame'] = obj.frame

print('Finished')



