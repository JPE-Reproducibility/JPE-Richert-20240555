if ~exist('cf_seed','var') || isempty(cf_seed), cf_seed=0; end
rng(2000+cf_seed);
%FIRST SET UP THE TARGET DISTRIBUTIONS TO MATCH%%%%%%%%%%%%%%%%%%
if positionschange==1
nout(:,1:2)=0.98.*nout(:,1:2);
end
[ncdf]=cdf_estimator_imm(nout,nout,noi,R,auc,-300,300);
%get a correlation and a cdf of y+y^c
nyout=nout; nyout(:,1)=noi; nyout(:,2)=noi;
[ycdf]=cdf_estimator_imm(nyout,nyout,noi,R,auc,-300,300);
qg=[-1000 -500 -100 -50 -10 -5 -2 -1 0 1 2 5 10 50 100 500 1000];
for qgp=1:size(qg,2)
voutn=nout;
for jj=1:size(nout,1)
qtemp=vout{jj}(:,1);
vtempU=vout{jj}(:,3);
vtempL=vout{jj}(:,2);
if qg(qgp)>max(qtemp)
vlowg=vtempL(end)-maxslope.*(qg(qgp)-max(qtemp));
vupg=vtempU(end)-minslope.*(qg(qgp)-max(qtemp));
elseif qg(qgp)<min(qtemp)
vupg=vtempU(1)+maxslope.*(min(qtemp)-qg(qgp));
vlowg=vtempL(1)+minslope.*(min(qtemp)-qg(qgp));
elseif max(qg(qgp)==qtemp)==1
    qI=find(qtemp==qg(qgp),1,'first');
    vlowg=vtempL(qI);
    vupg=vtempU(qI);
else
    qright=find(qtemp>qg(qgp),1,'first');
    qleft=find(qtemp<qg(qgp),1,'last');
vlowg=vtempL(qright);
vupg=vtempU(qleft);
end
voutn(jj,1)=vlowg;
voutn(jj,2)=vupg;
end
voutn(voutn(:,1)>100,1)=100;
voutn(voutn(:,1)<0,1)=0;
voutn(voutn(:,2)>100,2)=100;
voutn(voutn(:,2)<0,2)=0;
voutn(isnan(voutn(:,2)),2)=100;
voutn(isnan(voutn(:,1)),1)=0;
if positionschange==1
voutn(:,1:2)=voutn(:,1:2)-maxslope.*10;
end
[vcdft{qgp}]=cdf_estimator_imm(voutn,voutn,noi,R,auc,R-8,R+8);

if qg(qgp)==1
    vat1=voutn;
end
if qg(qgp)==5
    vat5=voutn;
end
end
close all;

%match vat1 and vat5 correlations
vmin=R-8;
vmax=R+8;
[cop_vat15]=pairwise_jointd_estimator_imm(vat1,vat5,noi,R,auc,vmin,vmax,vmin,vmax);
%match noi and n correlations
vatnoi=nout;
vatnoi(:,1)=noi;
vatnoi(:,2)=noi;
[cop_noin]=pairwise_jointd_estimator_imm(nout,vatnoi,noi,R,auc,min(noi),max(noi),-300,300);

rsa=1;
r=1;
rng(123+cf_seed,'twister');
K=3;

ngrid=1000;ndraw=1000;
spread=median(table2array(immtab(:,3))-table2array(immtab(:,2)));
minPrice=R(r)-sfrac.*spread;
maxPrice=R(r)+sfrac.*spread;

I=median(npart)-1;
Kbar=8;
npq=1000*Kbar;
nsim=1000;
nrep=1000;
N=I;
rng(200+cf_seed);
generatesimsforcf;
Xgrid=linspace(0,1,1000);
knotvec=linspace(0,1,2);
[Quantf]=BsplineBasis3(knotvec',Xgrid');
nstepin=ones(Kbar,1)./sum(ones(Kbar,1));
theta=[0.5;1;13;-3;-1;1;3;0.05;R(r);1;3;.05;0.05;-.15;.85;10;0.01;2;0.01;20;R(r);1;.8;.05;.1;0;0;0];
BD=[];
tau=0;
Qmax=0;
Outerfitfun=@(x)doubleauctionOuter_1stepspecial_yin(x,tau,Mcombos,Qpvec,Pqvec,Pqcombos,Kbar,nstepin,R,minPrice,maxPrice,Quantf,Xgrid,Qmax,qg,maxslope,sell_limit,vcdft,cop_noin,cop_vat15,ycdf);
options=optimoptions('fmincon','MaxFunctionEvaluations',500,'Display','off','Algorithm','sqp');
lb=[0;0.01;0.1;-1000;-200;-200;-200;0;0;0;0;0;0;-.9;-.9;1;0;0;0;0.5;0;0;-1000;0;0;-100;-1;-10];
lb(lb==0)=1e-8;
ub=[10;10;50;200;200;200;200;200;R(r);500;10;500;10;.9;.9;7;15;15;15;1000;.5;.5;0;1000;1000;100;1;10];

