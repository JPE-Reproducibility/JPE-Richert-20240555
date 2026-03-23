function [ER]=getExpectedR(eta,R,sig_eta,PRgrid,Rquantile)

for rr=1:size(Rquantile,2)
    peta_gR(:,rr)=normpdf(eta-Rquantile(rr),sig_eta);
end
probS=peta_gR.*(PRgrid(2)-PRgrid(1));
probS=probS./sum(probS,2);

ER=sum(probS.*Rquantile,2);

