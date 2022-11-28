#!/bin/bash -l

#$ -l h_rt=24:00:00
#$ -pe omp 1
#$ -N ref_vol_stitch
#$ -j y

module load matlab/2018b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; OCT_ret_vol_stitch_from_AB; exit"

