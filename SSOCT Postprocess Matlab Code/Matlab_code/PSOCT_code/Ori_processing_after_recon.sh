#!/bin/bash -l

#$ -l h_rt=24:00:00
#$ -pe omp 2
#$ -N Ori_aft_recon
#$ -j y

module load matlab/2020b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; Ori_processing_after_recon; exit"