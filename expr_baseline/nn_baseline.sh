#!/bin/sh

### Specify job arguements

#SBATCH -p defq
#SBATCH -N 1
#SBATCH -n 28
#SBATCH -t 01-12:00:00
#SBATCH -o outfiles/%x-%j.out
#SBATCH -J naive_nn


### Get Matlab in loaded

module load r2-applications
module load matlab/r2021a


### Get dipendencies added to Matlab path

# MATLAB_TOOLS_PATH = "/home/mmerris/wares/matlab_tools"
# EXPR_SRC_PATH = "/home/mmerris/GCP_SWEEPS"
# matlab -nodisplay -nosplash -r "try, addlibrarypath(MATLAB_TOOLS_PATH, EXPR_SRC_PATH), catch me, fprintf('%s / %s\n',me.identifier,me.message), exit(1), end, exit(0)"

cd $PWD
CURRENTDATE='date +"%m-%d-%y-%H:%M:%S"'
OUTFILE="/home/mmerris/scratch/out_nn_"+"%{CURRENTDATE}"+".txt"
matlab -nodisplay -nosplash -r  nn_baseline_naive_r2 >${OUTFILE}
