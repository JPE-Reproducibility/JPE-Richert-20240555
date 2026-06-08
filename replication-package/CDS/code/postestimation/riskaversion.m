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
% Appendix C.2: expected-utility ratio EU[gamble]/u(mean payout) over the CARA range.
% Bond-default gamble = wealth x bondInit (avg bond position); auction-outcome gamble =
% wealth2 x bondAuc (90th-pct auction position). Closer to 1 => more linear (less curvature).
utilratio     = mean(1-exp(-rho.*(wealth   .*bondInit)))./(1-exp(-rho.*mean(wealth   .*bondInit)));
utilratio_auc = mean(1-exp(-rho.*(wealth2(:).*bondAuc )))./(1-exp(-rho.*mean(wealth2(:).*bondAuc )));
fprintf('  C.2 utility ratio over CARA rho in [%.3f, %g]:\n', rho(1), rho(end))
fprintf('    Auction-outcome gamble: min=%.4f max=%.4f\n', min(utilratio_auc), max(utilratio_auc))
fprintf('    Bond-default gamble:    min=%.4f max=%.4f\n', min(utilratio), max(utilratio))
fprintf('    %-8s %12s %12s\n','rho','auction','default')
for j = round(linspace(1,numel(rho),9))
    fprintf('    %-8.3f %12.4f %12.4f\n', rho(j), utilratio_auc(j), utilratio(j))
end
