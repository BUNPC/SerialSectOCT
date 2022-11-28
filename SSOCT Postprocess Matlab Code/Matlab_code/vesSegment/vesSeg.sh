#!/bin/bash -l

#$ -P npbssmic
#$ -pe omp 28
#$ -l mem_per_core=13G
#$ -m ea
#$ -l h_rt=24:00:00
#$ -N vessel_segmentation
#$ -j y

module load matlab/2020b
matlab -nodisplay -singleCompThread -r "vesSeg_script; exit"

