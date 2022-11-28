#!/bin/bash -l

#$ -l h_rt=72:00:00
#$ -pe omp 2
#$ -N fit_aft_2
#$ -j y

module load matlab/2019b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; Fitting_after_recon_AB2; exit"