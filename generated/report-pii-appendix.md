## Appendix: Detailed PII Detection Results

*Generated on 2026-06-08 14:18:48*

This appendix lists all detected instances of potential personally identifiable information (PII) in the project files. Each entry shows the matched PII terms and, for data files, sample values to help verify whether the flagged content is indeed sensitive.

### Data Files

**/replication-package/CDS/confidential-data-not-for-publication/auctionlistid.csv**

- Variable: `name`
  - Matched terms: name
  - Sample values: Thomas Cook Group PLC, Top Gun Realisations, Steinhoff Europe AG

**/replication-package/CDS/confidential-data-not-for-publication/bondtypes.csv**

- Variable: `lockup`
  - Matched terms: loc
  - Sample values: 0, 1
- Variable: `name`
  - Matched terms: name
  - Sample values: Northwest Airlines, Inc., Delta Air Lines, Inc., Calpine Corporation

**/replication-package/CDS/confidential-data-not-for-publication/immspreads_clean.csv**

- Variable: `biddername`
  - Matched terms: name
  - Sample values: ubs, citigroup, merrilllynch

**/replication-package/CDS/confidential-data-not-for-publication/limitorders_clean.csv**

- Variable: `biddername`
  - Matched terms: name
  - Sample values: jpmorgan, ubs, barclays

**/replication-package/CDS/confidential-data-not-for-publication/openinterest_clean.csv**

- Variable: `biddername`
  - Matched terms: name
  - Sample values: suisse, goldmansachs, morganstanley

### Code Files

**/replication-package/CDS/code/cfs/doubleauctionOuter_1stepspecial_yin.m**

- Line 21: lat
  ```
  % 14 15 : correlation params
  ```
- Line 122: lat
  ```
  %here we calculate the vector of clearing prices and PclPq in each simulated auction
  ```
- Line 238: lat
  ```
  %Simulate new bids and clearing prices
  ```

**/replication-package/CDS/code/cfs/postmain_cfs.m**

- Line 67: lat
  ```
  % Save Table 5 as LaTeX
  ```

**/replication-package/CDS/code/cfs/smc_cfs_yin.m**

- Line 7: lat
  ```
  %get a correlation and a cdf of y+y^c
  ```
- Line 56: lat
  ```
  %match vat1 and vat5 correlations
  ```
- Line 60: lat
  ```
  %match noi and n correlations
  ```
- Line 142: block, loc
  ```
  blocks=2;
  ```
- Line 168: loc
  ```
  nuIloc=[1:1:B];
  ```
- Line 170: loc
  ```
  nuIloc=randsample([1:1:B],B,true,weightB);
  ```
- Line 171: loc
  ```
  nuj=thetaB(:,nuIloc);
  ```
- Line 177: block, loc
  ```
  %ASSIGN TO BLOCKS...L random blocks within block proposal density
  ```
- Line 180: block, loc
  ```
  if blocks>1
  ```
- Line 181: block, loc
  ```
  blockA=randi(blocks,Kp,1);
  ```
- Line 182: block, loc
  ```
  for l=1:blocks
  ```
- Line 183: block, loc
  ```
  covJ{l}=sigj(j).*cov(thetaB(blockA==l,:)')./max(max(cov(thetaB(blockA==l,:)')));
  ```
- Line 185: block, loc
  ```
  mvnpdf(thetaB(blockA==l,1),zeros(sum(blockA==l),1),covJ{l});
  ```
- Line 195: block, loc
  ```
  mbblock=cell(blocks,B,K+1);
  ```
- Line 198: block, loc
  ```
  for bbb=1:blocks
  ```
- Line 199: block, loc
  ```
  if sum(blockA==bbb)>0
  ```
- Line 200: block, loc
  ```
  mbblock{bbb,bO,kkO}=mvnrnd(zeros(sum(blockA==bbb),1),covJ{bbb})';
  ```
- Line 214: loc
  ```
  lnINold=lnfitOld(1,nuIloc(b));
  ```
- Line 218: block, loc
  ```
  if blocks==1
  ```
- Line 223: block, loc
  ```
  gx=zeros(1,blocks);
  ```
- Line 224: block, loc
  ```
  gxR=zeros(1,blocks);
  ```
- Line 225: block, loc
  ```
  for bb=1:blocks
  ```
- Line 226: block, loc
  ```
  if sum(blockA==bb)>0
  ```
- Line 227: block, loc
  ```
  x(blockA==bb)=xold(blockA==bb)+mbblock{bb,b,kk};
  ```
- Line 267: block, loc
  ```
  for bbb=1:blocks
  ```
- Line 268: block, loc
  ```
  if sum(blockA==bbb)>0
  ```
- Line 269: block, loc
  ```
  mbblock2{bbb}=mvnrnd(zeros(sum(blockA==bbb),1),covJ{bbb})';
  ```
- Line 278: block, loc
  ```
  for bb=1:blocks
  ```
- Line 279: block, loc
  ```
  if sum(blockA==bb)>0
  ```
- Line 280: block, loc
  ```
  xa(blockA==bb)=xold(blockA==bb)+mbblock2{bb};
  ```

**/replication-package/CDS/code/cfs/weightsolnpricespartialgridINTs1_yin.m**

- Line 21: lon
  ```
  Pownlong=Pown(:);
  ```

**/replication-package/CDS/code/computation/BsplineBasis3.m**

- Line 35: city
  ```
  %knots of multiplicity>1. If the user wishes to suppress these warning
  ```
- Line 54: second
  ```
  %   3) Similarly, Ydblprime (TxK+3) contains second derivatives of the
  ```
- Line 74: son
  ```
  %%%%We use coincident boundary knots for reasons that will become  clear
  ```
- Line 81: degree
  ```
  %%%%Begin with the order 1 (degree d=0) B-spline basis, defined by
  ```
- Line 85: degree
  ```
  %%%%Then, to compute the order d+1 spline basis (of degree d>0), we use
  ```
- Line 118: city, second
  ```
  warning('BsplineBasis3:C2Fail','existence of knots with multiplicity at least two implies discontinu
  ```
- Line 123: city
  ```
  warning('BsplineBasis3:C1Fail','existence of knots with multiplicity at least three implies disconti
  ```
- Line 153: degree
  ```
  D = 3;  %%%%This is the degree of the spline basis functions to be computed
  ```
- Line 162: degree
  ```
  %%%%This first loop computes the first order basis functions (of degree
  ```
- Line 165: degree
  ```
  d0=order1-1; %%%%d stands for "degree"
  ```
- Line 180: degree, second
  ```
  %%%%This second loop computes the second order basis functions (of degree
  ```
- Line 183: degree
  ```
  d1 = order2-1; %%%%d stands for "degree"
  ```
- Line 193: second
  ```
  elseif x(indx+d1+1)-x(indx+1)==0;  %%%%Here we check for zero denominator in the second term
  ```
- Line 200: degree
  ```
  %%%%This third loop computes the third order basis functions (of degree
  ```
- Line 203: degree
  ```
  d2 = order3-1; %%%%d stands for "degree"
  ```
- Line 213: second
  ```
  elseif x(indx+d2+1)-x(indx+1)==0;  %%%%Here we check for zero denominator in the second term
  ```
- Line 220: degree
  ```
  %%%%This fourth loop computes the fourth order basis functions (of degree
  ```
- Line 223: degree
  ```
  d3 = order4-1; %%%%d stands for "degree"
  ```
- Line 233: second
  ```
  %%%%This loop initiates the second derivatives matrix if called for.
  ```
- Line 235: second
  ```
  Ydblprime = zeros(size(B3)); %%%%The variable Yprime here will contain the second derivatives of the
  ```
- Line 246: second
  ```
  %%%%Here we compute the second derivatives, if called for
  ```
- Line 256: second
  ```
  elseif x(indx+d3+1)-x(indx+1)==0;  %%%%Here we check for zero denominator in the second term
  ```
- Line 262: second
  ```
  %%%%Here we compute the second derivatives, if called for
  ```
- Line 278: second
  ```
  %%%%Here we compute the second derivatives, if called for, checking for the relevant zero denominato
  ```

**/replication-package/CDS/code/computation/BsplineEval3.m**

- Line 14: second
  ```
  %contain the first, second, and/or third derivatives of f at the points in
  ```

**/replication-package/CDS/code/computation/cdf_estimator.m**

- Line 5: lat
  ```
  %missing is something for bounding correlations--both across v-qg and with
  ```

**/replication-package/CDS/code/computation/cdf_estimator_imm.m**

- Line 5: lat
  ```
  %missing is something for bounding correlations--both across v-qg and with
  ```
- Line 85: lat
  ```
  %calculate averages
  ```

**/replication-package/CDS/code/computation/dscatter.m**

- Line 4: loc, location
  ```
  %   DSCATTER(X,Y) creates a scatterplot of X and Y at the locations
  ```
- Line 40: lon, name
  ```
  %       xlabel(params(1).LongName); ylabel(params(2).LongName);
  ```
- Line 63: name
  ```
  'Incorrect number of arguments to %s.',mfilename);
  ```
- Line 67: name
  ```
  pname = varargin{j};
  ```
- Line 69: name
  ```
  k = strmatch(lower(pname), okargs); %#ok
  ```
- Line 71: name
  ```
  error('Bioinfo:UnknownParameterName',...
  ```
- Line 72: name
  ```
  'Unknown parameter name: %s.',pname);
  ```
- Line 74: name
  ```
  error('Bioinfo:AmbiguousParameterName',...
  ```
- Line 75: name
  ```
  'Ambiguous parameter name: %s.',pname);
  ```
- Line 130: lon
  ```
  % Reverse the columns to put the first column of X along the horizontal
  ```
- Line 131: lon, second
  ```
  % axis, the second along the vertical.
  ```

**/replication-package/CDS/code/computation/emcdf.m**

- Line 2: lat
  ```
  %Calculate empirical dist...transform and max
  ```

**/replication-package/CDS/code/computation/heatscatter.m**

- Line 3: name
  ```
  %% heatscatter(X, Y, outpath, outname, numbins, markersize, marker, plot_colorbar, plot_lsf, xlab, y
  ```
- Line 9: name
  ```
  %            outname            name of the output-file. if outname contains
  ```
