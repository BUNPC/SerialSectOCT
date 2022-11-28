#!/bin/bash -l

#$ -l h_rt=72:00:00
#$ -pe omp 12
#$ -l mem_per_core=8G
#$ -N stitch_BRM
#$ -j y

module load matlab/2020b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; stitching3D_BRM; exit"

