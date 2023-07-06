#!/bin/bash -l

#$ -l h_rt=100:00:00
#$ -pe omp 8
#$ -l mem_per_core=4G
#$ -N fireimage_generation
#$ -j y

module load matlab/2020b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; Fireimage_generation_ayman; exit"