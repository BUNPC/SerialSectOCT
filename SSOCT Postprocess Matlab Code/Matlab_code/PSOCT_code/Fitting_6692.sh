#!/bin/bash -l

#$ -l h_rt=72:00:00
#$ -pe omp 4
#$ -N fit_6692
#$ -j y

module load matlab/2019b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; Fitting_6692; exit"

