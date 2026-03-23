#!/bin/bash
#SBATCH --job-name=cds_post3a
#SBATCH --account=ssd
#SBATCH --partition=ssd
#SBATCH --qos=ssd
#SBATCH --nodes=1
#SBATCH --ntasks=21
#SBATCH --mem=128G
#SBATCH --time=06:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --output=../../output/logs/job3a_%j.out
#SBATCH --error=../../output/logs/job3a_%j.err

# Job 3a: postestimation_clean + CF runs 1-2
# Runtime: ~2.5 hrs (postestimation ~5 min, CF1 ~1:20, CF2 ~0:45)
module load matlab

cd $SLURM_SUBMIT_DIR/../..
matlab -nodisplay -nosplash -r "addpath('code/slurm'); job3a_postcfs"
RC=$?

if [ $RC -eq 0 ]; then
    echo "Job 3a succeeded — submitting Job 3b"
    cd $SLURM_SUBMIT_DIR && sbatch job3b_postcfs.sh
else
    echo "Job 3a FAILED (exit code $RC) — NOT submitting Job 3b"
fi
