#!/bin/bash -l

#$ -l h_rt=72:00:00
#$ -pe omp 4
#$ -N fit_NC
#$ -j y

module load matlab/2019b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; Fitting_NC; exit"

