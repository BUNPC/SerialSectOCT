#!/bin/bash -l

#$ -l h_rt=24:00:00
#$ -pe omp 4
#$ -N cerebellum
#$ -j y

module load matlab/2019b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; Fitting_cerebellum; exit"

