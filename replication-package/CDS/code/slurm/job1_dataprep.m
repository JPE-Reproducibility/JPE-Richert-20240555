%% Job 1: Data Preparation (serial)
% Runs: bondpriceimport, data_summary, normalize_prices
% Saves: intermediate/maindata.mat, intermediate/for211.mat
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

if ~exist(fig_path,'dir'), mkdir(fig_path); end
if ~exist(tab_path,'dir'), mkdir(tab_path); end
if ~exist(log_path,'dir'), mkdir(log_path); end
if ~exist(int_path,'dir'), mkdir(int_path); end
if ~exist(fullfile(int_path,'positionschange'),'dir')
    mkdir(fullfile(int_path,'positionschange'));
end

addpath(fullfile(code_dir, 'computation'));
addpath(fullfile(code_dir, 'datacleaning'));
addpath(fullfile(code_dir, 'estimation'));
addpath(fullfile(code_dir, 'postestimation'));
addpath(fullfile(code_dir, 'cfs'));

updatedata   = 1;
bootstrap    = 1;
runbootstrap = 1;
ncores       = 1;
nbs          = 200;

%% Diary log
diary off
logfile = fullfile(log_path, 'job1_dataprep_log.txt');
if exist(logfile,'file')~=0, delete(logfile); end
diary(logfile)

fprintf('=== Job 1: Data Preparation ===\n');
fprintf('Started: %s\n\n', datestr(now));

%% Bond price import
fprintf('--- bondpriceimport ---\n');
tic;
bondpriceimport;
fprintf('  bondpriceimport: %.1f min\n\n', toc/60);

%% Data summary
fprintf('--- data_summary ---\n');
bond_price_analysis = 1;
analyzefs = 1;
t1 = tic;
data_summary;
fprintf('  data_summary: %.1f sec\n\n', toc(t1));

save(fullfile(int_path,'maindata'));

%% Normalize prices
fprintf('--- normalize_prices ---\n');
t2 = tic;
normalize_prices;
fprintf('  normalize_prices: %.1f sec\n\n', toc(t2));

close all;
save(fullfile(int_path,'for211'));

if size(Bondconv,1)==1
    Bondconv=Bondconv';
    Bondvol=Bondvol';
    Bondcf=Bondcf';
    Bonddur=Bonddur';
end

%% Verify outputs exist
assert(exist(fullfile(int_path,'maindata.mat'),'file')==2, 'maindata.mat not created');
assert(exist(fullfile(int_path,'for211.mat'),'file')==2, 'for211.mat not created');

fprintf('\n=== Job 1 complete: %s ===\n', datestr(now));
diary off
exit(0);

catch e
    fprintf('\nFATAL ERROR in Job 1: %s\n', e.message);
    for k = 1:length(e.stack)
        fprintf('  %s (line %d)\n', e.stack(k).name, e.stack(k).line);
    end
    diary off
    exit(1);
end
