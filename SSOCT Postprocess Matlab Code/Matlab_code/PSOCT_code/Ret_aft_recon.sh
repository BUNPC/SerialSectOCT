#!/bin/bash -l

#$ -l h_rt=48:00:00
#$ -pe omp 4
#$ -N Ret_aft_recon
#$ -j y

module load matlab/2020b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; Ret_processing_after_recon; exit"

