# Stitch_UAVSAR_SLC
Stitch UAVSAR SLC stack of one track to form a consecutive SLC image for InSAR timeseries analysis (ISCE)  

This stitching workflow contains one C-Shell code and one Python code:  
1. `UAVSAR_coregStack_StitchSegments.csh` is the main script  
2. `MakeShelveData.py` is the sub-routine called in the main script (Scratched from ISCE source codes)  

This code will create all the necessary files `prepareUAVSAR_coregStack.py` does  
So you can skip `prepareUAVSAR_coregStack.py` and carry on with `stackStripMap.py`  
See also: [UAVSAR processing workflow by Forrest Williams](https://github.com/forrestfwilliams/UAVSAR_InSAR).  

Make sure you have all ISCE and ISCE stack processor available in your working environment  

UAVSAR SLC data can be downloaded via: [UAVSAR Data Search](https://uavsar.jpl.nasa.gov/cgi-bin/data.pl).  

---
### UAVSAR_coregStack_StitchSegments.csh
Requires three input arguments
1. filelst (Containing all .slc filenames)
2. combined segments (e.g. combine segment 1 and 2, then put `12`, combine segment 2, 3 and 4, then put `234`)
3. Doppler file (Downloaded from NASA data portal)

---
### How to use this code
#### For example: stitching segment 1 and 2 for UAVSAR *track SanAnd_23017*  
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
6. Create `merged/` and link `SLC/`. also prepare your dem file in `dem/`
   ```shell
   cd ../
   mkdir merged
   cd merged
   ln -s ../SLC/
   cd ..
   mkdir dem
   cd dem
   ln -s /YOUR_DEM .
   cd ..
   ```
7. Carry on with `stackStripMap.py`

---  
Note that I did not seek to fully understand how ISCE processes and produces the files, as it is rather complicated.  
I just tried to piece them together and make it automatic for processing multiple tracks of SLCs.  
