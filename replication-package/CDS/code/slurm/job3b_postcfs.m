%% Job 3b: CF runs 3-4 + postmain_cfs (Table 5)
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
logfile = fullfile(log_path, 'job3b_log.txt');
if exist(logfile,'file')~=0, delete(logfile); end
diary(logfile)

fprintf('=== Job 3b: CF 3-4 + postmain_cfs ===\n');
fprintf('Started: %s\n\n', datestr(now));

%% Load data first (need Bondvol for sell_limit)
load(fullfile(int_path,'smc_cfs_np'));
code_dir = fullfile(pwd, 'code'); root_dir = pwd;
data_path = fullfile(root_dir, 'confidential-data-not-for-publication');
output_path = fullfile(root_dir, 'output');
fig_path = fullfile(output_path, 'figures');
tab_path = fullfile(output_path, 'tables');
log_path = fullfile(output_path, 'logs');
int_path = fullfile(output_path, 'intermediate');
ncores = 20; nbs = 200; bootstrap = 1; runbootstrap = 1;

%% CF runs 3-4
fprintf('--- Counterfactuals: runs 3-4 ---\n');
sell_limit=median(Bondvol);
sfrac=1;
positionschange=0;
for imqi=3:4
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

%% Collect CF results (Table 5)
fprintf('--- postmain_cfs ---\n');
clearvars -except code_dir root_dir data_path output_path fig_path tab_path log_path int_path ...
    ncores nbs bootstrap runbootstrap sell_limit sfrac positionschange immquantiles
load(fullfile(int_path,'smc_cfs_np'));
code_dir = fullfile(pwd, 'code'); root_dir = pwd;
data_path = fullfile(root_dir, 'confidential-data-not-for-publication');
output_path = fullfile(root_dir, 'output');
fig_path = fullfile(output_path, 'figures');
tab_path = fullfile(output_path, 'tables');
log_path = fullfile(output_path, 'logs');
int_path = fullfile(output_path, 'intermediate');
ncores = 20; nbs = 200; bootstrap = 1; runbootstrap = 1;
sell_limit=median(Bondvol);
sfrac=1;
postmain_cfs;

fprintf('\n=== Job 3b complete: %s ===\n', datestr(now));
diary off
exit(0);

catch e
    fprintf('\nFATAL ERROR in Job 3b: %s\n', e.message);
    for k = 1:length(e.stack)
        fprintf('  %s (line %d)\n', e.stack(k).name, e.stack(k).line);
    end
    diary off
    exit(1);
end
