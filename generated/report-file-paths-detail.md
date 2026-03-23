## Filepaths Analysis Details

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/datacleaning/bondprices.m**

- Line 23, unix : %column for each day plus/minus

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/slurm/job1_dataprep.sh**

- Line 1, unix : #!/bin/bash
- Line 12, unix : #SBATCH --output=../../output/logs/job1_%j.out
- Line 13, unix : #SBATCH --error=../../output/logs/job1_%j.err
- Line 18, unix : # Output: intermediate/maindata.mat, intermediate/for211.mat

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/datacleaning/acrossrounds.m**

- Line 110, unix : %their noi/auction noi their imm/auction imm/ auction price/max bid,

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/computation/evalkspdf_num.m**

- Line 23, windows : fprintf('Kernel choice not defined or spelt wrong\n')

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/slurm/job2b_estimation.sh**

- Line 1, unix : #!/bin/bash
- Line 11, unix : #SBATCH --output=../../output/logs/job2b_%j.out
- Line 12, unix : #SBATCH --error=../../output/logs/job2b_%j.err
- Line 17, unix : # Output: intermediate/smc_cfs_np.mat

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/computation/cdf_estimator.m**

- Line 34, unix : % 1. probability of a yd that is negative/positive

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/slurm/job1_dataprep.m**

- Line 3, unix : % Saves: intermediate/maindata.mat, intermediate/for211.mat
- Line 44, windows : fprintf('Started: %s\n\n', datestr(now));
- Line 47, windows : fprintf('--- bondpriceimport ---\n');
- Line 50, mixed : fprintf('  bondpriceimport: %.1f min\n\n', toc/60);
- Line 53, windows : fprintf('--- data_summary ---\n');
- Line 58, windows : fprintf('  data_summary: %.1f sec\n\n', toc(t1));
- Line 63, windows : fprintf('--- normalize_prices ---\n');
- Line 66, windows : fprintf('  normalize_prices: %.1f sec\n\n', toc(t2));

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/slurm/job2a_estimation.sh**

- Line 1, unix : #!/bin/bash
- Line 11, unix : #SBATCH --output=../../output/logs/job2a_%j.out
- Line 12, unix : #SBATCH --error=../../output/logs/job2a_%j.err
- Line 17, unix : # Requires: intermediate/for211.mat from Job 1

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/computation/evalkspdf_denom.m**

- Line 23, windows : fprintf('Kernel choice not defined or spelt wrong\n')

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/datacleaning/bondpriceimport.m**

- Line 89, unix : %compare within/across bond cusips: try to get a reference for CTD vs

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/slurm/job0_validate.m**