- Line 15: lat
  ```
  %                                heat3-calculation, thus the coloring
  ```
- Line 26: lat
  ```
  %                                the correlation/p-value of the data
  ```
- Line 44: name
  ```
  if ~exist('outname','var') || isempty(outname)
  ```
- Line 45: name
  ```
  error('Param outname is mandatory! --> EXIT!');
  ```
- Line 177: name
  ```
  [p,n,r] = fileparts(outname);
  ```
- Line 181: name
  ```
  outname = strcat(p,n,r);
  ```
- Line 182: name
  ```
  outfile = fullfile(outpath, outname);
  ```

**/replication-package/CDS/code/computation/jacobianest.m**

- Line 10: loc, location
  ```
  %  x0  - vector location at which to differentiate fun
  ```
- Line 91: lat
  ```
  relativedelta = MaxStep*StepRatio .^(0:-1:-25);
  ```
- Line 92: lat
  ```
  nsteps = length(relativedelta);
  ```
- Line 100: lat
  ```
  delta = x0_i*relativedelta;
  ```
- Line 102: lat
  ```
  delta = relativedelta;
  ```
- Line 107: second
  ```
  % difference to give a second order estimate
  ```
- Line 116: second
  ```
  % these are pure second order estimates of the
  ```
- Line 120: second
  ```
  % The error term on these estimates has a second order
  ```
- Line 122: lat
  ```
  % Use Romberg exrapolation to improve the estimates to
  ```
- Line 157: lat
  ```
  % subfunction - romberg extrapolation
  ```
- Line 160: lat
  ```
  % do romberg extrapolation for each estimate
  ```
- Line 180: lat
  ```
  % qr factorization used for the extrapolation as well
  ```
- Line 187: lat
  ```
  % this does the extrapolation to a zero step size.
  ```

**/replication-package/CDS/code/computation/permn.m**

- Line 87: son
  ```
  %    out by Wilson).
  ```
- Line 89: name
  ```
  % 5.0 (may 2015) NAME CHANGED (COMBN -> PERMN) and updated description,
  ```
- Line 92: lat
  ```
  % 5.1 (may 2015) always calculate M via indices
  ```
- Line 99: second
  ```
  error('permn:negativeN','Second argument should be a positive integer') ;
  ```

**/replication-package/CDS/code/computation/table2latex.m**

- Line 2: lat, name
  ```
  % Function table2latex(T, filename) converts a given MATLAB(R) table into %
  ```
- Line 3: lat
  ```
  % a plain .tex file with LaTeX formatting.                                %
  ```
- Line 9: name
  ```
  %       - filename: (Optional) Output path, including the name of the file.
  ```
- Line 14: name, son
  ```
  %       LastName = {'Sanchez';'Johnson';'Li';'Diaz';'Brown'};             %
  ```
- Line 20: name
  ```
  %       T.Properties.RowNames = LastName;                                 %
  ```
- Line 21: lat
  ```
  %       table2latex(T);                                                   %
  ```
- Line 32: name
  ```
  filename = 'table.tex';
  ```
- Line 33: name
  ```
  fprintf('Output path is not defined. The table will be written in %s.\n', filename);
  ```
- Line 34: name
  ```
  elseif ~ischar(filename)
  ```
- Line 35: name
  ```
  error('The output file name must be a string.');
  ```
- Line 37: name
  ```
  if ~strcmp(filename(end-3:end), '.tex')
  ```
- Line 38: name
  ```
  filename = [filename '.tex'];
  ```
- Line 48: name
  ```
  col_names = strjoin(T.Properties.VariableNames, ' & ');
  ```
- Line 49: name
  ```
  row_names = T.Properties.RowNames;
  ```
- Line 50: name
  ```
  if ~isempty(row_names)
  ```
- Line 52: name
  ```
  col_names = ['& ' col_names];
  ```
- Line 56: name
  ```
  fileID = fopen(filename, 'w');
  ```
- Line 58: name
  ```
  fprintf(fileID, '%s \\\\ \n', col_names);
  ```
- Line 72: name
  ```
  if ~isempty(row_names)
  ```
- Line 73: name
  ```
  temp = [row_names{row}, temp];
  ```

**/replication-package/CDS/code/computation/weightedMedian.m**

- Line 3: lat
  ```
  % Function for calculating the weighted median
  ```
- Line 39: lat
  ```
  sumVec = [];    % vector for cumulative sums of the weights
  ```
- Line 51: lat
  ```
  % final test to exclude errors in calculation
  ```
- Line 54: lat
  ```
  'The weighted median could not be calculated.');
  ```

**/replication-package/CDS/code/computation/weightedcorrs.m**

- Line 3: lat
  ```
  %   WEIGHTEDCORRS returns a symmetric matrix R of weighted correlation
  ```
- Line 30: lat
  ```
  %   "Exponential smoothing weighted correlations",
  ```
- Line 47: lat
  ```
  %   Y(:, 2) = rand * Y(:, 1) + rand;                                              % Linear relation
  ```
- Line 49: lat
  ```
  %   r1 = r1(2)                                                                    % Traditional Corr
  ```
- Line 51: lat
  ```
  %   r2 = r2(2)                                                                    % Weighted Correla
  ```
- Line 53: lat
  ```
  % % b) An horizontal line has a correlation equal to 0
  ```
- Line 55: lat
  ```
  %   Y(:, 2) = 1:T;                                                                % Linear relation
  ```
- Line 57: lat
  ```
  %   r1 = r1(2)                                                                    % Traditional Corr
  ```
- Line 59: lat
  ```
  %   r2 = r2(2)                                                                    % Weighted Correla
  ```
- Line 61: lat
  ```
  % % c) A vertical line has a correlation equal to 0
  ```
- Line 63: lat
  ```
  %   Y(:, 2) = rand;                                                               % Linear relation
  ```
- Line 65: lat
  ```
  %   r1 = r1(2)                                                                    % Traditional Corr
  ```
- Line 67: lat
  ```
  %   r2 = r2(2)                                                                    % Weighted Correla
  ```
- Line 71: lat
  ```
  %   Y(:, 2) = rand * Y(:, 1) .^ 2 + rand;                                         % Parabolic relati
  ```
- Line 73: lat
  ```
  %   r1 = r1(2)                                                                    % Traditional Corr
  ```
- Line 75: lat
  ```
  %   r2 = r2(2)                                                                    % Weighted Correla
  ```
- Line 83: lat
  ```
  %   r1 = r1(2)                                                                    % Traditional Corr
  ```
- Line 85: lat
  ```
  %   r2 = r2(2)                                                                    % Weighted Correla
  ```
- Line 89: lat
  ```
  %   Y(:, 2) = exp(3 * (1:T) / T);                                                 % Exponential rela
  ```
- Line 91: lat
  ```
  %   r1 = r1(2)                                                                    % Traditional Corr
  ```
- Line 93: lat
  ```
  %   r2 = r2(2)                                                                    % Weighted Correla
  ```
- Line 97: lat
  ```
  %   Y(:, 2) = log(1:T);                                                           % Logarithmic rela
  ```
- Line 99: lat
  ```
  %   r1 = r1(2)                                                                    % Traditional Corr
  ```
- Line 101: lat
  ```
  %   r2 = r2(2)                                                                    % Weighted Correla
  ```
- Line 106: lat
  ```
  % % EXAMPLE 1: verify some of the properties for weighted correlations.
  ```
- Line 109: lat
  ```
  % % GENERATE CORRELATED STOCHASTIC PROCESSES
  ```
- Line 115: lat
  ```
  % Y = cumsum(Y);                                                                % correlated stochas
  ```
- Line 122: lat
  ```
  % % COMPUTE CORRELATION MATRIX
  ```
- Line 123: lat
  ```
  %   r1 = weightedcorrs(Y, w);                                                     % Weighted Correla
  ```
- Line 125: lat
  ```
  % % COMPUTE CORRELATION MATRIX FOR MODIFIED DATA
  ```
- Line 128: lat
  ```
  %   r2 = weightedcorrs(a * Y + b, w);                                             % Weighted Correla
  ```
- Line 137: son
  ```
  %   plot(r1(indexes), r2(indexes), '*', 'MarkerSize', 6);                         % Comparison betwe
  ```
- Line 138: lat
  ```
  %   title('Identical correlations for Y and a * Y + b', ...                       % title label for 
  ```
- Line 140: lat
  ```
  %   xlabel('Correlations for Y', 'FontSize', 16, 'FontWeight', 'Bold');
  ```
- Line 141: lat
  ```
  %   ylabel('Correlations for modified Y = a * Y + b', ...
  ```
- Line 147: lat
  ```
  % % OF THE TWO CORRELATION MATRICES
  ```
- Line 150: lat
  ```
  %   title('Identical correlations for Y and a * Y + b', ...                       % title label for 
  ```
- Line 171: lat
  ```
  % % GENERATE CORRELATED STOCHASTIC PROCESSES
  ```
- Line 177: lat
  ```
  %   Y = cumsum(Y);                                                                % correlated stoch
  ```
- Line 184: lat
  ```
  % % COMPUTE CORRELATION MATRIX
  ```
- Line 185: lat
  ```
  %   r1 = weightedcorrs(Y, w);                                                     % Weighted Correla
  ```
- Line 187: lat
  ```
  % % COMPUTE CORRELATION MATRIX FOR MODIFIED DATA
  ```
- Line 190: lat
  ```
  %   r2 = weightedcorrs(repmat(a, T, 1) .* Y + repmat(b, T, 1), w);                % Weighted Correla
  ```
- Line 199: son
  ```
  %   plot(r1(indexes), r2(indexes), '*', 'MarkerSize', 6);                         % Comparison betwe
  ```
- Line 200: lat
  ```
  %   str = 'Identical correlations after arbitrary affine transformations';
  ```
- Line 202: lat
  ```
  %   xlabel('Correlations for Y', 'FontSize', 16, 'FontWeight', 'Bold');
  ```
- Line 203: lat
  ```
  %   ylabel('Correlations for modified Y', ...
  ```
- Line 209: lat
  ```
  % % OF THE TWO CORRELATION MATRICES
  ```
- Line 212: lat
  ```
  %   title('Identical correlations for Y and modified Y', ...                      % title label for 
  ```
