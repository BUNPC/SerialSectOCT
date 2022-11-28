#!/bin/bash -l

#$ -l h_rt=12:00:00
#$ -pe omp 8
#$ -N Recon_2P_tmp
#$ -j y

module load matlab/2020b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; Recon_2P_tmp; exit"