- Line 5, windows : fprintf('Host: %s\n', getenv('HOSTNAME'));
- Line 6, windows : fprintf('PWD:  %s\n', pwd);
- Line 7, windows : fprintf('Date: %s\n\n', datestr(now));
- Line 17, windows : fprintf('--- Data files (%s) ---\n', data_path);
- Line 24, windows : fprintf('  FAIL %-35s NOT FOUND\n', data_files{i});
- Line 30, windows : fprintf('\n--- Code directories ---\n');
- Line 31, unix : code_dirs = {'code/computation', 'code/datacleaning', 'code/estimation', ...
- Line 32, unix : 'code/postestimation', 'code/cfs'};
- Line 39, windows : fprintf('  FAIL %-30s NOT FOUND\n', code_dirs{i});
- Line 45, windows : fprintf('\n--- Critical code files ---\n');
- Line 46, unix : critical = {'code/datacleaning/bondpriceimport.m', ...
- Line 47, unix : 'code/datacleaning/data_summary.m', ...
- Line 48, unix : 'code/datacleaning/normalize_prices.m', ...
- Line 49, unix : 'code/estimation/npestimator.m', ...
- Line 50, unix : 'code/estimation/complex_bootstrap.m', ...
- Line 51, unix : 'code/estimation/complex_estimator_step1.m', ...
- Line 52, unix : 'code/estimation/complex_estimator_step2.m', ...
- Line 53, unix : 'code/estimation/complex_estimator_step2b.m', ...
- Line 54, unix : 'code/estimation/v_correction.m', ...
- Line 55, unix : 'code/estimation/complex_bootstrap_pe_outputs.m', ...
- Line 56, unix : 'code/postestimation/postestimation_clean.m', ...
- Line 57, unix : 'code/postestimation/robustnesschecks.m', ...
- Line 58, unix : 'code/cfs/smc_cfs_yin.m', ...
- Line 59, unix : 'code/cfs/postmain_cfs.m', ...
- Line 60, unix : 'code/computation/nearestSPD.m'};
- Line 64, windows : fprintf('  OK  %s\n', critical{i});
- Line 66, windows : fprintf('  FAIL %s NOT FOUND\n', critical{i});
- Line 72, windows : fprintf('\n--- Output directory ---\n');
- Line 85, windows : fprintf('  OK  output/ writable\n');
- Line 88, windows : fprintf('\n--- MATLAB toolboxes ---\n');
- Line 94, windows : fprintf('  OK  %s\n', needed{i});
- Line 104, windows : fprintf('  OK  parpool creation works\n');
- Line 106, windows : fprintf('  FAIL parpool: %s\n', e.message);
- Line 111, windows : fprintf('\n--- Quick data load test ---\n');
- Line 114, windows : fprintf('  OK  auctionlistid.csv: %d rows, %d cols\n', size(t,1), size(t,2));
- Line 116, windows : fprintf('  FAIL %s\n', e.message);
- Line 123, windows : fprintf('  ALL CHECKS PASSED — safe to submit jobs\n');
- Line 125, windows : fprintf('  %d CHECKS FAILED — fix before submitting\n', nfail);
- Line 133, windows : fprintf('  %s line %d\n', e.stack(1).file, e.stack(1).line);
- Line 139, unix : s = sprintf('%.1f GB', b/1e9);
- Line 141, unix : s = sprintf('%.1f MB', b/1e6);
- Line 143, unix : s = sprintf('%.1f KB', b/1e3);

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/computation/BsplineEval3.m**

- Line 14, unix : %contain the first, second, and/or third derivatives of f at the points in

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/datacleaning/debug_bondforestimation.m**

