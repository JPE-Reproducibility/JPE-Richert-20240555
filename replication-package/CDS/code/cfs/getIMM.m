function [imm]=getIMM(eta,R,sig_eta,PRgrid,Rquantile,rmean,sig_quo,corrp)

etaSET=R+randn(1000,1).*sig_eta;
Eset=getExpectedR(etaSET,R,sig_eta,PRgrid,Rquantile);

etaIN=eta;
Ein=getExpectedR(etaIN,R,sig_eta,PRgrid,Rquantile);
rimm=rmean+mean(Ein)+(sig_quo./sig_eta).*corrp.*(etaIN-mean(Eset))+(1-corrp.^2).*(sig_quo).*randn(size(etaIN));


rup=(rimm+2);
rlow=(rimm-2);
rup(rup<rlow)=[];
rlow(rlow>rup)=[];
rup=sort(rup);
rlow=sort(rlow,'descend');
imm=mean((rup(1:floor(size(rup,1)./2))+rlow(1:floor(size(rup,1)./2)))./2);