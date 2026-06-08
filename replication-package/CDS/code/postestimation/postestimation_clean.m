%POST-ESTIMATION EXERCISES: WHAT CAN WE LEARN
%This is for stuff that I do not bootstrap--stats with standard errors are
%calculated in bootstrap file
% Part 1: How does fair clearing prices (truthful) and participation vary
% across NOI
minslope=0.1.*maxslope;
calculate_surplusraw

qg=[linspace(prctile(noi,1),0,1000) linspace(0,prctile(noi,99),1000)];
minslope=0.1.*maxslope;
qgrid=qg;
for qgp=1:size(qg,2)
voutn=nout;
for jj=1:size(nout,1)
qtemp=vout{jj}(:,1);
qtemp=qtemp-noi(jj); %adjust for initial submission
vtempU=vout{jj}(:,3);
vtempL=vout{jj}(:,2);
vtempU(vtempL>vtempU)=vtempL(vtempL>vtempU);
vmaxda=8; 
vminda=-8; 
vmind=max(vminda+imm1cap(jj),0);
vmaxd=min(vmaxda+imm1cap(jj),100);
if size(vout{jj},2)>5
btemp=vout{jj}(:,7);
else
    btemp=0;
end
if qg(qgp)>max(qtemp)
vlowg=min(vtempL)-maxslope.*(qg(qgp)-max(qtemp));
vupg=min(vtempU)-minslope.*(qg(qgp)-max(qtemp));

if max(qtemp)<=0 & qg(qgp)<=0
batg=min(btemp);
else
batg=0;
end
elseif qg(qgp)<min(qtemp)
vupg=max(vtempU)+maxslope.*(min(qtemp)-qg(qgp));
vlowg=max(vtempL)+minslope.*(min(qtemp)-qg(qgp));
if max(qtemp)>0 & qg(qgp)>=0
batg=max(btemp);
else
batg=100;
end
elseif max(qg(qgp)==qtemp)==1
    qI=find(qtemp==qg(qgp),1,'first');
    vlowg=vtempL(qI);
    vupg=vtempU(qI);
    batg=btemp(qI);
else
    qright=find(qtemp>qg(qgp),1,'first');
    qleft=find(qtemp<qg(qgp),1,'last');
vlowg=vtempL(qright);
vupg=vtempU(qleft);
 batg=btemp(qright);
end
vlowg=max(vlowg,vmind); vlowg=min(vlowg,vmaxd);
vupg=max(vupg,vmind); vupg=min(vupg,vmaxd);

vatqg_lb(jj,qgp)=vlowg;
vatqg_ub(jj,qgp)=vupg;
batqg(jj,qgp)=batg;
end
end

%WITH INITIAL SUBMISSIONS IN
for qgp=1:size(qg,2)
voutn=nout;
for jj=1:size(nout,1)
qtemp=vout{jj}(:,1);
qtemp=qtemp;% Keep initial submissions included in v--we are going to clear resid only now
vtempU=vout{jj}(:,3);
vtempL=vout{jj}(:,2);
vtempL(vtempL>vtempU)=vtempU(vtempL>vtempU);
vmaxda=8;
vminda=-8;
vmind=max(vminda+imm1cap(jj),0);
vmaxd=min(vmaxda+imm1cap(jj),100);
if size(vout{jj},2)>5
btemp=vout{jj}(:,7);
else
    btemp=0;
end
if qg(qgp)>max(qtemp)
vlowg=min(vtempL)-maxslope.*(qg(qgp)-max(qtemp));
vupg=min(vtempU)-minslope.*(qg(qgp)-max(qtemp));

if max(qtemp)<=0 & qg(qgp)<=0
batg=min(btemp);
else
batg=0;
end
elseif qg(qgp)<min(qtemp)
vupg=max(vtempU)+maxslope.*(min(qtemp)-qg(qgp));
vlowg=max(vtempL)+minslope.*(min(qtemp)-qg(qgp));
if max(qtemp)>0 & qg(qgp)>=0
batg=max(btemp);
else
batg=100;
end
elseif max(qg(qgp)==qtemp)==1
    qI=find(qtemp==qg(qgp),1,'first');
    vlowg=vtempL(qI);
    vupg=vtempU(qI);
    batg=btemp(qI);
