#numnodes = numnodes + 1 #Since NUMNODES - 1 occurs in mnode.sh
#!/bin/bash

#Want to eventually integrate this into Frontier
#Eventually --> Give inputs to change camera angle
#Example usage: makegif_multinode.sh
#datatype is: 3d-intfc 3d-curves etc.
#Node input is one less than actual (8 nodes = input of 7)

function create_movie_index_multinode()
{

    #N=i1
    #if [ "$#" -ne 1 ]; then
        #N=$NUMNODES
    #fi 

    filename=$1
    directory_name="movie_index"
    if [ -d "$directory_name" ]; then 
        rm -rf $directory_name
    fi

    mkdir $directory_name

    echo "...creating movie index for $filename"
    for nd in `seq -f "nd%04g" 0 $FUNC_NUMNODES`; do
        i=0;
        for file in *$nd; do
            i=`expr $i + 1`
            ln -P ${file}/${filename}.vtk ./${directory_name}/${filename}${nd}-${i}.vtk
        done
    done

}


CWD=`pwd`

export DATATYPE=$1
export REAL_NUMNODES=$2

#NUMNODES CALCULATION FOR FUNCTION USE
export FUNC_NUMNODES=$(($2 - 1))

#Default: Starting position is (0,0,1), aligned at -90 degrees from positive Z 
HORIZ_CAM=$3

#TODO: CHECK FOR NUMBER FOR $3 and $4
declare -i HORIZ_CAM #declare integer

export HORIZ_CAM=$((-90 - $3)) #Degrees around Z-axis (theta), correct P.view default

#Get user input, this is wrt to the positive Z axis, this is phi
raw_vert_cam=$4
declare -i raw_vert_cam #declare integer


if [ "$raw_vert_cam" -ge "88" ] && [ "$raw_vert_cam" -le "90" ]; then
    raw_vert_cam=$(($(($raw_vert_cam))-3))
fi 

if [ "$raw_vert_cam" -ge "91" ] && [ "$raw_vert_cam" -le "92" ]; then
    raw_vert_cam=$(($(($raw_vert_cam))+2))
fi 


if [ "$raw_vert_cam" -le "90" ]; then #if <90, P.view treats it wrong, need to correct
    raw_vert_cam=$(($(($raw_vert_cam))*-1))
fi

#Corrected phi is <90, otherwise treated as the input itself
export VERT_CAM=$raw_vert_cam #Degrees off of Z-axis (phi)

create_movie_index_multinode $DATATYPE $NUMNODES

#The i is generated from the create_movie_index function
export NUMFRAMES=$i
export MOVIEDIR="$CWD/movie_index"

JPGDIR="$MOVIEDIR/JPGs"
mkdir -p $JPGDIR
export JPGDIR

echo " ...saving animation"

#Need to change the forfiles.py for multinode function
pvbatch --use-offscreen-rendering ./pv_multiple_readers.py

GIFNAME="${CWD}/${DATATYPE}.gif"

echo "  ...creating $GIFNAME"

convert $JPGDIR/${DATATYPE}*.jpg $GIFNAME

echo "   ...done"




