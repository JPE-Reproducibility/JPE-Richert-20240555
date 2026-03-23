%% ============ ROBUSTNESS CHECKS (Appendix C) ============
disp('========== ROBUSTNESS CHECKS ==========')
load(fullfile(int_path,'smc_cfs_np'))
disp('--- Appendix C.5.1: Truthful Reporting Incentives ---')
truthfulpimmcheck
disp('--- Appendix C.5.1: Quote Manipulation Calibration ---')
round1_quotescalibration
%%%%%%%%%%%%%%%%%
%Collusion check: final values summary
for jj=1:size(vatqg_lb,1)
    [~,ic]=min(abs(qgrid-br_qwon(jj)));
mvqwonH(jj)=vatqg_ub(jj,ic); 
mvqwonL(jj)=vatqg_ub(jj,ic);
end
%%%%%%%%%%%%%%%%%
disp('--- Appendix C.2: Risk Aversion Check ---')
riskaversion
%%%%%%%%%%%%%%%%%%%%
%% Figure OS.6: Sample Bounds from Monotonicity
qd=[0;vout{61}(1,1); vout{61}(1,1)];bd=[vout{61}(1,7);vout{61}(1,7);vout{61}(2,7)];
for dd=2:size(vout{61},1)
qd=[qd;[vout{61}(dd,1);vout{61}(dd,1)]];bd=[bd;[vout{61}(dd,7);vout{61}(min(dd+1,size(vout{61},1)),7)]];
end
figure; plot(qd,bd); hold on; scatter(vout{61}(:,1),vout{61}(:,2),[],'b','filled','v'); scatter(vout{61}(:,1),vout{61}(:,3),[],'r','filled','^');
saveas(gcf,fullfile(fig_path,'graphn61.png'))
qd=[0;vout{57}(1,1); vout{57}(1,1)];bd=[vout{57}(1,7);vout{57}(1,7);vout{57}(2,7)];
for dd=2:size(vout{57},1)
qd=[qd;[vout{57}(dd,1);vout{57}(dd,1)]];bd=[bd;[vout{57}(dd,7);vout{57}(min(dd+1,size(vout{57},1)),7)]];
end
figure; plot(qd,bd); hold on; scatter(vout{57}(:,1),vout{57}(:,2),[],'b','filled','v'); scatter(vout{57}(:,1),vout{57}(:,3),[],'r','filled','^');
saveas(gcf,fullfile(fig_path,'graphn57.png'))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%ACCOUNTING FOR CUSTOMER ORDERS in stage 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(fullfile(int_path,'smc_cfs_np'),'imm')
%NLB and NUB are bounds on (n-y) 
integrateforcust=1;
big_known=0;
relaxbounds_vnocustomer=0;
if integrateforcust==1
    ts=supplyp2(:); tq=supplyq2(:); flz=(ts==0|tq==0); ts(flz==1)=[];tq(flz==1)=[];
    xs=supplyp2.*max((cumsum(supplyq2,2)>1),(cumsum(supplyq2,2)<-1)); xs=xs(:);
    xq=supplyq2.*max((cumsum(supplyq2,2)>1),(cumsum(supplyq2,2)<-1)); xq=xq(:);
    flz=(xs==0)+(xq==0); xs(flz==1)=[]; xq(flz==1)=[];
    cf=0.05;
for ii=1:size(supplyp2,1)
    for jj=1:size(supplyp2,2)
    if supplyq2(ii,jj)~=0
    if NOIlong(ii)>0
    taucL=sum((supplyp2(aucidfs==aucidfs(ii),:)>=supplyp2(ii,jj)).*(supplyq2(aucidfs==aucidfs(ii),:)),2);
    Prseen(ii,jj)=sum(taucL>(1-sum(supplyq2(ii,1:jj))))./size(taucL,1);
    else
    taucL=sum((supplyp2(aucidfs==aucidfs(ii),:)<=supplyp2(ii,jj)).*(supplyq2(aucidfs==aucidfs(ii),:)),2);
    Prseen(ii,jj)=sum(taucL<(-1-sum(supplyq2(ii,1:jj))))./size(taucL,1);
    end
    Prbid_subset(ii,jj)=sum((abs(xs-supplyp2(ii,jj))<cf).*(abs(xq==supplyq2(ii,jj))<cf))./size(xs,1);
    Prbid(ii,jj)=sum((abs(ts-supplyp2(ii,jj))<cf).*(abs(tq-supplyq2(ii,jj))<cf))./size(ts,1);
    Prclient(ii,jj)=Prbid_subset(ii,jj).*(1./Prseen(ii,jj))./Prbid(ii,jj);
    else
        Prbid_subset(ii,jj)=0;
        Prbid(ii,jj)=0;
        Prclient(ii,jj)=0;
    
    end
    end
end
Prclient(isnan(Prclient))=0;
Prclient(isinf(Prclient))=0;
Prclient(Prclient>1)=1;
drop=(Prclient>0.25);
%to save on computation in the robustness check I use HT-smoothing rather
%than the better bounds used in the main exercise: should get similar
%results (still consistent) and look not that different
[vout_ca,nout_ca]=basic_estimator(supplyp,round(supplyq,3),idfs,idss,ndraw,NOItotexp,noi,Npossibleexp,supplyp2, round(supplyq2,3),drawnids,[],[],carriedoverp, carriedoverq,immcap2,round(NOIlong,3),eta,[],100*ones(size(bondvols)),imm1cap,1,maxslope,zeros(size(idss)),imm);
[vout_cs,nout_cs]=basic_estimator_copydrop(supplyp,round(supplyq,3),idfs,idss,ndraw,NOItotexp,noi,Npossibleexp,supplyp2, round(supplyq2,3),drawnids,[],[],carriedoverp, carriedoverq,immcap2,round(NOIlong,3),eta,[],100*ones(size(bondvols)),imm1cap,1,maxslope,zeros(size(idss)),imm,drop);
%% --- Appendix C.6: Customer Orders Robustness ---
disp('--- Appendix C.6: Customer Orders Robustness ---')
fprintf('  Correlation of n-bounds (LB): %.4f\n', corr(nout_cs(:,1),nout_ca(:,1)))
fprintf('  Correlation of n-bounds (UB): %.4f\n', corr(nout_cs(:,2),nout_ca(:,2)))
fprintf('  Mean n-bound (LB, with drop): %.2f\n', mean(nout_cs(:,1)))
fprintf('  Mean n-bound (UB, with drop): %.2f\n', mean(nout_cs(:,2)))
fprintf('  Mean n-bound (LB, baseline):  %.2f\n', mean(nout_ca(:,1)))
fprintf('  Mean n-bound (UB, baseline):  %.2f\n', mean(nout_ca(:,2)))
save(fullfile(int_path,'np_part2'))
end


