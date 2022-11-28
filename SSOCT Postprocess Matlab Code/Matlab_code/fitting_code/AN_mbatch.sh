#!/bin/bash -l

#$ -l h_rt=48:00:00
#$ -pe omp 12
#$ -N HumanBrain
#$ -j y

module load matlab/2018b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; AN_OCT_Scattering; exit"

