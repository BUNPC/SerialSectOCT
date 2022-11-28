#!/bin/bash -l

#$ -P npbssmic
#$ -pe omp 16
#$ -l mem_per_core=16G
#$ -m ea
#$ -N vessel_seg
#$ -j y

module load matlab/2019b
matlab -nodisplay -singleCompThread -r "vesSeg_script2; exit"

