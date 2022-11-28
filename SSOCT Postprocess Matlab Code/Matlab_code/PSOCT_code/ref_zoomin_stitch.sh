#!/bin/bash -l

#$ -l h_rt=24:00:00
#$ -pe omp 4
#$ -l mem_per_core=16G
#$ -N zoomin_stitch
#$ -j y

module load matlab/2020b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; ref_zoomin_stitch; exit"

