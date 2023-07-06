#!/bin/bash -l

#$ -l h_rt=72:00:00
#$ -pe omp 4
#$ -N BRM_ori_RGB
#$ -l mem_per_core=16G
#$ -j y

module load matlab/2020b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; BRM_Gen_ori_RGB; exit"

