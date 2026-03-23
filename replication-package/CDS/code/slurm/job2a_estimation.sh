#!/bin/bash
#SBATCH --job-name=cds_est2a
#SBATCH --account=ssd
#SBATCH --partition=ssd
#SBATCH --qos=ssd
#SBATCH --nodes=1
#SBATCH --ntasks=21
#SBATCH --mem=128G
#SBATCH --time=10:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --output=../../output/logs/job2a_%j.out
#SBATCH --error=../../output/logs/job2a_%j.err

# Job 2a: npestimator + complex_bootstrap (step1 + CIs + step2)
# Saves pre_vcorrection.mat checkpoint; defers v_correction to Job 2b
# Runtime: ~7 hours (step1 ~6hrs, CIs+step2 ~30min)
# Requires: intermediate/for211.mat from Job 1
module load matlab

cd $SLURM_SUBMIT_DIR/../..
matlab -nodisplay -nosplash -r "addpath('code/slurm'); job2a_estimation"
RC=$?

if [ $RC -eq 0 ]; then
    echo "Job 2a succeeded — submitting Job 2b"
    cd $SLURM_SUBMIT_DIR && sbatch job2b_estimation.sh
else
    echo "Job 2a FAILED (exit code $RC) — NOT submitting Job 2b"
fi
