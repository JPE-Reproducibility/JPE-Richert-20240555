function [weightc,vupout,vlowout,nlow,nup,Gfit,surp,surpA,surpAB]=weightsolnpricespartialgridINTs1_yin(weights,tau,Mcombos,Pcl,Pclp,Pown,Ppown,Pmown,gamma,qx,R,maxslope,qset_point,vcdft,cop_noin,cop_vat15,yin,ycdf)

vmax=R+8;
vmin=R-8;
nmax=300;

nrep=size(Pcl,1);
nsim=size(qx,1);
oldw=weights';
weightc=weights;
weights=prod(weights(Mcombos),2);
weights=weights(1:size(Pcl,2));
weights=weights./sum(weights);

PpRevown=[100.*ones(size(Pown,1),1) Pown(:,1:end-1)];
inRangeM=(Pcl<repmat(Pown(:),1,size(Pcl,2))).*(Pcl>repmat(Ppown(:),1,size(Pcl,2)));
inRangeMrev=(Pcl>repmat(Pown(:),1,size(Pcl,2))).*(Pcl<repmat(PpRevown(:),1,size(Pcl,2)));
inRangeM=inRangeM.*(qx(:)>=0)+inRangeMrev.*(qx(:)<0);
Prob=sum(inRangeM.*weights',2);
Epcl=sum(Pcl.*(inRangeM==1).*(weights'),2)./sum((inRangeM==1).*(weights'),2);
Pownlong=Pown(:);
Epcl(isnan(Epcl))=Pown(isnan(Epcl));

dE1=mean(Pcl.*(inRangeM==1).*(weights'),2);
inRangeM2=(Pclp<repmat(Pown(:),1,size(Pcl,2))).*(Pclp>repmat(Ppown(:),1,size(Pcl,2)));
inRangeM2rev=(Pclp>repmat(Pown(:),1,size(Pcl,2))).*(Pclp<repmat(Pmown(:),1,size(Pcl,2)));
inRangeM2=inRangeM2.*(qx(:)>=0)+inRangeM2rev.*(qx(:)<0);
dE2=mean(Pclp.*(inRangeM2==1).*(weights'),2);
dEpcl=(dE2-dE1)./gamma;


dEpcl=reshape(dEpcl,nsim,[]);
Epcl=reshape(Epcl,nsim,[]);
Prob=reshape(Prob,nsim,[]);
Zviol=sum(sum((Prob==0).*(qx~=0)));
Prob(Prob<1e-18)=1e-18;

%n grid--and store errors
ngrid=linspace(-nmax,nmax,1000);
for nn=1:size(ngrid,2)
    vhat=Epcl+(dEpcl./Prob).*(qx+ngrid(nn));
    boundv(:,nn)=sum(max((vhat-vmax),0)+max((vmin-vhat),0),2);
    monv(:,nn)=sum(max(vhat(:,2:end)-vhat(:,1:end-1),0),2);
end
[nmin2]=min(boundv+monv,[],2);
rcut=nmin2+0.1;
nlow=min(ngrid.*((boundv+monv)<rcut)+1e5.*(((boundv+monv)>=rcut)),[],2);
nup=max(ngrid.*((boundv+monv)<rcut)-1e5.*(((boundv+monv)>=rcut)),[],2);



vlowt=Epcl+(dEpcl./Prob).*(qx+nlow);
vupt=Epcl+(dEpcl./Prob).*(qx+nup);
vlow=min(vlowt,vupt);
vup=max(vlowt,vupt);

qxk=qx;
qxk(:,2:end)=qxk(:,2:end)-qxk(:,1:end-1);
qxk(qx==0)=0;
vup(vup>100)=100;
vlow(vlow>100)=100;
vup(vup<0)=0;
vlow(vlow<0)=0;
vupAA=vup; vupAA(qxk<0)=vlow(qxk<0);
surp=sum((vupAA-Epcl).*Prob.*qxk,2);
surpA=sum(weightc'.*surp)./sum(weightc);
%To get the lower bound on surplus
vupAB=vlow; vupAB(qxk<0)=vup(qxk<0);
surpMin=sum((vupAB-Epcl).*Prob.*qxk,2);
surpAB=sum(weightc'.*surpMin)./sum(weightc);

%output cdf--v at qg points, joint distribution of n and yi+yic, and joint
%dist of v(1),v(5)
qg=qset_point;
for qgp=1:size(qset_point,2)
    for kk=1:size(vup,1)
        qtemp=qx(kk,:);
        vtempL=vlow(kk,:);
        vtempU=vup(kk,:);
        vtempL(qtemp==0)=[];vtempU(qtemp==0)=[];qtemp(qtemp==0)=[];

        if qg(qgp)>max(qtemp)
            vlowg=vtempL(end)-maxslope.*(qg(qgp)-max(qtemp));
            vupg=vtempU(end)-0.1*maxslope.*(qg(qgp)-max(qtemp));
        elseif qg(qgp)<min(qtemp)
            vlowg=vtempU(1)+0.1*maxslope.*(min(qtemp)-qg(qgp));
            vupg=vtempL(1)+maxslope.*(min(qtemp)-qg(qgp));
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
        vup_g(kk,qgp)=vupg;
        vlow_g(kk,qgp)=vlowg;
    end
end
vlowout=vlow_g;
vupout=vup_g;


%Grid/extrap
for jj=1:size(cop_vat15,1)
    vat15_j(jj,1)=sum((weightc').*(vup_g(:,10)<=cop_vat15(jj,1)).*(vup_g(:,12)<=cop_vat15(jj,2)))./sum(weightc);
    vat15_j(jj,2)=sum((weightc').*(vlow_g(:,10)<=cop_vat15(jj,1)).*(vlow_g(:,12)<=cop_vat15(jj,2)))./sum(weightc);
end

for jj=1:size(cop_noin,1)
    noin_j(jj,1)=sum((weightc').*(nup<=cop_noin(jj,2)).*(yin<=cop_noin(jj,1)))./sum(weightc);
    noin_j(jj,2)=sum((weightc').*(nlow<=cop_noin(jj,2)).*(yin<=cop_noin(jj,1)))./sum(weightc);
end
Gfit=sum(min(cop_vat15(:,4)-vat15_j(:,1),0).^2)+sum(max(cop_vat15(:,3)-vat15_j(:,2),0).^2);
Gfit=Gfit+sum(min(cop_noin(:,4)-noin_j(:,1),0).^2)+sum(max(cop_noin(:,3)-noin_j(:,2),0).^2);
%%%%All remaining marginals
for jj=1:size(vcdft,2)
    vm{jj}(:,1)=sum((vcdft{jj}(:,1)>=vup_g(:,jj)').*(weightc),2);
    vm{jj}(:,2)=sum((vcdft{jj}(:,1)>=vlow_g(:,jj)').*(weightc),2);
    aw=ones(size(vcdft{jj}(:,1)));
    aw(1)=1000; aw(end)=1000;
    Gfit=Gfit+sum(aw.*min(vcdft{jj}(:,3)-vm{jj}(:,1),0).^2)+sum(aw.*max(vcdft{jj}(:,2)-vm{jj}(:,2),0).^2);
end
ycdfin=sum((yin<=ycdf(:,1)').*weightc')./sum(weightc);
Gfit=Gfit+sum((ycdfin'-ycdf(:,2)).^2);
Gfit=Gfit+(1./100.*min(min(yin)-ycdf(1,1),0)).^2+(1./100.*max(max(yin)-ycdf(end,1),0).^2);
Gfit=Gfit+Zviol;