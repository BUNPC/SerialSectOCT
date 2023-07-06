#!/bin/bash -l

#$ -l h_rt=24:00:00
#$ -pe omp 4
#$ -N BRM_ori_stitch
#$ -l mem_per_core=16G
#$ -j y

module load matlab/2020b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; BRM_ori_stitch; exit"

