## Potentially Hardcoded Numeric Constants


We found the following set of hard coded numbers. This may be completely legitimate (parameter input, thresholds for computations, etc), and is hence only for information.

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20240555-4/replication-package/CDS/code/datacleaning/acrossrounds.m**

- Line 16, : supplyq(aucidsupply==120)=supplyq(aucidsupply==120).*0.0095;
- Line 17, : supplyq(aucidsupply==131)=supplyq(aucidsupply==131).*0.0095;
- Line 18, : supplyq(aucidsupply==88)=supplyq(aucidsupply==88).*0.0095;
- Line 19, : supplyq(aucidsupply==90)=supplyq(aucidsupply==90).*0.0095;
- Line 20, : supplyq(aucidsupply==95)=supplyq(aucidsupply==95).*0.0095;

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20240555-4/replication-package/CDS/code/computation/weightedcorrs.m**

- Line 32, : %   DOI:10.1140/epjb/e2012-20697-x.

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20240555-4/replication-package/CDS/code/computation/verify_env.m**

- Line 64, : v(3) = sum(betainv(rand(1e4,1)*0.998+0.001, 2.3, 4.1));  % stat fns

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20240555-4/replication-package/CDS/code/estimation/basic_estimator_copydrop.m**

- Line 149, : epsilonp=0.125./imp;
- Line 316, : bwp=max(bwp,1.4826*max(0.01,median(abs(Pclsample-median(Pclsample))))*(4/(3*max(size(Pclsample))))^(1./5));
- Line 318, : bwpm=max(bwpm,1.4826*max(0.01,median(abs(Pclsamplem-median(Pclsamplem))))*(4/(3*max(size(Pclsamplem))))^(1./5));
- Line 320, : bwpp=max(bwpp,1.4826*max(0.01,median(abs(Pclsamplepl-median(Pclsamplepl))))*(4/(3*max(size(Pclsamplepl))))^(1./5));
- Line 322, : bwppp=max(bwppp,1.4826*max(0.01,median(abs(Pclsampleplpl-median(Pclsampleplpl))))*(4/(3*max(size(Pclsampleplpl))))^(1./5));
- Line 324, : bwpmm=max(bwpmm,1.4826*max(0.01,median(abs(Pclsamplemm-median(Pclsamplemm))))*(4/(3*max(size(Pclsamplemm))))^(1./5));
- Line 656, : %price increment=0.125 which must not be optimal, limiting mv.

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20240555-4/replication-package/CDS/code/cfs/postmain_cfs.m**

- Line 102, : upperboundU=Eprofit-(0.0024./2).*((Bpos./100).^2).*(lbv);
- Line 103, : lowerboundU=Eprofit-(0.0024./2).*((Bpos./100).^2).*(ubv);
- Line 152, : fv_gain_LB = 2.9/0.917 * 0.01 * incr_coverage_LB/100;
- Line 153, : fv_gain_UB = 2.9/0.917 * 0.01 * incr_coverage_UB/100;

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20240555-4/replication-package/CDS/code/estimation/complex_estimator_step1.m**

- Line 70, : empdir=max(0.005,1./NOIlong(kk));
- Line 147, : epsilonp=0.125./imp;
- Line 299, : bwp=max(bwp,1.4826*max(0.01,median(abs(Pclsample-median(Pclsample))))*(4/(3*max(size(Pclsample))))^(1./5));
- Line 301, : bwpm=max(bwpm,1.4826*max(0.01,median(abs(Pclsamplem-median(Pclsamplem))))*(4/(3*max(size(Pclsamplem))))^(1./5));
- Line 303, : bwpp=max(bwpp,1.4826*max(0.01,median(abs(Pclsamplepl-median(Pclsamplepl))))*(4/(3*max(size(Pclsamplepl))))^(1./5));
- Line 305, : bwppp=max(bwppp,1.4826*max(0.01,median(abs(Pclsampleplpl-median(Pclsampleplpl))))*(4/(3*max(size(Pclsampleplpl))))^(1./5));
- Line 307, : bwpmm=max(bwpmm,1.4826*max(0.01,median(abs(Pclsamplemm-median(Pclsamplemm))))*(4/(3*max(size(Pclsamplemm))))^(1./5));

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20240555-4/replication-package/CDS/code/estimation/basic_estimator.m**

- Line 148, : epsilonp=0.125./imp;
- Line 308, : bwp=max(bwp,1.4826*max(0.01,median(abs(Pclsample-median(Pclsample))))*(4/(3*max(size(Pclsample))))^(1./5));
- Line 310, : bwpm=max(bwpm,1.4826*max(0.01,median(abs(Pclsamplem-median(Pclsamplem))))*(4/(3*max(size(Pclsamplem))))^(1./5));
- Line 312, : bwpp=max(bwpp,1.4826*max(0.01,median(abs(Pclsamplepl-median(Pclsamplepl))))*(4/(3*max(size(Pclsamplepl))))^(1./5));
- Line 314, : bwppp=max(bwppp,1.4826*max(0.01,median(abs(Pclsampleplpl-median(Pclsampleplpl))))*(4/(3*max(size(Pclsampleplpl))))^(1./5));
- Line 316, : bwpmm=max(bwpmm,1.4826*max(0.01,median(abs(Pclsamplemm-median(Pclsamplemm))))*(4/(3*max(size(Pclsamplemm))))^(1./5));
- Line 645, : %price increment=0.125 which must not be optimal, limiting mv.

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20240555-4/replication-package/CDS/code/computation/jacobianest.m**

