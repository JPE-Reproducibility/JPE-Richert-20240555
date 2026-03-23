
ndraws=100;
nsim=100;
BPmeanSO=BPmeanS;
BPmeanS=BPmeanS(max(isnan(BPmeanS),[],2)==0,:);
R=median(IMM); 
spread=1; %half the spread
immi=(immhigh+immlow)./2;

bwI=1.06.*nanstd(BPmeanS(:,61)).*size(BPmeanS(:,61),1).^(-1./5);

sigma_etaG=linspace(0.1,1,5);
sigpbG=linspace(1,10,5);
mpbG=linspace(-10,0,10);

for aa=1:size(sigma_etaG,2)
    for bb=1:size(sigpbG,2)
        for cc=1:size(mpbG,2)

sigma_eta=sigma_etaG(aa);
mpb=mpbG(cc);
sigpb=sigpbG(bb);
%generate draws

eta=randn(ndraws,1);
Pben=mpb+sigpb.*randn(ndraws,1);
    
            kweight=sum(normpdf((BPmeanS(:,61)-BPmeanS(:,61)')./bwI),2);
    kweightBL=kweight./sum(kweight);
%calculate these optimal
for jj=1:ndraws
    kweight=kweightBL;
    kweight=kweight.*normpdf(BPmeanS(:,61),R+eta(jj),sigma_eta);
    kweight=kweight./sum(kweight);
    %reshape the small known price subsample to the 2000x1
    kweight2=zeros(size(immi));
    for ii=1:size(aucidbond(max(isnan(BPmeanSO),[],2)==0,:),1)
        kweight2(aucidfs==aucidbond(ii))=kweight(ii);
    end
    kweight2=kweight2./sum(kweight2);
    expectedopposingQ=reshape(randsample(immi,nsim*10,true,kweight2),10,[]);
    NOIExp=randsample(NOIlong,nsim,true,kweight2);
    consGrid=[R-10:0.125:R+10];
    %how much in expectation does this choice influence the outcome
    eps=0.125;
    %for each consGrid point put it into expectedopposing, calculated the
    %imm that results in each simulated set
    for ll=1:size(consGrid,2)
    for kk=1:size(expectedopposingQ,2)
    [maxB,icb]=sort(-[expectedopposingQ(:,kk)-spread;consGrid(ll)-spread]);
    maxB=-1*maxB;
   [minO,ics]=sort([expectedopposingQ(:,kk)+spread;consGrid(ll)+spread]);
   dsq=(maxB>=minO);
   maxBT=maxB(sum(dsq)+1:sum(dsq)+ceil((size(maxB,1)-sum(dsq))/2));
   minOT=minO(sum(dsq)+1:sum(dsq)+ceil((size(maxB,1)-sum(dsq))/2));
   innt=(mean(maxBT)+mean(minOT))./2;
   IMM=round(8*innt)/8;
   %NOI
   %calculate adjustment amounts
   AmountoffTL=((maxB-IMM).*(maxB>IMM).*(NOIExp(kk)>0)).*(dsq);
   AmountoffTH=((minO-IMM).*(minO<IMM).*(NOIExp(kk)<0)).*(dsq);
   Amountoff=AmountoffTL(icb==max(icb))+AmountoffTH(ics==max(ics));
   %         
    Pclin(kk)=IMM;
    fineS(kk)=Amountoff; 
    end
   Pcl(ll)=mean(Pclin);
   fine(ll)=mean(fineS);
end
    Pcleps=Pcl(2:end);
    Pcl=Pcl(1:end-1);
    consGrid=consGrid(2:end);
    % putting it together
    Pimpact=(Pcleps-Pcl)./eps;
    PionGrid=Pben(jj).*Pimpact.*(-1.*(consGrid<R))-fine(2:end);
    [~,ic]=max(PionGrid);   
    Rquote(jj)=consGrid(ic);
end

%measure distance

%null distribution first
    kweight=sum(normpdf((BPmeanS(:,61)-BPmeanS(:,61)')./bwI),2);
    kweight=kweight./sum(kweight);
    kweight=kweight.*normpdf(BPmeanS(:,61),R,sigma_eta);
    kweight=kweight./sum(kweight);


kweight2=zeros(size(immi));
   for ii=1:size(aucidbond(max(isnan(BPmeanSO),[],2)==0,:),1)
        kweight2(aucidfs==aucidbond(ii))=kweight(ii);
    end
    kweight2=kweight2./sum(kweight2);
    expectedopposingQ=reshape(randsample(immi,nsim*11,true,kweight2),11,[]);

    for kk=1:size(expectedopposingQ,2)
    [maxB,icb]=sort(-[expectedopposingQ(:,kk)-spread]);
    maxB=-1*maxB;
   [minO,ics]=sort([expectedopposingQ(:,kk)+spread]);
   dsq=(maxB>=minO);
   maxBT=maxB(sum(dsq)+1:sum(dsq)+ceil((size(maxB,1)-sum(dsq))/2));
   minOT=minO(sum(dsq)+1:sum(dsq)+ceil((size(maxB,1)-sum(dsq))/2));
   innt=(mean(maxBT)+mean(minOT))./2;
   IMM=round(8*innt)/8;
    Pcl(kk)=IMM;
    end

distance(aa,bb,cc)=sum((prctile(Pcl,[10;25;50;75;90])-prctile(Rquote,[10;25;50;75;90])).^2);
end
    end
end

save(fullfile(int_path,'temp_calibration'),'-v7.3');

[aa,bb,cc]=ind2sub(size(distance),find(distance==min(distance),1,'first'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NOW GET WHAT THE EXPECTED AND THE RATIO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%OF THE VARIANCES.
sigma_eta=sigma_etaG(aa);
mpb=mpbG(cc);
sigpb=sigpbG(bb);
eta=sigma_eta.*randn(ndraws,1);
Pben=mpb+sigpb.*randn(ndraws,1);

for jj=1:ndraws
    kweight=normpdf((BPmeanS(:,57)-(R+eta(jj)))./bwI);
    kweight2=zeros(size(immi));
    for ii=1:size(aucidbond(max(isnan(BPmeanSO),[],2)==0,:),1)
        kweight2(aucidfs==aucidbond(ii))=kweight(ii);
    end
    kweight2=kweight2./sum(kweight2);
    expectedopposingQ=reshape(randsample(immi,nsim*10,true,kweight2),10,[]);
    NOIExp=randsample(NOIlong,nsim,true,kweight2);
    consGrid=[R-10:0.125:R+10];
    %how much in expectation does this choice influence the outcome
    eps=0.125;
    %for each consGrid point put it into expectedopposing, calculated the
    %imm that results in each simulated set
    for ll=1:size(consGrid,2)
    for kk=1:size(expectedopposingQ,2)
    [maxB,icb]=sort(-[expectedopposingQ(:,kk)-spread;consGrid(ll)-spread]);
    maxB=-1*maxB;
   [minO,ics]=sort([expectedopposingQ(:,kk)+spread;consGrid(ll)+spread]);
   dsq=(maxB>=minO);
   maxBT=maxB(sum(dsq)+1:sum(dsq)+ceil((size(maxB,1)-sum(dsq))/2));
   minOT=minO(sum(dsq)+1:sum(dsq)+ceil((size(maxB,1)-sum(dsq))/2));
   innt=(mean(maxBT)+mean(minOT))./2;
   IMM=round(8*innt)/8;
   AmountoffTL=((maxB-IMM).*(maxB>IMM).*(NOIExp(kk)>0)).*(dsq);
   AmountoffTH=((minO-IMM).*(minO<IMM).*(NOIExp(kk)<0)).*(dsq);
   Amountoff=AmountoffTL(icb==max(icb))+AmountoffTH(ics==max(ics));
    Pcl(kk)=IMM;
    fineS(kk)=Amountoff;
    end
   PclOut(ll)=mean(Pcl);
   fine(ll)=mean(fineS);
end
    Pcleps=PclOut(2:end);
    PclOut=PclOut(1:end-1);
    consGrid=consGrid(2:end);
    % putting it together
    Pimpact=(Pcleps-PclOut)./eps;
    PionGrid=Pben(jj).*Pimpact.*(-1.*(consGrid<R))-fine(2:end);
    [~,ic]=max(PionGrid);   
    Rquote(jj)=consGrid(ic);
 end

corrp=corr(Rquote',eta);
sig_quo=std(Rquote);
load(fullfile(int_path,'maindata'),'IMM')
PRgrid=linspace(0,1,500);
Rquantile=quantile(IMM,PRgrid);
for abc=1:10
etain=eta(randi(size(eta,1),10,1));
[ER]=getExpectedR(R+etain,R,sigma_eta,PRgrid,Rquantile);
[imm]=getIMM(R+etain,R,sigma_eta,PRgrid,Rquantile,mpb,sig_quo,corrp);
[ER2]=getExpectedRIMM(R+etain,R,imm,sigma_eta,PRgrid,Rquantile,mpb,sig_quo,corrp);
v1(abc)=var(ER);
v2(abc)=var(ER2);
end
fprintf('  Calibrated parameters: sigma_eta=%.2f, mpb=%.1f, sigpb=%.1f\n', sigma_eta, mpb, sigpb)
fprintf('  Variance ratio V(E[R|IMM])/V(E[R|eta]): %.4f\n', mean(v2./v1))

BPmeanS=BPmeanSO;

