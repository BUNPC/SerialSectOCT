#!/bin/bash -l

#$ -l h_rt=48:00:00
#$ -pe omp 2
#$ -N move_data
#$ -j y

module load matlab/2020b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; move_data; exit"

