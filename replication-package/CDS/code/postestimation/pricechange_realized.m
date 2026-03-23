function [plb_out,pub_out]=pricechange_realized(vatqg_lb,vatqg_ub,qgrid,aucidfs)

vatqg_lb(isnan(vatqg_lb))=0;
vatqg_ub(isnan(vatqg_ub))=0;
uauc=unique(aucidfs);
for jj=1:size(uauc,1)
setS=find(aucidfs==uauc(jj));
%stick the v-hats together
vubsell=vatqg_ub(setS,qgrid<0); vubbuy=vatqg_ub(setS,qgrid>0);
vlbsell=vatqg_lb(setS,qgrid<0); vlbbuy=vatqg_lb(setS,qgrid>0);
qgsell=qgrid(qgrid<0); qgbuy=qgrid(qgrid>0); qgbuyInc=repmat([qgbuy-[0 qgbuy(1:end-1)]],size(setS,1),1); qgbuyInc=qgbuyInc(:);
qgsellInc=repmat([qgsell-[qgsell(2:end) 0]],size(setS,1),1);
qgsellInc=qgsellInc(:);
[vc,icv]=sort(vubbuy(:),'descend');
[vcs,icvs]=sort(vubsell(:),'ascend');
ogv=interp1(cumsum(qgbuyInc(icv)),vc,cumsum(-qgsellInc(icvs)));
try
pub_out(jj)=vcs(find((ogv-vcs)<=0,1,'first'));
catch
pub_out(jj)=vcs(end);
end
[vcl,icvl]=sort(vlbbuy(:),'descend');
[vcls,icvls]=sort(vlbsell(:),'ascend');
ogv=interp1(cumsum(qgbuyInc(icvl)),vcl,cumsum(-qgsellInc(icvls)));
try
plb_out(jj)=vcls(find((ogv-vcls)<=0,1,'first'));
catch
plb_out(jj)=vcls(end);
end
end
