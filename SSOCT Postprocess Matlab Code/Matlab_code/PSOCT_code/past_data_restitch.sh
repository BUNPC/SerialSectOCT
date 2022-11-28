#!/bin/bash -l

#$ -l h_rt=12:00:00
#$ -pe omp 4
#$ -N past_restitch
#$ -j y

module load matlab/2018b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; past_data_restitch; exit"

