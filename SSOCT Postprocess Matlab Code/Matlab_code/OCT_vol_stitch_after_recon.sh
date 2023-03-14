#!/bin/bash -l

#$ -l h_rt=24:00:00
#$ -pe omp 2
#$ -l mem_per_core=4G
#$ -N vol_stitch
#$ -j y

module load matlab/2018b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; OCT_vol_stitch_after_recon; exit"

