#!/bin/bash -l

#$ -l h_rt=12:00:00
#$ -pe omp 4
#$ -N co_cross_stitch
#$ -l mem_per_core=32G
#$ -j y

module load matlab/2020b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; co_cross_stitch_wrap; exit"

