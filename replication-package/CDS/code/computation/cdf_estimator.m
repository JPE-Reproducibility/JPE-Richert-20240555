function [ncdf]=cdf_estimator(nout,noi)
%although it takes in nout, you can use the same code to get marginal
%distributions of v, at some grid points in q, by replacing first two
%columns of n-out by the appropriate v(qg_l).--given that what we are
%missing is something for bounding correlations--both across v-qg and with
%n-y.

nopartflag=nout(:,4);
a_noi=nout(:,3);
nub=nout(:,2);
nlb=nout(:,1);
nub_sel=nub(nopartflag==0);
nlb_sel=nlb(nopartflag==0);
pm=nout(:,5);
pm_sel=pm(nopartflag==0);

nub_sel(nlb_sel>nub_sel)=nlb_sel(nlb_sel>nub_sel);
%steps:
for ii=1:size(nub_sel,1)
% 0. c-bar estimate:--not obvious how you should smooth this thing--lets bin the data, take the max in each bin
% then smooth over that
pnear=(pm>=pm_sel(ii)-10).*(pm<=pm_sel(ii)+10);
us=prctile(a_noi(pnear==1),[1+100*sum(a_noi(pnear==1)<=0)./sum(pnear==1):5:95]);
us2=prctile(a_noi(pnear==1),[5:5:100*sum(a_noi(pnear==1)<=0)./sum(pnear==1)]);
ybarG=[min(a_noi(pnear==1)) us2 us(2:end) max(a_noi(pnear==1))]; %what do you do when crossing 0?
for ay=2:size(ybarG,2)
    if ybarG(ay-1)<=0 & ybarG(ay)<=0
cy1(ay)=max(nub.*(nopartflag==1).*(a_noi<=ybarG(ay)).*(a_noi>=ybarG(ay-1)).*(pnear));
    elseif ybarG(ay-1)>0 & ybarG(ay)>0
cy1(ay)=min(nlb.*(nopartflag==1).*(a_noi<=ybarG(ay)).*(a_noi>=ybarG(ay-1)).*(pnear)+10000.*(((a_noi<=ybarG(ay)).*(a_noi>=ybarG(ay-1)).*(pnear))==0));
    end
end
cy1(1)=cy1(2);
% 1. probability of a yd that is negative/positive
rng(200)
resid_y=noi(pnear==1);
resid_yd=sum(resid_y(randi(size(resid_y,1),10,1000)));
yoth_pos=sum(resid_yd>0)./size(resid_yd,2);
yoth_neg=sum(resid_yd<0)./size(resid_yd,2);

Prob_low=min((nlb_sel(ii)>0).*1e8+(nlb_sel(ii)<=0).*yoth_pos,(nub_sel(ii)<=0).*1e8+(nub_sel(ii)>=0).*(yoth_neg));
Prob_high=max((nlb_sel(ii)<=0).*yoth_pos,(nub_sel(ii)>=0).*(yoth_neg));

wi_bar(ii,1)=1./Prob_low;
wi_under(ii,1)=1./Prob_high;
end


% 2. criss-cross to get the cdf bounds pointwise on a grid
ngrid=linspace(min(nout(:,1)),max(nout(:,2)),1000);
for jj=1:size(ngrid,2)
num=sum((nub_sel<=ngrid(jj)).*wi_under);
denom=sum((nub_sel<=ngrid(jj)).*wi_under+(1-(nub_sel<=ngrid(jj))).*wi_bar);
ncdf(jj,1)=num./denom;
num=sum((nlb_sel<=ngrid(jj)).*wi_bar);
denom=sum((nlb_sel<=ngrid(jj)).*wi_bar+(1-(nlb_sel<=ngrid(jj))).*wi_under);
ncdf(jj,2)=num./denom;
end
%plot the marginal distribution in n.
%figure; plot(ngrid,ncdf)