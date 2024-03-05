#!python
import os
import glob
import argparse
import shelve
import isce
import isceobj
from isceobj.Sensor import createSensor
from isceobj.Util import Poly1D
from isceobj.Planet.AstronomicalHandbook import Const

# Make data.bak, data.dat, data.dir files in the directory SLC/date/

# Parse the required files to the script
parser = argparse.ArgumentParser(description='Parse annotation, Doppler, segment, output directory, stitched SLC name')
parser.add_argument('--annotation','-a',type=str,required=True)
parser.add_argument('--doppler','-d',type=str,required=True)
parser.add_argument('--segment','-s',type=str,required=True)
parser.add_argument('--output','-o',type=str,required=True)
parser.add_argument('--slc','-S',type=str,required=True)
args = parser.parse_args()

metaFile = args.annotation
dopFile = args.doppler
stackSegment = args.segment
slcDir = args.output
slcFile = args.slc

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

# write_xml
# "write_xml" is in isce2/contrib/stack/stripmapStack/prepareUAVSAR_coregStack.py
# This is to produce xml and vrt files
shelveFile = os.path.join(slcDir, 'data')
with shelve.open(shelveFile,flag='r') as db:
    frame = db['frame']

length = frame.numberOfLines 
width = frame.numberOfSamples
print('')
print(slcFile)
print ('Width:',width,'Length:',length)

slc = isceobj.createSlcImage()
slc.setWidth(width)
slc.setLength(length)
slc.filename = slcFile
slc.setAccessMode('write')
slc.renderHdr()
slc.renderVRT()


