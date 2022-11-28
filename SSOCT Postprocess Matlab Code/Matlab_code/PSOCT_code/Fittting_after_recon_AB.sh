#!/bin/bash -l

#$ -l h_rt=48:00:00
#$ -pe omp 4
#$ -N fit_aft_recon
#$ -j y

module load matlab/2019b
matlab -nodisplay -singleCompThread -r "Fitting_after_recon_AB; exit"

