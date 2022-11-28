#!/bin/bash -l

#$ -l h_rt=24:00:00
#$ -pe omp 2
#$ -N double_check
#$ -j y

module load matlab/2020b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; Double_check_tile_recon; exit"

