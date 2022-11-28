#!/bin/bash -l

#$ -l h_rt=1:00:00
#$ -pe omp 4
#$ -N ret_vol_stitch
#$ -j y

module load matlab/2018b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; ret_volume_stitch; exit"

