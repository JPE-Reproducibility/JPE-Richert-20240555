%% Job 3a: Post-estimation + CF runs 1-2
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

ncores = 20; nbs = 200; bootstrap = 1; runbootstrap = 1;

%% Configure parallel cluster
pc = parcluster('local');
pc.JobStorageLocation = getenv('TMPDIR');
pc.NumWorkers = ncores;

%% Diary log
diary off
logfile = fullfile(log_path, 'job3a_log.txt');
if exist(logfile,'file')~=0, delete(logfile); end
diary(logfile)

fprintf('=== Job 3a: Post-estimation + CF 1-2 ===\n');
fprintf('Started: %s\n\n', datestr(now));

%% Load estimation results
fprintf('--- Loading smc_cfs_np.mat ---\n');
assert(exist(fullfile(int_path,'smc_cfs_np.mat'),'file')==2, 'smc_cfs_np.mat not found');
load(fullfile(int_path,'smc_cfs_np'));
code_dir = fullfile(pwd, 'code'); root_dir = pwd;
data_path = fullfile(root_dir, 'confidential-data-not-for-publication');
output_path = fullfile(root_dir, 'output');
fig_path = fullfile(output_path, 'figures');
tab_path = fullfile(output_path, 'tables');
log_path = fullfile(output_path, 'logs');
int_path = fullfile(output_path, 'intermediate');
ncores = 20; nbs = 200; bootstrap = 1; runbootstrap = 1;

%% Post-estimation (Table 4, Section 6.1-6.3, Figures)
fprintf('--- postestimation_clean ---\n');
t_pe = tic;
postestimation_clean;
fprintf('  postestimation_clean: %.1f min\n\n', toc(t_pe)/60);
close all;

%% Save updated workspace (needed by robustnesschecks later)
save(fullfile(int_path,'smc_cfs_np'),'-v7.3');

%% CF runs 1-2
fprintf('--- Counterfactuals: runs 1-2 ---\n');
sell_limit=median(Bondvol);
sfrac=1;
positionschange=0;
for imqi=1:2
    fprintf('  CF run imqi=%d — %s\n', imqi, datestr(now));
    t_cf = tic;
    clearvars -except sell_limit sfrac positionschange imqi immquantiles t_cf ...
        code_dir root_dir data_path output_path fig_path tab_path log_path int_path ...
        ncores nbs bootstrap runbootstrap
    load(fullfile(int_path,'smc_cfs_np'));
    code_dir = fullfile(pwd, 'code'); root_dir = pwd;
    data_path = fullfile(root_dir, 'confidential-data-not-for-publication');
    output_path = fullfile(root_dir, 'output');
    fig_path = fullfile(output_path, 'figures');
    tab_path = fullfile(output_path, 'tables');
    log_path = fullfile(output_path, 'logs');
    int_path = fullfile(output_path, 'intermediate');
    ncores = 20; nbs = 200; bootstrap = 1; runbootstrap = 1;
    R=immquantiles(imqi);
    smc_cfs_yin;
    fprintf('  CF run imqi=%d done: %.1f hrs\n', imqi, toc(t_cf)/3600);
end

fprintf('\n=== Job 3a complete: %s ===\n', datestr(now));
diary off
exit(0);

catch e
    fprintf('\nFATAL ERROR in Job 3a: %s\n', e.message);
    for k = 1:length(e.stack)
        fprintf('  %s (line %d)\n', e.stack(k).name, e.stack(k).line);
    end
    diary off
    exit(1);
end