- Line 27, unix : % Check if varvol/totalvol vary within auction
- Line 29, windows : fprintf('    varvol varies within auction: %s\n', mat2str(rows.varvol'));
- Line 32, windows : fprintf('    totalvol varies within auction: %s\n', mat2str(rows.totalvol'));
- Line 56, windows : fprintf('    mat_years: %s\n', mat2str(mat_years', 4));
- Line 57, windows : fprintf('    mature_year: %s\n', mat2str(rows.mature_year'));
- Line 58, windows : fprintf('    T column: %s\n', mat2str(rows.T'));
- Line 61, windows : fprintf('    simple (mature_year - auction_year): %s\n', mat2str(simple_mat'));
- Line 62, windows : fprintf('    ref might be: max(simple)=%d min(simple)=%d\n', max(simple_mat), min(simple_mat));

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/cfs/smc_cfs_yin.m**

- Line 237, unix : %accept/reject
- Line 254, windows : if mod(j,25)==0; fprintf('  SMC stage %d/%d, accept=%.2f\n', j, J, AA(j)); end
- Line 323, windows : fprintf('\n--- CF Results: sell_limit=%d, sfrac=%d, positionschange=%d ---\n', round(sell_limit), sfrac, positionschange)

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/computation/table2latex.m**

- Line 25, unix : %   Date:    09/10/2018                                                   %

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/slurm/job3a_postcfs.m**

- Line 35, windows : fprintf('Started: %s\n\n', datestr(now));
- Line 38, windows : fprintf('--- Loading smc_cfs_np.mat ---\n');
- Line 51, windows : fprintf('--- postestimation_clean ---\n');
- Line 54, windows : fprintf('  postestimation_clean: %.1f min\n\n', toc(t_pe)/60);
- Line 61, windows : fprintf('--- Counterfactuals: runs 1-2 ---\n');
- Line 66, windows : fprintf('  CF run imqi=%d — %s\n', imqi, datestr(now));
- Line 82, windows : fprintf('  CF run imqi=%d done: %.1f hrs\n', imqi, toc(t_cf)/3600);

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/estimation/v_correction.m**

- Line 67, windows : fprintf('  v_correction section 1 complete — saving checkpoint\n');

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/postestimation/riskaversion.m**

- Line 2, windows : fprintf('  Variance of baseline wealth: %.6f\n', var(wealth))
- Line 5, windows : fprintf('  Variance of wealth2 (auction outcomes): %.6f\n', var(wealth2))
- Line 9, mixed : fprintf('  Variance of wealth2 (H/T doubling): %.6f\n', var(wealth2))
- Line 10, mixed : fprintf('  Variance ratio (baseline/H-T auction gamble): %.1fx\n', var(wealth)/var(wealth2))
- Line 11, unix : %double initial position--maximize uncertainty by H/T you get it or not

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/computation/histwc.m**

- Line 31, unix : vinterval = linspace(minV, maxV, nbins)-delta/2.0;

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/computation/dscatter.m**

- Line 186, unix : % z = -1:(1/bw):1;

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/computation/evalkspdf.m**

- Line 23, windows : fprintf('Kernel choice not defined or spelt wrong\n')

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/postestimation/robustnesschecks.m**

- Line 78, windows : fprintf('  Correlation of n-bounds (LB): %.4f\n', corr(nout_cs(:,1),nout_ca(:,1)))
- Line 79, windows : fprintf('  Correlation of n-bounds (UB): %.4f\n', corr(nout_cs(:,2),nout_ca(:,2)))
- Line 80, windows : fprintf('  Mean n-bound (LB, with drop): %.2f\n', mean(nout_cs(:,1)))
- Line 81, windows : fprintf('  Mean n-bound (UB, with drop): %.2f\n', mean(nout_cs(:,2)))
- Line 82, windows : fprintf('  Mean n-bound (LB, baseline):  %.2f\n', mean(nout_ca(:,1)))
- Line 83, windows : fprintf('  Mean n-bound (UB, baseline):  %.2f\n', mean(nout_ca(:,2)))

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/slurm/job3c_postcfs.sh**

- Line 1, unix : #!/bin/bash
- Line 11, unix : #SBATCH --output=../../output/logs/job3c_%j.out
- Line 12, unix : #SBATCH --error=../../output/logs/job3c_%j.err

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/estimation/basic_estimator.m**

- Line 555, unix : %Finally, add the restrictions for not cornering the mkt at floor/ceiling being optimal AND
- Line 588, unix : %compute the minimum/maximum

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/computation/weightedcorrs.m**

- Line 32, unix : %   DOI:10.1140/epjb/e2012-20697-x.

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/cfs/doubleauctionOuter_1stepspecial_yin.m**

- Line 24, unix : %26-28 yin construction from linear projection of p/qs

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/slurm/job3c_postcfs.m**

- Line 35, windows : fprintf('Started: %s\n\n', datestr(now));
- Line 49, windows : fprintf('--- Robustness CF: sell_limit=500 — %s ---\n', datestr(now));
- Line 58, windows : fprintf('  Robustness CF sell_limit=500 done: %.1f hrs\n', toc(t_cf)/3600);
- Line 61, windows : fprintf('--- Robustness CF: sell_limit=100, sfrac=2 — %s ---\n', datestr(now));
- Line 81, windows : fprintf('  Robustness CF sell_limit=100 done: %.1f hrs\n', toc(t_cf)/3600);
- Line 85, windows : fprintf('%-25s %16s %16s %16s\n', '', 'Mean Price', 'SD Price', 'Surplus ($M)')
- Line 91, windows : fprintf(fid, ' & Mean Price & SD Price & Surplus (\\$M) \\\\\n\\hline\n');
- Line 96, unix : disp('Table OS.6 saved to output/tables/tableOS6.tex')
- Line 99, windows : fprintf('--- Robustness CF: positionschange=1 — %s ---\n', datestr(now));
- Line 118, windows : fprintf('  Robustness CF positionschange done: %.1f hrs\n', toc(t_cf)/3600);
- Line 121, windows : fprintf('--- robustnesschecks — %s ---\n', datestr(now));
- Line 124, windows : fprintf('  robustnesschecks: %.1f min\n\n', toc(t_rob)/60);

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/slurm/job2a_estimation.m**

- Line 41, windows : fprintf('Started: %s\n\n', datestr(now));
- Line 44, windows : fprintf('--- Loading for211.mat ---\n');
- Line 66, windows : fprintf('--- npestimator ---\n');
- Line 69, windows : fprintf('  npestimator: %.1f sec\n\n', toc(t1));
- Line 73, windows : fprintf('--- complex_bootstrap (skip_vcorrection=1) ---\n');
- Line 76, windows : fprintf('  complex_bootstrap: %.1f hrs\n\n', toc(t2)/3600);

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/estimation/npestimator.m**

- Line 17, unix : %construct X(NOI,yI) with a row for each unique bidder/auction pair

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/postestimation/truthfulpimmcheck.m**

- Line 11, unix : %calculate imm/noi
- Line 55, windows : fprintf('  P95 benefit of manipulation: %.2f\n', benManipule)
- Line 56, windows : fprintf('  Mean cost of manipulation: %.0f\n', costManipule)
- Line 57, mixed : fprintf('  dR/dp_quote (avg effect on IMM): %.4f\n', dRdpquote)

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/computation/jacobianest.m**

- Line 67, unix : % Release date: 3/6/2007
- Line 170, unix : srinv = 1/StepRatio;
- Line 195, windows : rinv = rromb\eye(nexpon+1);

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/computation/permn.m**

- Line 75, unix : %   erroneous values. His excellent solution was to add (1/2) to the values

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/computation/cdf_estimator_imm.m**

- Line 54, unix : % 1. probability of a yd that is negative/positive

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/slurm/job0_validate.sh**

- Line 1, unix : #!/bin/bash
- Line 11, unix : #SBATCH --output=../../output/logs/job0_%j.out
- Line 12, unix : #SBATCH --error=../../output/logs/job0_%j.err

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/slurm/job3a_postcfs.sh**

- Line 1, unix : #!/bin/bash
- Line 11, unix : #SBATCH --output=../../output/logs/job3a_%j.out
- Line 12, unix : #SBATCH --error=../../output/logs/job3a_%j.err

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/postestimation/postestimation_clean.m**

- Line 142, windows : fprintf('  Position adjustment ratio: %.4f\n', adjpos)
- Line 190, unix : %since the correlation bounds are positive the var(Pv-n/bP^c) is monotone
- Line 201, windows : fprintf('%-30s %12s %12s %18s\n', '', 'Mean', 'Variance', 'Cov. Auction Price')
- Line 202, windows : fprintf('%-30s %12.2f %12.0f %18.0f\n', 'Auction Price', mean(aucpricefs), var(aucpricefs), var(aucpricefs))
- Line 205, windows : fprintf('%-30s %12.2f %12.0f %18.0f\n', 'Initial Market Price', mean(IMM), var(IMM), T4_covIMMPc)
- Line 211, windows : fprintf(fid, ' & Mean & Variance & Cov. Auction Price \\\\\n\\hline\n');
- Line 219, unix : disp('Table 4 saved to output/tables/table4.tex')
- Line 221, windows : fprintf('  Price bias E[P^c] - E[P^v_LB] = %.2f cents\n', mean(aucpricefs) - mean(p_lowimm))
- Line 239, windows : fprintf('  SD of risk (lower bound): %.2f cents\n', sqrt(min(lbv)))
- Line 386, windows : fprintf('  Shading percentiles (LB): P10=%.3f P25=%.3f P50=%.3f P75=%.3f P90=%.3f\n', shad_pctiles(:,1))
- Line 387, windows : fprintf('  Shading percentiles (UB): P10=%.3f P25=%.3f P50=%.3f P75=%.3f P90=%.3f\n', shad_pctiles(:,2))

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/estimation/complex_estimator_step1.m**

- Line 394, unix : %up/down one
- Line 594, unix : %Finally, add the restrictions for not cornering the mkt at floor/ceiling being optimal AND

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/computation/heatscatter.m**

- Line 20, unix : %            plot_colorbar      [double], boolean 0/1, default 1
- Line 23, unix : %            plot_lsf           [double], boolean 0/1, default 1
- Line 26, unix : %                                the correlation/p-value of the data

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/computation/pairwise_jointd_estimator_imm.m**

- Line 40, unix : % 1. probability of a yd that is negative/positive

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/estimation/complex_bootstrap.m**

- Line 13, windows : fprintf('  Resuming from bootstrap checkpoint — skipping parfor\n');
- Line 17, windows : fprintf('  Bootstrap: seed=%d, nbs=%d, nbatches=%d\n', bootstrap_seed, nbs, nbatches);
- Line 28, unix : parfor j=1:(nbs/nbatches)
- Line 75, unix : for j=1:(nbs/nbatches)
- Line 336, windows : fprintf('  Saved pre_vcorrection.mat checkpoint\n');
- Line 339, windows : fprintf('  skip_vcorrection=1 — deferring v_correction to next job\n');

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/postestimation/round1_quotescalibration.m**

- Line 180, windows : fprintf('  Calibrated parameters: sigma_eta=%.2f, mpb=%.1f, sigpb=%.1f\n', sigma_eta, mpb, sigpb)

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/slurm/job3b_postcfs.sh**

- Line 1, unix : #!/bin/bash
- Line 11, unix : #SBATCH --output=../../output/logs/job3b_%j.out
- Line 12, unix : #SBATCH --error=../../output/logs/job3b_%j.err

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/main_cds.m**

- Line 142, windows : fprintf('%-25s %16s %16s %16s\n', '', 'Mean Price', 'SD Price', 'Surplus ($M)')
- Line 148, windows : fprintf(fid, ' & Mean Price & SD Price & Surplus (\\$M) \\\\\n\\hline\n');
- Line 153, unix : disp('Table OS.6 saved to output/tables/tableOS6.tex')

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/computation/histwcv.m**

- Line 31, unix : vinterval = linspace(minV, maxV, nbins)-delta/2.0;

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/slurm/job2b_estimation.m**

- Line 5, unix : % Saves: intermediate/smc_cfs_np.mat
- Line 50, windows : fprintf('\n--- Loading pre_vcorrection.mat ---\n');
- Line 62, windows : fprintf('  Checkpoint loaded\n\n');
- Line 65, unix : %% Recovery: bootstrap done, CIs/step2/v_correction not saved
- Line 70, windows : fprintf('Started: %s\n\n', datestr(now));
- Line 73, windows : fprintf('--- Loading for211.mat ---\n');
- Line 92, windows : fprintf('--- npestimator ---\n');
- Line 95, windows : fprintf('  npestimator: %.1f min\n\n', toc(t1)/60);
- Line 98, windows : fprintf('--- Loading bootstrap checkpoint (bsinprogressCCC.mat) ---\n');
- Line 114, windows : fprintf('--- complex_bootstrap (recovery: skip parfor, rerun rest) ---\n');
- Line 119, windows : fprintf('  complex_bootstrap total: %.1f hrs\n\n', toc(t2)/3600);
- Line 122, windows : fprintf('--- Saving smc_cfs_np.mat ---\n');
- Line 134, windows : fprintf('--- v_correction ---\n');
- Line 137, windows : fprintf('  v_correction: %.1f hrs\n\n', toc(t3)/3600);
- Line 141, windows : fprintf('--- complex_bootstrap_pe_outputs ---\n');
- Line 145, windows : fprintf('--- Saving smc_cfs_np.mat ---\n');

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/computation/pairwise_jointd_estimator.m**

- Line 35, unix : % 1. probability of a yd that is negative/positive

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/estimation/basic_estimator_copydrop.m**

- Line 566, unix : %Finally, add the restrictions for not cornering the mkt at floor/ceiling being optimal AND
- Line 599, unix : %compute the minimum/maximum

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/slurm/job3b_postcfs.m**

- Line 35, windows : fprintf('Started: %s\n\n', datestr(now));
- Line 49, windows : fprintf('--- Counterfactuals: runs 3-4 ---\n');
- Line 54, windows : fprintf('  CF run imqi=%d — %s\n', imqi, datestr(now));
- Line 70, windows : fprintf('  CF run imqi=%d done: %.1f hrs\n', imqi, toc(t_cf)/3600);
- Line 74, windows : fprintf('--- postmain_cfs ---\n');

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/cfs/weightsolnpricespartialgridINTs1_yin.m**

- Line 106, unix : %Grid/extrap

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/datacleaning/firststagebidding.m**

- Line 31, unix : %calculate imm/noi

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/cfs/postmain_cfs.m**

- Line 64, windows : fprintf('%-30s %16s %16s %18s %16s\n', '', 'Mean', 'Variance', 'Cov(P^c,P^v)', 'Surplus')
- Line 71, windows : fprintf(fid, ' & Mean & Variance & Cov$(P^c, P^v)$ & Surplus \\\\\n\\hline\n');
- Line 76, unix : disp('Table 5 saved to output/tables/table5.tex')
- Line 81, windows : fprintf('  CF price bias (E[P^v_LB] - E[P^DA_UB]): %.2f cents\n', pbiasCF)
- Line 97, windows : fprintf('  CF SD of risk (lower bound): %.2f cents\n', sqrt(min(lbvcf)))

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/datacleaning/normalize_prices.m**

- Line 1, unix : %normalizes prices by price cap/floor
- Line 24, unix : %expresses NOI as a share of outstanding bonds/outstandingCDS.
- Line 57, unix : %generate unique ids for bidder/auction and throw these on the initial
- Line 58, unix : %round quantities AND the big vector of p/q (1849x1 idfs) (6445x1 idss)
- Line 241, windows : fprintf('%-50s %10s %10s %18s\n', '', 'Mean', 'Sd', '[P10, P90]')
- Line 250, windows : fprintf(fid, ' & Mean & Sd & $[P_{10}, P_{90}]$ \\\\\n\\hline\n');
- Line 263, unix : disp('Table 3 saved to output/tables/table3.tex')
- Line 267, windows : fprintf('  Total auctions in sample: %d\n', size(aucidfslist,1))
- Line 268, windows : fprintf('  Total bidder-auction observations: %d\n', size(aucidfs,1))
- Line 269, windows : fprintf('  Median eligible bonds per auction: %.0f\n', median(OS1_nbonds))
- Line 272, windows : fprintf('  Requests of zero: %d\n', sum(noi==0))
- Line 274, windows : fprintf('  Auctions with no second stage (NOI=0): %d\n', sum(NOI==0))
- Line 279, windows : fprintf('  Mean quantity conditional on bidding (shares): %.2f\n', mean(maxQi(maxQi~=0)))
- Line 314, windows : fprintf(fid, ' & IMM Submission & Residualized bid \\\\\n\\hline\n');
- Line 319, windows : fprintf(fid, '\\hline\n');
- Line 326, unix : disp('Table OS.4 saved to output/tables/tableOS4.tex')
- Line 359, windows : fprintf(fid, 'VARIABLES & (1) Auction Price & (2) Auction IMM \\\\\n\\hline\n');
- Line 372, windows : fprintf(fid, '\\hline\n');
- Line 379, unix : disp('Table OS.5 saved to output/tables/tableOS5.tex')
- Line 395, windows : fprintf('  N = %d\n', size(br_beta,2));
- Line 417, windows : fprintf('  Mean Opp. coef = %.2f (%.2f), N = %d\n', b(1), se(1), size(meanpricesub,2));
- Line 431, windows : fprintf(fid, '\\hline\n');
- Line 437, unix : disp('Table A.1 saved to output/tables/tableA1.tex')

**/Users/florianoswald/actions-runner/_work/JPE-Richert-20240555/JPE-Richert-20240555/replication-package/CDS/code/datacleaning/data_summary.m**

- Line 58, windows : fprintf('%-30s %10s %10s %18s\n', '', 'Mean', 'Sd', '[P10, P90]')
- Line 63, windows : fprintf('N = %d auctions\n', size(OS1_vars,1));
- Line 68, windows : fprintf(fid, ' & Mean & Sd & $[P_{10}, P_{90}]$ \\\\\n\\hline\n');
- Line 77, unix : disp('Table OS.1 saved to output/tables/tableOS1.tex')
- Line 104, mixed : fprintf('%-50s %12s %12s\n', 'Dealer', 'Bid/Offer', 'Size ($M)')
- Line 113, windows : fprintf('%-50s %12s %12.3f\n', pd_bidders{ii}, direction, abs(pd_noi_vals(ii)));
- Line 115, windows : fprintf('%-50s %12s %12.3f\n', 'Net Open Interest', 'Offer', sum(pd_noi_vals));
- Line 120, mixed : fprintf(fid, 'Dealer & Bid/Offer & Size (\\$M) \\\\\n\\hline\n');
- Line 130, unix : disp('Table 1 saved to output/tables/table1.tex')
- Line 136, windows : fprintf('%-50s %8s %8s\n', 'Dealer', 'Bid', 'Offer')
- Line 138, windows : fprintf('%-50s %8.2f %8.2f\n', pd_bidders{ii}, pd_bids(ii), pd_offers(ii));
- Line 143, windows : for ii=1:size(sorted_bids,1); fprintf('  %d: %.2f\n', ib(ii), sorted_bids(ii)); end
- Line 144, windows : fprintf('Sorted Offers (asc):\n')
- Line 145, windows : for ii=1:size(sorted_offers,1); fprintf('  %d: %.2f\n', io(ii), sorted_offers(ii)); end
- Line 146, windows : fprintf('IMM = %.2f\n', IMM(aucidfslist==pd_aucid));
- Line 151, windows : fprintf(fid, 'Dealer & Bid & Offer \\\\\n\\hline\n');
- Line 158, unix : disp('Table 2 saved to output/tables/table2.tex')
- Line 181, windows : fprintf('%-20s %14s %14s %14s\n', '', 'After 30 Days', 'After 5 Days', 'After 1 Day')
- Line 186, windows : fprintf('N = %d\n', size(BPmeanS,1));
- Line 191, windows : fprintf(fid, ' & Price after 30 Days & Price after 5 Days & Price after 1 Day \\\\\n\\hline\n');
- Line 200, unix : disp('Table OS.3 saved to output/tables/tableOS3.tex')
- Line 305, unix : disp('Table OS.2 saved to output/tables/tableOS2.tex')
- Line 324, unix : elseif strcmp(eventtype(aucid==aucidfslist(aa)),'Repudiation/moratorium')
- Line 338, unix : %purchase/sold RAW (ie summed with customers)

