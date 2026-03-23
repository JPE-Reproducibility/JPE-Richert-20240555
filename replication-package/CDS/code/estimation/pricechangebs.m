function [dSurpU,dSurpL,p_lowout,p_upout,plb_out,pub_out]=pricechangebs(enter,imm,ndraw,vatqg_lb,vatqg_ub,qgrid,IMMtarget,bwIMM)

rng(2000)
ew=enter(:,1); ew=1./ew; ew=ew./nansum(ew); ew(isnan(ew))=0; 
imw=normpdf((imm-IMMtarget)./bwIMM);
imw=imw./sum(imw); ew=ew.*imw(1:size(ew,1));

setS=reshape(randsample(size(ew,1),ndraw*11,true,ew),[],11);
vatqg_lb(isnan(vatqg_lb))=0;
vatqg_ub(isnan(vatqg_ub))=0;
for jj=1:ndraw
%stick the v-hats together
vubsell=vatqg_ub(setS(jj,:)',qgrid<0); vubbuy=vatqg_ub(setS(jj,:)',qgrid>0);
vlbsell=vatqg_lb(setS(jj,:)',qgrid<0); vlbbuy=vatqg_lb(setS(jj,:)',qgrid>0);
qgsell=qgrid(qgrid<0); qgbuy=qgrid(qgrid>0); qgbuyInc=repmat([qgbuy-[0 qgbuy(1:end-1)]],size(setS(jj,:)',1),1); qgbuyInc=qgbuyInc(:);
qgsellInc=repmat([qgsell-[qgsell(2:end) 0]],size(setS(jj,:)',1),1);
qgsellInc=qgsellInc(:);
[vc,icv]=sort(vubbuy(:),'descend');
[vcs,icvs]=sort(vubsell(:),'ascend');
ogv=interp1(cumsum(qgbuyInc(icv)),vc,cumsum(-qgsellInc(icvs)));
try
p_upp(jj)=vcs(find((ogv-vcs)<=0,1,'first'));
catch
p_upp(jj)=vcs(end);
end
[vcl,icvl]=sort(vlbbuy(:),'descend');
[vcls,icvls]=sort(vlbsell(:),'ascend');
ogv=interp1(cumsum(qgbuyInc(icvl)),vcl,cumsum(-qgsellInc(icvls)));
try
p_low(jj)=vcls(find((ogv-vcls)<=0,1,'first'));
catch
p_low(jj)=vcls(end);
end
end
p_lowout=mean(p_low);
p_upout=mean(p_upp);
plb_out=p_low(1:10);
pub_out=p_upp(1:10);

%properly bound the variance 
if ndraw>2000
pl=min(p_low(1:1000),p_upp(1:1000));
pu=p_upp(1:1000);
options=optimoptions('fmincon','MaxFunctionEvaluations',5000000,'Display','off');
fvar=@(x)var(x);
[pva,fva]=fmincon(fvar,(pl+pu)./2,[],[],[],[],pl,pu,[],options);
fvar=@(x)-var(x);
[pva,fva]=fmincon(fvar,(pl+pu)./2,[],[],[],[],pl,pu,[],options);
end

%SURPLUS BASELINE--to participants inside and allocation only.
%DO SURPLUS from EFFICIENT CHANGE TOO!

for jj=1:ndraw
%stick the v-hats together
vubsell=vatqg_ub(setS(jj,:)',qgrid<0); vubbuy=vatqg_ub(setS(jj,:)',qgrid>0);
vlbsell=vatqg_lb(setS(jj,:)',qgrid<0); vlbbuy=vatqg_lb(setS(jj,:)',qgrid>0);
qgsell=qgrid(qgrid<0); qgbuy=qgrid(qgrid>0); qgbuyIncO=repmat([qgbuy-[0 qgbuy(1:end-1)]],size(setS(jj,:)',1),1); qgbuyInc=qgbuyIncO(:);
qgsellIncO=repmat([qgsell-[qgsell(2:end) 0]],size(setS(jj,:)',1),1); qgsellInc=qgsellIncO(:);
[vc,icv]=sort(vubbuy(:),'descend');
[vcs,icvs]=sort(vlbsell(:),'ascend');
ogv=interp1(cumsum(qgbuyInc(icv)),vc,cumsum(-qgsellInc(icvs)));
try
p_upp(jj)=vcs(find((ogv-vcs)<=0,1,'first'));
catch
p_upp(jj)=vcs(end);
end
[vcl,icvl]=sort(vlbbuy(:),'descend');
[vcls,icvls]=sort(vubsell(:),'ascend');
ogv=interp1(cumsum(qgbuyInc(icvl)),vcl,cumsum(-qgsellInc(icvls)));
try
p_low(jj)=vcls(find((ogv-vcls)<=0,1,'first'));
catch
p_low(jj)=vcls(end);
end

dqLb=(vlbbuy>=p_low(jj));
dqLs=(vubsell<=p_low(jj));
dqUs=(vlbsell<=p_upp(jj));
dqUb=(vubbuy>=p_upp(jj));

dSurpU(jj)=mean(sum(dqUb.*vubbuy.*qgbuyIncO,2)-sum(dqUs.*vlbsell.*qgsellIncO,2));
dSurpL(jj)=mean(sum(dqLb.*vlbbuy.*qgbuyIncO,2)-sum(dqLs.*vubsell.*qgsellIncO,2));
end

dSurpU=mean(dSurpU);
dSurpL=mean(dSurpL);

