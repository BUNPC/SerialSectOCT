#!/bin/bash -l

#$ -l h_rt=24:00:00
#$ -pe omp 4
#$ -l mem_per_core=4G
#$ -N OCT_recon_30over
#$ -j y

module load matlab/2020b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; OCT_recon_30overlap; exit"

