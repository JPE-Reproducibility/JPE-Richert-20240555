%% Job 0: Validate environment before committing resources
% Checks all paths, data files, code files, and MATLAB toolboxes
try
    fprintf('=== Validation Check ===\n');
    fprintf('Host: %s\n', getenv('HOSTNAME'));
    fprintf('PWD:  %s\n', pwd);
    fprintf('Date: %s\n\n', datestr(now));

    nfail = 0;

    %% Check data files
    data_path = fullfile(pwd, 'confidential-data-not-for-publication');
    data_files = {'bondtypes.csv', 'gosyop23q6grk5y1.csv', ...
                  'immspreads_clean.csv', 'openinterest_clean.csv', ...
                  'limitorders_clean.csv', 'auctionlistid.csv', ...
                  'bondforestimation.csv'};
    fprintf('--- Data files (%s) ---\n', data_path);
    for i = 1:length(data_files)
        f = fullfile(data_path, data_files{i});
        if exist(f, 'file')
            d = dir(f);
            fprintf('  OK  %-35s (%s)\n', data_files{i}, format_bytes(d.bytes));
        else
            fprintf('  FAIL %-35s NOT FOUND\n', data_files{i});
            nfail = nfail + 1;
        end
    end

    %% Check code directories
    fprintf('\n--- Code directories ---\n');
    code_dirs = {'code/computation', 'code/datacleaning', 'code/estimation', ...
                 'code/postestimation', 'code/cfs'};
    for i = 1:length(code_dirs)
        d = fullfile(pwd, code_dirs{i});
        if exist(d, 'dir')
            files = dir(fullfile(d, '*.m'));
            fprintf('  OK  %-30s (%d .m files)\n', code_dirs{i}, length(files));
        else
            fprintf('  FAIL %-30s NOT FOUND\n', code_dirs{i});
            nfail = nfail + 1;
        end
    end

    %% Check critical code files
    fprintf('\n--- Critical code files ---\n');
    critical = {'code/datacleaning/bondpriceimport.m', ...
                'code/datacleaning/data_summary.m', ...
                'code/datacleaning/normalize_prices.m', ...
                'code/estimation/npestimator.m', ...
                'code/estimation/complex_bootstrap.m', ...
                'code/estimation/complex_estimator_step1.m', ...
                'code/estimation/complex_estimator_step2.m', ...
                'code/estimation/complex_estimator_step2b.m', ...
                'code/estimation/v_correction.m', ...
                'code/estimation/complex_bootstrap_pe_outputs.m', ...
                'code/postestimation/postestimation_clean.m', ...
                'code/postestimation/robustnesschecks.m', ...
                'code/cfs/smc_cfs_yin.m', ...
                'code/cfs/postmain_cfs.m', ...
                'code/computation/nearestSPD.m'};
    for i = 1:length(critical)
        f = fullfile(pwd, critical{i});
        if exist(f, 'file')
            fprintf('  OK  %s\n', critical{i});
        else
            fprintf('  FAIL %s NOT FOUND\n', critical{i});
            nfail = nfail + 1;
        end
    end

    %% Check output directory is writable
    fprintf('\n--- Output directory ---\n');
    out_path = fullfile(pwd, 'output');
    test_dirs = {out_path, fullfile(out_path,'figures'), fullfile(out_path,'tables'), ...
                 fullfile(out_path,'logs'), fullfile(out_path,'intermediate'), ...
                 fullfile(out_path,'intermediate','positionschange')};
    for i = 1:length(test_dirs)
        if ~exist(test_dirs{i}, 'dir')
            mkdir(test_dirs{i});
        end
    end
    % Test write
    testfile = fullfile(out_path, 'intermediate', '_writetest.mat');
    x = 1; save(testfile, 'x'); delete(testfile);
    fprintf('  OK  output/ writable\n');

    %% Check MATLAB toolboxes
    fprintf('\n--- MATLAB toolboxes ---\n');
    v = ver;
    toolbox_names = {v.Name};
    needed = {'Parallel Computing Toolbox', 'Statistics and Machine Learning Toolbox'};
    for i = 1:length(needed)
        if any(strcmp(toolbox_names, needed{i}))
            fprintf('  OK  %s\n', needed{i});
        else
            fprintf('  WARN %s (not found)\n', needed{i});
            nfail = nfail + 1;
        end
    end
    % Direct test: can we create a parpool?
    try
        p = parpool('local', 2);
        delete(p);
        fprintf('  OK  parpool creation works\n');
    catch e
        fprintf('  FAIL parpool: %s\n', e.message);
        nfail = nfail + 1;
    end

    %% Try loading a small data file
    fprintf('\n--- Quick data load test ---\n');
    try
        t = readtable(fullfile(data_path, 'auctionlistid.csv'), 'ReadVariableNames', true);
        fprintf('  OK  auctionlistid.csv: %d rows, %d cols\n', size(t,1), size(t,2));
    catch e
        fprintf('  FAIL %s\n', e.message);
        nfail = nfail + 1;
    end

    %% Summary
    fprintf('\n========================================\n');
    if nfail == 0
        fprintf('  ALL CHECKS PASSED — safe to submit jobs\n');
    else
        fprintf('  %d CHECKS FAILED — fix before submitting\n', nfail);
    end
    fprintf('========================================\n');

    exit(nfail > 0);

catch e
    fprintf('\nFATAL ERROR: %s\n', e.message);
    fprintf('  %s line %d\n', e.stack(1).file, e.stack(1).line);
    exit(1);
end

function s = format_bytes(b)
    if b > 1e9
        s = sprintf('%.1f GB', b/1e9);
    elseif b > 1e6
        s = sprintf('%.1f MB', b/1e6);
    elseif b > 1e3
        s = sprintf('%.1f KB', b/1e3);
    else
        s = sprintf('%d B', b);
    end
end
