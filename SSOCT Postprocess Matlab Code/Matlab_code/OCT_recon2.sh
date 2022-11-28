#!/bin/bash -l

#$ -l h_rt=72:00:00
#$ -pe omp 4
#$ -l mem_per_core=8G
#$ -N OCT_recon
#$ -j y

module load matlab/2020b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; OCT_recon2; exit"

