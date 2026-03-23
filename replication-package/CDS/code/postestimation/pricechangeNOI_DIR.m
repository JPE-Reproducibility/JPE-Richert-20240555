function[pl_out,pu_out]=pricechangeNOI_DIR(ew,vatqg_lb,vatqg_ub,qgrid,NOItarget,noi,bwn,nout)
rng(200)
ndrawBB=1000;
setS=reshape(randsample(size(ew,1),ndrawBB*1000*11,true,ew),[],11);
distN=normpdf((NOItarget-sum(noi(setS),2))./bwn); 
distN(sign(sum(noi(setS),2))~=sign(NOItarget))=0;
distN=distN./sum(distN);
setA=randsample(size(distN,1),ndrawBB,true,distN);
setS=setS(setA,:);

vatqg_lb(isnan(vatqg_lb))=0;
vatqg_ub(isnan(vatqg_ub))=0;
for jj=1:ndrawBB
%stick the v-hats together
vubsell=vatqg_ub(setS(jj,:)',qgrid<0); vubbuy=vatqg_ub(setS(jj,:)',qgrid>0);
vlbsell=vatqg_lb(setS(jj,:)',qgrid<0); vlbbuy=vatqg_lb(setS(jj,:)',qgrid>0);


qgsell=qgrid(qgrid<0); qgbuy=qgrid(qgrid>0); qgbuyInc=repmat([qgbuy-[0 qgbuy(1:end-1)]],size(setS(jj,:)',1),1); qgbuyIncO=qgbuyInc; qgbuyInc=qgbuyInc(:);
qgsellInc=repmat([qgsell-[qgsell(2:end) 0]],size(setS(jj,:)',1),1);
qgsellInc=qgsellInc(:);

if NOItarget>0
qgsellInc=qgsellInc.*0;
[vc,icv]=sort(vubbuy(:),'descend');
[vcl,icvl]=sort(vlbbuy(:),'descend');
try
p_upp(jj)=vc(find((sum(noi(setS(jj,:)))-cumsum(qgbuyInc(icv)))<=0,1,'first'));
p_low(jj)=vcl(find((sum(noi(setS(jj,:)))-cumsum(qgbuyInc(icvl)))<=0,1,'first'));
catch
    p_low(jj)=vcl(1);
    p_upp(jj)=vcl(end);
end

else
qgbuyInc=0.*qgbuyInc;
[vc,icv]=sort(vubsell(:),'ascend');
[vcl,icvl]=sort(vlbsell(:),'ascend');
   
try
p_upp(jj)=vc(find((sum(noi(setS(jj,:)))-cumsum(qgsellInc(icv)))>=0,1,'first'));
p_low(jj)=vcl(find((sum(noi(setS(jj,:)))-cumsum(qgsellInc(icvl)))>=0,1,'first'));
catch
    p_low(jj)=vcl(end);
    p_upp(jj)=vc(1);
end


end



end
if NOItarget>0
p_low(p_low>1)=1;
p_upp(p_upp>1)=1;
else
p_low(p_low<-1)=-1;
p_upp(p_upp<-1)=-1;
end

pl_out=mean(p_low);
pu_out=mean(p_upp);



