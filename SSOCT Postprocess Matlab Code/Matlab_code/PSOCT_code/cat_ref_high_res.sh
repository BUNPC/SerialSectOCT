#!/bin/bash -l

#$ -P npbssmic
#$ -l h_rt=24:00:00
#$ -pe omp 36
#$ -m ea
#$ -N concat_ref_in_high_res
#$ -j y

cd /projectnb/npbssmic/s/Matlab_code/PSOCT_code
module load matlab/2019b
matlab -nodisplay -singleCompThread -r "Concat_ref_high_res_vol(156,'/projectnb/npbssmic/ns/210104_2x2x2cm_BA44_45/'); exit"