A=[1 -1 0; 0 1 -1];
A2=[1 -1 0 0 ; 0 1 -1 0; 0 0 1 -1];
A=[A zeros(2,size(theta,1)-3); zeros(3,3) A2 zeros(3,size(theta,1)-7)];
b=zeros(size(A,1),1);

A=[A; 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
A(end,:)=-1*A(end,:);
b=[b;-R(r)-1];
idw='stats:regress:RankDefDesignMat';
warning('off',idw);
options=optimoptions('fmincon','MaxFunctionEvaluations',1000,'Display','off','Algorithm','sqp');



%initialization and parameters
bidfit=@(x)Outerfitfun(x);
ub(9)=R+spread;
lb(9)=R-spread;
ub(1:3)=[2;2;sfrac.*spread];
ub(4)=0;
lb(4)=-1000;
ub(20)=100;
ub(5:7)=1000;
lb(5:7)=0;
ub(8)=10;
ub(11)=10;
ub(10)=2;
ub(12)=2;
%deviation to the max price: purchasing bonds
lb(23)=0;
ub(23)=1000;
%deviation to the min price:selling bonds
lb(24)=-1000;
ub(24)=0;

normalizeT=@(x)normalizeXs(x,A,lb,ub);
x0=rand(size(theta));

J=100;
K=4;
Kp=size(x0,1);
B=40;
lambda=2;
psi=(([1:1:J]-1)./(J-1)).^lambda;
blocks=2;
thetaB=randn(Kp,B);
weightB=ones(1,B);
ndraws=1000;
ndraws=ndraws;
AA(1)=1;
sigj(1)=1;
lnfitOld=-1000000*ones(1,B);
r1Mat=rand(B,J,K+1);
p=gcp('nocreate');
if isempty(p)
    p=parpool(ncores);
end

for j=2:J
lnfitOld(isnan(lnfitOld))=-1000000;
vj=exp((psi(j)-psi(j-1)).*ndraws.*lnfitOld);
weightB(weightB<1e-40)=1e-40;
weightB=(vj.*weightB)./sum(vj.*weightB);
if max(isnan(weightB))==1
weightB=ones(1,B);
weightB=weightB./sum(weightB);
end
ESSj=B./((mean(weightB.^2))./(mean(weightB).^2));
if ESSj>B/2
    nuj=thetaB;
    nuIloc=[1:1:B];
else
  nuIloc=randsample([1:1:B],B,true,weightB);  
  nuj=thetaB(:,nuIloc);
  weightB=ones(size(weightB));
end

sigj(j)=sigj(j-1).*(0.95+0.1*exp(16*(AA(j-1)-0.35))./(1+exp(16*(AA(j-1)-0.35))));

%ASSIGN TO BLOCKS...L random blocks within block proposal density
%sigj*lagged covariance of draws from iteration j-1 within block l.
rng(j*200+cf_seed)
if blocks>1
blockA=randi(blocks,Kp,1);
for l=1:blocks
covJ{l}=sigj(j).*cov(thetaB(blockA==l,:)')./max(max(cov(thetaB(blockA==l,:)')));
try
   mvnpdf(thetaB(blockA==l,1),zeros(sum(blockA==l),1),covJ{l});
catch
[covJ{l},countiterSPD]=nearestSPD(sigj(j).*covJ{l});  
if countiterSPD>=20000
covJ{l}=sigj(j).*eye(size(covJ{l}));
end
end
end
end

mbblock=cell(blocks,B,K+1);
for bO=1:B
for kkO=1:K+1
for bbb=1:blocks
               if sum(blockA==bbb)>0
               mbblock{bbb,bO,kkO}=mvnrnd(zeros(sum(blockA==bbb),1),covJ{bbb})';
               end
end
end 
end

acceptJ=0;
lnfittemp=lnfitOld;
parfor b=1:B
for kk=1:K+1
    %proposal
    if kk==1
       x=nuj(:,b); 
      xold=nuj(:,b);
       lnINold=lnfitOld(1,nuIloc(b));
        gx=1;gxR=1;
    else
       xold=x;
       if blocks==1
       x=xold+sigj(j).*randn(Kp,1);
       gx=normpdf(x./sigj(j));
        gxR=normpdf(xold./sigj(j));
       else
           gx=zeros(1,blocks);
           gxR=zeros(1,blocks);
           for bb=1:blocks
               if sum(blockA==bb)>0
                     x(blockA==bb)=xold(blockA==bb)+mbblock{bb,b,kk};          
               end
           end
       end
    end
    if kk>1
    lnA=(-.5).*bidfit(normalizeT(x)); 
    if j==2
    lnINold=lnfittemp(b);
    end
    %accept/reject
   alpha=(exp(psi(j).*ndraws.*lnA-psi(j).*ndraws.*lnINold));%.*prod(gx./gxR);
    r1=r1Mat(b,j,kk);
    if r1<=alpha
        x=x;
        lnINold=lnA;
        acceptJ=acceptJ+1;
        lnfittemp(b)=lnINold;  
    else
        x=xold;
    end
    end