else
    qright=find(qtemp>qg(qgp),1,'first');
    qleft=find(qtemp<qg(qgp),1,'last');
vlowg=vtempL(qright);
vupg=vtempU(qleft);
 batg=btemp(qright);
end
vlowg=max(vlowg,vmind); vlowg=min(vlowg,vmaxd);
vupg=max(vupg,vmind); vupg=min(vupg,vmaxd);

vatqg_lbt(jj,qgp)=vlowg;
vatqg_ubt(jj,qgp)=vupg;
batqgt(jj,qgp)=batg;
end
end

%how does this vary in IMM, and overall
immquantiles=prctile(IMM,[25./2:25:100]);
for jj=1:size(immquantiles,2)
bwIMM=1.06.*std(IMM).*size(IMM,1).^(-1./5);
imw=normpdf((IMM-immquantiles(jj))./bwIMM);
imw=imw./sum(imw);
econdP(jj)=sum(aucpricefs.*imw);
econdIMM(jj)=sum(IMM.*imw);
[dSurpU(jj),dSurpL(jj),p_lowimm(jj),p_uppbsimm(jj),plb_outi(jj,:),pub_outi(jj,:)]=pricechangebs(ones(size(imm)),imm,2000,vatqg_lb,vatqg_ub,qgrid,immquantiles(jj),bwIMM);
end
%% ============ SECTION 6.1: Surplus from Reallocation ============
disp('========== SECTION 6.1: Surplus from Reallocation ==========')
fprintf('  Truthful bidding surplus bounds: [$%.0fM, $%.0fM]\n', mean(dSurpL)./100, mean(dSurpU)./100)

%% ============ SECTION 6.2: Price Bias ============
disp('========== SECTION 6.2: Price Bias ==========')
pbias=mean(econdP-p_lowimm);
adjpos=(100-mean(p_lowimm))./(100-mean(aucpricefs));
fprintf('  E[P|IMM] - E[P^v_LB] (kernel-weighted): %.2f cents\n', pbias)
fprintf('  Position adjustment ratio: %.4f\n', adjpos)

%now use this to calculate auction pricing risk
nx=linspace(0,1.3,10000); %share hedged
eix=0.02; %set the default probability
vix=eix.*(1-eix); %variance by definition
pbias=(mean(p_lowimm)-nx.*mean(econdP)); %pbias: compare against the other estimator of expectation to be consistent with CF


%get the conditional variance bounds:
for jj=1:size(immquantiles,2)
    fmc=@(x)-1.*(mean(x.^2)-mean(x).^2);
    [vmaxin,fm]=fmincon(fmc,(plb_outi(jj,:)+pub_outi(jj,:))./2,[],[],[],[],plb_outi(jj,:),pub_outi(jj,:));
    varUBc(jj)=abs(fmc(vmaxin));
end
%get lower bound:
for jj=1:size(immquantiles,2)
    fmc=@(x)1.*(mean(x.^2)-mean(x).^2);
    [vmaxin,fm]=fmincon(fmc,(plb_outi(jj,:)+pub_outi(jj,:))./2,[],[],[],[],plb_outi(jj,:),pub_outi(jj,:));
    varLBc(jj)=abs(fmc(vmaxin));
end
vubt=@(x)-((1./size(immquantiles,2))*sum(varUBc)+(((1./size(immquantiles,2)).*sum(x.^2))-mean(x).^2));
[vmaxin,fm]=fmincon(vubt,(p_lowimm(:)+p_uppbsimm(:))./2,[],[],[],[],p_lowimm(:),p_uppbsimm(:));
varUBcc=abs(vubt(vmaxin));
vubt=@(x)(1./size(immquantiles,2))*sum(varUBc)+(((1./size(immquantiles,2)).*sum(x.^2))-mean(x).^2);
[vmaxin,fm]=fmincon(vubt,(p_lowimm(:)+p_uppbsimm(:))./2,[],[],[],[],p_lowimm(:),p_uppbsimm(:));
varLBcc=abs(vubt(vmaxin));
varLBcc=varLBcc+mean(varLBc);
varUBcc=varUBcc+mean(varUBc);

