#!/bin/bash -l

#$ -l h_rt=48:00:00
#$ -pe omp 4
#$ -N Hui_Sup
#$ -j y

module load matlab/2019b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; Fitting_Hui_SupFrontal; exit"

