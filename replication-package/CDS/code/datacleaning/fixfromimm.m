%this builds the variable fromimm properly


counter=1;
fromimmnew=zeros(size(supplyp));
for k=1:size(aucidfslist,1)
   tempid=aucidfslist(k);
   tempp=supplyp(aucidsupply==tempid);
   tempq=supplyq(aucidsupply==tempid);
   tempb_id=supplyid(aucidsupply==tempid);
   tempnoi=noi(aucidfs==tempid);
   tempimmlow=immlow(aucidfs==tempid);
   tempimmhigh=immhigh(aucidfs==tempid);
   bidderimm=immbidderid(aucidfs==tempid);
   biddernoi=noibidderid(aucidfs==tempid);
   %now loop over each bidder in the auction to find matching one
   bidderlist=unique([tempb_id]);
   for aa=1:length(bidderlist)
   if max(strcmp(tempb_id,bidderlist(aa)))==1
   ownbidsp=tempp(strcmp(tempb_id,bidderlist(aa)));
   ownbidsq=tempq(strcmp(tempb_id,bidderlist(aa)));
     ownimmlow=max(tempimmlow(strcmp(bidderimm,bidderlist(aa))));
     ownimmhigh=max(tempimmhigh(strcmp(bidderimm,bidderlist(aa))));
   %is the imm low or high submitted ever the same as the price of a
   %bid--if yes drop the bid at this price with the smaller q. if no drop
   %the bid with the smallest q.
   if isempty(ownimmlow)==1
          newtemp=zeros(size(ownbidsp));
   [~,ntind]=min(ownbidsq);  
     newtemp(ntind)=1;
   else
    tl=(ownbidsp==ownimmlow);
   th=(ownbidsp==ownimmhigh);
       newtemp=zeros(size(ownbidsp));
   if max(tl)>0
    [~,ntind]=max(tl);
    newtemp(ntind)=1;
   elseif max(th)>0
     [~,ntind]=max(th);
    newtemp(ntind)=1;
   else
     [~,ntind]=min(ownbidsq);  
     newtemp(ntind)=1;
   end
   end
   newtempb=zeros(size(tempb_id));
   newtempb(strcmp(tempb_id,bidderlist(aa)))=newtemp;
   fromimmnew(aucidsupply==tempid)=fromimmnew(aucidsupply==tempid)+newtempb;
   end
   end
end

fromimm=fromimmnew;
aucidsupplyorig=aucidsupply;
