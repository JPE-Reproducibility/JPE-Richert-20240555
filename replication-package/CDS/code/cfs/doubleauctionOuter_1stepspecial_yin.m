function [Gfit,meanD,maxD,Pcl,weightco,wiraw,Pown,qx,NV,surp,sdpcl,C_binds,surpA,surpAB,PclA,vclA,vcuA]=doubleauctionOuter_1stepspecial_yin(theta,tau,Mcombos,Qpvec,Pqvec,Pqcombos,Kbar,nstepin,Rcommon,minPrice,maxPrice,Quantf,Xgrid,Qmax,qset_point,maxslope,sell_limit,vcdft,cop_noin,copvat15,ycdf)

meanD=[];
maxD=[];
wiraw=[];
NV=[];

rng(200);
nrep=size(Pqvec,1)./Kbar;

%Parameter list: 
%Theta:
% 1-3: price leftmost step bspline 4 params
% 4-7: Q leftmost step bspline 4 params
% 9: simple level shift to all prices additive at last step
% 8,10,11,12:  build 2 beta distribution parameters (for q increment) as a linear
% function of number of steps (intercept--slope in n-steps)
% 13 17 18 19:  build 2 beta distribution parameters (for p increment) as a linear
% function of number of steps (intercept--slope in n-steps)
% 20: multiplicative rescaling of Q-steps at the end
% 14 15 : correlation params
%16, 21-22 k-weights
%23-25 market cornering parameters
%26-28 yin construction from linear projection of p/qs
%29 some kind of shock to yin



Pintp=theta(1:size(Quantf,2)-1);
Qintp=theta(size(Quantf,2):2*size(Quantf,2)-1);


Qintp=cumsum(Qintp);

muP=theta(9); 
%for ref.
%Pinc=theta(13);
corrpI=theta(14);
corrpinc=theta(15);
PoisP=theta(16);

try
weights=1./nrep.*ones(1,nrep);

 Qpvect=reshape(Qpvec,[],Kbar);
 Qpvect(1:floor(nstepin(1)*size(Qpvect,1)),2:end)=0;
 lastc=floor(nstepin(1)*size(Qpvect,1));
 for kb=2:size(nstepin,1)
     Qpvect(lastc+1:floor((sum(nstepin(1:kb)))*size(Qpvect,1)),kb+1:end)=0;
     lastc=floor((sum(nstepin(1:kb)))*size(Qpvect,1));
 end
Qpvecz=Qpvect;

muQinc=theta(8)+theta(10)*(sum(Qpvect~=0,2));
sigQinc=theta(11)+theta(12)*(sum(Qpvect~=0,2)); 


muPinc=theta(13)+theta(17)*(sum(Qpvect~=0,2));
sigPinc=theta(18)+theta(19)*(sum(Qpvect~=0,2)); 
scaleP=theta(20);

ngg=4;
p1in(1:(ngg./2),1)=maxPrice;
p1in((ngg./2)+1:ngg,1)=minPrice;
q1in(1:(ngg./2),1)=theta(23)+norminv(Qpvec(1:(ngg./2),1)).*theta(25);
q1in((ngg./2)+1:ngg,1)=theta(24)+norminv(Qpvec((ngg./2)+1:ngg,1)).*theta(25);

weights=weights.*(PoisP.^(sum(Qpvect~=0,2)'-1).*(exp(-PoisP))./factorial(sum(Qpvect~=0,2)'-1));
weights=weights./(poisscdf(size(Qpvect,2),PoisP));
 weights=weights./(1./nrep);
 Qpvect(Qpvect==0)=NaN;
Qpvect=reshape(Qpvec,[],Kbar);
Qpvec=Qpvect;

Pqvec=reshape(Pqvec,[],Kbar);
Pqvect=Pqvec;
Pqvect(:,1)=interp1(Xgrid,Quantf*[0; Pintp],Pqvect(:,1));


Pqvect(:,2:end)=betainv(Pqvect(:,2:end),repmat(muPinc,1,size(Pqvect(:,2:end),2)),repmat(sigPinc,1,size(Pqvect(:,2:end),2)));

