bidder_SH=[];
NOI_SS=[];
totalQ=[];
for ii=1:size(aucidfslist,1)
    tempbidder_list=unique(supplyid(aucidsupply==aucidfslist(ii)));
    for aa=1:size(tempbidder_list,1) 
        ownQ=sum(supplyq(strcmp(supplyid,tempbidder_list(aa)) & aucidsupply==aucidfslist(ii)));
        bidder_SH=[bidder_SH; sum(ownQ)./NOI(ii)];
        totalQ=[totalQ; ownQ];
        NOI_SS=[NOI_SS; NOI(ii)];
        if sum(ownQ)./NOI(ii)>1
           tempbidder_list(aa);
           aucidfslist(ii);
        end
    end    
end



cumQ=[];
orQ=[];
orB=[];
N_over=[];
NNOI=[];
NOIS=[];
flag_multistep=[];
multiS=[];
flag_Nover=[];
for ii=1:size(aucidfslist,1)
    tempbidder_list=unique(supplyid(aucidsupply==aucidfslist(ii)));
    for aa=1:size(tempbidder_list,1) 
        clear fl_multistep
        ownbidQ=supplyq(strcmp(supplyid,tempbidder_list(aa)) & aucidsupply==aucidfslist(ii));
        [ownbidP,ic]=sort(supplyp(strcmp(supplyid,tempbidder_list(aa)) & aucidsupply==aucidfslist(ii)),'descend');
        for jj=1:size(ownbidP,1)
        fl_multistep(jj,1)=(sum((ownbidP(jj)==ownbidP))>1);
        end
        cumQ=[cumQ;cumsum(ownbidQ(ic))./NOI(ii)];
        orQ=[orQ;(ownbidQ(ic))./NOI(ii)];
        orB=[orB;ownbidP];
        N_over=[N_over;sum(abs(cumsum(ownbidQ(ic))./NOI(ii))>1)];
        NOIS=[NOIS;NOI(ii)];
        NNOI=[NNOI;ones(size(ownbidP)).*NOI(ii)];
        flag_multistep=[flag_multistep;fl_multistep];
        flag_Nover=[flag_Nover;abs(cumsum(ownbidQ(ic)./NOI(ii)))>1];
        multiS=[multiS; max(fl_multistep)];
    end
end


%There is at least a chance of sum(N_over>=1) that get identified as over
%when Cust submits to that dealer (this is probably really conservative)
PrCBound=sum(N_over>1)./sum(N_over>=1);
PrCBound=sum(N_over>1)./size(N_over,1);




%NOTE:  The sum of (a) the excess, if any, of (i)
%the aggregate Quotation Amount of a Participating Bidder's Valid Limit Order Submissions over (ii) the
%portion of such aggregate Quotation Amount attributable to any Customer Limit Order Submissions
%received by such Participating Bidder that are taken into account in such Participating Bidder's Valid Limit
%Order Submissions and (b) such Participating Bidder's Initial Market Bid or Initial Market Offer, as
%applicable, that is on the same side of the market as its Valid Limit Order Submissions must be, to the best
%of such Participating Bidder's knowledge and belief, not in excess of the size of the Open Interest. 


for ii=1:size(aucidfslist,1)
   nusteps(ii)=size(supplyp(aucidsupply==aucidfslist(ii)),1);
   nuprices(ii)=size(unique(supplyp(aucidsupply==aucidfslist(ii))),1);
end




%What chance of zero submitters:
for aa=1:size(aucidfslist,1)
    npart(aa)=size(unique(supplyid(aucidsupply==aucidfslist(aa))),1);
    ubidderlist=unique(supplyid(aucidsupply==aucidfslist(aa)));
    nzeroc=0;
    for jj=1:npart(aa)
       if sum(strcmp(supplyid(aucidsupply==aucidfslist(aa)),ubidderlist(jj)))<2
          nzeroc=nzeroc+1; 
       end
    end
    nzero(aa)=nzeroc;
end

%regress to see if customers probability of going "over" or the bids conditional on going over bids change?

[b,ci]=regress(N_over,[NOIS ones(size(N_over))]);
[b,ci]=regress(multiS,[NOIS ones(size(N_over))]);


%over bids prices over bids quantities
[b,ci]=regress(supplyp-immFC', [flag_multistep NNOI NNOI.*flag_multistep ones(size(flag_Nover))]);
[b,ci]=regress(supplyq, [flag_multistep NNOI  NNOI.*flag_multistep ones(size(flag_Nover))]);


bgrid=linspace(min(supplyp-immFC'),max(supplyp-immFC'),200);
for jj=1:size(bgrid,2)
  plist=supplyp(abs(supplyq-NOItotsupply')<=0.001)-immFC(abs(supplyq-NOItotsupply')<=0.001)';
  bw=std(plist).*1.06.*size(plist,1).^(-1./5);
  prbgrid(jj)=1./size(plist,1).*sum(normcdf((plist-bgrid(jj))./bw));
  
  plist=supplyp(abs(supplyq-NOItotsupply')<=0.001)-immFC(abs(supplyq-NOItotsupply')<=0.001)';
  bw=std(plist).*1.06.*size(plist,1).^(-1./5);
  prbgridN(jj)=1./size(plist,1).*sum(normcdf((bgrid(jj)-plist)./bw));
end
%what if its for the full quantity? ignore this case...fairly unlikely.
   %first get the probability a bid like this is over
    bwP=std(supplyp-immFC').*size(supplyp,1).^(-1./5).*1.06;
    bwQ=std(supplyq).*size(supplyq,1).^(-1./5).*1.06;
    pr_num=sum(flag_Nover'.*(normpdf((supplyp-supplyp')./bwP).*normpdf((supplyq-supplyq')./bwQ)),2)./sum(normpdf((supplyp-supplyp')./bwP).*normpdf((supplyq-supplyq')./bwQ),2); 

for jj=1:size(supplyp,1)
    %now divide that by the probability from bgrid above...
    if NOItotsupply(jj)>0
    pr_denom(jj)=interp1(bgrid,prbgrid,supplyp(jj)-immFC(jj));
    else
    pr_denom(jj)=interp1(bgrid,prbgridN,supplyp(jj)-immFC(jj));
    end
    prcust(jj)=pr_num(jj)./pr_denom(jj);
end
prcust=prcust';
prcust(prcust>1)=1;