- Line 34, : %      -2.1012      -2.3222     -0.23222
- Line 35, : %      -2.2045      -2.6926     -0.53852
- Line 36, : %      -2.3096      -3.1176     -0.93528
- Line 37, : %      -2.4158      -3.6039      -1.4416
- Line 38, : %      -2.5225      -4.1589      -2.0795
- Line 39, : %       -2.629      -4.7904      -2.8742
- Line 40, : %      -2.7343      -5.5063      -3.8544
- Line 41, : %      -2.8374      -6.3147      -5.0518
- Line 42, : %      -2.9369      -7.2237      -6.5013
- Line 43, : %      -3.0314      -8.2403      -8.2403
- Line 46, : %   5.0134e-15   5.0134e-15            0
- Line 47, : %   5.0134e-15            0   2.8211e-14
- Line 48, : %   5.0134e-15   8.6834e-15   1.5804e-14
- Line 49, : %            0     7.09e-15   3.8227e-13
- Line 50, : %   5.0134e-15   5.0134e-15   7.5201e-15
- Line 51, : %   5.0134e-15   1.0027e-14   2.9233e-14
- Line 52, : %   5.0134e-15            0   6.0585e-13
- Line 53, : %   5.0134e-15   1.0027e-14   7.2673e-13
- Line 54, : %   5.0134e-15   1.0027e-14   3.0495e-13
- Line 55, : %   5.0134e-15   1.0027e-14   3.1707e-14
- Line 56, : %   5.0134e-15   2.0053e-14   1.4013e-12
- Line 70, : StepRatio = 2.0000001;
- Line 194, : errest = s'*12.7062047361747*sqrt(cov1(1));

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20240555-4/replication-package/CDS/code/postestimation/round1_quotescalibration.m**

- Line 43, : consGrid=[R-10:0.125:R+10];
- Line 45, : eps=0.125;
- Line 133, : consGrid=[R-10:0.125:R+10];
- Line 135, : eps=0.125;

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20240555-4/replication-package/CDS/code/estimation/complex_estimator_step2.m**

- Line 176, : %price increment=0.125 which must not be optimal, limiting mv.

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20240555-4/replication-package/CDS/code/estimation/complex_estimator_step2b.m**

- Line 173, : %price increment=0.125 which must not be optimal, limiting mv.

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20240555-4/replication-package/CDS/code/cfs/generatesimsforcf.m**

- Line 2, : xgrid=linspace(0.001,3,100);

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20240555-4/replication-package/CDS/code/datacleaning/customerorder_frequency.m**

- Line 102, : plist=supplyp(abs(supplyq-NOItotsupply')<=0.001)-immFC(abs(supplyq-NOItotsupply')<=0.001)';
- Line 106, : plist=supplyp(abs(supplyq-NOItotsupply')<=0.001)-immFC(abs(supplyq-NOItotsupply')<=0.001)';

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20240555-4/replication-package/CDS/code/datacleaning/firststagebidding.m**

- Line 9, : noi(aucidfs==88)=noi(aucidfs==88).*0.0095;
- Line 10, : noi(aucidfs==95)=noi(aucidfs==95).*0.0095;
- Line 11, : noi(aucidfs==120)=noi(aucidfs==120).*0.0095;
- Line 12, : noi(aucidfs==131)=noi(aucidfs==131).*0.0095;

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20240555-4/replication-package/CDS/code/postestimation/postestimation_clean.m**

- Line 248, : upperboundU=Eprofit-(0.0024./2).*((Bpos./100).^2).*(lbv);
- Line 249, : lowerboundU=Eprofit-(0.0024./2).*((Bpos./100).^2).*(ubv);

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20240555-4/replication-package/CDS/code/datacleaning/normalize_prices.m**

- Line 465, : plot([47.397;47.397],[35;55],'r--','Linewidth',2)

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20240555-4/replication-package/CDS/code/datacleaning/data_summary.m**

- Line 85, : supplyfunctab(supplyfunctab.aucid == 88,3)=supplyfunctab(supplyfunctab.aucid == 88,3).*0.0095;
- Line 86, : supplyfunctab(supplyfunctab.aucid == 95,3)=supplyfunctab(supplyfunctab.aucid == 95,3).*0.0095;
- Line 87, : supplyfunctab(supplyfunctab.aucid == 120,3)=supplyfunctab(supplyfunctab.aucid == 120,3).*0.0095;
- Line 88, : supplyfunctab(supplyfunctab.aucid == 131,3)=supplyfunctab(supplyfunctab.aucid == 131,3).*0.0095;

