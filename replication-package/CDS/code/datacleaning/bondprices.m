load(fullfile(int_path,'bondprices'))
%that file is built using bondpriceimport--that takes quite some time to
%run
aucidbond=matchedauc';
BPmean(aucidbond<8,:)=[];
BPsd(aucidbond<8,:)=[];
BPvol(aucidbond<8,:)=[];
BP_sdmeanxbond(aucidbond<8,:)=[];
aucidbond(aucidbond<8)=[];
count=1;
for aa=1:max(size(aucidbond))
    try
        auctionpriceb(count,1)=auctionprice(aucid==aucidbond(aa));
        count=count+1;        
    end
end
if exist('sovlist')
[r,c]=max(aucidbond==sovlist');
aucidbond(c(c~=1))=[];
bondpricesT(c(c~=1),:)=[];
end
%BP denotes a bond price matrix which is one row for each aucid and one
%column for each day plus/minus
tsplots=1;

cleanbondprice
%this interpolates the price and Sd and replaces zeros in vol ntrade
%BPpdealer and can plot if tsplots=1;


%construct a pfinal, a normalized pfinal, a pinitial and a
%p-direct-post-auction
pfinal30T=max(BPmean,[],2).*BPmean(:,59);
pfinal5T=max(BPmean,[],2).*BPmean(:,36);
pfinal1T=max(BPmean,[],2).*BPmean(:,31);
pinit30T=max(BPmean,[],2).*BPmean(:,1);
pinit5T=max(BPmean,[],2).*BPmean(:,24);
pinit1T=max(BPmean,[],2).*BPmean(:,29);

pfinal30=BPmeanS(:,59);
pfinal5=BPmeanS(:,36);
pfinal1=BPmeanS(:,31);
pinit30=BPmeanS(:,1);
pinit5=BPmeanS(:,24);
pinit1=BPmeanS(:,29);

%figure
%scatter(pfinal30,pinit30)
%figure
%scatter(pfinal30,pfinal1)

pauc=auctionpriceb;%./max(BPmean,[],2);
Xmat=[pauc pinit5 pinit1];
[y1,CI1]=regress(pfinal30(isinf(pauc)==0),Xmat(isinf(pauc)==0,:))
%DON"t WORRY--WE WILL COME BACK TO SIMILAR REGRESSIONS OUTSIDE OF THIS ONCE
%YOU HAVE THE IMM.-That just hasnt been built yet.

pfinal30(pfinal30==0)=NaN;
pfinal5(pfinal5==0)=NaN;
pricebias30=pfinal30-pauc;
pricebias5=pfinal5-pauc;
%histogram(pricebias30);
%histogram(pricebias5);
BPmeanS(BPmeanS==0)=NaN;
figure; plot([-30:1:30],nanmedian(BPmeanS-auctionpriceb))
xlabel('Days')
ylim([0,5])
ylabel('Bond Price-Auction Price')
saveas(gcf,fullfile(fig_path,'abnormaleventgraph.png'))

figure; plot([-30:1:30],nanmean(BPmeanS-auctionpriceb))
xlabel('Days')
ylim([0,5])
ylabel('Bond Price-Auction Price')
saveas(gcf,fullfile(fig_path,'abnormaleventgraph_mean.png'))



%how much variation in bond prices across bonds within a day--CTD risk (and
%interday settlement risk)
mean(sum(BP_sdmeanxbond.*(BP_sdmeanxbond>0))./sum((BP_sdmeanxbond>0)))