- Line 221: lat
  ```
  % % Example 3: differences with respect to traditional correlations.
  ```
- Line 224: lat
  ```
  % % GENERATE CORRELATED STOCHASTIC PROCESSES
  ```
- Line 230: lat
  ```
  %   Y = cumsum(Y);                                                                % correlated stoch
  ```
- Line 250: lat
  ```
  % % COMPUTE CORRELATION MATRICES
  ```
- Line 251: lat
  ```
  %   r1 = weightedcorrs(Y, w);                                                     % Weighted Correla
  ```
- Line 252: lat
  ```
  %   r2 = corrcoef(Y);                                                             % Traditional Corr
  ```
- Line 259: lat, son
  ```
  %   plot(r1(indexes), r2(indexes), '.');                                          % Comparison with 
  ```
- Line 262: lat
  ```
  %   title('Scatter Diagram for Traditional and Weighted Correlations', ...        % title label for 
  ```
- Line 264: lat
  ```
  %   xlabel('Weighted Correlation coefficients', ...                               % x label ...
  ```
- Line 266: lat
  ```
  %   ylabel('Traditional Correlation coefficients', ...                            % y label ...
  ```
- Line 272: lat
  ```
  % % OF THE TWO CORRELATION MATRICES
  ```
- Line 274: lat
  ```
  %   hist(r2(indexes) - r1(indexes), 100);                                         % Differences betw
  ```
- Line 275: lat
  ```
  %   title('Differences between Traditional and Weighted Correlations', ...        % title label for 
  ```
- Line 278: lat
  ```
  %   xlabel('Differences between Traditional and Weighted Correlations', ...       % x label ...
  ```
- Line 285: lat
  ```
  % % Example 4: If weights are uniform, then the traditional correlation
  ```
- Line 289: lat
  ```
  % % GENERATE CORRELATED STOCHASTIC PROCESSES
  ```
- Line 295: lat
  ```
  %   Y = cumsum(Y);                                                                % correlated stoch
  ```
- Line 310: lat
  ```
  % % COMPUTE CORRELATION MATRICES
  ```
- Line 311: lat
  ```
  %   r1 = weightedcorrs(Y, w);                                                     % Weighted Correla
  ```
- Line 312: lat
  ```
  %   r2 = corrcoef(Y);                                                             % Traditional Corr
  ```
- Line 321: lat, son
  ```
  %   plot(r1(indexes), r2(indexes), '*', 'MarkerSize', 6);                         % Comparison with 
  ```
- Line 322: lat
  ```
  %   title('Scatter Diagram for Traditional and Weighted Correlations', ...        % title label for 
  ```
- Line 324: lat
  ```
  %   xlabel('Weighted Correlation coefficients (uniform weights!!!)', ...          % x label ...
  ```
- Line 326: lat
  ```
  %   ylabel('Traditional Correlation coefficients', ...                            % y label ...
  ```
- Line 332: lat
  ```
  % % OF THE TWO CORRELATION MATRICES
  ```
- Line 334: lat
  ```
  %   hist(r2(indexes) - r1(indexes), 100);                                         % Difference betwe
  ```
- Line 336: lat
  ```
  %   temp(2, :) = 'Correlation coefficients (uniform weights!!!)';
  ```
- Line 345: lat
  ```
  % % Example 5: more reliable dynamic correlations (it may take some mins):
  ```
- Line 349: lat
  ```
  % % GENERATE CORRELATED STOCHASTIC PROCESSES
  ```
- Line 355: lat
  ```
  %   Y = cumsum(Y);                                                                % correlated stoch
  ```
- Line 367: lat
  ```
  % % COMPUTE DYNAMIC CORRELATION MATRICES
  ```
- Line 369: lat
  ```
  %     temp = weightedcorrs(Y(i:(delta + i - 1), :), w);                           % Dynamic Weighted
  ```
- Line 371: lat
  ```
  %     temp = corrcoef(Y(i:(delta + i - 1), :));                                   % Dynamic Traditio
  ```
- Line 375: lat
  ```
  % % PLOT THE AVERAGE CORRELATIONS, BOTH WEIGHTED AND TRADITIONAL
  ```
- Line 380: lat
  ```
  %   title('Moving Average Correlations', ...                                      % title label for 
  ```
- Line 383: lat
  ```
  %   temp = '       Moving Average Correlations       ';
  ```
- Line 394: lat
  ```
  % % GENERATE CORRELATED STOCHASTIC PROCESSES
  ```
- Line 400: lat
  ```
  %   Y = cumsum(Y);                                                                % correlated stoch
  ```
- Line 426: second
  ```
  %       sprintf('Weights centered on t = %d', floor(T / 2)), ...                  % ... second item 
  ```
- Line 428: loc, location
  ```
  %       'Location', 'North');                                                     % Legend Location
  ```
- Line 430: lat
  ```
  % % COMPUTE CORRELATIONS FOR EACH POSSIBLE CENTRAL OBSERVATION
  ```
- Line 434: lat
  ```
  %      temp = weightedcorrs(Y, w);                                                % Weighted Correla
  ```
- Line 440: lat
  ```
  % % PLOT CENTERED CORRELATION FOR EACH POSSIBLE CENTRAL OBSERVATION
  ```
- Line 445: lat
  ```
  %   title('Correlations with bell-shaped weights', ...                            % title label for 
  ```
- Line 448: lat
  ```
  %   ylabel(['   Correlations with bell-shaped weights  '; ...                     % y label, first l
  ```
- Line 449: second
  ```
  %       'centered on different Central Observations'], ...                        % y label, second 
  ```
- Line 454: lat
  ```
  % % PLOT HISTOGRAM OF CENTERED CORRELATIONS COMPUTED
  ```
- Line 458: lat
  ```
  %   title(['     Histogram of the correlation computed with      '; ...           % title label, fir
  ```
- Line 459: second
  ```
  %       'bell-shaped weights on different Central Observations'], ...             % title label, sec
  ```
- Line 462: lat
  ```
  %   xlabel('Correlation', 'FontSize', 16, 'FontWeight', 'Bold');
  ```
- Line 506: lat
  ```
  R = temp ./ sqrt(R * R');                                                     % Matrix of Weighted C
  ```

**/replication-package/CDS/code/datacleaning/acrossrounds.m**

- Line 127: second
  ```
  %and lose in secondary? )
  ```

**/replication-package/CDS/code/datacleaning/bondpriceimport.m**

- Line 5: name
  ```
  bondtypes=(readtable(fullfile(data_path,'bondtypes.csv'),'ReadVariableNames',true));
  ```
- Line 7: loc
  ```
  bondidlocs_short=table2array(bondtypes(:,10));
  ```
- Line 8: loc
  ```
  aucidbonds=[]; bonddlocs=table(repmat(bondidlocs_short,6,1));
  ```
- Line 12: loc
  ```
  for kk=1:size(bondidlocs_short,1)
  ```
- Line 13: loc
  ```
  bt={bondidlocs_short{kk}; bondidlocs_short{kk}(1:end-1);bondidlocs_short{kk}(2:end);bondidlocs_short
  ```
- Line 14: loc
  ```
  bonddlocs(count:count+size(bt,1)-1,:)=array2table(bt);
  ```
- Line 18: loc
  ```
  writetable(bonddlocs,fullfile(int_path,'bondpermutations.txt'));
  ```
- Line 24: name
  ```
  %    filename: gosyop23q6grk5y1.csv (in data_path)
  ```
- Line 35: name
  ```
  % Specify column names and types
  ```
- Line 36: name
  ```
  opts.VariableNames = ["cusip_id1", "bond_sym_id1", "company_symbol1", "date", "tradetime", "quantity
  ```
- Line 66: loc
  ```
  bonddlocs=table2array(bonddlocs);
  ```
- Line 68: loc
  ```
  for jk=1:size(bonddlocs,1) %added ,1
  ```
- Line 69: loc
  ```
  if isequal(bonddlocs{jk},bondslist(ii))
  ```
- Line 84: name
  ```
  auctionlistid=(readtable(fullfile(data_path,'auctionlistid.csv'),'ReadVariableNames',true));
  ```

**/replication-package/CDS/code/datacleaning/bondprices.m**

- Line 27: lat
  ```
  %this interpolates the price and Sd and replaces zeros in vol ntrade
  ```

**/replication-package/CDS/code/datacleaning/build_bondforestimation.m**

- Line 6: name
  ```
  bt = readtable(fullfile(data_path,'bondtypes.csv'),'ReadVariableNames',true);
  ```
- Line 43: name
  ```
  bondest = array2table(out, 'VariableNames', ...
  ```

**/replication-package/CDS/code/datacleaning/data_summary.m**

- Line 5: name
  ```
  immtab=(readtable(fullfile(data_path,'immspreads_clean.csv'),'ReadVariableNames',true));
  ```
- Line 6: name
  ```
  noitab=(readtable(fullfile(data_path,'openinterest_clean.csv'),'ReadVariableNames',true));
  ```
- Line 7: name
  ```
  supplyfunctab=(readtable(fullfile(data_path,'limitorders_clean.csv'),'ReadVariableNames',true));
  ```
- Line 8: name
  ```
  auctionpriceT=readtable(fullfile(data_path,'auctionlistid.csv'),'ReadVariableNames',true);
  ```
- Line 31: name
  ```
  bondest=readtable(fullfile(int_path,'bondforestimation.csv'),'ReadVariableNames',true);
  ```
- Line 33: block, loc
  ```
  %IF SOVEREIGNS ARE OUT RUN TTHIS BLOCK AS WELL!
  ```
- Line 64: lat
  ```
  % Save Table OS.1 as LaTeX
  ```
- Line 91: lat
  ```
  %IMM calculation
  ```
- Line 112: name
  ```
  pd_noi_names = table2array(noitab(table2array(noitab(:,3))==pd_aucid, 1));
  ```
- Line 114: name
  ```
  % Match NOI values to IMM bidder order by name
  ```
- Line 117: name
  ```
  idx = find(strcmp(pd_noi_names, pd_bidders{ii}));
  ```
- Line 134: lat
  ```
  % Save Table 1 as LaTeX
  ```
- Line 157: name
  ```
  % Rows are placed in the paper's order (IDs 1-9) with proper dealer names. As in
  ```
