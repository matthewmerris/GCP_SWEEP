### Specify job arguements

#SBATCH -p defq
#SBATCH -N 8
#SBATCH -n 28
#SBATCH -t 01-12:00:00
#SBATCH -o %x-%j.out
#SBATCH -J naive_nn

###
module load r2-applications
module load 
module load matlab/r2021a