%compute for the realized set of bidders what would be the bounds
[plb_out,pub_out]=pricechange_realized(vatqg_lb,vatqg_ub,qgrid,aucidfs);
options=optimoptions('fmincon','Display','off');
for jj=1:size(nx,2)
fmc=@(x)var(x-nx(jj).*aucpricefs);
minVar=fmincon(fmc,(plb_out'+pub_out')./2,[],[],[],[],plb_out',pub_out',[],options);
varLB2(jj)=fmc(minVar);
fmc=@(x)-var(x-nx(jj).*aucpricefs);
minVar=fmincon(fmc,(plb_out'+pub_out')./2,[],[],[],[],plb_out',pub_out',[],options);
varUB2(jj)=-fmc(minVar);
end
%compute a bound on the covariance?
fmc=@(x)corr(x,aucpricefs);
minVar=fmincon(fmc,(plb_out'+pub_out')./2,[],[],[],[],plb_out',pub_out',[],options);
mincorrA=fmc(minVar);
fmc=@(x)-corr(x,aucpricefs);
minVar=fmincon(fmc,(plb_out'+pub_out')./2,[],[],[],[],plb_out',pub_out',[],options);
maxcorrA=-fmc(minVar);
%since the correlation bounds are positive the var(Pv-n/bP^c) is monotone
%in var(Pv)...
varUB3=varUBcc+nx.^2.*var(aucpricefs)-2.*nx.*maxcorrA.*sqrt(varUBcc).*sqrt(var(aucpricefs));
varLB3=varLBcc+nx.^2.*var(aucpricefs)-2.*nx.*mincorrA.*sqrt(varLBcc).*sqrt(var(aucpricefs));

covPvPc_LB = mincorrA.*sqrt(varLBcc).*sqrt(var(aucpricefs));
covPvPc_UB = maxcorrA.*sqrt(varUBcc).*sqrt(var(aucpricefs));

%% ============ TABLE 4: Statistics to Evaluate Auction Performance ============
disp('========== TABLE 4: Statistics to Evaluate Auction Performance ==========')
T4_covIMMPc = cov(IMM, aucpricefs); T4_covIMMPc = T4_covIMMPc(1,2);
fprintf('%-30s %12s %12s %18s\n', '', 'Mean', 'Variance', 'Cov. Auction Price')
fprintf('%-30s %12.2f %12.0f %18.0f\n', 'Auction Price', mean(aucpricefs), var(aucpricefs), var(aucpricefs))
fprintf('%-30s [%6.2f,%6.2f] [%7.2f,%6.0f] [%6.0f,%6.0f]\n', 'Truthful Bidding Price', ...
    mean(p_lowimm), mean(p_uppbsimm), varLBcc, varUBcc, covPvPc_LB, covPvPc_UB)
fprintf('%-30s %12.2f %12.0f %18.0f\n', 'Initial Market Price', mean(IMM), var(IMM), T4_covIMMPc)
fprintf('%-30s %12.2f %12.2f %18s\n', 'Default Event Indicator', eix, eix*(1-eix), '-')
% Save Table 4 as LaTeX
fid = fopen(fullfile(tab_path, 'table4.tex'), 'w');
fprintf(fid, '\\begin{table}[htbp]\n\\centering\n\\caption{Statistics to Evaluate Auction Performance}\n\\label{tab:performance}\n');
fprintf(fid, '\\begin{tabular}{lccc}\n\\hline\\hline\n');
fprintf(fid, ' & Mean & Variance & Cov. Auction Price \\\\\n\\hline\n');
fprintf(fid, 'Auction Price & %.2f & %.0f & %.0f \\\\\n', mean(aucpricefs), var(aucpricefs), var(aucpricefs));
fprintf(fid, 'Truthful Bidding Price & $[%.2f, %.2f]$ & $[%.2f, %.0f]$ & $[%.0f, %.0f]$ \\\\\n', ...
    mean(p_lowimm), mean(p_uppbsimm), varLBcc, varUBcc, covPvPc_LB, covPvPc_UB);