- Line 164: name
  ```
  t2_name = {'Barclays Bank PLC';'BNP Paribas SA';'Credit Suisse';'Deutsche Bank'; ...
  ```
- Line 185: name
  ```
  fprintf('  %-3s %-44s %6s %6s   %5s %6s   %5s %6s\n', 'ID','Name','Bid','Offer','SrtID','Bid','SrtID
  ```
- Line 187: name
  ```
  fprintf('  %-3d %-44s %6g %6g   %5d %6g   %5d %6g\n', ii, t2_name{ii}, ...
  ```
- Line 192: lat
  ```
  % Save Table 2 as LaTeX (Submissions | Sorted Bids | Sorted Offers)
  ```
- Line 198: name
  ```
  fprintf(fid, 'ID & Name & Bid & Offer & ID & Bid & ID & Offer \\\\\n\\hline\n');
  ```
- Line 200: name
  ```
  fprintf(fid, '%d & %s & %g & %g & %d & %g & %d & %g \\\\\n', ii, t2_name{ii}, ...
  ```
- Line 228: name
  ```
  OS3_varnames = {'Auction price','IMM price','Constant'};
  ```
- Line 231: name
  ```
  fprintf('%-20s %8.2f (%4.2f) %8.2f (%4.2f) %8.2f (%4.2f)\n', OS3_varnames{ii}, ...
  ```
- Line 235: lat
  ```
  % Save Table OS.3 as LaTeX
  ```
- Line 241: name
  ```
  fprintf(fid, '%s & %.2f & %.2f & %.2f \\\\\n', OS3_varnames{ii}, be30(ii), be5(ii), be1(ii));
  ```
- Line 318: second
  ```
  %second column # positive first stage NOI
  ```
- Line 336: name
  ```
  T.Properties.VariableNames = {'Bidder','Participated','y_i>0','y_i<0','1 step','2 steps','3 steps','
  ```
- Line 340: lat
  ```
  % Save Table OS.2 as LaTeX
  ```
- Line 385: lat
  ```
  %walk through the auctions and bidders---for each one calculate
  ```

**/replication-package/CDS/code/datacleaning/firststagebidding.m**

- Line 16: loc
  ```
  loc=find(bondid==tempid);
  ```
- Line 17: loc
  ```
  if isempty(loc)==0
  ```
- Line 18: loc
  ```
  Bondvol(aucidfs==tempid)=bondvol(loc);
  ```
- Line 19: loc
  ```
  Bonddur(aucidfs==tempid)=bonddur(loc);
  ```
- Line 20: loc
  ```
  Bondconv(aucidfs==tempid)=bondconv(loc);
  ```
- Line 21: loc
  ```
  Bondcf(aucidfs==tempid)=bondcf(loc);
  ```
- Line 31: lat
  ```
  %calculate imm/noi
  ```
- Line 46: lat
  ```
  %calculate adjustment amounts
  ```
- Line 65: lat
  ```
  %auctionprice--relate to the first stage bidding
  ```
- Line 96: lat
  ```
  ylabel('$p^M$','Interpreter','latex')
  ```

**/replication-package/CDS/code/datacleaning/normalize_prices.m**

- Line 29: lon
  ```
  NOIabslong(aucidfs==aucidfslist(k))=NOIabs(k,1);
  ```
- Line 30: lon
  ```
  NOIlong(aucidfs==aucidfslist(k))=NOI(k,1);
  ```
- Line 33: lon
  ```
  NOIsh=(NOIlong(aaa)'./(Bondvol(aaa)));
  ```
- Line 99: lon
  ```
  carriedoverp(NOIlong'>0,:)=carriedoverp(NOIlong'>0,:)./imm1cap(NOIlong'>0);
  ```
- Line 100: lon
  ```
  carriedoverp(NOIlong'<0,:)=((carriedoverp(NOIlong'<0,:))./imm1cap(NOIlong'<0));
  ```
- Line 101: lon
  ```
  carriedoverq=carriedoverq./abs(NOIlong');
  ```
- Line 246: lat
  ```
  % Save Table 3 as LaTeX
  ```
- Line 274: second
  ```
  fprintf('  Auctions with no second stage (NOI=0): %d\n', sum(NOI==0))
  ```
- Line 276: lon
  ```
  repurchase_rate = sum((sign(maxQi)'~=sign(NOIlong))'.*(sign(NOIlong')==sign(noi)))./sum((sign(NOIlon
  ```
- Line 283: lon
  ```
  bwNOI=1.06.*((prctile(NOIlong,75)-prctile(NOIlong,25))./1.34).*(max(size(NOIlong))).^(-1./5);
  ```
- Line 284: lon
  ```
  qw_fv=nansum(qw_newbid'.*normpdf((imm-imm')./bwimm).*(normpdf((NOIlong-NOIlong')./bwNOI)),2)./sum((i
  ```
- Line 293: lon
  ```
  [b,ci,~,~,stats1]=regress(immhigh,[Bonddur' Bondcf' Bondconv' (Bondvol./1e6)' NOIlong' global_bidder
  ```
- Line 298: name
  ```
  OS4_varnames = {'Duration','Conversion','Convexity','Volume','Global Dealer'};
  ```
- Line 299: name
  ```
  for ii=1:5; fprintf('  %-20s %8.3f (%6.3f)\n', OS4_varnames{ii}, OS4_col1(ii,1), OS4_col1(ii,2)); en
  ```
- Line 309: name
  ```
  for ii=1:5; fprintf('  %-20s %8.3f (%6.3f)\n', OS4_varnames{ii}, OS4_col2(ii,1), OS4_col2(ii,2)); en
  ```
- Line 310: lat
  ```
  % Save Table OS.4 as LaTeX
  ```
- Line 316: name
  ```
  fprintf(fid, '%s & %.2f & %.2f \\\\\n', OS4_varnames{ii}, OS4_col1(ii,1), OS4_col2(ii,1));
  ```
- Line 349: name
  ```
  OS5_varnames = {'Duration','Conversion','Convexity','Volume','NOI','IMM','IMM^2','Constant'};
  ```
- Line 351: name
  ```
  for ii=1:8; fprintf('  %-15s %10.4f (%8.4f)\n', OS5_varnames{ii}, b1(ii), se1(ii)); end
  ```
- Line 352: name
  ```
  OS5b_varnames = {'Duration','Conversion','Convexity','Volume','NOI','Constant'};
  ```
- Line 354: name
  ```
  for ii=1:6; fprintf('  %-15s %10.4f (%8.4f)\n', OS5b_varnames{ii}, b2(ii), se2(ii)); end
  ```
- Line 355: lat
  ```
  % Save Table OS.5 as LaTeX
  ```
- Line 361: name
  ```
  fprintf(fid, '%s & %.3f & %.2f \\\\\n', OS5_varnames{ii}, b1(ii), b2(ii));
  ```
- Line 390: lon
  ```
  X=[br_Nsteps' br_auc_noi' br_noi' ones(size(NOIlong'))];
  ```
- Line 393: name
  ```
  A1_P1_varnames = {'IMM var.','N steps','Auction NOI','Own NOI','Constant'};
  ```
- Line 394: name
  ```
  for ii=1:5; fprintf('  %-15s %8.3f (%6.3f)\n', A1_P1_varnames{ii}, b(ii), se(ii)); end
  ```
- Line 400: lon
  ```
  X=[(br_imm-br_auc_imm)' br_Nsteps' br_auc_noi' br_noi' ones(size(NOIlong')) br_maxbidq'];
  ```
- Line 419: lat
  ```
  % Save Table A.1 as LaTeX
  ```

**/replication-package/CDS/code/estimation/basic_estimator.m**

- Line 1: lon
  ```
  function [vout,nout]=basic_estimator(supplyp,supplyq,idfs,idss,ndraw,NOItotexp,noi,Npossibleexp,supp
  ```
- Line 29: lat
  ```
  %First loop through the data: calculate value and position estimates%
  ```
- Line 56: lat
  ```
  % calculate the clearing price
  ```
- Line 78: lon
  ```
  %get clearing price if q+epsilon here bid instead
  ```
- Line 87: lon
  ```
  %adding 2 epsilon
  ```
- Line 96: lon
  ```
  %and instead subtracting epsilon...
  ```
- Line 105: lon
  ```
  %subtracting 2 epsilon
  ```
- Line 127: lat
  ```
  % calculate the clearing price
  ```
- Line 136: lat
  ```
  %CALCULATE PRICE LEVEL FOR CURRENT AUCTION
  ```
- Line 144: lon
  ```
  %now get the clearing prices at -epsilon, +epsilon on i's prices: because
  ```
- Line 148: lon
  ```
  epsilonp=0.125./imp;
  ```
- Line 149: lon
  ```
  [bidsp, ic]=sort(direction.*[reshape(supplyp2(drawnids{kk},:),ndraw,(Npossibleexp(kk)-1)*size(supply
  ```
- Line 160: lat
  ```
  % calculate the clearing price
  ```
- Line 171: lon
  ```
  %and minus epsilonp
  ```
- Line 172: lon
  ```
  [bidsp, ic]=sort(direction.*[reshape(supplyp2(drawnids{kk},:),ndraw,(Npossibleexp(kk)-1)*size(supply
  ```
- Line 183: lat
  ```
  % calculate the clearing price
  ```
- Line 227: lon
  ```
  ownbidq=ownbidq.*(abs(NOIlong(kk)));
  ```
- Line 235: lon
  ```
  ownbidq(ownbidq>NOIlong(kk))=NOIlong(kk);
  ```
- Line 237: lon
  ```
  ownbidq(ownbidq<NOIlong(kk))=NOIlong(kk);
  ```
- Line 298: lon
  ```
  posib=(abs(ownbidq_cum)<=abs(NOIlong(kk)));
  ```
- Line 304: lat
  ```
  %calculate probabilities and derivative
  ```
- Line 341: lon
  ```
  dProb(aa,1)=(-Probplpl(aa,1)+8*Probpl(aa,1)-8*Probm(aa,1)+Probmm(aa,1))./(12.*empdir.*(abs(NOIlong(k
  ```
