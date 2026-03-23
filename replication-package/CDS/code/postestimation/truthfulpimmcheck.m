
[b,I]=regress(aucpricefs,[ones(size(aucpricefs)) NOIabs IMM]);
dPdR=b(3);
Nlb=nout(:,1);
dPrdp=(noi-br_qwon'-Nlb').*(dPdR./100);


delta=0.5;
for k=1:size(aucidfslist,1)
   tempid=aucidfslist(k);
   %calculate imm/noi 
   tempIMM=IMM(aucidfslist==tempid);
   bidlist=bidimm(aucidfs==tempid);
   offerlist=offerimm(aucidfs==tempid);
   dIMM=[];
   for ab=1:size(bidlist,1)
       clear cM cMO
       bidlistraw=bidlist;
       offerlistraw=offerlist;
       bidlist(ab)=bidlist(ab)+delta; 
   offerlist(ab)=offerlist(ab)+delta;
   %drop tradeable markets
   [maxB,icbr]=sort(-bidlistraw);
   maxB=-1*maxB;
   [minO,icsr]=sort(offerlistraw);
   dsqraw=(maxB>=minO);
   
      cMO(ab)=(bidlistraw(ab)>minO(1)).*(bidlistraw(ab)-tempIMM).*(2500000);
   tB=maxB(ab);
    [maxB,icb]=sort(-bidlist);
   maxB=-1*maxB;
   [minO,ics]=sort(offerlist);
   dsq=(maxB>=minO);

   cM(ab)=(bidlist(ab)>minO(1)).*(bidlist(ab)-tempIMM).*(2500000);
   
   maxBT=maxB(sum(dsq)+1:sum(dsq)+ceil((size(maxB,1)-sum(dsq))/2));
   minOT=minO(sum(dsq)+1:sum(dsq)+ceil((size(maxB,1)-sum(dsq))/2));
   innt=(mean(maxBT)+mean(minOT))./2;
   IMMp=round(8*innt)/8;
   dIMM(ab)=(IMMp-tempIMM)./delta;
   
   end
   dIMMk(k)=mean(dIMM);
   maxdIMMk(k)=max(dIMM);
   deltacM(k)=(mean((cMO-cM)./delta));
end

dRdpquote=mean(dIMMk);
 %basically a .02 cents on the dollar increase in price..

 benManipule=prctile(abs(dPrdp(:).*dRdpquote),95).*1000;
 costManipule=mean(deltacM);

fprintf('  P95 benefit of manipulation: %.2f\n', benManipule)
fprintf('  Mean cost of manipulation: %.0f\n', costManipule)
fprintf('  dR/dp_quote (avg effect on IMM): %.4f\n', dRdpquote)
 
 
 
 

 
 
 
 
 
