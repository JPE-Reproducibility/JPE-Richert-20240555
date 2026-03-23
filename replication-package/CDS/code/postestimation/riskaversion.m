wealth=(([aucpricefs;100.*ones(9900,1)]))./100;
fprintf('  Variance of baseline wealth: %.6f\n', var(wealth))
wealth2=((aucpricefs-IMM)).*(1+1.*((aucpricefs-IMM)>0)-1.*((aucpricefs-IMM)<0))+100;
wealth2=wealth2./100;
fprintf('  Variance of wealth2 (auction outcomes): %.6f\n', var(wealth2))
%two risk aversions 1 in the baseline level of wealth (at the end of the
%auction) and one in the wealth only over auction outcomes
wealth2=1+0.04.*(rand(size(NOI))>.5);
fprintf('  Variance of wealth2 (H/T doubling): %.6f\n', var(wealth2))
fprintf('  Variance ratio (baseline/H-T auction gamble): %.1fx\n', var(wealth)/var(wealth2))
%double initial position--maximize uncertainty by H/T you get it or not
rho=linspace(1e-8,2,100);

bondInit=mean(noi(noi>0));
rho=linspace(0.2,2,100);
%Choose 0.2 as the min: at that level the uninsured bond owner is losing
%.5% of total utility
bondAuc=prctile(br_qwon,90); 
rho=linspace(.005,10,100);
utilratio = mean(1-exp(-rho.*(wealth.*bondInit)))./(1-exp(-rho.*mean(wealth.*bondInit)));
fprintf('  Utility ratio range [min, max]: [%.4f, %.4f]\n', min(utilratio), max(utilratio))