- Line 346: lon
  ```
  dEpcond(aa,1)=(-Epclplpl(aa,1)+8*Epclpl(aa,1)-8*Epclm(aa,1)+Epclmm(aa,1))./(12.*empdir.*(abs(NOIlong
  ```
- Line 354: lon
  ```
  dEpcl(aa,1)=(-dEpp(aa,1)+8*dEp(aa,1)-8*dEm(aa,1)+dEmm(aa,1))./(12.*empdir.*(abs(NOIlong(kk))));
  ```
- Line 371: lon
  ```
  dProb(aa,1)=(-Probplpl(aa,1)+8*Probpl(aa,1)-8*Probm(aa,1)+Probmm(aa,1))./(12.*empdir.*(abs(NOIlong(k
  ```
- Line 377: lon
  ```
  dEpcond(aa,1)=(-Epclplpl(aa,1)+8*Epclpl(aa,1)-8*Epclm(aa,1)+Epclmm(aa,1))./(12.*empdir.*(abs(NOIlong
  ```
- Line 385: lon
  ```
  dEpcl(aa,1)=(-dEpp(aa,1)+8*dEp(aa,1)-8*dEm(aa,1)+dEmm(aa,1))./(12.*empdir.*(abs(NOIlong(kk))));
  ```
- Line 403: lon
  ```
  dProb(aa,1)=(-Probplpl(aa,1)+8*Probpl(aa,1)-8*Probm(aa,1)+Probmm(aa,1))./(12.*empdir.*(abs(NOIlong(k
  ```
- Line 414: lon
  ```
  dEpcond(aa,1)=(-Epclplpl(aa,1)+8*Epclpl(aa,1)-8*Epclm(aa,1)+Epclmm(aa,1))./(12.*empdir.*(abs(NOIlong
  ```
- Line 422: lon
  ```
  dEpcl(aa,1)=(-dEpp(aa,1)+8*dEp(aa,1)-8*dEm(aa,1)+dEmm(aa,1))./(12.*empdir.*(abs(NOIlong(kk))));
  ```
- Line 443: lon
  ```
  nbu=nbu(invert_at==1 & abs(ownbidq_cum)<abs(NOIlong(kk)));
  ```
- Line 444: lon
  ```
  nbl=nbl(invert_at==1 & abs(ownbidq_cum)<abs(NOIlong(kk)));
  ```
- Line 448: lon
  ```
  ilisti=find(abs(ownbidq_cum)>=abs(NOIlong(kk)));
  ```
- Line 454: lon
  ```
  qddp=ownbidq_cum(ilisti(ii))-(qclsamplepl_price-1).*NOIlong(kk);
  ```
- Line 455: lon
  ```
  qdd=ownbidq_cum(ilisti(ii))-(qclsample-1).*NOIlong(kk);
  ```
- Line 459: lon
  ```
  dq(ilisti(ii))=mean(qd(Pclsample>=ownbids(ilisti(ii)) & Pclsample<(ownbids(ilisti(ii))+epsilonp.*imp
  ```
- Line 460: lon
  ```
  dpq(ilisti(ii))=mean(qpd(Pclsample>=ownbids(ilisti(ii)) & Pclsample<(ownbids(ilisti(ii))+epsilonp.*i
  ```
- Line 461: lon
  ```
  dpp(ilisti(ii))=mean(ppd(Pclsample>=ownbids(ilisti(ii)) & Pclsample<(ownbids(ilisti(ii))+epsilonp.*i
  ```
- Line 467: lon
  ```
  %cleared at bk and now would at bk+epsilonp.*imp change
  ```
- Line 469: lon
  ```
  dpp(ilisti(ii))=epsilonp.*imp; dq(ilisti(ii))=0; dpq(ilisti(ii))=0;
  ```
- Line 470: lon
  ```
  dpp_l(ilisti(ii))=epsilonp.*imp; dq_l(ilisti(ii))=ownbidq(ilisti(ii)); dpq_l(ilisti(ii))=epsilonp.*i
  ```
- Line 472: lon
  ```
  qddm=ownbidq(ilisti(ii))-(qclsamplem_price-1).*NOIlong(kk);
  ```
- Line 473: lon
  ```
  qdd=ownbidq(ilisti(ii))-(qclsample-1).*NOIlong(kk);
  ```
- Line 477: lon
  ```
  dq_2(ilisti(ii))=mean(qd(Pclsample>=(ownbids(ilisti(ii))-epsilonp.*imp) & Pclsample<ownbids(ilisti(i
  ```
- Line 478: lon
  ```
  dpq_2(ilisti(ii))=mean(qpd(Pclsample>=(ownbids(ilisti(ii))-epsilonp.*imp) & Pclsample<ownbids(ilisti
  ```
- Line 479: lon
  ```
  dpp_2(ilisti(ii))=mean(ppd(Pclsample>=(ownbids(ilisti(ii))-epsilonp.*imp) & Pclsample<ownbids(ilisti
  ```
- Line 482: lon
  ```
  dpp_2(ilisti(ii))=-epsilonp.*imp; dq_2(ilisti(ii))=0; dpq_2(ilisti(ii))=0;
  ```
- Line 483: lon
  ```
  dpp_2l(ilisti(ii))=-epsilonp.*imp; dq_2l(ilisti(ii))=-ownbidq(ilisti(ii)); dpq_2l(ilisti(ii))=imp.*e
  ```
- Line 514: city
  ```
  %now build monotonicity bounds
  ```
- Line 517: lon
  ```
  if invert_at(ii)==1 & invert_at(jj)==1 & abs(ownbidq_cum(ii))<abs(NOIlong(kk)) & abs(ownbidq_cum(jj)
  ```
- Line 530: city
  ```
  %switch tdel=-tdel: since monotonicity is still left to right but the points are swapped in ii,jj sp
  ```
- Line 560: lon
  ```
  nblt=(sum((vmaxd-Epcl).*Prob.*ownbidq)-(vmind-pceil).*NOIlong(kk))./(mean(Pclsample)-pceil);
  ```
- Line 565: lon
  ```
  nbut=(sum((vmind-Epcl).*Prob.*ownbidq)-(vmaxd-pfloor).*NOIlong(kk))./(mean(Pclsample)-pfloor);
  ```
- Line 751: lon
  ```
  adjout=(ownbidq(aa)+empdir.*NOIlong(kk)).*(vmind).*Probpl-Epclpl.*(ownbidq(aa)+empdir.*NOIlong(kk)).
  ```
- Line 773: lon
  ```
  adjout=(ownbidq(aa)+empdir.*NOIlong(kk)).*(vmaxd).*Probpl-Epclpl.*(ownbidq(aa)+empdir.*NOIlong(kk)).
  ```
- Line 800: lon
  ```
  nout(kk,:)=[nlow nup NOIlong(kk) nopartflag imm1cap(kk) imm(kk) size(vlow,1) EsurpL EsurpU mean(Pcls
  ```

**/replication-package/CDS/code/estimation/basic_estimator_copydrop.m**

- Line 1: lon
  ```
  function [vout,nout]=basic_estimator_copydrop(supplyp,supplyq,idfs,idss,ndraw,NOItotexp,noi,Npossibl
  ```
- Line 29: lat
  ```
  %First loop through the data: calculate value and position estimates%
  ```
- Line 56: lat
  ```
  % calculate the clearing price
  ```
- Line 79: lon
  ```
  %get clearing price if q+epsilon here bid instead
  ```
- Line 88: lon
  ```
  %adding 2 epsilon
  ```
- Line 97: lon
  ```
  %and instead subtracting epsilon...
  ```
- Line 106: lon
  ```
  %subtracting 2 epsilon
  ```
- Line 128: lat
  ```
  % calculate the clearing price
  ```
- Line 137: lat
  ```
  %CALCULATE PRICE LEVEL FOR CURRENT AUCTION
  ```
- Line 145: lon
  ```
  %now get the clearing prices at -epsilon, +epsilon on i's prices: because
  ```
- Line 149: lon
  ```
  epsilonp=0.125./imp;
  ```
- Line 150: lon
  ```
  [bidsp, ic]=sort(direction.*[reshape(supplyp2(drawnids{kk},:),ndraw,(Npossibleexp(kk)-1)*size(supply
  ```
- Line 161: lat
  ```
  % calculate the clearing price
  ```
- Line 172: lon
  ```
  %and minus epsilonp
  ```
- Line 173: lon
  ```
  [bidsp, ic]=sort(direction.*[reshape(supplyp2(drawnids{kk},:),ndraw,(Npossibleexp(kk)-1)*size(supply
  ```
- Line 184: lat
  ```
  % calculate the clearing price
  ```
- Line 239: lon
  ```
  ownbidq=ownbidq.*(abs(NOIlong(kk)));
  ```
- Line 247: lon
  ```
  ownbidq(ownbidq>NOIlong(kk))=NOIlong(kk);
  ```
- Line 249: lon
  ```
  ownbidq(ownbidq<NOIlong(kk))=NOIlong(kk);
  ```
- Line 306: lon
  ```
  posib=(abs(ownbidq_cum)<=abs(NOIlong(kk)));
  ```
- Line 312: lat
  ```
  %calculate probabilities and derivative
  ```
- Line 348: lon
  ```
  dProb(aa,1)=(-Probplpl(aa,1)+8*Probpl(aa,1)-8*Probm(aa,1)+Probmm(aa,1))./(12.*empdir.*(abs(NOIlong(k
  ```
- Line 353: lon
  ```
  dEpcond(aa,1)=(-Epclplpl(aa,1)+8*Epclpl(aa,1)-8*Epclm(aa,1)+Epclmm(aa,1))./(12.*empdir.*(abs(NOIlong
  ```
- Line 361: lon
  ```
  dEpcl(aa,1)=(-dEpp(aa,1)+8*dEp(aa,1)-8*dEm(aa,1)+dEmm(aa,1))./(12.*empdir.*(abs(NOIlong(kk))));
  ```
- Line 379: lon
  ```
  dProb(aa,1)=(-Probplpl(aa,1)+8*Probpl(aa,1)-8*Probm(aa,1)+Probmm(aa,1))./(12.*empdir.*(abs(NOIlong(k
  ```
- Line 385: lon
  ```
  dEpcond(aa,1)=(-Epclplpl(aa,1)+8*Epclpl(aa,1)-8*Epclm(aa,1)+Epclmm(aa,1))./(12.*empdir.*(abs(NOIlong
  ```
