%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAIN REPLICATION SCRIPT
% "Quantity Commitments in Multiunit Auctions: Evidence from
%  Credit Event Auctions" - Eric Richert
%
% This script reproduces all tables and figures in the paper.
% Set paths below and run. All outputs saved to output/.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all; clc;

%% ================= PATH SETUP (edit only this section) =================
% All paths are relative to this file's location (code/)
code_dir = fileparts(mfilename('fullpath'));
root_dir = fullfile(code_dir, '..');

% Input data
data_path = fullfile(root_dir, 'confidential-data-not-for-publication');

% Output directories
output_path = fullfile(root_dir, 'output');
fig_path    = fullfile(output_path, 'figures');
tab_path    = fullfile(output_path, 'tables');
log_path    = fullfile(output_path, 'logs');
int_path    = fullfile(output_path, 'intermediate');

% Create output dirs if they don't exist
if ~exist(fig_path,'dir'), mkdir(fig_path); end
if ~exist(tab_path,'dir'), mkdir(tab_path); end
if ~exist(log_path,'dir'), mkdir(log_path); end
if ~exist(int_path,'dir'), mkdir(int_path); end
if ~exist(fullfile(int_path,'positionschange'),'dir')
    mkdir(fullfile(int_path,'positionschange'));
end

%% ================= ADD CODE PATHS ======================================
addpath(fullfile(code_dir, 'computation'))
addpath(fullfile(code_dir, 'datacleaning'))
addpath(fullfile(code_dir, 'estimation'))
addpath(fullfile(code_dir, 'postestimation'))
addpath(fullfile(code_dir, 'cfs'))

%% ================= SETTINGS ============================================
updatedata   = 1;
bootstrap    = 1;
runbootstrap  = 1;
ncores       = 20;
nbs          = 200;
%% ================= Verify Env ============================================
verify_env()


%% ================= DIARY LOG ===========================================
% Single log for the whole run (data prep -> estimation -> CFs -> robustness)
diary off
logfile = fullfile(log_path, 'cdsresults_log.txt');
if exist(logfile,'file')~=0, delete(logfile); end
diary(logfile)

%% ================= BOND PRICE IMPORT ===================================
% Import and process FINRA TRACE bond price data
% Can skip by setting bond_price_analysis=0 below
bondpriceimport
% bondpriceimport clears workspace except paths and settings

%% ================= DATA PREPARATION ====================================
if updatedata==1
    bond_price_analysis=1;
    analyzefs=1;
    data_summary
    % Dependencies: immspreads_clean.csv, openinterest_clean.csv,
    %   limitorders_clean.csv, auctionlistid.csv, bondtypes.csv
    % Calls: build_bondforestimation, bondprices, firststagebidding, outcomelinks
    %   which call: cleanbondprice, acrossrounds, tiesstats, fixfromimm
    save(fullfile(int_path,'maindata'))
else
    load(fullfile(int_path,'maindata'))
end

normalize_prices
close all
save(fullfile(int_path,'for211'))

if size(Bondconv,1)==1
    Bondconv=Bondconv';
    Bondvol=Bondvol';
    Bondcf=Bondcf';
    Bonddur=Bonddur';
end

%% ================= ESTIMATION ==========================================
npestimator
% Sets up data: draws bootstrap samples and pointers

complex_bootstrap
% Main estimation: calls complex_estimator_step1 (n-bounds, win probs)
% and complex_estimator_step2 (value bounds)

%% ================= POST-ESTIMATION (Section 6) =========================
postestimation_clean
% Risk calculations, bias, inefficiency, auction performance (Table 4)

close all

save(fullfile(int_path,'smc_cfs_np'),'-v7.3')

%% ================= COUNTERFACTUALS (Section 7) =========================
% MAIN SPEC: double auction at each IMM quantile
sell_limit=median(Bondvol);
sfrac=1;
positionschange=0;
for imqi=1:size(immquantiles,2)
    clearvars -except sell_limit sfrac positionschange imqi immquantiles ...
        code_dir root_dir data_path output_path fig_path tab_path log_path int_path ...
        ncores nbs bootstrap runbootstrap
    load(fullfile(int_path,'smc_cfs_np'))
    R=immquantiles(imqi);
    smc_cfs_yin
end

% Collect CF results: variance, bias, risk (Table 5)
postmain_cfs

% APPENDIX SPECS FOR ROBUSTNESS
% Alternative volume cap (Table OS.6, row 1)
sell_limit=500;
sfrac=1;
positionschange=0;
R=median(IMM);
smc_cfs_yin
OS6_500 = [min(Pcl) max(Pcl) min(sdpcl) max(sdpcl) min(surpAB)*median(ndeal)/100 max(surpA)*median(ndeal)/100];

% Alternative volume cap / step fraction (Table OS.6, row 2)
sell_limit=100;
sfrac=2;
positionschange=0;
PclU=[]; sdU=[]; sAU=[]; sABU=[];
for ch=2:-1:1
    cf_seed=(ch-1)*1000;
smc_cfs_yin
PclU=[PclU Pcl(:).']; sdU=[sdU sdpcl(:).']; sABU=[sABU surpAB(:)];
end
clear cf_seed
OS6_100 = [min(PclU) max(PclU) min(sdU) max(sdU) min(sABU)*median(ndeal)/100 max(surpA)*median(ndeal)/100];

%% Table OS.6: Change in Auction Format (Bond Supply)
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

% Appendix D.3: Counterfactual allowing for changes in positions (positions reduced 2%)
sell_limit=median(Bondvol);
sfrac=1;
positionschange=1;
nout_orig=nout;
PclU=[]; sdU=[]; ch=1;
cf_seed=(ch-1)*1000;
nout=nout_orig;
smc_cfs_yin
PclU=[PclU Pcl(:).']; sdU=[sdU sdpcl(:).'];
clear cf_seed
%% Appendix D.3: double-auction price and SD bounds under changed positions
D3_price = [min(PclU) max(PclU)];
D3_sd    = [min(sdU) max(sdU)];
disp('========== APPENDIX D.3: Counterfactual with Changes in Positions ==========')
fprintf('  Expected price: [%.2f, %.2f]\n', D3_price)
fprintf('  Std dev:        [%.2f, %.2f]\n', D3_sd)

%% ================= ROBUSTNESS CHECKS (Appendix) ========================
robustnesschecks
% Calls: truthfulpimmcheck, round1_quotescalibration, riskaversion

diary off
disp('=== Replication complete. Outputs saved to output/ ===')
