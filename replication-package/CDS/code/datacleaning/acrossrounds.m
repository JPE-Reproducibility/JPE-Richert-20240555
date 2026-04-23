%acrossrounds
immbidderid=table2cell(immtab(:,1));
immlow=table2array(immtab(:,2));
immhigh=table2array(immtab(:,3));

noibidderid=table2cell(noitab(:,1));
supplyid=table2cell(supplyfunctab(:,1));

aucidsupply=table2array(supplyfunctab(:,4));
aucidsupply(aucidsupply==194)=195;
supplyq=table2array(supplyfunctab(:,3));
supplyp=table2array(supplyfunctab(:,2));
fromimm=table2array(supplyfunctab(:,5));
partially=table2array(supplyfunctab(:,6));

supplyq(aucidsupply==120)=supplyq(aucidsupply==120).*0.0095;
supplyq(aucidsupply==131)=supplyq(aucidsupply==131).*0.0095;
supplyq(aucidsupply==88)=supplyq(aucidsupply==88).*0.0095;
supplyq(aucidsupply==90)=supplyq(aucidsupply==90).*0.0095;
supplyq(aucidsupply==95)=supplyq(aucidsupply==95).*0.0095;


%fix the variable fromimm....this indicator is not reliable in the csv file
fixfromimm

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CHECK BEHAVIOR OF INDIVIDUALS ACROSS AUCTIONS
UB_ID=unique(immbidderid);
for aa=1:size(UB_ID,1)
    supp_bidtrack(find(strcmp(supplyid,UB_ID(aa))),1)=aa;
    noi_bidtrack(find(strcmp(noibidderid,UB_ID(aa))),1)=aa;
    imm_bidtrack(find(strcmp(immbidderid,UB_ID(aa))),1)=aa;
end

for aa=1:size(aucidfslist,1)
sup_IMM(aucidsupply==aucidfslist(aa))=IMM(aucidfslist==aucidfslist(aa));
end
%figure; scatter(noi_bidtrack,noi)
%figure; scatter(imm_bidtrack,immhigh)
%figure; scatter(supp_bidtrack,supplyp-sup_IMM')
clear sup_IMM

for aa=1:size(aucidfslist,1) %added ,1
    tempS=unique(supp_bidtrack(aucidsupply==aucidfslist(aa)));
    for jj=1:size(tempS,1)
        nstepA(imm_bidtrack==tempS(jj) & aucidfs==aucidfslist(aa))=sum(supp_bidtrack(aucidsupply==aucidfslist(aa))==tempS(jj));
    end 
end
nstepA=[nstepA zeros(1,size(imm_bidtrack,1)-size(nstepA,2))];
 %figure; scatter(imm_bidtrack,nstepA)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
counter=1;
carried_p=[];
carried_q=[];
carried_id=[];
carried_aucid=[];
for k=1:size(aucidfslist,1)
   tempid=aucidfslist(k);
   tempp=supplyp(aucidsupply==tempid);
   tempq=supplyq(aucidsupply==tempid);
   tempb_id=supplyid(aucidsupply==tempid);
   carryover=fromimm(aucidsupply==tempid);
   carried_p=[carried_p; tempp(carryover==1)];
   carried_q=[carried_q; tempq(carryover==1)];
   carried_id=[carried_id; tempb_id(carryover==1)];
   carried_aucid=[carried_aucid; repmat(tempid,size(tempp(carryover==1),1),1)];
   tempp(carryover==1)=[];
   tempq(carryover==1)=[];
   tempb_id(carryover==1)=[];
   tempnoi=noi(aucidfs==tempid);
   tempimm=ownIMM(aucidfs==tempid);
   bidderimm=immbidderid(aucidfs==tempid);
   biddernoi=noibidderid(aucidfs==tempid);
   
   %now loop over each bidder in the auction
   bidderlist=unique([tempb_id; bidderimm]);
   nsplit=sum(partially(aucidsupply==tempid));
   nsplit(nsplit==0)=1;
   for aa=1:length(bidderlist)
   if max(strcmp(tempb_id,bidderlist(aa)))==1
   ownbidsp=tempp(strcmp(tempb_id,bidderlist(aa)));
   ownbidsq=tempq(strcmp(tempb_id,bidderlist(aa)));
   if NOItot(k)>0
   [~,indsr]=sort(ownbidsp,'descend');
   ownbidsp=ownbidsp(indsr);
   owbidsq=ownbidsq(indsr);
   else
   [~,indsr]=sort(-ownbidsp,'descend');
   ownbidsp=ownbidsp(indsr);
   owbidsq=ownbidsq(indsr);
   end
   else
       ownbidsp=0;
       ownbidsq=0;
   end
   if max(strcmp(bidderimm,bidderlist(aa)))==1
   ownbidimm=tempimm(strcmp(bidderimm,bidderlist(aa)));
   br_imm(counter)=max(tempimm(strcmp(bidderimm,bidderlist(aa))));
   else
       ownbidimm=0;
       br_imm(counter)=0;
   end
   if max(strcmp(biddernoi,bidderlist(aa)))==1
   ownbidnoi=tempimm(strcmp(biddernoi,bidderlist(aa)));
      br_noi(counter)=max(tempnoi(strcmp(biddernoi,bidderlist(aa))));
   else
       ownbidnoi=0;
       br_noi(counter)=0;
   end
   %their noi/auction noi their imm/auction imm/ auction price/max bid,
   %numberof steps, slope
   br_auc_noi(counter)=NOItot(k);
   br_auc_imm(counter)=IMM(k);
   br_auc_pauc(counter)=aucpricefs(k);
   br_maxbid(counter)=max(ownbidsp);
   br_maxbidq(counter)=ownbidsq(1);
   meanpricesub(counter)=sum(ownbidsq.*ownbidsp)./(sum(ownbidsq));
   if size(ownbidsp,1)>1
   yreg=regress(ownbidsp,[cumsum(ownbidsq) ones(size(ownbidsq))]);
   br_beta(counter)=yreg(1);
   else
       br_beta(counter)=0;
   end
   %N_steps for that bidder
   br_Nsteps(counter)=size(ownbidsp,1);
   %concentration of winnings.... (ie. did one guy win it all and overpay
   %and lose in secondary? )
   tempwin=ownbidsq.*(ownbidsp>br_auc_pauc(counter))+(ownbidsq./nsplit).*(ownbidsp==br_auc_pauc(counter));
   br_qwon(counter)=sum(tempwin);
   
   br_auc_id(counter)=tempid;
   counter=counter+1;
   end
shares_s2(br_auc_id==tempid)=sum(br_qwon(br_auc_id==tempid)./br_auc_noi(br_auc_id==tempid));
shares_noi(br_auc_id==tempid)=(br_noi(br_auc_id==tempid)./br_auc_noi(br_auc_id==tempid));
br_auc_hhi_s2(br_auc_id==tempid)=sum(shares_s2(br_auc_id==tempid).^2);
br_auc_hhi_NOI(br_auc_id==tempid)=sum(shares_noi(br_auc_id==tempid).^2);
end




switchdirection=((br_noi>0).*(br_auc_noi<0).*(br_maxbid>0)+(br_noi<0).*(br_auc_noi>0).*(br_maxbid>0))';

save(fullfile(int_path,'maindata'))


