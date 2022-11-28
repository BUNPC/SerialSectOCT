#!/bin/bash -l

#$ -l h_rt=24:00:00
#$ -pe omp 4
#$ -N ret_depth
#$ -j y

module load matlab/2020b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; ret_depth_resolve; exit"

