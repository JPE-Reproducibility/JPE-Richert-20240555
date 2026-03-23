ncomp=1000;
xgrid=linspace(0.001,3,100);
Pqvec=rand(npq,1);
Qpvec=rand(npq,1);
ids=randi(size(Pqvec,1),nsim,Kbar);

ids=[];
for kk=1:Kbar
   ids=[ids [(nrep).*(kk-1)+1:1:nrep.*kk]'];
end
warning('off','MATLAB:nearlySingularMatrix')
resampleM=randi(nsim,nrep,N);
resampleMk=[];
for aa=1:size(resampleM,1)
    idb=[];
    for bb=1:size(resampleM,2)
       
        idtemp=ids(resampleM(aa,bb),:);
        idtemp(isnan(idtemp)==1)=0;
        idresample=[idtemp];
        idb=[idb idresample];    
    end
        resampleMk=[resampleMk zeros(max(0,size(idb,2)-size(resampleMk,2)),1)'; idb zeros(max(0,size(resampleMk,2)-size(idb,2)),1)'];
    
    
end
resampleMk(1,:)=[];
Mcombos=resampleM;
Pqcombos=resampleMk;

cdist=2;
