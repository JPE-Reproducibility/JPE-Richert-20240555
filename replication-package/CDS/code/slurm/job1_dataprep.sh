#!/bin/bash
#SBATCH --job-name=cds_dataprep
#SBATCH --account=ssd
#SBATCH --partition=ssd
#SBATCH --qos=ssd
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=06:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --output=../../output/logs/job1_%j.out
#SBATCH --error=../../output/logs/job1_%j.err

# Job 1: Data Preparation (serial)
# Runs: bondpriceimport, data_summary, normalize_prices
# Runtime: ~1.5 hours (bondpriceimport dominates)
# Output: intermediate/maindata.mat, intermediate/for211.mat

module load matlab

cd $SLURM_SUBMIT_DIR/../..
matlab -nodisplay -nosplash -r "addpath('code/slurm'); job1_dataprep"
RC=$?

if [ $RC -eq 0 ]; then
    echo "Job 1 succeeded — submitting Job 2a"
    cd $SLURM_SUBMIT_DIR && sbatch job2a_estimation.sh
else
    echo "Job 1 FAILED (exit code $RC) — NOT submitting Job 2"
fi