Qpvect(:,1)=corrpI.*norminv(Qpvec(:,1))+(sqrt(1-corrpI.^2).*norminv(Pqvec(:,1)));
Qpvect(:,1)=interp1(Xgrid,Quantf*Qintp,normcdf(Qpvect(:,1)));
Qpvect(:,2:end)=corrpinc.*norminv(Qpvec(:,2:end))+(sqrt(1-corrpinc.^2).*norminv(Pqvec(:,2:end)));
Qpvect(:,2:end)=scaleP.*betainv(normcdf(Qpvect(:,2:end)),repmat(muQinc,1,size(Pqvect(:,2:end),2)),repmat(sigQinc,1,size(Pqvect(:,2:end),2)));
Qpvect(:,1)=Qpvect(:,1);
Qpvect(isnan(Qpvect))=1e-8;
Qpvect(Qpvecz==0)=0;
Pqvect(Qpvecz==0)=0;
PriceD=Pqvect;

Pqvect(1:ngg,1)=p1in(1:ngg)-muP;
Qpvect(1:ngg,1)=q1in(1:ngg);
weights=weights./sum(weights);
pr1step=sum(weights(1:size(Qpvect((sum(Qpvect~=0,2)==1)),1)));

yin=[ones(size(Qpvect,1),1) sign(Qpvect(:,1)).*log(abs(Qpvect(:,1)))]*theta(26:27);
yin=yin+randn(size(yin)).*theta(28);
yin(abs(yin)<1)=0;

invRat(1:(ngg./2))=theta(21)./((ngg./2)./size(Qpvect((sum(Qpvect~=0,2)==1)),1));
invRat(ngg./2+1:ngg)=theta(22)./((ngg./2)./size(Qpvect((sum(Qpvect~=0,2)==1)),1));
invRat(ngg+1:size(Qpvect((sum(Qpvect~=0,2)==1)),1))=(1-theta(21)-theta(22))./((size(Qpvect((sum(Qpvect~=0,2)==1)),1)-ngg)./(size(Qpvect((sum(Qpvect~=0,2)==1)),1)));
invRat=invRat./sum(invRat);
weights(1:size(Qpvect((sum(Qpvect~=0,2)==1)),1))=0;
weights=weights./sum(weights); weights=weights.*(1-pr1step);
weights(1:size(Qpvect((sum(Qpvect~=0,2)==1)),1))=invRat.*pr1step;
weights=weights./sum(weights);
C_binds=sum(weights(1:ngg)); 


pqvs=Pqvect;
pqvs(:,2:end)=Pqvect(:,1)-cumsum(Pqvect(:,2:end),2);
pqvs=pqvs+muP;
pqvs(pqvs<minPrice)=minPrice;
pqvs(pqvs>maxPrice)=maxPrice;
pqvs(pqvs<1)=1;
Pqvect=pqvs;
PriceD=pqvs;


%here we calculate the vector of clearing prices and PclPq in each simulated auction
%Qpvect
Pqorig=Pqcombos;
Pqcombos(Pqcombos==0)=1;
Qpvecto=Qpvect;
Qpvect=cumsum(Qpvect,2);
Qpvect(Qpvecto==0)=0;
Qpv=Qpvect.*(Qpvect>0);
QI=[Qpv(:,1) Qpv(:,2:end)-Qpv(:,1:end-1)];
QI=QI.*(Qpvect>0);
Qpv2=Qpvect.*(Qpvect<0);
QI2=[Qpv2(:,1:end-1)-Qpv2(:,2:end) Qpv2(:,end)];
QuantityD=QI(Pqcombos);
QuantityD2=QI2(Pqcombos);
pricecombosim=Pqvect(Pqcombos);
QuantityD(Pqorig==0)=0;
QuantityD2(Pqorig==0)=0;
pricecombosim(Pqorig==0)=0;

