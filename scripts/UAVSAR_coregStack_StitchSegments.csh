#!/bin/csh
####################################################################
#                                     				   #
# 		University of California, Riverside 		   #
# 				      				   #
#    		   Earth and Planetary Sciences     		   #
#				      				   #
#            		   Li-Chieh Lin	      		 	   #
#             		    2024.02.27	       		 	   #
#                                     				   #
# (2024.03.04)			      				   #
# Update: Make .vrt and .xml based on ISCE code not from templates #
####################################################################
# Files required:
# 1. filelist: SLC files that need to be stitched
# 2. segments: what segments to be stitched
# 3. doppler: The raw doppler file .dop

if ($#argv != 3) then
  echo ""
  echo "-This is code stitch consecutive segments of UAVSAR SLCs obtaied from NASA UAVSAR data portal"
  echo "   URL: https://uavsar.jpl.nasa.gov/cgi-bin/data.pl"
  echo ""
  echo ""
  echo "-Input parameter:"
  echo " #1 argument: To-be-stitched SLC names stored in a text file"
  echo " #2 argument: The segments that need stitching"
  echo "   e.g. segment 2 and 3 needs to be stitched, then put 23"
  echo ""
  echo "-The program will create a directory called SLC/ above the current working directory"
  echo ""
  echo "-Execute this code where the SLCs are"
  echo "Usage: csh UAVSAR_coregStack_StitchSegments.csh filelst 23 SanAnd_23019_01_BC.dop"
  echo ""
  exit 1
endif


set filelst = `echo $1`
set segments = `echo $2`
set dop = `echo $3`
set PWD = `pwd`

##### Make SLC/ directory #####
if (! -d ../SLC/) then
  mkdir ../SLC
endif


##### Report input files and parameters #####
echo "" 
echo "--- Files to be stitched segement-by-segment ---"
cat $filelst
echo "--- Stitch segment $segments ---"

set date_pre = 000000 
foreach slc (`cat $filelst`)
##### Concatenate SLC segments into one #####
set date = `echo $slc | awk -F_ '{print $5}'`


if ($date_pre == $date) then
  continue
else

echo ""
echo "##### Date: $date #####"

# Find SLCs on the same date
  set slc = `cat $filelst | awk -F_ '{if ($5==date) {print $0}}' date=$date`
  set slc_prefix = `echo $slc | awk '{print $1}' | awk -F_ '{print $1"_"$2"_"$3"_"$4"_"$5"_"$6"_"$7"_"$8}'`
  set slc_suffix = `echo $slc | awk '{print $1}' | awk -F_ '{print $10}'`

# Stitch SLCs
  echo "# SLCs to be stiched:"
  echo $slc
  echo ""
  echo "# Stitched SLC name:"
  echo ${slc_prefix}_s${segments}_${slc_suffix}
  echo ""
  echo "### Stiching... "
  cat $slc > ${slc_prefix}_s${segments}_${slc_suffix}
  echo ""

# Get the year for the stitched SLC file name and directory name
  set ann = `echo ${slc_prefix}.ann`
  set year = `cat $ann | grep "Start Time of Acquisition" | awk '{print $7}' | awk -F- '{print $3}'`
  set datetmp = `echo $date | rev | cut -c 1-4 | rev`
  set SLCdir = `echo $year$datetmp`
  if (! -d ../SLC/$SLCdir) then
    mkdir ../SLC/$SLCdir
  endif 

  cd ../SLC/
  set SLCstore = `pwd`
  set SLCxml = `echo ${SLCstore}/${SLCdir}/${SLCdir}.slc`
  cd $PWD
  

# Get the Rows and Columns
  set Multilook = `echo ${slc_suffix} | awk -F. '{print $1}'`

  echo "# Fetch Columns and Rows of SLCs..."
  set len = `echo $segments | awk '{print length($0)}'`
  @ i = 0
  set Y = `seq 1 1 $len`
  foreach num (`seq 1 1 $len`)
    @ i += 1
    set seg = `echo $segments | cut -c $i`
    set X = `cat $ann | grep "slc_${seg}_${Multilook} Columns" | awk '{print $5}'`
    set Y[$i] = `cat $ann | grep "slc_${seg}_${Multilook} Rows" | awk '{print $5}'`
    echo "SLC$i Columns (X): $X | Rows (Y): $Y[$i]"
  end
    set Y_sum = `echo $Y | sed 's/ /+/g' | bc -l`
    echo ""
    echo "Combined Rows (Y): $Y_sum"


# Pipe external Python script to make necessary files for later run_files
# Make a new .ann file which contains the length and width information of combined SLCs
# This is important since the dimension of waterMask will be made upon the segment read in
  echo ""
  echo "### Making data.bak, data.dir and data.dat using external python script scratched from ISCE"
  set output = `echo ${SLCstore}/${SLCdir}`
 
# Copy a new .ann to modify 
  set ann_comb = `echo ${slc_prefix}_s${segments}.ann`
  set seg_start = `echo $segments | cut -c 1` 
  set seg_end = `echo $segments | rev | cut -c 1`
  set mag_col_addr = `cat $ann | grep "slc_${seg_start}_1x1_mag.col_addr" | awk '{print $4}'`
  # It seems all segments share the same value of mag.col_addr
  set Starting_Azimuth = `cat $ann | grep "Segment ${seg_start} Data Starting Azimuth" | awk '{print $8}'`
  set Approx_Corner1 = `cat $ann | grep "Segment ${seg_start} Data Approximate Corner 1" | awk '{print $9,"",$10}'`
  set Approx_Corner2 = `cat $ann | grep "Segment ${seg_start} Data Approximate Corner 2" | awk '{print $9,"",$10}'`
  set Approx_Corner3 = `cat $ann | grep "Segment ${seg_end} Data Approximate Corner 3" | awk '{print $9,"",$10}'`
  set Approx_Corner4 = `cat $ann | grep "Segment ${seg_end} Data Approximate Corner 4" | awk '{print $9,"",$10}'`
  
  cp $ann $ann_comb
  echo "" >> $ann_comb
  echo "" >> $ann_comb
  echo "; Length and Width information of combined segments of SLCs" >> $ann_comb
  echo "" >> $ann_comb
  echo "; File size parameters" >> $ann_comb
  echo "" >> $ann_comb
  echo "slc_${segments}_1x1 Columns                                        (pixels)        = $X                   ; samples in SLC 1x1 segment $segments" >> $ann_comb
  echo "slc_${segments}_1x1 Rows                                           (pixels)        = $Y_sum                  ; lines in SLC 1x1 segment $segments" >> $ann_comb
  echo "" >> $ann_comb
  echo "" >> $ann_comb
  echo "set name" >> $ann_comb
  echo "slc_${segments}_1x1_mag.set_rows                                   (pixels)        = $Y_sum                  ; SLC lines" >> $ann_comb
  echo "slc_${segments}_1x1_mag.set_cols                                   (pixels)        = $X                   ; SLC samples" >> $ann_comb
  echo "slc_${segments}_1x1_mag.col_addr                                   (m)             = $mag_col_addr            ; cross track offset from peg (C0)" >> $ann_comb
  echo "Segment ${segments} Data Starting Azimuth                          (m)             = $Starting_Azimuth" >> $ann_comb
  echo "Segment ${segments} Data Approximate Corner 1                      (&)             = $Approx_Corner1       ; latitude, longitude in decimal degrees" >> $ann_comb
  echo "Segment ${segments} Data Approximate Corner 2                      (&)             = $Approx_Corner2       ; latitude, longitude in decimal degrees" >> $ann_comb
  echo "Segment ${segments} Data Approximate Corner 3                      (&)             = $Approx_Corner3       ; latitude, longitude in decimal degrees" >> $ann_comb
  echo "Segment ${segments} Data Approximate Corner 4                      (&)             = $Approx_Corner4       ; latitude, longitude in decimal degrees" >> $ann_comb
  mv ${slc_prefix}_s${segments}_${slc_suffix} $SLCdir.slc
  mv $SLCdir.slc $SLCstore/$SLCdir
  python MakeShelveData.py -a $ann_comb -d $dop -s $segments -o $output -S $SLCstore/$SLCdir/$SLCdir.slc

  mv $ann_comb $SLCstore/$SLCdir

set date_pre = `echo $date`
endif

echo "" 
end

echo "-------------------------------------"
echo "prepareUAVSAR_coregStack.py is done"
echo "Proceed to stackStripMap.py"
echo "-------------------------------------"