fprintf(fid, 'Initial Market Price & %.2f & %.0f & %.0f \\\\\n', mean(IMM), var(IMM), T4_covIMMPc);
fprintf(fid, 'Default Event Indicator & %.2f & %.2f & -- \\\\\n', eix, eix*(1-eix));
fprintf(fid, '\\hline\\hline\n\\end{tabular}\n\\end{table}\n');
fclose(fid);
disp('Table 4 saved to output/tables/table4.tex')

fprintf('  Price bias E[P^c] - E[P^v_LB] = %.2f cents\n', mean(aucpricefs) - mean(p_lowimm))
fprintf('  As pct of expected payouts: %.1f%%\n', abs(mean(aucpricefs) - mean(p_lowimm))/mean(aucpricefs)*100)

pbias=(mean(p_lowimm)-nx.*mean(aucpricefs));
pbiasU=(mean(p_uppbsimm)-nx.*mean(aucpricefs));
for jj=1:size(nx,2)
    fxaa=@(x)vix.*(100.*nx(jj)-100).^2+vix.*x.^2+2.*eix.*(1-eix).*(100.*nx(jj)-100).*x;
    lbvAt(jj)=fminbnd(fxaa,pbias(jj),pbiasU(jj));
    lbvA(jj)=fxaa(lbvAt(jj));
    fxaa=@(x)-(vix.*(100.*nx(jj)-100).^2+vix.*x.^2+2.*eix.*(1-eix).*(100.*nx(jj)-100).*x);
    ubvAt(jj)=fminbnd(fxaa,pbias(jj),pbiasU(jj));
    ubvA(jj)=-fxaa(ubvAt(jj));
end
ubv=ubvA+(vix+eix.^2).*varUB3;
lbv=lbvA+(vix+eix.^2).*varLB3;

%% ============ SECTION 6.3: Risk from Price Uncertainty ============
disp('========== SECTION 6.3: Risk from Price Uncertainty ==========')
fprintf('  SD of risk (lower bound): %.2f cents\n', sqrt(min(lbv)))
% Secondary-market within-day price SD at +5 days (paper comparison), for Section 6.3
if exist('BPsd','var')
    fprintf('  Secondary-market within-day price SD at +5 days: %.2f cents\n', mean(BPsd(BPsd(:,36)~=0,36)))
end

%Optimal hedging position (utility calculation)
Bpos=100000000;
Eprofit=Bpos./100*((1-eix).*100+eix.*mean(p_lowimm));
upperboundU=Eprofit-(0.0024./2).*((Bpos./100).^2).*(lbv);
lowerboundU=Eprofit-(0.0024./2).*((Bpos./100).^2).*(ubv);
[mx,icmlb]=max(lowerboundU);
hedge_range = [min(nx(upperboundU>mx)) max(nx(upperboundU>mx))];
fprintf('  Optimal hedging range: [%.1f%%, %.1f%%]\n', 100*hedge_range(1), 100*hedge_range(2))
fprintf('  Optimal hedging position: %.1f%%\n', 100*nx(icmlb))

%Hedging effectiveness (SD): bounds using upper bound on insured risk
risk_uninsured=sqrt(vix.*mean(varLBcc)+vix.*(100-mean(p_lowimm)).^2+eix.^2.*mean(varLBcc));
risk_uninsured_UB=sqrt(vix.*mean(varUBcc)+vix.*(100-mean(p_lowimm)).^2+eix.^2.*mean(varUBcc));
vrat=@(x)(x-interp1(nx,sqrt(ubv),1))./x;
xsol=fmincon(vrat,(risk_uninsured+risk_uninsured_UB)./2,[],[],[],[],risk_uninsured,risk_uninsured_UB,[],options);
hedge_eff_n1_LB = vrat(xsol);
vrat=@(x)(x-min(sqrt(ubv)))./x;
xsol=fmincon(vrat,(risk_uninsured+risk_uninsured_UB)./2,[],[],[],[],risk_uninsured,risk_uninsured_UB,[],options);
hedge_eff_opt_LB = vrat(xsol);

