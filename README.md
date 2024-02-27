# Stitch_UAVSAR_SLC
Stitch UAVSAR SLC stack of one track to form a consecutive SLC image for InSAR timeseries analysis (ISCE)  

This stitching workflow contains one C-Shell code and one Python code:  
1. `UAVSAR_coregStack_StitchSegments.csh` is the main script  
2. `MakeShelveData.py` is the sub-routine called in the main script

This code will create all the necessary files `prepareUAVSAR_coregStack.py` does  
So you can skip `prepareUAVSAR_coregStack.py` and carry on with `stackStripMap.py`  
  
UAVSAR SLC data can be downloaded via: https://uavsar.jpl.nasa.gov/cgi-bin/data.pl  

---
### UAVSAR_coregStack_StitchSegments.csh
Requires three input arguments
1. filelst (Containing all .slc filenames)
2. combined segments (e.g. combine segment 1 and 2, then put `12`. combine segment 2, 3 and 3, then put `234`)
3. Doppler file (Downloaded from NASA data portal)

---
### Arrange the placement of data and directories  


---
### How to use this code
#### For example: stitching segment 1 and 2 for UAVSAR track SanAnd_23017  
1. Download UAVSAR SLC data and put everything in one directory (e.g. `data/`)
2. Put both `UAVSAR_coregStack_StitchSegments.csh` and `MakeShelveData.py` to `data/`
3. Prepare input files for `UAVSAR_coregStack_StitchSegments.csh`
   ```shell
   cd data/
   ls *.slc > filelst
   ```
5. Execute the code:
   ```shell
   csh UAVSAR_coregStack_StitchSegments.csh filelst 12 SanAnd_23017_01_BC.dop
   ```
6. Create `merge/` and link `SLC/`
   ```shell
   cd ../
   mkdir merged
   cd merged
   ln -s ../SLC/
   cd ..
   ```
7. Carry on with `stackStripMap.py`
