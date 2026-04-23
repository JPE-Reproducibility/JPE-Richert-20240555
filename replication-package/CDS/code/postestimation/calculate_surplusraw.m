qg=[linspace(min(noi),0,1000) linspace(0,max(noi),1000)];
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



r=find(qg==0);
for jj=1:size(NOIlong,1)
if NOIlong(jj)>0
    tsq=NOIlong(jj).*supplyq(idss==idfs(jj));
    tsp=imm1cap(jj).*supplyp(idss==idfs(jj));
ssq_U=find(qg>=sum(tsq(tsp>=aucpricefs2(jj))),1,'first');
ssq_L=find(qg<=sum(tsq(tsp>aucpricefs2(jj))),1,'last');
if ssq_U>r
SS_surp_UB(jj)=sum((qg(r+1:ssq_U)-qg(r:ssq_U-1)).*(vatqg_ub(ii,r+1:ssq_U)));
else
SS_surp_UB(jj)=0;
end
if ssq_U>r
SS_surp_LB(jj)=sum((qg(r+1:ssq_L)-qg(r:ssq_L-1)).*(vatqg_lb(ii,r+1:ssq_L)));
else
SS_surp_LB(jj)=0;
end
FS_surp_UB(jj)=sign(noi(jj)).*8.*noi(jj);
FS_surp_LB(jj)=-sign(noi(jj)).*8.*noi(jj);
else
    %other direction
    tsq=NOIlong(jj).*supplyq(idss==idfs(jj));
    tsp=imm1cap(jj).*supplyp(idss==idfs(jj));
ssq_U=find(qg>=sum(tsq(tsp<=aucpricefs2(jj))),1,'first');
ssq_L=find(qg<=sum(tsq(tsp<aucpricefs2(jj))),1,'last');
if ssq_U>r 
SS_surp_UB(jj)=sum((qg(ssq_U:r)-qg(ssq_U+1:r+1)).*(vatqg_ub(ii,ssq_U:r)));
else
SS_surp_UB(jj)=0;
end
if ssq_U>r
SS_surp_LB(jj)=sum((qg(ssq_L:r)-qg(ssq_L+1:r+1)).*(vatqg_lb(ii,ssq_L:r)));
else
SS_surp_LB(jj)=0;
end
FS_surp_UB(jj)=sign(noi(jj)).*8.*noi(jj);
FS_surp_LB(jj)=-sign(noi(jj)).*8.*noi(jj);
end
end
%% Section 6.1: Status quo auction surplus (per-person * ndealers)
SQsurp_UB = mean(FS_surp_UB+SS_surp_UB).*11;
SQsurp_LB = mean(FS_surp_LB+SS_surp_LB).*11;
fprintf('  Status quo surplus bounds: [$%.0fM, $%.0fM]\n', SQsurp_LB./100, SQsurp_UB./100)
