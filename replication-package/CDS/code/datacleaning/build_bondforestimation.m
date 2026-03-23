% build_bondforestimation.m
% Constructs bondforestimation.csv from bondtypes.csv
% bondforestimation contains auction-level aggregates of bond characteristics.
% Requires: data_path, int_path in workspace.

bt = readtable(fullfile(data_path,'bondtypes.csv'),'ReadVariableNames',true);

aucids = unique(bt.aucid);
nAuc = size(aucids,1);

out = zeros(nAuc, 14);

for ii = 1:nAuc
    a = aucids(ii);
    rows = bt(bt.aucid == a, :);
    n = size(rows,1);

    % Maturity in integer years (mature_year - auction_year)
    % NaN -> 50, negative -> 0, >50 -> 50
    mat_years = rows.mature_year - rows.auction_year(1);
    mat_years(isnan(mat_years)) = 50;
    mat_years(mat_years < 0) = 0;
    mat_years(mat_years > 50) = 50;
    maxmat = max(mat_years);
    minmat = min(mat_years);

    out(ii, 1)  = a;                                    % aucid
    out(ii, 2)  = rows.varvol(1);                       % varvol
    out(ii, 3)  = rows.totalvol(1);                     % totalvol
    out(ii, 4)  = mean(rows.duration);                  % meandur
    out(ii, 5)  = 1;                                    % tagauc
    out(ii, 6)  = mean(rows.convexity);                 % meanconv
    out(ii, 7)  = mean(rows.cf);                        % meancf
    out(ii, 8)  = maxmat;                               % maxtmaturity
    out(ii, 9)  = minmat;                               % mintmaturity
    out(ii, 10) = max(rows.couponnum);                  % maxcoupon
    out(ii, 11) = min(rows.couponnum);                  % mincoupon
    out(ii, 12) = mean(rows.floatingratenote);          % sharefrn
    out(ii, 13) = mean(rows.otherinst);                 % shareother
    out(ii, 14) = n;                                    % Nbonds
end

bondest = array2table(out, 'VariableNames', ...
    {'aucid','varvol','totalvol','meandur','tagauc','meanconv','meancf', ...
     'maxtmaturity','mintmaturity','maxcoupon','mincoupon','sharefrn','shareother','Nbonds'});

writetable(bondest, fullfile(int_path,'bondforestimation.csv'));
clear bt aucids nAuc out ii a rows n mat_years maxmat minmat;