- Line 393: lon
  ```
  dEpcl(aa,1)=(-dEpp(aa,1)+8*dEp(aa,1)-8*dEm(aa,1)+dEmm(aa,1))./(12.*empdir.*(abs(NOIlong(kk))));
  ```
- Line 411: lon
  ```
  dProb(aa,1)=(-Probplpl(aa,1)+8*Probpl(aa,1)-8*Probm(aa,1)+Probmm(aa,1))./(12.*empdir.*(abs(NOIlong(k
  ```
- Line 422: lon
  ```
  dEpcond(aa,1)=(-Epclplpl(aa,1)+8*Epclpl(aa,1)-8*Epclm(aa,1)+Epclmm(aa,1))./(12.*empdir.*(abs(NOIlong
  ```
- Line 430: lon
  ```
  dEpcl(aa,1)=(-dEpp(aa,1)+8*dEp(aa,1)-8*dEm(aa,1)+dEmm(aa,1))./(12.*empdir.*(abs(NOIlong(kk))));
  ```
- Line 452: lon
  ```
  nbu=nbu(invert_at==1 & abs(ownbidq_cum)<abs(NOIlong(kk)));
  ```
- Line 453: lon
  ```
  nbl=nbl(invert_at==1 & abs(ownbidq_cum)<abs(NOIlong(kk)));
  ```
- Line 457: lon
  ```
  ilisti=find(abs(ownbidq_cum)>=abs(NOIlong(kk)));
  ```
- Line 463: lon
  ```
  qddp=ownbidq_cum(ilisti(ii))-(qclsamplepl_price-1).*NOIlong(kk);
  ```
- Line 464: lon
  ```
  qdd=ownbidq_cum(ilisti(ii))-(qclsample-1).*NOIlong(kk);
  ```
- Line 468: lon
  ```
  dq(ilisti(ii))=mean(qd(Pclsample>=ownbids(ilisti(ii)) & Pclsample<(ownbids(ilisti(ii))+epsilonp.*imp
  ```
- Line 469: lon
  ```
  dpq(ilisti(ii))=mean(qpd(Pclsample>=ownbids(ilisti(ii)) & Pclsample<(ownbids(ilisti(ii))+epsilonp.*i
  ```
- Line 470: lon
  ```
  dpp(ilisti(ii))=mean(ppd(Pclsample>=ownbids(ilisti(ii)) & Pclsample<(ownbids(ilisti(ii))+epsilonp.*i
  ```
- Line 476: lon
  ```
  %cleared at bk and now would at bk+epsilonp.*imp change
  ```
- Line 478: lon
  ```
  dpp(ilisti(ii))=epsilonp.*imp; dq(ilisti(ii))=0; dpq(ilisti(ii))=0;
  ```
- Line 479: lon
  ```
  dpp_l(ilisti(ii))=epsilonp.*imp; dq_l(ilisti(ii))=ownbidq(ilisti(ii)); dpq_l(ilisti(ii))=epsilonp.*i
  ```
- Line 481: lon
  ```
  qddm=ownbidq(ilisti(ii))-(qclsamplem_price-1).*NOIlong(kk);
  ```
- Line 482: lon
  ```
  qdd=ownbidq(ilisti(ii))-(qclsample-1).*NOIlong(kk);
  ```
- Line 486: lon
  ```
  dq_2(ilisti(ii))=mean(qd(Pclsample>=(ownbids(ilisti(ii))-epsilonp.*imp) & Pclsample<ownbids(ilisti(i
  ```
- Line 487: lon
  ```
  dpq_2(ilisti(ii))=mean(qpd(Pclsample>=(ownbids(ilisti(ii))-epsilonp.*imp) & Pclsample<ownbids(ilisti
  ```
- Line 488: lon
  ```
  dpp_2(ilisti(ii))=mean(ppd(Pclsample>=(ownbids(ilisti(ii))-epsilonp.*imp) & Pclsample<ownbids(ilisti
  ```
- Line 491: lon
  ```
  dpp_2(ilisti(ii))=-epsilonp.*imp; dq_2(ilisti(ii))=0; dpq_2(ilisti(ii))=0;
  ```
- Line 492: lon
  ```
  dpp_2l(ilisti(ii))=-epsilonp.*imp; dq_2l(ilisti(ii))=-ownbidq(ilisti(ii)); dpq_2l(ilisti(ii))=imp.*e
  ```
- Line 523: city
  ```
  %now build monotonicity bounds
  ```
- Line 526: lon
  ```
  if invert_at(ii)==1 & invert_at(jj)==1 & abs(ownbidq_cum(ii))<abs(NOIlong(kk)) & abs(ownbidq_cum(jj)
  ```
- Line 539: city
  ```
  %switch tdel=-tdel: since monotonicity is still left to right but the points are swapped in ii,jj sp
  ```
- Line 571: lon
  ```
  nblt=(sum((vmaxd-Epcl).*Prob.*ownbidq)-(vmind-pceil).*NOIlong(kk))./(mean(Pclsample)-pceil);
  ```
- Line 576: lon
  ```
  nbut=(sum((vmind-Epcl).*Prob.*ownbidq)-(vmaxd-pfloor).*NOIlong(kk))./(mean(Pclsample)-pfloor);
  ```
- Line 763: lon
  ```
  adjout=(ownbidq(aa)+empdir.*NOIlong(kk)).*(vmind).*Probpl-Epclpl.*(ownbidq(aa)+empdir.*NOIlong(kk)).
  ```
- Line 785: lon
  ```
  adjout=(ownbidq(aa)+empdir.*NOIlong(kk)).*(vmaxd).*Probpl-Epclpl.*(ownbidq(aa)+empdir.*NOIlong(kk)).
  ```
- Line 812: lon
  ```
  nout(kk,:)=[nlow nup NOIlong(kk) nopartflag imm1cap(kk) imm(kk) size(vlow,1) EsurpL EsurpU mean(Pcls
  ```

**/replication-package/CDS/code/estimation/complex_bootstrap.m**

- Line 5: second
  ```
  %complex estimator_step2: the main second stage of estimation: combining
  ```
- Line 7: lon
  ```
  %plugging (along with extrainfo: stored win probabilities) to get v-hats
  ```
- Line 9: lon
  ```
  [nbounds,extrainfo]=complex_estimator_step1(supplyp,supplyq,idfs,idss,ndraw,NOItotexp,noi,Npossiblee
  ```
- Line 101: lat
  ```
  %time so that the correlation matrix can still be calculated--this won't
  ```
- Line 102: lat
  ```
  %effect inequalities later since these terms will have little effects
  ```
- Line 231: lon
  ```
  [vout,nout]=complex_estimator_step2(Lgms,Ugms,extrainfo,supplyp,supplyq,idfs,idss,ndraw,NOItotexp,no
  ```

**/replication-package/CDS/code/estimation/complex_estimator_step1.m**

- Line 1: lon
  ```
  function [nbounds,extrainfo]=complex_estimator_step1(supplyp,supplyq,idfs,idss,ndraw,NOItotexp,noi,N
  ```
- Line 17: lat
  ```
  %First loop through the data: calculate value and position estimates%
  ```
- Line 45: lat
  ```
  % calculate the clearing price
  ```
- Line 70: lon
  ```
  empdir=max(0.005,1./NOIlong(kk));
  ```
- Line 72: lon
  ```
  %get clearing price if q+epsilon here bid instead
  ```
- Line 81: lon
  ```
  %adding 2 epsilon
  ```
- Line 90: lon
  ```
  %and instead subtracting epsilon...
  ```
- Line 99: lon
  ```
  %subtracting 2 epsilon
  ```
- Line 120: lat
  ```
  % calculate the clearing price
  ```
- Line 135: lat
  ```
  %CALCULATE PRICE LEVEL FOR CURRENT AUCTION
  ```
- Line 143: lon
  ```
  %now get the clearing prices at -epsilon, +epsilon on i's prices: because
  ```
- Line 147: lon
  ```
  epsilonp=0.125./imp;
  ```
- Line 148: lon
  ```
  [bidsp, ic]=sort(direction.*[reshape(supplyp2oth(drawnids{kk},:),ndraw,(Npossibleexp(kk)-1)*size(sup
  ```
- Line 159: lat
  ```
  % calculate the clearing price
  ```
- Line 169: lon
  ```
  %and minus epsilonp
  ```
- Line 170: lon
  ```
  [bidsp, ic]=sort(direction.*[reshape(supplyp2oth(drawnids{kk},:),ndraw,(Npossibleexp(kk)-1)*size(sup
  ```
- Line 181: lat
  ```
  % calculate the clearing price
  ```
- Line 220: lon
  ```
  ownbidq=ownbidq.*(abs(NOIlong(kk)));
  ```
- Line 228: lon
  ```
  ownbidq(ownbidq>NOIlong(kk))=NOIlong(kk);
  ```
- Line 230: lon
  ```
  ownbidq(ownbidq<NOIlong(kk))=NOIlong(kk);
  ```
- Line 289: lon
  ```
  posib=(abs(ownbidq_cum)<=abs(NOIlong(kk)));
  ```
- Line 295: lat
  ```
  %calculate probabilities and derivative
  ```
- Line 331: lon
  ```
  dEpcl(aa,1)=(-dEpp(aa,1)+8*dEp(aa,1)-8*dEm(aa,1)+dEmm(aa,1))./(12.*empdir.*(abs(NOIlong(kk))));
  ```
- Line 347: lon
  ```
  dEpcl(aa,1)=(-dEpp(aa,1)+8*dEp(aa,1)-8*dEm(aa,1)+dEmm(aa,1))./(12.*empdir.*(abs(NOIlong(kk))));
  ```
- Line 363: lon
  ```
  dEpcl(aa,1)=(-dEpp(aa,1)+8*dEp(aa,1)-8*dEm(aa,1)+dEmm(aa,1))./(12.*empdir.*(abs(NOIlong(kk))));
  ```
- Line 387: lon
  ```
  nbu=nbu(invert_at==1 & abs(ownbidq_cum)<abs(NOIlong(kk)));
  ```
