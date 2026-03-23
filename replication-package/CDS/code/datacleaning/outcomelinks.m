if bond_price_analysis==1
%does the price gap either from auction to post auction or pre-to-post
%auciton depends on who wins?
SSglobalID=SSglobalID';
for aa=1:size(aucidfslist,1)
for ii=1:max(SSglobalID)
    if NOItot(aa)>0
   shareWon(ii,aa)=sum((supplyp(SSglobalID==ii & aucidsupply==aucidfslist(aa))>=aucpricefs(aa)).*supplyq(SSglobalID==ii & aucidsupply==aucidfslist(aa)))./NOItot(aa);
    else
   shareWon(ii,aa)=abs(sum((supplyp(SSglobalID==ii & aucidsupply==aucidfslist(aa))<=aucpricefs(aa)).*supplyq(SSglobalID==ii & aucidsupply==aucidfslist(aa)))./NOItot(aa));  
    end
end
end
shareWon(isinf(shareWon))=1;
shareWon(isnan(shareWon))=0;
T=[table(utb),array2table(mean(abs(shareWon),2))];

purchaserC=max(shareWon);

for bb=1:size(aucidbond,1)
purchaserCshort(bb,1)=purchaserC(aucidfslist==aucidbond(bb));
end


for aa=1:size(aucidbond,1)
eventB(aa)=event(aucidfslist==aucidbond(aa));
end

[b,ci]=regress(BPmeanS(:,59)-auctionpriceb,[bondNp bondnoi bondimm (eventB==1)' (eventB==3)' purchaserCshort ones(size(BPmeanS,1),1)])
[b,ci]=regress(BPmeanS(:,25)-auctionpriceb,[bondNp bondnoi bondimm (eventB==1)' (eventB==3)' purchaserCshort ones(size(BPmeanS,1),1)])
[b,ci]=regress(BPmeanS(:,59)-BPmeanS(:,25),[bondNp bondnoi bondimm (eventB==1)' (eventB==3)' purchaserCshort ones(size(BPmeanS,1),1)])

[b,ci]=regress(BPmeanS(:,59)-auctionpriceb,[purchaserCshort ones(size(BPmeanS,1),1)])
[b,ci]=regress(BPmeanS(:,25)-auctionpriceb,[purchaserCshort ones(size(BPmeanS,1),1)])
[b,ci]=regress(BPmeanS(:,59)-BPmeanS(:,25),[purchaserCshort ones(size(BPmeanS,1),1)])


end



