
for ii=1:size(aucidfslist,1)
    tempbids=supplyp(aucidsupply==aucidfslist(ii));
    tempbids(fromimm(aucidsupply==aucidfslist(ii))==1)=[];
    ntied(ii)=size(tempbids,1)-size(unique(tempbids),1);
    prtied(ii)=ntied(ii)./size(tempbids,1);
end




