%Setup a bunch of draws: draw bootstrap samples/ build all input data
rng(2000);
ndraw=2000;
tagLong=zeros(size(aucpricefs2));
tagLong(tagn)=1;
for i=1:size(aucidfslist,1)
NOItotexp(aucidfs==aucidfslist(i))=NOItot(i);
Npossibleexp(aucidfs==aucidfslist(i))=Npossible(i);
end
NOItotexp=NOItotexp';
Npossibleexp=Npossibleexp';

for aa=1:size(aucidfslist,1) %added ,1
    eventlong(aucidfs==aucidfslist(aa))=event(aa);
end
eventlong=eventlong';
%construct X(NOI,yI) with a row for each unique bidder/auction pair
X=[NOItotexp noi imm];
X(isnan(X)==1)=0;
Xbs{1}=X;
nauc=size(unique(aucidfslist),1);
noi(isnan(noi)==1)=0;
Noiabslong(isnan(NOIabslong)==1)=0;
avgimm=(immhigh+immlow)./2;
eta=((avgimm-imm)./imm);
%first one the real ids...then after that the new sets...resample at the
%auction level
bsincl=reshape(randsample(aucidfslist,nbs*nauc, true),nauc,nbs);
for jj=1:nbs
    Xtemp=[];
    supplypt=[];
    supplyqt=[];
    supplyp2t=[];
    supplyq2t=[];
    truetemp=[];
    truetempb=[];
    truetempbss=[];
    carriedtemp=[];
    carriedtempq=[];
    Nptemp=[];
    NOItemp=[];
    noitemp=[];
    idsst=[];
    idsstt=[];
    idfst=[];
    immcap2temp=[];
    immcap1temp=[];
    immtemp=[];
    NOIabslongtemp=[];
    etatemp=[];
    Bondvtemp=[];
    Bonddurtemp=[];
    Bondcftemp=[];
    eventlongtemp=[];
    Bondconvtemp=[];
    aucpricefs2temp=[];
    tagntemp=[];
    count=1;
    countb=1;
    for kk=1:nauc
        Xtemp=[Xtemp; X(aucidfs==bsincl(kk,jj),:)];
        ZZ=idfs(aucidfs==bsincl(kk,jj),:);
        TAA=[countb:1:countb+size(ZZ,1)-1]';
        idfst=[idfst; TAA];
        if size(TAA,1)>0
            tempss=idss(aucidsupply==bsincl(kk,jj));
        for abab=1:size(ZZ,1)
            tempss(tempss==ZZ(abab))=TAA(abab);
        end
        end
        countb=countb+size(ZZ,1);
        idsst=[idsst; tempss];
