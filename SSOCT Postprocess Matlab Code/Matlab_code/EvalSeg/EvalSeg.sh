#!/bin/bash -l
#$ -l h_rt=12:00:00
#$ -N evalseg
#$ -j y
#$ -pe omp 12

cd /projectnb/npbssmic/s/Matlab_code/EvalSeg
/projectnb2/npbssmic/s/Matlab_code/EvalSeg/EvaluateSegmentation vol_label.tif vessel05115.tif -use all -thd 0.5 -xml /projectnb/npbssmic/s/Matlab_code/EvalSeg/200726PSOCT.xml
