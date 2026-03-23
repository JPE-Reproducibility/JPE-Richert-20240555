
%loop over mean bond prices--throw out any where price is 20 above median
for ii=1:size(BPmean,1)
    BPmean(ii,BPmean(ii,:)>(nanmedian(BPmean(ii,:))+20))=NaN;
end


figure 
hold on
BPmean(isnan(BPmean)==1)=0;
%BPmeanS=BPmean./max(BPmean,[],2);
BPmeanS=BPmean;
for i=1:size(BPmean,1)
lastP=BPmeanS(i,1);
for k=2:size(BPmean,2)
    if BPmeanS(i,k)==0
    BPmeanS(i,k)=lastP;
    else
    lastP=BPmeanS(i,k);
    end
end
lastP=BPmeanS(i,end);
for k=1:size(BPmean,2)-1
    if BPmeanS(i,end-k)==0
    BPmeanS(i,end-k)=lastP;
    else
    lastP=BPmeanS(i,end-k);
    end
end
if tsplots==1
plot([1:1:size(BPmean,2)+0.01],BPmeanS(i,:))
end
end



BPvol(isnan(BPvol)==1)=0;


figure 
hold on
BPsd(isnan(BPsd)==1)=0;
BPsdS=BPsd./max(BPsd,[],2);
for i=1:size(BPsd,1)
lastP=BPsdS(i,1);
for k=2:size(BPsd,2)
    if BPsdS(i,k)==0
    BPsdS(i,k)=lastP;
    else
    lastP=BPsdS(i,k);
    end
end
lastP=BPsdS(i,end);
for k=1:size(BPsd,2)-1
    if BPsdS(i,end-k)==0
    BPsdS(i,end-k)=lastP;
    else
    lastP=BPsdS(i,end-k);
    end
end
if tsplots==1
plot([1:1:size(BPsd,2)+0.01],BPsdS(i,:))
end
end


figure 
hold on
BP_sdmeanxbond(isnan(BP_sdmeanxbond)==1)=0;
BPsdS_meanxbond=BP_sdmeanxbond./max(BP_sdmeanxbond,[],2);
for i=1:size(BP_sdmeanxbond,1)
lastP=BPsdS_meanxbond(i,1);
for k=2:size(BP_sdmeanxbond,2)
    if BPsdS_meanxbond(i,k)==0
    BPsdS_meanxbond(i,k)=lastP;
    else
    lastP=BPsdS_meanxbond(i,k);
    end
end
lastP=BPsdS_meanxbond(i,end);
for k=1:size(BP_sdmeanxbond,2)-1
    if BPsdS_meanxbond(i,end-k)==0
    BPsdS_meanxbond(i,end-k)=lastP;
    else
    lastP=BPsdS_meanxbond(i,end-k);
    end
end
if tsplots==1
plot([1:1:size(BPsd,2)+0.01],BPsdS_meanxbond(i,:))
end
end

noit=table2array(noitab(:,2));
noiID=table2array(noitab(:,3));
for aa=1:size(aucidbond,1)
    BPnoi(aa,1)=sum(noit(noiID==aucidbond(aa)));
end
figure
hold on
plot([1:1:size(BPsd,2)+0.01],mean(BPmeanS(BPnoi>0,:)./auctionpriceb(BPnoi>0),1))
plot([1:1:size(BPsd,2)+0.01],prctile(BPmeanS(BPnoi>0,:)./auctionpriceb(BPnoi>0),50))
plot([1:1:size(BPsd,2)+0.01],mean(BPmeanS(BPnoi<0,:)./auctionpriceb(BPnoi<0),1))
plot([1:1:size(BPsd,2)+0.01],prctile(BPmeanS(BPnoi<0,:)./auctionpriceb(BPnoi<0),50))


figure
hold on
yyaxis left
plot([1:1:size(BPsd,2)+0.01],mean(BPmeanS./max(BPmean,[],2),1))
plot([1:1:size(BPsd,2)+0.01],prctile(BPmeanS./max(BPmean,[],2),50))
yyaxis right
plot([1:1:size(BPsd,2)+0.01],mean(BPvol,1))
title('Price and Volume')
legend('Mean','Median','Volume')
figure
hold on
yyaxis left
plot([1:1:size(BPsd,2)+0.01],mean(BPsd,1))
plot([1:1:size(BPsd,2)+0.01],prctile(BPsd,50))
title('Price Sd')
figure
plot([1:1:size(BPsd,2)+0.01],mean(BPvol,1))
title('Trade Volume')

figure
hold on
yyaxis left
plot([1:1:size(BP_sdmeanxbond,2)+0.01],mean(BP_sdmeanxbond,1))
plot([1:1:size(BP_sdmeanxbond,2)+0.01],prctile(BP_sdmeanxbond,50))
title('Price Sd Across bonds')
disp('cheapest to deliver risk: auction day average sd of prices x bonds conditional on multiple trading')
mean(BP_sdmeanxbond(BP_sdmeanxbond(:,31)~=0,31))
disp('cheapest to deliver risk: auction day +30 average sd of prices x bonds conditional on multiple trading')
mean(BP_sdmeanxbond(BP_sdmeanxbond(:,end)~=0,end))
disp('cheapest to deliver risk: auction day +5 average sd of prices x bonds conditional on multiple trading')
mean(BP_sdmeanxbond(BP_sdmeanxbond(:,36)~=0,36))