[bidsp, ic]=sort(pricecombosim,2,'descend');
bidsq=Qmax+QuantityD(sub2ind(size(bidsp),repmat([1:1:size(ic,1)]',1,size(ic,2)),ic));
bidsq2=Qmax+QuantityD2(sub2ind(size(bidsp),repmat([1:1:size(ic,1)]',1,size(ic,2)),ic));

residsupplyp=cumsum(bidsq2.*(bidsp>0).*(bidsq2<0),2,'reverse');
rso=residsupplyp(:,1);
residemandp=cumsum(bidsq.*(bidsp>0).*(bidsq>0),2);
residsupplyp=residsupplyp+residemandp;
pDelt=bidsp;
for jj=2:size(residsupplyp,2)
pDelt(residsupplyp(:,jj)==residsupplyp(:,jj-1),jj)=bidsp(residsupplyp(:,jj)==residsupplyp(:,jj-1),jj-1);
end
bidsp=pDelt;

Pown=pqvs;
Pown(Qpvect==0)=minPrice;
Ppown=[Pown(:,2:end),zeros(size(Pown,1),1)];
Pmown=[150*ones(size(Pown,1),1), Pown(:,1:end-1)];
qx=Qpvect;
qown=qx;
qown(:,1)=qown(:,1)+yin;
qpown=[qown(:,2:size(qx,2)) qown(:,end)];
qownL=qown(:);
gamma=min(prctile(abs(qx(qx~=0)),5),1);

nrep=200;
Pcl=zeros(size(Qpvect,1)*size(Qpvect,2),nrep);
Pclp=zeros(size(Qpvect,1)*size(Qpvect,2),nrep);

for auc=1:nrep
     t=(residsupplyp(auc,:)+qown(:));
      [mj, idx] = max((residsupplyp(auc,:)+qown(:))>=0, [], 2);
        idx(mj==0)=size(residsupplyp,2)-5;
     idxx=sub2ind(size(t),[1:1:size(t,1)]',idx);
     idxx2=sub2ind(size(t),[1:1:size(t,1)]',max(idx-1,1));
     idxx3=sub2ind(size(t),[1:1:size(t,1)]',min(idx+5,size(residsupplyp,2)));
     idxx2(idx==1)=idxx3(idx==1);
     idxx2(idx==size(residsupplyp,2)-5)=idxx3(idx==size(residsupplyp,2)-5);
     idxm=idx-1;
     idxm(idx==1)=idx(idx==1)+5;
     Pclt=(bidsp(auc,idx)'-t(idxx).*((bidsp(auc,idxm)'-bidsp(auc,idx)')./(t(idxx2)-t(idxx))));  
     Pclt(t(idxx)<0)=0;
     tpa=bidsp(auc,idx);
     Pclt(idx==1)=tpa(idx==1);

     Pcl(:,auc)=Pclt;
     t=(residsupplyp(auc,:)+qown(:)+gamma);    
     [~, idx] = max((residsupplyp(auc,:)+qown(:)+gamma)>=0, [], 2);
     idxx=sub2ind(size(t),[1:1:size(t,1)]',idx);
     idxx2=sub2ind(size(t),[1:1:size(t,1)]',max(idx-1,1));
     idxx3=sub2ind(size(t),[1:1:size(t,1)]',min(idx+5,size(residsupplyp,2)));
     idxx2(idx==1)=idxx3(idx==1);
     idxm=idx-1;
     idxm(idx==1)=idx(idx==1)+5;
     Pclt=(bidsp(auc,idx)'-t(idxx).*((bidsp(auc,idxm)'-bidsp(auc,idx)')./(t(idxx2)-t(idxx))));  
     Pclt(t(idxx)<0)=0; 
     tpa=bidsp(auc,idx);
     Pclt(idx==1)=tpa(idx==1);
     Pclp(:,auc)=Pclt;
end
%toc
Pclp(Pclp>100)=100;
Pclp(isnan(Pclp))=1e-12;
Pclp(Pclp<1e-12)=1e-12;
Pcl(isnan(Pcl))=1e-12;
Pcl(isinf(Pcl))=100;
Pcl(Pcl>100)=100; 
Pclp(Pcl==100)=0;


notopout=(sum(Pcl(:)>=maxPrice)+sum(Pcl(:)<=minPrice))./numel(Pcl);


Pclp(Pclp>maxPrice)=maxPrice;
Pclp(Pclp<minPrice)=minPrice;
Pcl(Pcl>maxPrice)=maxPrice;
Pcl(Pcl<minPrice)=minPrice;
Pclt(Pclt>maxPrice)=maxPrice;
Pclt(Pclt<minPrice)=minPrice;


weightc=weights;
weightc=prod(weightc(Mcombos),2);
weightc=weightc(1:size(Pcl,2));
weightc=weightc./sum(weightc);


[weightc,vupg,vlowg,nlow,nup,Gfit,surp,surpA,surpAB]=weightsolnpricespartialgridINTs1_yin(weights,tau,Mcombos,Pcl,Pclp,Pown,Ppown,Pmown,gamma,qx,Rcommon,maxslope,qset_point,vcdft,cop_noin,copvat15,yin,ycdf);
weightco=weightc;
if isempty(sell_limit)==0
    Gfit=Gfit+sum(1./10*(max(-mean(residsupplyp(:,1))-sell_limit,0)).^2);
end
vlowg(vlowg>Rcommon+8)=Rcommon+8; vupg(vupg>Rcommon+8)=Rcommon+8;
vlowg(vlowg<Rcommon-8)=Rcommon-8; vupg(vupg<Rcommon-8)=Rcommon-8;
vlowg(vlowg>vupg)=vupg(vlowg>vupg);
weights(weights<0)=0;
weights=weights./sum(weights);
%Simulate new bids and clearing prices
for ii=1:100
    bidsel=randsample(size(pqvs,1),size(Mcombos,2)+1,'true',weights');
    prices_sim=[];
    q_sim=[];
    q_sims=[];
    vl_buy=[]; vl_sell=[];
    vu_buy=[]; vu_sell=[];
    vq_buy=[]; vq_sell=[];
    for kk=1:size(bidsel,1)
        vl_buy=[vl_buy vlowg(bidsel(kk),qset_point>0)]; vl_sell=[vl_sell vlowg(bidsel(kk),qset_point<0)];
        vu_buy=[vu_buy vupg(bidsel(kk),qset_point>0)]; vu_sell=[vu_sell vupg(bidsel(kk),qset_point<0)];
        qsm=(qset_point(qset_point<0)); qsp=qset_point(qset_point>0);
        vq_sell=[vq_sell qsm-[qsm(2:end) 0]]; vq_buy=[vq_buy qsp-[0 qsp(1:end-1)]];
        prices_sim=[prices_sim pqvs(bidsel(kk),:)];
        q_sim=[q_sim Qmax+QI(bidsel(kk),:)+yin(bidsel(kk))];
        q_sims=[q_sims Qmax+QI2(bidsel(kk),:)+yin(bidsel(kk))];
    end
    [ps,qs]=sort(prices_sim,'descend');  
    [~,ic]=max((cumsum(q_sim(qs))+cumsum(q_sims(qs),'reverse'))>=0);
    qcleared(ii)=sum(q_sims(qs(ps<=ps(ic))).*(q_sims(qs(ps<=ps(ic)))<=0));
    PclA(ii)=ps(ic);
    [vcl,icvl]=sort(vl_buy','descend');
    [vcls,icvls]=sort(vl_sell','ascend');
    ogv=interp1(cumsum(vq_buy(icvl)),vcl,cumsum(-vq_sell(icvls)));
    vclA(ii)=vcls(find((ogv-vcls')<=0,1,'first'));
    [vc,icv]=sort(vu_buy','descend');
    [vcs,icvs]=sort(vu_sell','ascend');
    ogv=interp1(cumsum(vq_buy(icv)),vc,cumsum(-vq_sell(icvs)));
    vcuA(ii)=vcs(find((ogv-vcs')<=0,1,'first'));
end
sdpcl=std(PclA);
Pcl=mean(PclA);
C_binds=(sum(PclA==maxPrice)+sum((PclA)==minPrice))./100;
mean(qcleared)
C_binds
Pcl

    catch
        Gfit=NaN;
        maxD=NaN;
      meanD=NaN;
      Pcl=NaN;
end


