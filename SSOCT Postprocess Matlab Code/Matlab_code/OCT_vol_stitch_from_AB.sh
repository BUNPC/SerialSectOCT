#!/bin/bash -l

#$ -l h_rt=48:00:00
#$ -pe omp 4
#$ -N vol_stitch
#$ -j y

module load matlab/2018b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; OCT_vol_stitch_from_AB; exit"

