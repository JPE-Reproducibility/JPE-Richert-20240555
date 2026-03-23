%% Job 2a: npestimator + complex_bootstrap (step1 + CIs + step2)
% Saves pre_vcorrection.mat checkpoint; defers v_correction to Job 2b
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
bootstrap_seed = 200;
updatedata = 1;
bootstrap = 1;
runbootstrap = 1;

%% Configure parallel cluster (per RCC docs)
pc = parcluster('local');
pc.JobStorageLocation = getenv('TMPDIR');
pc.NumWorkers = ncores;

%% Diary log
diary off
logfile = fullfile(log_path, 'job2_estimation_log.txt');
if exist(logfile,'file')~=0, delete(logfile); end
diary(logfile)

fprintf('=== Job 2a: Estimation ===\n');
fprintf('Started: %s\n\n', datestr(now));

%% Load data from Job 1
fprintf('--- Loading for211.mat ---\n');
assert(exist(fullfile(int_path,'for211.mat'),'file')==2, 'for211.mat not found');
load(fullfile(int_path,'for211'));
% Restore paths after load
code_dir = fullfile(pwd, 'code');
root_dir = pwd;
data_path = fullfile(root_dir, 'confidential-data-not-for-publication');
output_path = fullfile(root_dir, 'output');
fig_path    = fullfile(output_path, 'figures');
tab_path    = fullfile(output_path, 'tables');
log_path    = fullfile(output_path, 'logs');
int_path    = fullfile(output_path, 'intermediate');
ncores = 20; nbs = 200; bootstrap_seed = 200;
updatedata = 1; bootstrap = 1; runbootstrap = 1;

% Bondconv transpose fix
if size(Bondconv,1)==1
    Bondconv=Bondconv'; Bondvol=Bondvol';
    Bondcf=Bondcf'; Bonddur=Bonddur';
end

%% npestimator
fprintf('--- npestimator ---\n');
t1 = tic;
npestimator;
fprintf('  npestimator: %.1f sec\n\n', toc(t1));

%% complex_bootstrap (step1 + bootstrap + CIs + step2, skip v_correction)
skip_vcorrection = 1;
fprintf('--- complex_bootstrap (skip_vcorrection=1) ---\n');
t2 = tic;
complex_bootstrap;
fprintf('  complex_bootstrap: %.1f hrs\n\n', toc(t2)/3600);

%% Verify checkpoint
assert(exist(fullfile(int_path,'pre_vcorrection.mat'),'file')==2, 'pre_vcorrection.mat not created');

fprintf('\n=== Job 2a complete: %s ===\n', datestr(now));
diary off
exit(0);

catch e
    fprintf('\nFATAL ERROR in Job 2a: %s\n', e.message);
    for k = 1:length(e.stack)
        fprintf('  %s (line %d)\n', e.stack(k).name, e.stack(k).line);
    end
    diary off
    exit(1);
end
