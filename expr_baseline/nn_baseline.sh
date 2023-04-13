### Specify job arguements

#SBATCH -p defq
#SBATCH -N 8
#SBATCH -n 28
#SBATCH -t 01-12:00:00
#SBATCH -o %x-%j.out
#SBATCH -J naive_nn


### Get Matlab in loaded

module load r2-applications
module load 
module load matlab/r2021a


### Get dipendencies added to Matlab path

MATLAB_TOOLS_PATH = "/home/mmerris/wares/matlab_tools"
EXPR_SRC_PATH = "/home/mmerris/GCP_SWEEPS"
matlab -nodisplay -nosplash -r "try, addlibrarypath(MATLAB_TOOLS_PATH, EXPR_SRC_PATH), catch me, fprintf('%s / %s\n',me.identifier,me.message), exit(1), end, exit(0)"
matlab -nodisplay -nosplash -r -softwareopengl < /home/mmerris/GCP_SWEEP/expr_baseline/nn_baseline_naive_r2.m > /home/mmerris/scratch/out_nn_%j.txt
