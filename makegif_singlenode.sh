#!/bin/bash

#Example usage:

#makegif_singlenode.sh datatype
#datatype is: 3d-intfc 3d-curves etc.

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



CWD=`pwd`

export DATATYPE=$1

create_movie_index $DATATYPE

#The i is generated from the create_movie_index function 
export NUMFRAMES=$i
export MOVIEDIR="$CWD/movie_index"

JPGDIR="$MOVIEDIR/JPGs"
mkdir -p $JPGDIR
export JPGDIR

echo " ...saving animation"

pvbatch --use-offscreen-rendering ./pv_single_reader.py

GIFNAME="${CWD}/${DATATYPE}.gif"

echo "  ...creating $GIFNAME"

convert $JPGDIR/${DATATYPE}*.jpg $GIFNAME

echo "   ...done"

