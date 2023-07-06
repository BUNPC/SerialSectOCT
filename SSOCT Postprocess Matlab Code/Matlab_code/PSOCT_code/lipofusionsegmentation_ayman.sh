#!/bin/bash -l

#$ -l h_rt=100:00:00
#$ -pe omp 8
#$ -l mem_per_core=4G
#$ -N lipofusionsegmentation_ayman
#$ -j y

module load matlab/2020b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; lipofusionsegmentation_ayman; exit"