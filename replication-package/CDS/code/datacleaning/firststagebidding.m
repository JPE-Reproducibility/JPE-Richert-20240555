%firststage_bidding
aucidfs=table2array(immtab(:,end));
aucidfslist=unique(aucidfs);

bidimm=table2array(immtab(:,2));
offerimm=table2array(immtab(:,3));
noi=table2array(noitab(:,2));

noi(aucidfs==88)=noi(aucidfs==88).*0.0095;
noi(aucidfs==95)=noi(aucidfs==95).*0.0095;
noi(aucidfs==120)=noi(aucidfs==120).*0.0095;
noi(aucidfs==131)=noi(aucidfs==131).*0.0095;

for k=1:size(aucidfs,1)
   tempid=aucidfs(k);
   loc=find(bondid==tempid);
   if isempty(loc)==0
   Bondvol(aucidfs==tempid)=bondvol(loc);
   Bonddur(aucidfs==tempid)=bonddur(loc);
   Bondconv(aucidfs==tempid)=bondconv(loc);
   Bondcf(aucidfs==tempid)=bondcf(loc);
   end
end
Bondvol(Bondvol==0)=median(Bondvol);
Bondvol=Bondvol./(1000000);



for k=1:size(aucidfslist,1)
   tempid=aucidfslist(k);
   %calculate imm/noi 
   bidlist=bidimm(aucidfs==tempid);
   offerlist=offerimm(aucidfs==tempid);
   %drop tradeable markets
   [maxB,icb]=sort(-bidlist);
   maxB=-1*maxB;
   [minO,ics]=sort(offerlist);
   dsq=(maxB>=minO);
   maxBT=maxB(sum(dsq)+1:sum(dsq)+ceil((size(maxB,1)-sum(dsq))/2));
   minOT=minO(sum(dsq)+1:sum(dsq)+ceil((size(maxB,1)-sum(dsq))/2));
   innt=(mean(maxBT)+mean(minOT))./2;
   IMM(k,1)=round(8*innt)/8;
   %NOI
   noilist=noi(aucidfs==tempid);
   NOItot(k,1)=sum(noilist);
    %calculate adjustment amounts
   AmountoffT=((maxB-IMM(k)).*(maxB>IMM(k)).*(NOItot(k)>0)+(minO-IMM(k)).*(minO<IMM(k)).*(NOItot(k)<0)).*(dsq);
   if NOItot(k,1)<0
   Amountoff(aucidfs==tempid)=AmountoffT(icb);
   IMMcap(k,1)=IMM(k)+((bidlist(1,1)-offerlist(1,1))./2);
   else
   Amountoff(aucidfs==tempid)=AmountoffT(ics);
   IMMcap(k,1)=IMM(k)-((bidlist(1,1)-offerlist(1,1))./2);
   end   
   
   ownIMM(aucidfs==tempid)=(offerlist+bidlist)./2;
   %produce summary stats (variance of bids-max difference (and their
   %id)--concentration of NOI orders( #non-zero and variance of size conditional on non-zero)
   Npossible(k,1)=size(noilist,1);
   Nnoi(k,1)=sum(noilist~=0);
   varIMM(k,1)=var(ownIMM(aucidfs==tempid));
end
Amountoff=Amountoff';

%auctionprice--relate to the first stage bidding
for k=1:size(aucidfslist,1)
   tv=find(aucid==aucidfslist(k));
   if isempty(tv)==0
     aucpricefs(k,1)=auctionprice(tv);  
   end
end

hitcap=(IMMcap<=aucpricefs).*(NOItot>0)+(IMMcap>=aucpricefs).*(NOItot<0);


if analyzefs==1
%match bond price data to auction ids (needed for Table OS.3)
for k=1:size(aucidbond,1)
    tvb=find(aucidfslist==aucidbond(k));
    if isempty(tvb)==0
       bondimm(k,1)=IMM(tvb);
       bondnoi(k,1)=NOItot(tvb);
       bondNp(k,1)=Npossible(tvb);
       bondNn(k,1)=Nnoi(tvb);
       paucB(k,1)=aucpricefs(tvb);
    end
end
end
acrossrounds

tiesstats

%% Figure OS.7: Auction Price vs IMM
figure; scatter(aucpricefs,IMM)
xlabel('Auction price')
ylabel('$p^M$','Interpreter','latex')
saveas(gcf,fullfile(fig_path,'auctionpriceIMM.png'))

for ii=1:size(aucidfslist,1)
immSUP(aucidsupply==aucidfslist(ii))=IMM(ii);
noiSUP(aucidsupply==aucidfslist(ii))=NOItot(ii);
immFC(aucidsupply==aucidfslist(ii))=IMMcap(ii);
end

%% Section 2: Price cap statistics
fprintf('  Fraction of bids at price floor/ceiling: %.1f%%\n', 100*sum(immFC'==supplyp)./size(supplyp,1))
fprintf('  Fraction of auctions clearing at cap: %.1f%%\n', round(100*mean(sum(aucpricefs==IMMcap)./size(IMMcap,1)),0))
fprintf('  Fraction at cap conditional on nonzero NOI: %.1f%%\n', round(100*(sum(aucpricefs==IMMcap) - sum((NOItot==0))) ./ sum(NOItot~=0),0))
