#!/bin/bash
#SBATCH --job-name=cds_post3b
#SBATCH --account=ssd
#SBATCH --partition=ssd
#SBATCH --qos=ssd
#SBATCH --nodes=1
#SBATCH --ntasks=21
#SBATCH --mem=128G
#SBATCH --time=06:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --output=../../output/logs/job3b_%j.out
#SBATCH --error=../../output/logs/job3b_%j.err

# Job 3b: CF runs 3-4 + postmain_cfs (Table 5)
# Runtime: ~1.5 hrs (2 CF runs ~40 min each, postmain_cfs ~1 min)
module load matlab

cd $SLURM_SUBMIT_DIR/../..
matlab -nodisplay -nosplash -r "addpath('code/slurm'); job3b_postcfs"
RC=$?

if [ $RC -eq 0 ]; then
    echo "Job 3b succeeded — submitting Job 3c"
    cd $SLURM_SUBMIT_DIR && sbatch job3c_postcfs.sh
else
    echo "Job 3b FAILED (exit code $RC) — NOT submitting Job 3c"
fi
