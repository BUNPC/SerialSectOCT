#!/bin/bash -l

#$ -l h_rt=24:00:00
#$ -pe omp 4
#$ -l mem_per_core=8G
#$ -N ROI_stitch
#$ -j y

module load matlab/2018b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; Ref_ROI_recon; exit"

