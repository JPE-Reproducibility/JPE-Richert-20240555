function [ER]=getExpectedRIMM(eta,R,imm,sig_eta,PRgrid,Rquantile,rmean,sig_quo,corrp)

for kk=1:size(eta,1)
    
for rr=1:size(Rquantile,2)
for jj=1:100
etaIN=[eta(kk); randn(10,1).*sig_eta+Rquantile(rr)];
Ein=getExpectedR(etaIN,R,sig_eta,PRgrid,Rquantile);
rimm=rmean+mean(Ein)+(sig_quo./sig_eta).*corrp.*(etaIN-Rquantile(rr))+(1-corrp.^2).*(sig_quo).*randn(size(etaIN));

rup=(rimm+2);
rlow=(rimm-2);
rup(rup<rlow)=[];
rlow(rlow>rup)=[];
rup=sort(rup);
rlow=sort(rlow,'descend');
IMMsim(jj,1)=mean((rup(1:floor(size(rup,1)./2))+rlow(1:floor(size(rup,1)./2)))./2);
end
IMMsim(isnan(IMMsim))=[];
bw=1.06*std(IMMsim).*size(IMMsim,1).^(-1./5);
pcond(rr,1)=sum(normpdf((imm-IMMsim)./bw))./(size(IMMsim,1).*bw);
end
pcond(isnan(pcond))=0;
pcond=pcond./sum(pcond);
for rr=1:size(Rquantile,2)
    peta_gR(:,rr)=normpdf(eta(kk)-Rquantile(rr),sig_eta);
end
probS=peta_gR.*(PRgrid(2)-PRgrid(1));
probS=probS.*pcond';
probS=probS./sum(probS,2);

ER(kk,1)=sum(probS.*Rquantile,2);
end