end
thetaB(:,b)=x;
end
lnfitOld=lnfittemp;
AA(j)=sum(acceptJ)./(B*(K));
if mod(j,25)==0; fprintf('  SMC stage %d/%d, accept=%.2f\n', j, J, AA(j)); end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%NOW TAKE A BUNCH OF DRAWS FROM IT 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
exitflag=0;
counter=1;
sim_theta=thetaB;
for jaj=1:size(thetaB,2)
    lnfitOld(jaj)=-0.5.*bidfit(normalizeT(thetaB(:,jaj)));
end
while exitflag==0
rng(counter+cf_seed);
    for bbb=1:blocks
               if sum(blockA==bbb)>0
               mbblock2{bbb}=mvnrnd(zeros(sum(blockA==bbb),1),covJ{bbb})';
               end
    end
    lnINold=max(lnfitOld);
    wa=(exp(psi(j).*ndraws.*lnfitOld-psi(j).*ndraws.*lnINold)); wa=wa./sum(wa);
    if max(isnan(wa))==1
    wa=ones(1,B); wa=wa./sum(wa);
    end
    xold=thetaB(:,randsample(size(thetaB,2),1,true,wa));
           for bb=1:blocks
               if sum(blockA==bb)>0
                xa(blockA==bb)=xold(blockA==bb)+mbblock2{bb};          
               end
           end
           if size(xa,1)==1
               xa=xa';
           end
           lnA=-.5.*bidfit(normalizeT(xa));
           lnINold=max(lnfitOld);
            alpha=(exp(psi(j).*ndraws.*lnA-psi(j).*ndraws.*lnINold));%.*prod(gx./gxR);
    
    r1=rand(1);
    if r1<=alpha
    sim_theta=[sim_theta xa];
    end
    if size(sim_theta,2)>99 | counter>1000
       exitflag=1; 
    end
        counter=counter+1;
end
fprintf('  Posterior draws: %d (counter=%d)\n', size(sim_theta,2), counter);

if positionschange~=1
fnmind=fullfile(int_path,sprintf(['cf_topout_np_pt_',num2str(round(sell_limit)),num2str(2*sfrac),num2str(imqi)]));
%save(fnmind,'-v7.3');
save(fnmind, '-regexp', '^(?!(extraoutbs|extrainfobs|supplyp2bs|supplyq2bs)$).');

clear Gfit Pcl qx surp sdpcl C_binds
for jj=1:size(sim_theta,2)
[Gfit(jj),~,~,Pcl(jj),~,~,~,qx{jj},~,surp{jj},sdpcl(jj),C_binds(jj),surpA(jj,:),surpAB(jj,:),PclA{jj},vclA{jj},vcuA{jj}]=Outerfitfun(normalizeT(sim_theta(:,jj)));
end
%save(fnmind,'-v7.3');
save(fnmind, '-regexp', '^(?!(extraoutbs|extrainfobs|supplyp2bs|supplyq2bs)$).');

else
fnmind=fullfile(int_path,'positionschange',sprintf(['cf_topout_np_pt_',num2str(round(sell_limit)),num2str(2*sfrac),num2str(imqi)]));
%save(fnmind,'-v7.3');
save(fnmind, '-regexp', '^(?!(extraoutbs|extrainfobs|supplyp2bs|supplyq2bs)$).');

clear Gfit Pcl qx surp sdpcl C_binds
for jj=1:size(sim_theta,2)
[Gfit(jj),~,~,Pcl(jj),~,~,~,qx{jj},~,surp{jj},sdpcl(jj),C_binds(jj),surpA(jj,:),surpAB(jj,:),PclA{jj},vclA{jj},vcuA{jj}]=Outerfitfun(normalizeT(sim_theta(:,jj)));
end
%save(fnmind,'-v7.3');
save(fnmind, '-regexp', '^(?!(extraoutbs|extrainfobs|supplyp2bs|supplyq2bs)$).');
end


fprintf('\n--- CF Results: sell_limit=%d, sfrac=%d, positionschange=%d ---\n', round(sell_limit), sfrac, positionschange)
fprintf('  Clearing prices:       [%.2f, %.2f]\n', min(Pcl), max(Pcl))
fprintf('  Price std dev:         [%.2f, %.2f]\n', min(sdpcl), max(sdpcl))
fprintf('  Surplus (per bidder):  [%.4f, %.4f]\n', min(surpAB), max(surpA))
fprintf('  Surplus ($M):          [%.1f, %.1f]\n', min(surpAB)*median(ndeal)/100, max(surpA)*median(ndeal)/100)
fprintf('  Constraint binds:      [%.2f, %.2f]\n', min(C_binds), max(C_binds))



