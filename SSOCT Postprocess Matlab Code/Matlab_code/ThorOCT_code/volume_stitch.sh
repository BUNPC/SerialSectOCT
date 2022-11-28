#!/bin/bash -l

#$ -l h_rt=12:00:00
#$ -pe omp 8
#$ -N volume_stitch
#$ -j y

module load matlab/2018b
matlab -nodisplay -singleCompThread -r "stitch_volume; exit"