- Line 388: lon
  ```
  nbl=nbl(invert_at==1 & abs(ownbidq_cum)<abs(NOIlong(kk)));
  ```
- Line 396: lon
  ```
  ilistia=find(abs(ownbidq_cum)<abs(NOIlong(kk)) & ownbids+epsilonp<=imm1cap(kk));
  ```
- Line 401: lon
  ```
  %payments on units (1-qk) (average price change conditional on p'<=epsilon+bk) and the extra
  ```
- Line 406: lon
  ```
  ugain=ownbidq(aa).*mean((min(vmind,ownbids(aa))-Pclsamplepl_price).*normcdf((Pclsample-ownbids(aa)).
  ```
- Line 408: lon
  ```
  ugainU=-ownbidq(aa).*mean((max(vmaxd,ownbids(aa))-Pclsample).*normcdf((ownbids(aa)-Pclsample)./bwp).
  ```
- Line 411: lon
  ```
  bchange=-ownbidq_cum(aa-1).*mean((Pclsamplepl_price-Pclsample).*normcdf((Pclsample-ownbids(aa))./bwp
  ```
- Line 412: lon
  ```
  bchangeU=-ownbidq_cum(aa-1).*mean((Pclsamplem_price-Pclsample).*normcdf((ownbids(aa)-Pclsample)./bwp
  ```
- Line 416: lon
  ```
  nblt=(ugain+bchange)./(mean((Pclsamplepl_price-Pclsample).*normcdf((Pclsample-ownbids(aa))./bwp).*no
  ```
- Line 417: lon
  ```
  nbut=(ugainU+bchangeU)./(mean((Pclsamplem_price-Pclsample).*normcdf((ownbids(aa)-Pclsample)./bwp).*n
  ```
- Line 423: lon
  ```
  ilistia=find(abs(ownbidq_cum)<abs(NOIlong(kk)) & ownbids+epsilonp>=imm1cap(kk));
  ```
- Line 428: lon
  ```
  ugain=-ownbidq(aa).*mean((min(vmind,ownbids(aa))-Pclsample).*normcdf((Pclsample-ownbids(aa))./bwp).*
  ```
- Line 430: lon
  ```
  ugainU=ownbidq(aa).*mean((max(vmaxd,ownbids(aa))-Pclsamplem_price).*normcdf((ownbids(aa)-Pclsample).
  ```
- Line 437: lon
  ```
  %the original clearing price is in b_k+epsilon\geq P^c \geq b_k or  b_k-epsilon\leq P^c \leq b_k
  ```
- Line 439: lon
  ```
  bchange=-ownbidq_cum(aa-1).*mean((Pclsamplepl_price-Pclsample).*normcdf((Pclsample-ownbids(aa))./bwp
  ```
- Line 440: lon
  ```
  bchangeU=-ownbidq_cum(aa-1).*mean((Pclsamplem_price-Pclsample).*normcdf((ownbids(aa)-Pclsample)./bwp
  ```
- Line 445: lon
  ```
  nblt=(ugain+bchange)./(mean((Pclsamplepl_price-Pclsample).*normcdf((ownbids(aa)-Pclsample)./bwp).*no
  ```
- Line 446: lon
  ```
  nbut=(ugainU+bchangeU)./(mean((Pclsamplem_price-Pclsample).*normcdf((ownbids(aa)-Pclsample)./bwp).*n
  ```
- Line 456: lon
  ```
  %when abs(ownbidq_cum)>=abs(NOIlong(kk)...augment nbl,nbu
  ```
- Line 459: lon
  ```
  ilisti=find(abs(ownbidq_cum)>=abs(NOIlong(kk)));
  ```
- Line 469: lon
  ```
  qddp=max(min(ownbidq(ilisti(ii)),-(qclsamplepl_price-1).*NOIlong(kk)),0);
  ```
- Line 470: lon
  ```
  qdd=max(min(ownbidq(ilisti(ii)),-(qclsample-1).*NOIlong(kk)),0);
  ```
- Line 473: lon
  ```
  qddp=min(max(ownbidq(ilisti(ii)),(qclsamplepl_price+1).*NOIlong(kk)),0);
  ```
- Line 474: lon
  ```
  qdd=min(max(ownbidq(ilisti(ii)),(qclsample+1).*NOIlong(kk)),0);
  ```
- Line 482: lon
  ```
  dq(ilisti(ii))=sum(qd(Pclsample>=ownbids(ilisti(ii)).*normcdf(((ownbids(ilisti(ii))+epsilonp.*imp)-P
  ```
- Line 483: lon
  ```
  dpq(ilisti(ii))=sum(qpd(Pclsample>=ownbids(ilisti(ii)).*normcdf(((ownbids(ilisti(ii))+epsilonp.*imp)
  ```
- Line 484: lon
  ```
  dpp(ilisti(ii))=sum(ppd(Pclsample>=ownbids(ilisti(ii)).*normcdf(((ownbids(ilisti(ii))+epsilonp.*imp)
  ```
- Line 490: lon
  ```
  %cleared at bk and now would at bk+epsilonp.*imp change
  ```
- Line 492: lon
  ```
  dpp(ilisti(ii))=epsilonp.*imp; dq(ilisti(ii))=0; dpq(ilisti(ii))=0;
  ```
- Line 493: lon
  ```
  dpp_l(ilisti(ii))=epsilonp.*imp; dq_l(ilisti(ii))=ownbidq(ilisti(ii)); dpq_l(ilisti(ii))=epsilonp.*i
  ```
- Line 496: lon
  ```
  qddm=max(min(ownbidq(ilisti(ii)),-(qclsamplem_price-1).*NOIlong(kk)),0);
  ```
- Line 497: lon
  ```
  qdd=max(min(ownbidq(ilisti(ii)),-(qclsample-1).*NOIlong(kk)),0);
  ```
- Line 500: lon
  ```
  qddm=min(max(ownbidq(ilisti(ii)),(1+qclsamplem_price).*NOIlong(kk)),0);
  ```
- Line 501: lon
  ```
  qdd=min(max(ownbidq(ilisti(ii)),(1+qclsample).*NOIlong(kk)),0);
  ```
- Line 507: lon
  ```
  dq_2(ilisti(ii))=sum(qd(Pclsample>=ownbids(ilisti(ii)).*normcdf((-(ownbids(ilisti(ii))-epsilonp.*imp
  ```
- Line 508: lon
  ```
  dpq_2(ilisti(ii))=sum(qpd(Pclsample>=ownbids(ilisti(ii)).*normcdf((-(ownbids(ilisti(ii))-epsilonp.*i
  ```
- Line 509: lon
  ```
  dpp_2(ilisti(ii))=sum(ppd(Pclsample>=ownbids(ilisti(ii)).*normcdf((-(ownbids(ilisti(ii))-epsilonp.*i
  ```
- Line 513: lon
  ```
  dpp_2(ilisti(ii))=-epsilonp.*imp; dq_2(ilisti(ii))=0; dpq_2(ilisti(ii))=0;
  ```
- Line 514: lon
  ```
  dpp_2l(ilisti(ii))=-epsilonp.*imp; dq_2l(ilisti(ii))=-ownbidq(ilisti(ii)); dpq_2l(ilisti(ii))=imp.*e
  ```
- Line 548: city
  ```
  %now build monotonicity bounds
  ```
- Line 551: lon
  ```
  if invert_at(ii)==1 & invert_at(jj)==1 & abs(ownbidq_cum(ii))<abs(NOIlong(kk)) & abs(ownbidq_cum(jj)
  ```
- Line 565: city
  ```
  %switch tdel=-tdel: since monotonicity is still left to right but the points are swapped in ii,jj sp
  ```
- Line 599: lon
  ```
  nblt=(sum((vmind).*(Prob).*ownbidq)-vmind.*(NOIlong(kk).*Eqnn)-sum(Epcl.*Prob.*ownbidq)+pceil.*NOIlo
  ```
- Line 609: lon
  ```
  nbut=(sum((vmaxd).*(Prob).*ownbidq)-vmaxd.*(NOIlong(kk).*Eqnn)-sum(Epcl.*Prob.*ownbidq)+pfloor.*NOIl
  ```
- Line 657: lon
  ```
  adjout=(ownbidq(aa)+empdir.*NOIlong(kk)).*(vmind).*Probpl-Epclpl.*(ownbidq(aa)+empdir.*NOIlong(kk)).
  ```
- Line 681: lon
  ```
  adjout=(ownbidq(aa)+empdir.*NOIlong(kk)).*(vmaxd).*Probpl-Epclpl.*(ownbidq(aa)+empdir.*NOIlong(kk)).
  ```

**/replication-package/CDS/code/estimation/complex_estimator_step2.m**

- Line 1: lon
  ```
  function [vout,nout]=complex_estimator_step2(nlowF,nupF,extrainfo,supplyp,supplyq,idfs,idss,ndraw,NO
  ```
- Line 27: lat
  ```
  %First loop through the data: calculate value and position estimates%
  ```
- Line 40: lat
  ```
  %CALCULATE PRICE LEVEL FOR CURRENT AUCTION
  ```
- Line 48: lon
  ```
  %now get the clearing prices at -epsilon, +epsilon on i's prices: because
  ```
- Line 80: lon
  ```
  ownbidq=ownbidq.*(abs(NOIlong(kk)));
  ```
- Line 88: lon
  ```
  ownbidq(ownbidq>NOIlong(kk))=NOIlong(kk);
  ```
- Line 90: lon
  ```
  ownbidq(ownbidq<NOIlong(kk))=NOIlong(kk);
  ```
- Line 140: lon
  ```
  posib=(abs(ownbidq_cum)<=abs(NOIlong(kk)));
  ```
- Line 142: lon
  ```
  ilisti=find(abs(ownbidq_cum)>=abs(NOIlong(kk)));
  ```
- Line 280: lon
  ```
  qst1=sum(dEpcl(invert_at==1 & abs(ownbidq_cum)<abs(NOIlong(kk))).*nlow.*ownbidq(invert_at==1 & abs(o
  ```
- Line 281: lon
  ```
  qst2=sum(dEpcl(invert_at==1 & abs(ownbidq_cum)<abs(NOIlong(kk))).*nup.*ownbidq(invert_at==1 & abs(ow
  ```
