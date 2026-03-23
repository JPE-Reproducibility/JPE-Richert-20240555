#!/bin/bash
#SBATCH --job-name=cds_post3c
#SBATCH --account=ssd
#SBATCH --partition=ssd
#SBATCH --qos=ssd
#SBATCH --nodes=1
#SBATCH --ntasks=21
#SBATCH --mem=128G
#SBATCH --time=11:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --output=../../output/logs/job3c_%j.out
#SBATCH --error=../../output/logs/job3c_%j.err

# Job 3c: Robustness CFs (3 runs) + tableOS6 + robustnesschecks
# Runtime: ~5 hrs (3 robustness CFs ~3.5 hrs, robustnesschecks ~1 hr)
module load matlab

cd $SLURM_SUBMIT_DIR/../..
matlab -nodisplay -nosplash -r "addpath('code/slurm'); job3c_postcfs"
RC=$?

if [ $RC -eq 0 ]; then
    echo "Job 3c succeeded — pipeline complete"
else
    echo "Job 3c FAILED (exit code $RC)"
fi
