#!/bin/sh

### Specify job arguements

#SBATCH -p bsudfq
#SBATCH -N 1
#SBATCH -n 48
#SBATCH -t 30-12:00:00
#SBATCH -o outfiles/%x-%j.out
#SBATCH -J naive_nn


### Get Matlab in loaded

module load borah-applications
module load matlab/r2020a


### Get dipendencies added to Matlab path

# MATLAB_TOOLS_PATH = "/home/mmerris/wares/matlab_tools"
# EXPR_SRC_PATH = "/home/mmerris/GCP_SWEEPS"
# matlab -nodisplay -nosplash -r "try, addlibrarypath(MATLAB_TOOLS_PATH, EXPR_SRC_PATH), catch me, fprintf('%s / %s\n',me.identifier,me.message), exit(1), end, exit(0)"

cd $PWD
CURRENTDATE=$( date +'%m-%d-%y-%H:%M:%S')
OUTFILE="/bsuhome/mmerris/scratch/rank_est_${CURRENTDATE}.txt"
matlab -nodisplay -nosplash -r  testing_estRank_approach >${OUTFILE}
