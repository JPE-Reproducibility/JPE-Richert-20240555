%% Job 2b: v_correction + pe_outputs
% Normal: loads pre_vcorrection.mat from Job 2a, runs v_correction + pe_outputs
% Recovery: loads bsinprogressCCC.mat, reruns npestimator + step1 PE + CIs
%           + step2 + v_correction + pe_outputs (skips only the bootstrap parfor)
% Saves: intermediate/smc_cfs_np.mat
try
clear all; close all; clc;

%% Path setup
code_dir = fullfile(pwd, 'code');
root_dir = pwd;
data_path = fullfile(root_dir, 'confidential-data-not-for-publication');
output_path = fullfile(root_dir, 'output');
fig_path    = fullfile(output_path, 'figures');
tab_path    = fullfile(output_path, 'tables');
log_path    = fullfile(output_path, 'logs');
int_path    = fullfile(output_path, 'intermediate');

addpath(fullfile(code_dir, 'computation'));
addpath(fullfile(code_dir, 'datacleaning'));
addpath(fullfile(code_dir, 'estimation'));
addpath(fullfile(code_dir, 'postestimation'));
addpath(fullfile(code_dir, 'cfs'));

ncores = 20;
nbs    = 200;

%% Configure parallel cluster (per RCC docs)
pc = parcluster('local');
pc.JobStorageLocation = getenv('TMPDIR');
pc.NumWorkers = ncores;

%% Determine mode: normal (pre_vcorrection exists) vs recovery
recovery = exist(fullfile(int_path,'pre_vcorrection.mat'),'file')~=2;

%% Diary log
diary off
logfile = fullfile(log_path, 'job2_estimation_log.txt');
if recovery
    % Old log has output past the checkpoint (partial v_correction).
    % Delete it — we rerun npestimator + step1 PE so nothing is missing.
    if exist(logfile,'file')~=0; delete(logfile); end
end
% Normal: job2a log ends at pre_vcorrection save, we append seamlessly
diary(logfile)

%% Load checkpoint
if ~recovery
    %% Normal path: load pre_vcorrection from Job 2a
    fprintf('\n--- Loading pre_vcorrection.mat ---\n');
    load(fullfile(int_path,'pre_vcorrection'));
    % Restore path variables
    code_dir = fullfile(pwd, 'code');
    root_dir = pwd;
    data_path = fullfile(root_dir, 'confidential-data-not-for-publication');
    output_path = fullfile(root_dir, 'output');
    fig_path    = fullfile(output_path, 'figures');
    tab_path    = fullfile(output_path, 'tables');
    log_path    = fullfile(output_path, 'logs');
    int_path    = fullfile(output_path, 'intermediate');
    ncores = 20; nbs = 200;
    fprintf('  Checkpoint loaded\n\n');

elseif exist(fullfile(int_path,'bsinprogressCCC.mat'),'file')==2
    %% Recovery: bootstrap done, CIs/step2/v_correction not saved
    % Rerun npestimator (~2 min) and step1 PE (~30 min) so the log is
    % complete. Skip only the bootstrap parfor (~6 hrs) via checkpoint.

    fprintf('=== Job 2: Estimation ===\n');
    fprintf('Started: %s\n\n', datestr(now));

    % Load data from Job 1
    fprintf('--- Loading for211.mat ---\n');
    assert(exist(fullfile(int_path,'for211.mat'),'file')==2, 'for211.mat not found');
    load(fullfile(int_path,'for211'));
    code_dir = fullfile(pwd, 'code');
    root_dir = pwd;
    data_path = fullfile(root_dir, 'confidential-data-not-for-publication');
    output_path = fullfile(root_dir, 'output');
    fig_path    = fullfile(output_path, 'figures');
    tab_path    = fullfile(output_path, 'tables');
    log_path    = fullfile(output_path, 'logs');
    int_path    = fullfile(output_path, 'intermediate');
    updatedata = 1; bootstrap = 1; runbootstrap = 1; ncores = 20; nbs = 200; bootstrap_seed = 200;

    if size(Bondconv,1)==1
        Bondconv=Bondconv'; Bondvol=Bondvol';
        Bondcf=Bondcf'; Bonddur=Bonddur';
    end

    % Rerun npestimator (~2 min) — produces same log output as clean run
    fprintf('--- npestimator ---\n');
    t1 = tic;
    npestimator;
    fprintf('  npestimator: %.1f min\n\n', toc(t1)/60);

    % Load bootstrap results from checkpoint (overwrites workspace)
    fprintf('--- Loading bootstrap checkpoint (bsinprogressCCC.mat) ---\n');
    load(fullfile(int_path,'bsinprogressCCC'));
    if exist(fullfile(int_path,'extraoutbs.mat'),'file')==2
        load(fullfile(int_path,'extraoutbs'),'extraoutbs');
    end
    code_dir = fullfile(pwd, 'code');
    root_dir = pwd;
    data_path = fullfile(root_dir, 'confidential-data-not-for-publication');
    output_path = fullfile(root_dir, 'output');
    fig_path    = fullfile(output_path, 'figures');
    tab_path    = fullfile(output_path, 'tables');
    log_path    = fullfile(output_path, 'logs');
    int_path    = fullfile(output_path, 'intermediate');
    ncores = 20; nbs = 200;

    % Run step1 PE + CIs + step2 + v_correction + pe_outputs
    fprintf('--- complex_bootstrap (recovery: skip parfor, rerun rest) ---\n');
    resume_from_checkpoint = 1;
    skip_vcorrection = 0;
    t2 = tic;
    complex_bootstrap;
    fprintf('  complex_bootstrap total: %.1f hrs\n\n', toc(t2)/3600);

    % Save and exit
    fprintf('--- Saving smc_cfs_np.mat ---\n');
    save(fullfile(int_path,'smc_cfs_np'),'-v7.3');
    assert(exist(fullfile(int_path,'smc_cfs_np.mat'),'file')==2, 'smc_cfs_np.mat not created');
    fprintf('\n=== Job 2 complete: %s ===\n', datestr(now));
    diary off
    exit(0);

else
    error('No checkpoint found. Rerun from Job 2a.');
end

%% Normal path continues: v_correction + pe_outputs
fprintf('--- v_correction ---\n');
t3 = tic;
v_correction;
fprintf('  v_correction: %.1f hrs\n\n', toc(t3)/3600);

save(fullfile(int_path,'bsinprogressCCC'));

fprintf('--- complex_bootstrap_pe_outputs ---\n');
complex_bootstrap_pe_outputs;

%% Save final results
fprintf('--- Saving smc_cfs_np.mat ---\n');
save(fullfile(int_path,'smc_cfs_np'),'-v7.3');
assert(exist(fullfile(int_path,'smc_cfs_np.mat'),'file')==2, 'smc_cfs_np.mat not created');

fprintf('\n=== Job 2 complete: %s ===\n', datestr(now));
diary off
exit(0);

catch e
    fprintf('\nFATAL ERROR in Job 2b: %s\n', e.message);
    for k = 1:length(e.stack)
        fprintf('  %s (line %d)\n', e.stack(k).name, e.stack(k).line);
    end
    diary off
    exit(1);
end