%Hedging effectiveness (SD): bounds using lower bound on insured risk
risk_uninsured=sqrt(vix.*mean(varLBcc)+vix.*(100-mean(p_lowimm)).^2+eix.^2.*mean(varLBcc));
risk_uninsured_UB=sqrt(vix.*mean(varUBcc)+vix.*(100-mean(p_lowimm)).^2+eix.^2.*mean(varUBcc));
vrat=@(x)-((x-interp1(nx,sqrt(lbv),1))./x);
xsol=fmincon(vrat,(risk_uninsured+risk_uninsured_UB)./2,[],[],[],[],risk_uninsured,risk_uninsured_UB,[],options);
hedge_eff_n1_UB = abs(vrat(xsol));
vrat=@(x)-((x-min(sqrt(lbv)))./x);
xsol=fmincon(vrat,(risk_uninsured+risk_uninsured_UB)./2,[],[],[],[],risk_uninsured,risk_uninsured_UB,[],options);
hedge_eff_opt_UB = abs(vrat(xsol));

fprintf('  Hedging effectiveness at n=1 (SD): [%.1f%%, %.1f%%]\n', 100*hedge_eff_n1_LB, 100*hedge_eff_n1_UB)
fprintf('  Hedging effectiveness at optimal (SD): [%.1f%%, %.1f%%]\n', 100*hedge_eff_opt_LB, 100*hedge_eff_opt_UB)

%Hedging effectiveness (variance)
risk_uninsured=(vix.*mean(varLBcc)+vix.*(100-mean(p_lowimm)).^2+eix.^2.*mean(varLBcc));
risk_uninsured_UB=(vix.*mean(varUBcc)+vix.*(100-mean(p_lowimm)).^2+eix.^2.*mean(varUBcc));
vrat=@(x)(x-interp1(nx,(lbv),1))./x;
xsol=fmincon(vrat,(risk_uninsured+risk_uninsured_UB)./2,[],[],[],[],risk_uninsured,risk_uninsured_UB,[],options);
hedge_eff_var_n1 = vrat(xsol);
vrat=@(x)(x-min((lbv)))./x;
xsol=fmincon(vrat,(risk_uninsured+risk_uninsured_UB)./2,[],[],[],[],risk_uninsured,risk_uninsured_UB,[],options);
hedge_eff_var_opt = vrat(xsol);
fprintf('  Hedging effectiveness at n=1 (variance): %.1f%%\n', 100*hedge_eff_var_n1)
fprintf('  Hedging effectiveness at optimal (variance): %.1f%%\n', 100*hedge_eff_var_opt)

%% ============ SECTION 6.4: CDS Market Impact ============
disp('========== SECTION 6.4: CDS Market Impact ==========')
max_coverage = 100*max(hedge_eff_opt_LB, hedge_eff_opt_UB);
basis_points = abs(mean(aucpricefs) - mean(p_lowimm)) * eix * 100;
fprintf('  Max insurance coverage: %.1f%%\n', max_coverage)
fprintf('  Auction bias charge (basis points): %.1f bps\n', basis_points)
fprintf('  Firm value gain from full insurance (Danis-Gamba scaling): %.2f%% = 2.9/%.1f * (100-%.1f)/100\n', ...
    2.9/max_coverage*100*(1-max_coverage/100), max_coverage, max_coverage)