- Line 330: lon
  ```
  nout(kk,:)=[nlow nup NOIlong(kk) nopartflag imm1cap(kk) imm(kk) size(vlow,1) EsurpL EsurpU mean(Pcls
  ```

**/replication-package/CDS/code/estimation/complex_estimator_step2b.m**

- Line 1: lon
  ```
  function [vout,shad]=complex_estimator_step2b(nlow,nup,kk,extrainfo,supplyp,supplyq,idfs,idss,ndraw,
  ```
- Line 39: lat
  ```
  %CALCULATE PRICE LEVEL FOR CURRENT AUCTION
  ```
- Line 47: lon
  ```
  %now get the clearing prices at -epsilon, +epsilon on i's prices: because
  ```
- Line 79: lon
  ```
  ownbidq=ownbidq.*(abs(NOIlong(kk)));
  ```
- Line 87: lon
  ```
  ownbidq(ownbidq>NOIlong(kk))=NOIlong(kk);
  ```
- Line 89: lon
  ```
  ownbidq(ownbidq<NOIlong(kk))=NOIlong(kk);
  ```
- Line 139: lon
  ```
  posib=(abs(ownbidq_cum)<=abs(NOIlong(kk)));
  ```
- Line 141: lon
  ```
  ilisti=find(abs(ownbidq_cum)>=abs(NOIlong(kk)));
  ```
- Line 276: lon
  ```
  qst1=sum(dEpcl(invert_at==1 & abs(ownbidq_cum)<abs(NOIlong(kk))).*nlow.*ownbidq(invert_at==1 & abs(o
  ```
- Line 277: lon
  ```
  qst2=sum(dEpcl(invert_at==1 & abs(ownbidq_cum)<abs(NOIlong(kk))).*nup.*ownbidq(invert_at==1 & abs(ow
  ```
- Line 321: lon
  ```
  nout(kk,:)=[nlow nup NOIlong(kk) nopartflag imm1cap(kk) imm(kk) size(vlow,1) EsurpL EsurpU mean(Pcls
  ```

**/replication-package/CDS/code/estimation/npestimator.m**

- Line 4: lon
  ```
  tagLong=zeros(size(aucpricefs2));
  ```
- Line 5: lon
  ```
  tagLong(tagn)=1;
  ```
- Line 14: lon
  ```
  eventlong(aucidfs==aucidfslist(aa))=event(aa);
  ```
- Line 16: lon
  ```
  eventlong=eventlong';
  ```
- Line 23: lon
  ```
  Noiabslong(isnan(NOIabslong)==1)=0;
  ```
- Line 49: lon
  ```
  NOIabslongtemp=[];
  ```
- Line 54: lon
  ```
  eventlongtemp=[];
  ```
- Line 91: lon
  ```
  NOIabslongtemp=[NOIabslongtemp; NOIabslong(aucidfs==bsincl(kk,jj))'];
  ```
- Line 94: lon
  ```
  eventlongtemp=[eventlongtemp; eventlong(aucidfs==bsincl(kk,jj))];
  ```
- Line 99: lon
  ```
  tagntemp=[tagntemp;tagLong(aucidfs==bsincl(kk,jj))];
  ```
- Line 114: lon
  ```
  NOIabslongbs{jj}=NOIabslongtemp;
  ```
- Line 127: lon
  ```
  eventlongbs{jj}=eventlongtemp;
  ```
- Line 138: lon
  ```
  possiblePl=find(NOIlong>=0);
  ```
- Line 139: lon
  ```
  possibleM=find(NOIlong<0);
  ```
- Line 143: lon
  ```
  if size(NOIlong,1)==1
  ```
- Line 144: lon
  ```
  NOIlong=NOIlong';
  ```
- Line 153: lon
  ```
  wNOI=normpdf((NOIlong(k)-NOIlong)./bwNOI);
  ```
- Line 166: lon
  ```
  wNOI=normpdf((NOIlong(k)-NOIlong)./bwNOI);
  ```
- Line 192: lon
  ```
  tempp=tempp.*max(imm(aa)); tempq=tempq.*max(NOIlong(idfs==idss(aa)));
  ```
- Line 204: lon
  ```
  Ibidon(aa)=-noi(aa)+NOIabslong(aa).*sum(supplyq(idss==idfs(aa)))+NOIlong(aa).*carriedoverq(aa);
  ```

**/replication-package/CDS/code/estimation/pricechangebs.m**

- Line 51: loc, location
  ```
  %SURPLUS BASELINE--to participants inside and allocation only.
  ```

**/replication-package/CDS/code/estimation/v_correction.m**

- Line 26: lon
  ```
  [vt, shdt] = complex_estimator_step2b(nL_kk(ii), nU_kk(ii), jj, eobs_kk, supplyp,supplyq,idfs,idss,n
  ```
- Line 79: lon
  ```
  [vtemp]=complex_estimator_step2b(nbounds{jj,1}(aa),nbounds{jj,2}(aa),jj,extrainfo,supplyp,supplyq,id
  ```
- Line 167: lon
  ```
  [~,shadttt]=complex_estimator_step2b(nbounds{jj,1}(aa),nbounds{jj,2}(aa),jj,extrainfo,supplyp,supply
  ```

**/replication-package/CDS/code/main_cds.m**

- Line 12: lat, loc, location
  ```
  % All paths are relative to this file's location (code/)
  ```
- Line 13: name
  ```
  code_dir = fileparts(mfilename('fullpath'));
  ```
- Line 97: lat
  ```
  % Risk calculations, bias, inefficiency, auction performance (Table 4)
  ```

**/replication-package/CDS/code/postestimation/calculate_surplusraw.m**

- Line 62: lon
  ```
  for jj=1:size(NOIlong,1)
  ```
- Line 63: lon
  ```
  if NOIlong(jj)>0
  ```
- Line 64: lon
  ```
  tsq=NOIlong(jj).*supplyq(idss==idfs(jj));
  ```
- Line 82: lon
  ```
  tsq=NOIlong(jj).*supplyq(idss==idfs(jj));
  ```
- Line 100: son
  ```
  %% Section 6.1: Status quo auction surplus (per-person * ndealers)
  ```

**/replication-package/CDS/code/postestimation/postestimation_clean.m**

- Line 3: lat
  ```
  %calculated in bootstrap file
  ```
- Line 7: lat
  ```
  calculate_surplusraw
  ```
- Line 144: lat
  ```
  %now use this to calculate auction pricing risk
  ```
- Line 190: lat
  ```
  %since the correlation bounds are positive the var(Pv-n/bP^c) is monotone
  ```
- Line 207: lat
  ```
  % Save Table 4 as LaTeX
  ```
- Line 240: second, son
  ```
  % Secondary-market within-day price SD at +5 days (paper comparison), for Section 6.3
  ```
- Line 242: second
  ```
  fprintf('  Secondary-market within-day price SD at +5 days: %.2f cents\n', mean(BPsd(BPsd(:,36)~=0,3
  ```
- Line 245: lat
  ```
  %Optimal hedging position (utility calculation)
  ```
- Line 316: lon
  ```
  ew=ew.*normpdf((NOIgrid(jj)-NOIlong')./bwNOI)'; ew=ew./sum(ew);
  ```
- Line 323: lat, son
  ```
  %crazy extrapolation over that region. --For the same reason we need to be
  ```
- Line 330: lat
  ```
  xlabel('$y^\mathcal{N}$','FontSize',14,'interpreter','latex')
  ```
- Line 344: lat
  ```
  % Probability of buying back given (1) it is possible, (2) own price quote relative to imm price (3)
  ```
- Line 347: lon
  ```
  buyback_possible=(sign(NOIlong)==sign(noi));
  ```
- Line 350: lon
  ```
  Xmat=[imm-((immhigh+immlow)./2) abs(NOIlong-noi)];
  ```
- Line 355: lat
  ```
  % Exercise 1: something summarizing correlations in v, n?--contour plot the joint distribution--lowe
  ```
- Line 385: url
  ```
  saveas(gcf,fullfile(fig_path,'contourlow.png'))
  ```

**/replication-package/CDS/code/postestimation/robustnesschecks.m**

- Line 6: lat
  ```
  disp('--- Appendix C.5.1: Quote Manipulation Calibration ---')
  ```
- Line 49: lon
  ```
  if NOIlong(ii)>0
  ```
- Line 74: lon
  ```
  [vout_ca,nout_ca]=basic_estimator(supplyp,round(supplyq,3),idfs,idss,ndraw,NOItotexp,noi,Npossibleex
  ```
- Line 75: lon
  ```
  [vout_cs,nout_cs]=basic_estimator_copydrop(supplyp,round(supplyq,3),idfs,idss,ndraw,NOItotexp,noi,Np
  ```
- Line 78: lat
  ```
  fprintf('  Correlation of n-bounds (LB): %.4f\n', corr(nout_cs(:,1),nout_ca(:,1)))
  ```
- Line 79: lat
  ```
  fprintf('  Correlation of n-bounds (UB): %.4f\n', corr(nout_cs(:,2),nout_ca(:,2)))
  ```

**/replication-package/CDS/code/postestimation/round1_quotescalibration.m**

- Line 30: lat
  ```
  %calculate these optimal
  ```
- Line 42: lon
  ```
  NOIExp=randsample(NOIlong,nsim,true,kweight2);
  ```
- Line 46: lat
  ```
  %for each consGrid point put it into expectedopposing, calculated the
  ```
- Line 47: lat
  ```
  %imm that results in each simulated set
  ```
- Line 59: lat
  ```
  %calculate adjustment amounts
  ```
- Line 132: lon
  ```
  NOIExp=randsample(NOIlong,nsim,true,kweight2);
  ```
- Line 136: lat
  ```
  %for each consGrid point put it into expectedopposing, calculated the
  ```
- Line 137: lat
  ```
  %imm that results in each simulated set
  ```

**/replication-package/CDS/code/postestimation/truthfulpimmcheck.m**

- Line 11: lat
  ```
  %calculate imm/noi
  ```
- Line 55: lat
  ```
  fprintf('  P95 benefit of manipulation: %.2f\n', benManipule)
  ```
- Line 56: lat
  ```
  fprintf('  Mean cost of manipulation: %.0f\n', costManipule)
  ```

