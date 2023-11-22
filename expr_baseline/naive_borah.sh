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
module load matlab/r2023b


cd $PWD
CURRENTDATE=$( date +'%m-%d-%y-%H:%M:%S')
OUTFILE="/bsuhome/mmerris/scratch/out_nn_${CURRENTDATE}.txt"
# matlab -nodisplay -nosplash -r  nn_baseline_naive >${OUTFILE}
matlab -nodisplay -nosplash -r  nn_baseline_naive_parfor 
