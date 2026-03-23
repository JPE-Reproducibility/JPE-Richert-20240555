%% Job 3c: Robustness CFs + tableOS6 + robustnesschecks
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
logfile = fullfile(log_path, 'job3c_log.txt');
if exist(logfile,'file')~=0, delete(logfile); end
diary(logfile)

fprintf('=== Job 3c: Robustness CFs + checks ===\n');
fprintf('Started: %s\n\n', datestr(now));

%% Load estimation results
load(fullfile(int_path,'smc_cfs_np'));
code_dir = fullfile(pwd, 'code'); root_dir = pwd;
data_path = fullfile(root_dir, 'confidential-data-not-for-publication');
output_path = fullfile(root_dir, 'output');
fig_path = fullfile(output_path, 'figures');
tab_path = fullfile(output_path, 'tables');
log_path = fullfile(output_path, 'logs');
int_path = fullfile(output_path, 'intermediate');
ncores = 20; nbs = 200; bootstrap = 1; runbootstrap = 1;

%% Robustness CF: sell_limit=500
fprintf('--- Robustness CF: sell_limit=500 — %s ---\n', datestr(now));
t_cf = tic;
sell_limit=500;
sfrac=1;
positionschange=0;
imqi=4;
R=median(IMM);
smc_cfs_yin;
OS6_500 = [min(Pcl) max(Pcl) min(sdpcl) max(sdpcl) min(surpAB)*median(ndeal)/100 max(surpA)*median(ndeal)/100];
fprintf('  Robustness CF sell_limit=500 done: %.1f hrs\n', toc(t_cf)/3600);

%% Robustness CF: sell_limit=100, sfrac=2
fprintf('--- Robustness CF: sell_limit=100, sfrac=2 — %s ---\n', datestr(now));
clearvars -except OS6_500 code_dir root_dir data_path output_path fig_path tab_path log_path int_path ...
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
t_cf = tic;
sell_limit=100;
sfrac=2;
positionschange=0;
imqi=4;
R=median(IMM);
smc_cfs_yin;
OS6_100 = [min(Pcl) max(Pcl) min(sdpcl) max(sdpcl) min(surpAB)*median(ndeal)/100 max(surpA)*median(ndeal)/100];
fprintf('  Robustness CF sell_limit=100 done: %.1f hrs\n', toc(t_cf)/3600);

%% Table OS.6
disp('========== TABLE OS.6: Change in Auction Format (Bond Supply) ==========')
fprintf('%-25s %16s %16s %16s\n', '', 'Mean Price', 'SD Price', 'Surplus ($M)')
fprintf('%-25s [%6.2f,%6.2f] [%6.2f,%6.2f] [%5.1f,%5.1f]\n', 'Volume cap = 500', OS6_500)
fprintf('%-25s [%6.2f,%6.2f] [%6.2f,%6.2f] [%5.1f,%5.1f]\n', 'Volume cap = 100', OS6_100)
fid = fopen(fullfile(tab_path, 'tableOS6.tex'), 'w');
fprintf(fid, '\\begin{table}[htbp]\n\\centering\n\\caption{Change in Auction Format (Bond Supply)}\n\\label{tab:os6}\n');
fprintf(fid, '\\begin{tabular}{lccc}\n\\hline\\hline\n');
fprintf(fid, ' & Mean Price & SD Price & Surplus (\\$M) \\\\\n\\hline\n');
fprintf(fid, 'Volume cap = 500 & $[%.2f, %.2f]$ & $[%.2f, %.2f]$ & $[%.1f, %.1f]$ \\\\\n', OS6_500);
fprintf(fid, 'Volume cap = 100 & $[%.2f, %.2f]$ & $[%.2f, %.2f]$ & $[%.1f, %.1f]$ \\\\\n', OS6_100);
fprintf(fid, '\\hline\\hline\n\\end{tabular}\n\\end{table}\n');
fclose(fid);
disp('Table OS.6 saved to output/tables/tableOS6.tex')

%% Robustness CF: positionschange
fprintf('--- Robustness CF: positionschange=1 — %s ---\n', datestr(now));
clearvars -except OS6_500 OS6_100 code_dir root_dir data_path output_path fig_path tab_path log_path int_path ...
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
t_cf = tic;
sell_limit=median(Bondvol);
sfrac=1;
positionschange=1;
imqi=4;
R=median(IMM);
smc_cfs_yin;
fprintf('  Robustness CF positionschange done: %.1f hrs\n', toc(t_cf)/3600);

%% Robustness checks (Appendix C)
fprintf('--- robustnesschecks — %s ---\n', datestr(now));
t_rob = tic;
robustnesschecks;
fprintf('  robustnesschecks: %.1f min\n\n', toc(t_rob)/60);

fprintf('\n=== Job 3c complete: %s ===\n', datestr(now));
diary off
exit(0);

catch e
    fprintf('\nFATAL ERROR in Job 3c: %s\n', e.message);
    for k = 1:length(e.stack)
        fprintf('  %s (line %d)\n', e.stack(k).name, e.stack(k).line);
    end
    diary off
    exit(1);
end