fprintf('  Dollar gain per average firm ($M): %.0f\n', 2.9/max_coverage*100*(1-max_coverage/100)/100*51.2*1000)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SOME APPENDIX EXERCISES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%How does shading change across NOI?
aucprice_pred=nout(:,6);
aucprice_pred_short=IMM;
aucprice_predicted=nout(:,6);
NOIgrid=linspace(prctile(NOI,1),prctile(NOI,99),102);
NOIgrid(2:end-1)=linspace(prctile(NOI,10),prctile(NOI,90),100);
for jj=1:size(NOIgrid,2)
    ew=ones(size(nout(:,1),1),1);
    nt=NOI(sign(NOI)==sign(NOIgrid(jj)) & NOI>=NOIgrid(1) & NOI<=NOIgrid(end));
    IQRnt=prctile(nt,[75 25]);
    IQRnt=IQRnt(1)-IQRnt(2);
    bwNOI=min(std(nt),IQRnt./1.34).*0.9.*(size(nt,1)).^(-1./5);
    ew(sign(nout(:,3))~=sign(NOIgrid(jj)))=0;
    ew=ew.*normpdf((NOIgrid(jj)-NOIlong')./bwNOI)'; ew=ew./sum(ew);
    pl_BM(jj)=sum((aucpricefs2-aucprice_pred).*ew)./sum(ew);
    pu_BM(jj)=pl_BM(jj);
    share_part(jj)=sum((1-nout(:,4)).*ew);
    [pl_dir(jj),pu_dir(jj)]=pricechangeNOI_DIR(ew,vatqg_lbt-aucprice_pred,vatqg_ubt-aucprice_pred,qgrid,NOIgrid(jj),noi,max(1,0.05.*NOIgrid(jj)),nout);
    %Doing this exercise using bids with no extrapolation makes no sense of course when we condition
    %on a demand auction we don't get supply bids--so we are just throwing in a
    %crazy extrapolation over that region. --For the same reason we need to be
    %very careful about extrapolation in the case of values if we want to take something meaningful from this 
end
figure; yyaxis left;
plot(NOIgrid(NOIgrid>=0),pl_dir(NOIgrid>=0),'--k','LineWidth',1.5); hold on; plot(NOIgrid(NOIgrid<0),pu_dir(NOIgrid<0),':k','LineWidth',1.5)
plot(NOIgrid(NOIgrid<0),pl_BM(NOIgrid<0),'k-','LineWidth',3)
plot(NOIgrid(NOIgrid>=0),pl_BM(NOIgrid>=0),'k-','LineWidth',3)
xlabel('$y^\mathcal{N}$','FontSize',14,'interpreter','latex')
ylabel('Normalized Prices','FontSize',14)
xlim([prctile(NOI,10),prctile(NOI,90)])
yyaxis right
im=find(NOIgrid<0,1,'last');
histogram(NOI,[fliplr(NOIgrid(im-3:-3:1)) 0 NOIgrid(im+3:3:end)],'FaceColor','C')
ylabel('Number of Auctions','FontSize',14)
ylim([0,100])
ax=gca;
ax.YAxis(1).Color = 'k';
ax.YAxis(2).Color = 'k';
saveas(gcf,fullfile(fig_path,'NOI_exp_price.png'))

% When do they repurchase?
% Probability of buying back given (1) it is possible, (2) own price quote relative to imm price (3) abs(sum opposing submissions)
% Think about this as: when did they "overshoot"--
buyback=(max(abs(supplyq2),[],2)>0);
buyback_possible=(sign(NOIlong)==sign(noi));
buyback=buyback.*buyback_possible;
fprintf('  Repurchase rate (conditional on possible): %.1f%%\n', 100*sum(buyback)./sum(buyback_possible))
Xmat=[imm-((immhigh+immlow)./2) abs(NOIlong-noi)];
Xmat=Xmat(buyback_possible==1,:);
[b,ci]=corrcoef([buyback(buyback_possible==1),Xmat]);

% Part 3: Marginal Values
% Exercise 1: something summarizing correlations in v, n?--contour plot the joint distribution--lower bound left panel upper bound right?--condition on IMM?--
voutn1=nout;
r2=find(qg==0,1,'first');
for jj=1:size(nout,1)
    voutn1(jj,1)=vatqg_lb(jj,r2);
    voutn1(jj,2)=vatqg_ub(jj,r2);
end
voutn1(:,1:2)=voutn1(:,1:2)-aucprice_predicted;
[vcdf]=cdf_estimator_imm(voutn1,nout,noi,median(IMM),auc,-8,8);
vcdfo=vcdf;
[ncdf]=cdf_estimator_imm(nout,nout,noi,median(IMM),auc,-300,300);
ncdfo=ncdf;

voutn2=nout;
r2=find(qg==0,1,'first');
for jj=1:size(nout,1)
voutn2(jj,1)=vout{jj}(1,2);
voutn2(jj,2)=vout{jj}(1,3);
end
voutn2(:,1:2)=voutn2(:,1:2)-aucprice_predicted;
[vcdfB]=cdf_estimator_imm(voutn2,nout,noi,[],auc,-8,8);
ylim([0,1])
xlabel('Marginal Values')



nmin=-300;nmax=300;vmin=-8; vmax=8;
[cop_vn]=pairwise_jointd_estimator_imm(nout,voutn1,noi,median(IMM),size(IMM,1),nmin,nmax,vmin,vmax);
x=reshape(cop_vn(:,1),100,[]); y=reshape(cop_vn(:,2),100,[]); z=reshape(cop_vn(:,3),100,[]);
figure; contour(x,y,z,'ShowText','on')
saveas(gcf,fullfile(fig_path,'contourlow.png'))
x=reshape(cop_vn(:,1),100,[]); y=reshape(cop_vn(:,2),100,[]); z=reshape(cop_vn(:,4),100,[]);
figure; contour(x,y,z,'ShowText','on')
saveas(gcf,fullfile(fig_path,'contourup.png'))

%shading terms
%% ============ APPENDIX C.7: Bid Shading from Positions ============
disp('========== APPENDIX C.7: Bid Shading from Positions ==========')
shhad_part = shhad(nout(:,4)==0 & isnan(shhad(:,1))==0,:);
fprintf('  Mean absolute shading [LB, UB]: [%.3f, %.3f]\n', nanmean(abs(shhad_part(:,1))), nanmean(abs(shhad_part(:,2))))
fprintf('  Median shading [LB, UB]: [%.3f, %.3f]\n', nanmedian(shhad_part(:,1)), nanmedian(shhad_part(:,2)))
shad_pctiles = prctile(shhad_part, [10,25,50,75,90]);
fprintf('  Shading percentiles (LB): P10=%.3f P25=%.3f P50=%.3f P75=%.3f P90=%.3f\n', shad_pctiles(:,1))
fprintf('  Shading percentiles (UB): P10=%.3f P25=%.3f P50=%.3f P75=%.3f P90=%.3f\n', shad_pctiles(:,2))

%% Figure 4 (left): Distribution of Net Exposure
n_grid=linspace(-300,300,1000);
figure; hold on;
plot(n_grid,ncdfo(:,2),'k'); plot(n_grid,ncdfo(:,3),'k');
xlabel('Net Exposure: (n-y)','FontSize',14)
xlim([-300,300]);
saveas(gcf,fullfile(fig_path,'bootstrap_nmy.png'))
FedM=[-400;-180;-120;-80;-60;-40;-20;0;20;40;80;100;120;140;200;280;360];
Feddens=[1;2;2;1;1;2;6;33;12;3;4;1;1;1;1;1;1];
FedDist=cumsum(Feddens)./sum(Feddens);
hold on; plot(FedM,FedDist,'k--');
saveas(gcf,fullfile(fig_path,'bootstrap_nmy_withfed.png'))

%% Figure 4 (middle): Distribution of Marginal Values (conditional)
v0_grid=linspace(-8,8,1000);
figure; hold on;
plot(v0_grid,vcdfo(:,2),'k'); plot(v0_grid,vcdfo(:,3),'k');
xlabel('marginal values','FontSize',14)
xlim([-8,8]); ylim([0,1]);
saveas(gcf,fullfile(fig_path,'bootstrap_v0.png'))

%% Figure 4 (right): Distribution of Marginal Values (unconditional)
v0_grid=linspace(-8,8,1000);
figure; hold on;
plot(v0_grid,vcdfB(:,2),'k'); hold on; plot(v0_grid,vcdfB(:,3),'k')
xlabel('marginal values','FontSize',14)
xlim([-8,8]); ylim([0,1]);
saveas(gcf,fullfile(fig_path,'mvcdf.png'))



