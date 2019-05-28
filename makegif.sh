#!/bin/bash

#Want to eventually integrate this into Frontier
#Eventually --> Give inputs to change camera angle
#Example usage: makegif_multinode.sh
#datatype is: 3d-intfc 3d-curves etc.
#Node input is one less than actual (8 nodes = input of 7)

function create_movie_index()
{
    filename=$1
    dname="movie_index"
    if [ -d "$dname" ]; then
        rm -rf $dname
    fi

    mkdir $dname

    i=0
    echo "...creating movie index for $filename"
    for tsdir in vtk.ts*; do
        i=`expr $i + 1`
        ln -P ${tsdir}/${filename}.vtk ./${dname}/${filename}-${i}.vtk
    done
}

function singlenodegif()
{

CWD=`pwd`

export DATATYPE=$1

HORIZ_CAM=$2

#TODO: CHECK FOR NUMBER FOR $2 and $3
declare -i HORIZ_CAM #declare integer

export HORIZ_CAM=$((-90 - $2)) #Degrees around Z-axis (theta), correct P.view default

#Get user input, this is wrt to the positive Z axis, this is phi
raw_vert_cam=$3
#declare -i raw_vert_cam #declare integer

if [[ "$raw_vert_cam" -ge "88" && "$raw_vert_cam" -le "90" ]]; then
    raw_vert_cam=$(($(($raw_vert_cam))-3))
fi 

if [[ "$raw_vert_cam" -ge "91" && "$raw_vert_cam" -le "92" ]]; then
    raw_vert_cam=$(($(($raw_vert_cam))+2))
fi 


if [[ "$raw_vert_cam" -le "90" ]]; then #if <90, P.view treats it wrong, need to correct
    raw_vert_cam=$(($(($raw_vert_cam))*-1))
fi

#Corrected phi is <90, otherwise treated as the input itself
export VERT_CAM=$raw_vert_cam #Degrees off of Z-axis (phi)

create_movie_index $DATATYPE

#The i is generated from the create_movie_index function
export NUMFRAMES=$i
export MOVIEDIR="$CWD/movie_index"

JPGDIR="$MOVIEDIR/JPGs"
mkdir -p $JPGDIR
export JPGDIR

echo " ...saving animation"

pvbatch --use-offscreen-rendering ~/bin/pv_single_reader.py

GIFNAME="${CWD}/${DATATYPE}.gif"

echo "  ...creating $GIFNAME"

convert $JPGDIR/${DATATYPE}*.jpg $GIFNAME

echo "   ...done"

}


function create_movie_index_multinode()
{
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

function multinodegif()
{    

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
#declare -i raw_vert_cam #declare integer

if [[ "$raw_vert_cam" -ge "88" && "$raw_vert_cam" -le "90" ]]; then
    raw_vert_cam=$(($(($raw_vert_cam))-3))
fi 

if [[ "$raw_vert_cam" -ge "91" && "$raw_vert_cam" -le "92" ]]; then
    raw_vert_cam=$(($(($raw_vert_cam))+2))
fi 


if [[ "$raw_vert_cam" -le "90" ]]; then #if <90, P.view treats it wrong, need to correct
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
pvbatch --use-offscreen-rendering ~/bin/pv_multiple_readers.py

GIFNAME="${CWD}/${DATATYPE}.gif"

echo "  ...creating $GIFNAME"

convert $JPGDIR/${DATATYPE}*.jpg $GIFNAME

echo "   ...done"

}


#This script calls the proper gif maker based on command line arguments
#Single node files should have 3 command line arguments (type, theta, phi)
#TODO: Single node files only have 1 argument right now...need to add angles
#Only multi node files should have 4 args (type, nodes, theta, phi)

if [ "$#" -eq 3 ]; then
    echo "Single node file detected"
    singlenodegif $1 $2 $3
fi 

if [ "$#" -eq 4 ]; then
    echo "Multi node file detected"
    multinodegif $1 $2 $3 $4
fi 

if [ "$#" -ne 3 ] && [ "$#" -ne 4 ]; then
    echo "Invalid parameters"
    echo "Gif creation failure."
fi 