% % % %         %idss needs to be in the raw order--but should be numbered 1,...as
% % % %         %appear         
        idsstt=[idsstt; count*ones(size(supplyp(aucidsupply==bsincl(kk,jj),:)))];
        supplypt=[supplypt; supplyp(aucidsupply==bsincl(kk,jj),:)];
        supplyqt=[supplyqt; supplyq(aucidsupply==bsincl(kk,jj),:)];
        supplyp2t=[supplyp2t; supplyp2(aucidfs==bsincl(kk,jj),:)];
        supplyq2t=[supplyq2t; supplyq2(aucidfs==bsincl(kk,jj),:)];
        truetemp=[truetemp; aucidsupply(aucidsupply==bsincl(kk,jj),:)];
        truetempb=[truetempb; idfs(aucidfs==bsincl(kk,jj),:)];
        truetempbss=[truetempbss; idss(aucidsupply==bsincl(kk,jj),:)];
        carriedtemp=[carriedtemp; carriedoverp(aucidfs==bsincl(kk,jj))];
        carriedtempq=[carriedtempq; carriedoverq(aucidfs==bsincl(kk,jj))];
        Nptemp=[Nptemp; Npossibleexp(aucidfs==bsincl(kk,jj))];
        NOItemp=[NOItemp; NOItotexp(aucidfs==bsincl(kk,jj))];
        immcap2temp=[immcap2temp; immcap2(aucidsupply==bsincl(kk,jj),:)];
        noitemp=[noitemp;noi(aucidfs==bsincl(kk,jj))];
        immcap1temp=[immcap1temp;imm1cap(aucidfs==bsincl(kk,jj))];
        immtemp=[immtemp;imm(aucidfs==bsincl(kk,jj))];
        NOIabslongtemp=[NOIabslongtemp; NOIabslong(aucidfs==bsincl(kk,jj))'];
        etatemp=[etatemp; eta(aucidfs==bsincl(kk,jj))];
        Bondvtemp=[Bondvtemp; Bondvol(aucidfs==bsincl(kk,jj))];
        eventlongtemp=[eventlongtemp; eventlong(aucidfs==bsincl(kk,jj))];
        Bonddurtemp=[Bonddurtemp;Bonddur(aucidfs==bsincl(kk,jj))];
        Bondcftemp=[Bondcftemp;Bondcf(aucidfs==bsincl(kk,jj))];
        Bondconvtemp=[Bondconvtemp;Bondconv(aucidfs==bsincl(kk,jj))];
        aucpricefs2temp=[aucpricefs2temp;aucpricefs2(aucidfs==bsincl(kk,jj))];
        tagntemp=[tagntemp;tagLong(aucidfs==bsincl(kk,jj))];
        count=count+1;
    end
    Xbs{jj}=Xtemp;
    idssbst{jj}=idsstt;
    idssbs{jj}=idsst;
    idfsbs{jj}=idfst;
    trueaucid{jj}=truetemp;
    truebidid{jj}=truetempb;
    truebidid2s{jj}=truetempbss;
    supplypbs{jj}=supplypt;
    supplyqbs{jj}=supplyqt;
    supplyq2bs{jj}=supplyq2t;
    supplyp2bs{jj}=supplyp2t;
    NOItotexpbs{jj}=NOItemp;
    NOIabslongbs{jj}=NOIabslongtemp;
    Npossibleexpbs{jj}=Nptemp;
    carriedoverpbs{jj}=carriedtemp;
    carriedoverqbs{jj}=carriedtempq;
    immcap2bs{jj}=immcap2temp;
    immcap1bs{jj}=immcap1temp;
    immbs{jj}=immtemp;
    noibs{jj}=noitemp;
    etabs{jj}=etatemp;
    Bondvbs{jj}=Bondvtemp;
    Bonddurbs{jj}=Bonddurtemp;
    Bondcfbs{jj}=Bondcftemp;
    Bondconvbs{jj}=Bondconvtemp;
    eventlongbs{jj}=eventlongtemp;
    aucpricefs2bs{jj}=aucpricefs2temp;
    tagnbs{jj}=tagntemp;
end
for jj=1:nbs
    for kk=1:nauc
        pointerinc_bs(kk,jj)=find(aucidfslist==bsincl(kk,jj));
    end
end


    possiblePl=find(NOIlong>=0);
    possibleM=find(NOIlong<0);
    if size(imm,1)==1
        imm=imm';
    end
    if size(NOIlong,1)==1
        NOIlong=NOIlong';
    end
   for k=1:size(Npossibleexp,1)
    %for each number of bidders draw a large number of possible bidder sets
    Nopp=Npossibleexp(k)-1;
    if X(k,1)>=0
    bwimm=1.06*std(IMM).*size(IMM,1).^(-1./5);
    bwNOI=1.06.*std(NOI).*size(NOI,1).^(-1./5);
    wimm=normpdf((imm(k)-(imm))./bwimm); 
    wNOI=normpdf((NOIlong(k)-NOIlong)./bwNOI);
    wimm=wimm.*wNOI; wimm=wimm./sum(wimm);
    setOppP=reshape(randsample(possiblePl,ndraw*20*Nopp,'true',wimm(possiblePl)),[],Nopp);

    bwP=1.06.*std(sum(X(setOppP,2),2)).*size(NOI,1).^(-1./5);
    weightP=normpdf(((X(k,1)-X(k,2))-sum(reshape(X(setOppP(:),2),[],Nopp),2)')./bwP);
    weightP(weightP<1e-20)=1e-20;
    weightP=weightP./sum(weightP);
    drawnids{k}=setOppP(randsample(size(setOppP,1),ndraw,'true',weightP),:);    
    else
    bwimm=1.06*std(IMM).*size(IMM,1).^(-1./5);
    bwNOI=1.06.*std(NOI).*size(NOI,1).^(-1./5);
    wimm=normpdf((imm(k)-(imm))./bwimm); 
    wNOI=normpdf((NOIlong(k)-NOIlong)./bwNOI);
    wimm=wimm.*wNOI; wimm=wimm./sum(wimm); 
    setOppM=reshape(randsample(possibleM,ndraw*20*Nopp,'true',wimm(possibleM)),[],Nopp);

    bwP=1.06.*std(sum(X(setOppM,2),2)).*size(NOI,1).^(-1./5);
    weightP=normpdf(((X(k,1)-X(k,2))-sum(reshape(X(setOppM(:),2),[],Nopp),2)')./bwP);
    weightP(weightP<1e-20)=1e-20;
    weightP=weightP./sum(weightP);
    drawnids{k}=setOppM(randsample(size(setOppM,1),ndraw,'true',weightP),:);       
        end
   end

[EpredW,ciEpredW]=regress(aucpricefs2(tagn),[ones(size(Bondvol(tagn))) log(Bondvol(tagn)) Bonddur(tagn) Bondcf(tagn) Bondconv(tagn) event']);


save(fullfile(int_path,'temp_preinv'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%WITHOUT ACCOUNTING FOR CUSTOMER ORDERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%NLB and NUB are bounds on (n-y) 
for aa=1:size(supplyp2,1)
tempp=supplyp2(aa,:);
tempq=supplyq2(aa,:);
tempq(tempp==0)=[]; tempp(tempp==0)=[]; 
if isempty(tempp)==0
tempp=tempp.*max(imm(aa)); tempq=tempq.*max(NOIlong(idfs==idss(aa)));
%sort price
[tempp,ictp]=sort(tempp,'descend');
tempq=cumsum(tempq(ictp));
ts=(tempp-tempp')./(tempq-tempq');
ts(isinf(ts))=0; ts(isnan(ts))=0;
maxslope(aa)=mean(abs(ts(:)));
end
end
maxslope=prctile(maxslope,95);
carriedoverq(isnan(carriedoverq))=0;
for aa=1:size(idfs,1)
Ibidon(aa)=-noi(aa)+NOIabslong(aa).*sum(supplyq(idss==idfs(aa)))+NOIlong(aa).*carriedoverq(aa);
end
%%%%%%%%%%%%%%%%%%%%%%%%%

