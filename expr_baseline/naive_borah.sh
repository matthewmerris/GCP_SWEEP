#!/bin/sh

### Specify job arguements

#SBATCH -p bsudfq
#SBATCH -N 1
#SBATCH -n 48
#SBATCH -t 01-12:00:00
#SBATCH -o outfiles/%x-%j.out
#SBATCH -J naive_nn


### Get Matlab in loaded

module load borah-applications
module load matlab/r2020a


### Get dipendencies added to Matlab path
expr_directory="/bsuhome/mmerris/GCP_SWEEP"
expr_dir_with_subs=$(find "$expr_directory" - type d | tr '\n' ':')
export MATLABPATH=$expr_dir_with_subs$MATLABPATH

tools_directory="/bsuhome/mmerris/wares/matlab_tools/active"
tool_path_with_subs=$(find "$tools_directory" -type d | tr '\n' ':')
export MATLABPATH=$tool_path_with_subs$MATLABPATH

cd $PWD
CURRENTDATE=$( date +'%m-%d-%y-%H:%M:%S')
OUTFILE="/bsuhome/mmerris/scratch/out_nn_${CURRENTDATE}.txt"
matlab -nodisplay -nosplash -r  nn_baseline_naive_borah_rand_init >${OUTFILE}  1 #!/bin/sh
