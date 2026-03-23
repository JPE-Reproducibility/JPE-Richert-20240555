% debug_bondforestimation.m
% Diagnose mismatches between built and existing bondforestimation

if ~exist('data_path','var')
    data_path = fullfile(fileparts(fileparts(mfilename('fullpath'))),'..','confidential-data-not-for-publication');
end

bt = readtable(fullfile(data_path,'bondtypes.csv'),'ReadVariableNames',true);
ref = readtable(fullfile(data_path,'bondforestimation.csv'),'ReadVariableNames',true);

aucids = unique(bt.aucid);

%% varvol and totalvol
fprintf('\n=== varvol / totalvol ===\n');
for ii = 1:size(aucids,1)
    a = aucids(ii);
    rows = bt(bt.aucid == a, :);
    ref_row = ref(ref.aucid == a, :);
    if isempty(ref_row); continue; end
    vv_built = rows.varvol(1);
    vv_ref = ref_row.varvol;
    tv_built = rows.totalvol(1);
    tv_ref = ref_row.totalvol;
    if abs(vv_built - vv_ref) > 1 || abs(tv_built - tv_ref) > 1
        fprintf('  aucid=%d: varvol built=%g ref=%g diff=%g | totalvol built=%g ref=%g diff=%g | Nbonds=%d\n', ...
            a, vv_built, vv_ref, vv_built-vv_ref, tv_built, tv_ref, tv_built-tv_ref, size(rows,1));
        % Check if varvol/totalvol vary within auction
        if numel(unique(rows.varvol)) > 1
            fprintf('    varvol varies within auction: %s\n', mat2str(rows.varvol'));
        end
        if numel(unique(rows.totalvol)) > 1
            fprintf('    totalvol varies within auction: %s\n', mat2str(rows.totalvol'));
        end
    end
end

%% maxtmaturity and mintmaturity
fprintf('\n=== maxtmaturity / mintmaturity ===\n');
for ii = 1:size(aucids,1)
    a = aucids(ii);
    rows = bt(bt.aucid == a, :);
    ref_row = ref(ref.aucid == a, :);
    if isempty(ref_row); continue; end

    auc_year = rows.auction_year(1) + (rows.auction_month(1)-1)/12 + (rows.auction_day(1)-1)/365;
    mat_years = rows.mature_year + (rows.mature_month-1)/12 + (rows.mature_day-1)/365 - auc_year;

    maxmat_built = max(mat_years);
    minmat_built = min(mat_years);
    maxmat_ref = ref_row.maxtmaturity;
    minmat_ref = ref_row.mintmaturity;

    if abs(maxmat_built - maxmat_ref) > 0.5 || abs(minmat_built - minmat_ref) > 0.5
        fprintf('  aucid=%d: maxmat built=%.2f ref=%.2f | minmat built=%.2f ref=%.2f\n', ...
            a, maxmat_built, maxmat_ref, minmat_built, minmat_ref);
        fprintf('    mat_years: %s\n', mat2str(mat_years', 4));
        fprintf('    mature_year: %s\n', mat2str(rows.mature_year'));
        fprintf('    T column: %s\n', mat2str(rows.T'));
        % Check if ref used T or mature_year - auction_year (integer)
        simple_mat = rows.mature_year - rows.auction_year(1);
        fprintf('    simple (mature_year - auction_year): %s\n', mat2str(simple_mat'));
        fprintf('    ref might be: max(simple)=%d min(simple)=%d\n', max(simple_mat), min(simple_mat));
    end
end
