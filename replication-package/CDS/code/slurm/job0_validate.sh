#!/bin/bash
#SBATCH --job-name=cds_validate
#SBATCH --account=ssd
#SBATCH --partition=ssd
#SBATCH --qos=ssd
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=00:10:00
#SBATCH --output=../../output/logs/job0_%j.out
#SBATCH --error=../../output/logs/job0_%j.err

# Job 0: Quick validation (~1 min)
# Checks: MATLAB loads, data files exist, code files exist, paths work

module load matlab

cd $SLURM_SUBMIT_DIR/../..
matlab -nodisplay -nosplash -r "addpath('code/slurm'); job0_validate"
