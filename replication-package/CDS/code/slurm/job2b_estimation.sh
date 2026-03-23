#!/bin/bash
#SBATCH --job-name=cds_est2b
#SBATCH --account=ssd
#SBATCH --partition=ssd
#SBATCH --qos=ssd
#SBATCH --nodes=1
#SBATCH --ntasks=21
#SBATCH --mem=128G
#SBATCH --time=06:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --output=../../output/logs/job2b_%j.out
#SBATCH --error=../../output/logs/job2b_%j.err

# Job 2b: v_correction + pe_outputs
# Loads pre_vcorrection.mat (or recovers from bsinprogressCCC.mat)
# Runtime: ~4 hours (v_correction ~3.5hrs, pe_outputs ~1min)
# Output: intermediate/smc_cfs_np.mat
module load matlab

cd $SLURM_SUBMIT_DIR/../..
matlab -nodisplay -nosplash -r "addpath('code/slurm'); job2b_estimation"
RC=$?

if [ $RC -eq 0 ]; then
    echo "Job 2b succeeded — submitting Job 3a"
    cd $SLURM_SUBMIT_DIR && sbatch job3a_postcfs.sh
else
    echo "Job 2b FAILED (exit code $RC) — NOT submitting Job 3a"
fi
