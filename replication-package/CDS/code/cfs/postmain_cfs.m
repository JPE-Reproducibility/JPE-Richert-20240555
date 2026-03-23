%postmain_cfs
%collect the results to get the basic statistics: bias risk and
%inefficiencies and welfare from risk across the IMM levels 
options=optimoptions('fmincon','Display','off');
warning('off')
for jjj=1:size(immquantiles,2)
    imqi=immquantiles(jjj);
    fnmind=fullfile(int_path,sprintf(['cf_topout_np_pt_',num2str(round(sell_limit)),num2str(2*sfrac),num2str(jjj)]));
    load(fnmind)
    pupC(jjj)=max(Pcl);
    plowC(jjj)=min(Pcl);
    %bound the terms directly note vclA can be above vcuA bc of the
    %clearing rule (at next step)
    %bound the terms seperately: might be less noisy
    clear covLB covUB
    for kk=1:max(size(PclA))
        fmc=@(x)subsref(cov(x, PclA{kk}), struct('type','()','subs',{{1,2}}));
        fmx=fmincon(fmc,(vclA{kk}+vcuA{kk})'./2,[],[],[],[],min(vclA{kk},vcuA{kk})',max(vclA{kk},vcuA{kk})'+1e-12,[],options);
        covLB(kk)=fmc(fmx);
        fmc=@(x)-subsref(cov(x, PclA{kk}), struct('type','()','subs',{{1,2}}));
        fmx=fmincon(fmc,(vclA{kk}+vcuA{kk})'./2,[],[],[],[],min(vclA{kk},vcuA{kk})',max(vclA{kk},vcuA{kk})'+1e-12,[],options);
        covUB(kk)=-fmc(fmx);
    end
condCovc_LB(jjj)=mean(covLB);
condCovc_UB(jjj)=mean(covUB);
condEV_ub(jjj)=mean(vcuA{kk});
condEV_lb(jjj)=mean(vclA{kk});
condEP(jjj)=mean(PclA{kk});
condVP(jjj)=var(PclA{kk});
condV_lb(jjj)=min(sdpcl).^2;
condV_ub(jjj)=max(sdpcl).^2;
surpFULL(jjj,:)=[min(surpAB) max(surpA)]/100 * median(ndeal);
end
%% ============ SECTION 7: Counterfactual Surplus ============
disp('========== SECTION 7: Counterfactual Surplus ==========')
fprintf('  Mean surplus ($M) [LB, UB]: [%.1f, %.1f]\n', mean(surpFULL(:,1)), mean(surpFULL(:,2)))
fprintf('  Max surplus ($M) [LB, UB]: [%.1f, %.1f]\n', max(surpFULL(:,1)), max(surpFULL(:,2)))
fprintf('  Min surplus ($M) [LB, UB]: [%.1f, %.1f]\n', min(surpFULL(:,1)), min(surpFULL(:,2)))

warning('on')
fmc=@(x)-subsref(cov(x, condEP), struct('type','()','subs',{{1,2}}));
vsol=fmincon(fmc,(condEV_lb+condEV_ub)./2,[],[],[],[],condEV_lb,condEV_ub,[],options);
covUB=mean(condCovc_UB)+abs(fmc(vsol));
fmc=@(x)subsref(cov(x, condEP), struct('type','()','subs',{{1,2}}));
vsol=fmincon(fmc,(condEV_lb+condEV_ub)./2,[],[],[],[],condEV_lb,condEV_ub,[],options);
covLB=mean(condCovc_LB)+fmc(vsol);

fmc=@(x)var(x);
vsol=fmincon(fmc,(condEV_lb+condEV_ub)./2,[],[],[],[],condEV_lb,condEV_ub,[],options);
vcross_lb=fmc(vsol);
fmc=@(x)-var(x);
vsol=fmincon(fmc,(condEV_lb+condEV_ub)./2,[],[],[],[],condEV_lb,condEV_ub,[],options);
vcross_ub=abs(fmc(vsol));

lastterm_lb=vcross_lb+mean(condV_lb)+(nx.^2).*(mean(condVP)+var(condEP))-2.*nx.*covLB;
lastterm_ub=vcross_ub+mean(condV_ub)+(nx.^2).*(mean(condVP)+var(condEP))-2.*nx.*covUB;

%% ============ TABLE 5: Change in Auction Format ============
disp('========== TABLE 5: Change in Auction Format ==========')
T5_meanLB = mean(plowC); T5_meanUB = mean(pupC);
T5_varLB = vcross_lb+mean(condV_lb); T5_varUB = vcross_ub+mean(condV_ub);
T5_covLB = covLB; T5_covUB = covUB;
T5_surpLB = min(mean(surpFULL)); T5_surpUB = max(mean(surpFULL));
fprintf('%-30s %16s %16s %18s %16s\n', '', 'Mean', 'Variance', 'Cov(P^c,P^v)', 'Surplus')
fprintf('%-30s [%6.2f,%6.2f] [%6.0f,%6.0f] [%6.0f,%6.0f] [%5.1f,%5.1f]\n', ...
    'Double Auction Price', T5_meanLB, T5_meanUB, T5_varLB, T5_varUB, T5_covLB, T5_covUB, T5_surpLB, T5_surpUB)
% Save Table 5 as LaTeX
fid = fopen(fullfile(tab_path, 'table5.tex'), 'w');
fprintf(fid, '\\begin{table}[htbp]\n\\centering\n\\caption{Change in Auction Format}\n\\label{tab:cf}\n');
fprintf(fid, '\\begin{tabular}{lcccc}\n\\hline\\hline\n');
fprintf(fid, ' & Mean & Variance & Cov$(P^c, P^v)$ & Surplus \\\\\n\\hline\n');
fprintf(fid, 'Double Auction Price & $[%.2f, %.2f]$ & $[%.0f, %.0f]$ & $[%.0f, %.0f]$ & $[%.1f, %.1f]$ \\\\\n', ...
    T5_meanLB, T5_meanUB, T5_varLB, T5_varUB, T5_covLB, T5_covUB, T5_surpLB, T5_surpUB);
fprintf(fid, '\\hline\\hline\n\\end{tabular}\n\\end{table}\n');
fclose(fid);
disp('Table 5 saved to output/tables/table5.tex')

%% ============ SECTION 7: CF Price Bias and Risk ============
disp('========== SECTION 7: CF Price Bias and Risk ==========')
pbiasCF=mean(p_lowimm-pupC);
fprintf('  CF price bias (E[P^v_LB] - E[P^DA_UB]): %.2f cents\n', pbiasCF)

%Variance decomposition for CF risk
pbiascf=(mean(p_lowimm)-nx.*mean(pupC));
pbiasUcf=(mean(p_uppbsimm)-nx.*mean(plowC));
for jj=1:size(nx,2)
    fxaa=@(x)vix.*(100.*nx(jj)-100).^2+vix.*x.^2+2.*eix.*(1-eix).*(100.*nx(jj)-100).*x;
    lbvAt(jj)=fminbnd(fxaa,pbiascf(jj),pbiasUcf(jj));
    lbvAcf(jj)=fxaa(lbvAt(jj));
    fxaa=@(x)-(vix.*(100.*nx(jj)-100).^2+vix.*x.^2+2.*eix.*(1-eix).*(100.*nx(jj)-100).*x);
    ubvAt(jj)=fminbnd(fxaa,pbiascf(jj),pbiasUcf(jj));
    ubvAcf(jj)=-fxaa(ubvAt(jj));
end
ubvcf=ubvAcf+(vix+eix.^2).*lastterm_ub;
lbvcf=lbvAcf+(vix+eix.^2).*lastterm_lb;

fprintf('  CF SD of risk (lower bound): %.2f cents\n', sqrt(min(lbvcf)))

%Optimal hedging position (utility)
Bpos=100000000;
Eprofit=Bpos./100*((1-eix).*100+eix.*mean(p_lowimm));
upperboundU=Eprofit-(0.0024./2).*((Bpos./100).^2).*(lbv);
lowerboundU=Eprofit-(0.0024./2).*((Bpos./100).^2).*(ubv);
[mx,icmlb]=max(lowerboundU);
cf_hedge_range = [min(nx(upperboundU>mx)) max(nx(upperboundU>mx))];
fprintf('  CF optimal hedging range: [%.1f%%, %.1f%%]\n', 100*cf_hedge_range(1), 100*cf_hedge_range(2))
fprintf('  CF optimal hedging position: %.1f%%\n', 100*nx(icmlb))

%CF hedging effectiveness (SD): bounds using upper bound on insured risk
risk_uninsured=sqrt(vix.*mean(varLBcc)+vix.*(100-mean(p_lowimm)).^2+eix.^2.*mean(varLBcc));
risk_uninsured_UB=sqrt(vix.*mean(varUBcc)+vix.*(100-mean(p_lowimm)).^2+eix.^2.*mean(varUBcc));
vrat=@(x)(x-interp1(nx,sqrt(ubvcf),1))./x;
xsol=fmincon(vrat,(risk_uninsured+risk_uninsured_UB)./2,[],[],[],[],risk_uninsured,risk_uninsured_UB,[],options);
cf_hedge_n1_LB = vrat(xsol);
vrat=@(x)(x-min(sqrt(ubvcf)))./x;
xsol=fmincon(vrat,(risk_uninsured+risk_uninsured_UB)./2,[],[],[],[],risk_uninsured,risk_uninsured_UB,[],options);
cf_hedge_opt_LB = vrat(xsol);

%CF hedging effectiveness (SD): bounds using lower bound on insured risk
risk_uninsured=sqrt(vix.*mean(varLBcc)+vix.*(100-mean(p_lowimm)).^2+eix.^2.*mean(varLBcc));
risk_uninsured_UB=sqrt(vix.*mean(varUBcc)+vix.*(100-mean(p_lowimm)).^2+eix.^2.*mean(varUBcc));
vrat=@(x)-((x-interp1(nx,sqrt(lbvcf),1))./x);
xsol=fmincon(vrat,(risk_uninsured+risk_uninsured_UB)./2,[],[],[],[],risk_uninsured,risk_uninsured_UB,[],options);
cf_hedge_n1_UB = abs(vrat(xsol));
vrat=@(x)-((x-min(sqrt(lbvcf)))./x);
xsol=fmincon(vrat,(risk_uninsured+risk_uninsured_UB)./2,[],[],[],[],risk_uninsured,risk_uninsured_UB,[],options);
cf_hedge_opt_UB = abs(vrat(xsol));

fprintf('  CF hedging effectiveness at n=1 (SD): [%.1f%%, %.1f%%]\n', 100*cf_hedge_n1_LB, 100*cf_hedge_n1_UB)
fprintf('  CF hedging effectiveness at optimal (SD): [%.1f%%, %.1f%%]\n', 100*cf_hedge_opt_LB, 100*cf_hedge_opt_UB)

%CF hedging effectiveness (variance)
risk_uninsured=(vix.*mean(varLBcc)+vix.*(100-mean(p_lowimm)).^2+eix.^2.*mean(varLBcc));
risk_uninsured_UB=(vix.*mean(varUBcc)+vix.*(100-mean(p_lowimm)).^2+eix.^2.*mean(varUBcc));
vrat=@(x)(x-interp1(nx,(lbv),1))./x;
xsol=fmincon(vrat,(risk_uninsured+risk_uninsured_UB)./2,[],[],[],[],risk_uninsured,risk_uninsured_UB,[],options);
cf_hedge_var_n1 = vrat(xsol);
vrat=@(x)(x-min((lbv)))./x;
xsol=fmincon(vrat,(risk_uninsured+risk_uninsured_UB)./2,[],[],[],[],risk_uninsured,risk_uninsured_UB,[],options);
cf_hedge_var_opt = vrat(xsol);
fprintf('  CF hedging effectiveness at n=1 (variance): %.1f%%\n', 100*cf_hedge_var_n1)
fprintf('  CF hedging effectiveness at optimal (variance): %.1f%%\n', 100*cf_hedge_var_opt)


