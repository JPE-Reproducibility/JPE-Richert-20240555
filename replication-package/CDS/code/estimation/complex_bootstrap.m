%this function directly calls
%complex_estimator_step1: the main first stage estimation: gives n-bounds
%and we store the win probabilities ect. from the bids

%complex estimator_step2: the main second stage of estimation: combining
%the n-bounds to get a confidence set (or median unbiased set) and then
%plugging (along with extrainfo: stored win probabilities) to get v-hats

[nbounds,extrainfo]=complex_estimator_step1(supplyp,supplyq,idfs,idss,ndraw,NOItotexp,noi,Npossibleexp,supplyp2, supplyq2 ,supplyp2, supplyq2,drawnids,[],[],carriedoverp, carriedoverq,carriedoverp,carriedoverq,immcap2,NOIlong,eta,[],100*ones(size(bondvols)),imm1cap,1,maxslope,zeros(size(idss)),imm);

%% Bootstrap parfor (skip if resuming from checkpoint)
if exist('resume_from_checkpoint','var') && resume_from_checkpoint
    fprintf('  Resuming from bootstrap checkpoint — skipping parfor\n');
else
nbatches=5;
   if ~exist('bootstrap_seed','var'); bootstrap_seed = 0; end
   fprintf('  Bootstrap: seed=%d, nbs=%d, nbatches=%d\n', bootstrap_seed, nbs, nbatches);
   sc = parallel.pool.Constant(RandStream('Threefry', 'Seed', bootstrap_seed));
for kl=1:nbatches
p=gcp('nocreate');
delete(p);
   parpool(ncores);
  pctRunOnAll warning('off')
  supplypbst=supplypbs((kl-1)*(nbs/nbatches)+1:(kl-1)*(nbs/nbatches)+(nbs/nbatches));
  supplyp2bst=supplyp2bs((kl-1)*(nbs/nbatches)+1:(kl-1)*(nbs/nbatches)+(nbs/nbatches));
  supplyqbst=supplyqbs((kl-1)*(nbs/nbatches)+1:(kl-1)*(nbs/nbatches)+(nbs/nbatches));
  supplyq2bst=supplyq2bs((kl-1)*(nbs/nbatches)+1:(kl-1)*(nbs/nbatches)+(nbs/nbatches));
parfor j=1:(nbs/nbatches)
    drawnidstemp={};
    %trick: account for auction het in resampling!
jv=(kl-1)*(nbs/nbatches)+j;

    stream = sc.Value;
    stream.Substream = jv;
    RandStream.setGlobalStream(stream);
    possiblePl=find(NOItotexpbs{jv}(:,1)>=0);
    possibleM=find(NOItotexpbs{jv}(:,1)<0);
   %sets of opponents constructed in here: this is a huge matrix otherwise
   %to store
    for k=1:size(Npossibleexp,1)
    %for each number of bidders draw a large number of possible bidder sets
    Nopp=Npossibleexp(k)-1; 
    if X(k,1)>=0
    bwimm=1.06*std(IMM(pointerinc_bs(:,jv))).*nauc.^(-1./5);
    bwnoi=1.06*std(NOI(pointerinc_bs(:,jv))).*nauc.^(-1./5);
    wimm=normpdf((imm(k)-(immbs{jv}))./bwimm); 
    wnoi=normpdf((NOItotexp(k)-(NOItotexpbs{jv}))./bwnoi); 
    wimm=wimm.*wnoi; wimm(wimm<1e-20)=1e-20; wimm=wimm./sum(wimm);    
    setOppP=reshape(randsample(possiblePl,ndraw*20*Nopp,'true',wimm(possiblePl)),[],Nopp);

    bwP=1.06.*std(sum(Xbs{jv}(setOppP,2),2)).*nauc.^(-1./5);
    weightP=normpdf(((X(k,1)-X(k,2))-sum(reshape(Xbs{jv}(setOppP(:),2),[],Nopp),2)')./bwP);
    weightP(weightP<1e-20)=1e-20;
    weightP=weightP./sum(weightP);
    drawnidstemp{k}=setOppP(randsample(size(setOppP,1),ndraw,'true',weightP),:);    
    else
    bwimm=1.06*std(IMM(pointerinc_bs(:,jv))).*nauc.^(-1./5);
    bwnoi=1.06*std(NOI(pointerinc_bs(:,jv))).*nauc.^(-1./5);
    wimm=normpdf((imm(k)-(immbs{jv}))./bwimm); 
    wnoi=normpdf((NOItotexp(k)-(NOItotexpbs{jv}))./bwnoi); 
    wimm=wimm.*wnoi; wimm(wimm<1e-20)=1e-20; wimm=wimm./sum(wimm);
    setOppM=reshape(randsample(possibleM,ndraw*20*Nopp,'true',wimm(possibleM)),[],Nopp);

    bwP=1.06.*std(sum(Xbs{jv}(setOppM,2),2)).*nauc.^(-1./5);
    weightP=normpdf(((X(k,1)-X(k,2))-sum(reshape(Xbs{jv}(setOppM(:),2),[],Nopp),2)')./bwP);
    weightP(weightP<1e-20)=1e-20;
    weightP=weightP./sum(weightP);
     drawnidstemp{k}=setOppM(randsample(size(setOppM,1),ndraw,'true',weightP),:);       
        end
    end
[nboundsbs{j},extrainfobs{j}]=complex_estimator_step1(supplyp,supplyq,idfs,idss,ndraw,NOItotexp,noi,Npossibleexp,supplyp2, supplyq2,supplyp2bst{j}, supplyq2bst{j},drawnidstemp,[],[],carriedoverp,carriedoverq,carriedoverpbs{jv}, carriedoverqbs{jv},immcap2,NOItotexp,eta,[],100*ones(size(imm1cap)),imm1cap,0,maxslope,zeros(size(idss)),imm);
%%%%%%%%%%%%%%%%%%%%%%%%%
end

for j=1:(nbs/nbatches)
jv=(kl-1)*(nbs/nbatches)+j;
noutbss{jv}=nboundsbs{j};
extraoutbs{jv}=extrainfobs{j};
end
save(fullfile(int_path,'bsinprogressCCC'))
end
save(fullfile(int_path,'extraoutbs'),'extraoutbs','-v7.3');
end 

nmax=300;
for ii=1:size(nbounds,1)
tnl=[];
tnu=[];
for kk=1:nbs
tnl=[tnl noutbss{kk}{ii,1}];
tnu=[tnu noutbss{kk}{ii,2}];
end
tnl(isnan(tnl))=-nmax;
tnu(isnan(tnu))=nmax;
tnlo=tnl; tnuo=tnu;
tnl(tnl<=-nmax)=-nmax;
tnu(tnu>=nmax)=nmax;
tnu(tnu<=-nmax)=-nmax;
tnl(tnl>=nmax)=nmax;
%add raw noise back in when it is hitting the wrong bound all the
%time so that the correlation matrix can still be calculated--this won't
%effect inequalities later since these terms will have little effects
%based on their high estimation noise
tnl(min(tnl,[],2)==nmax,:)=tnlo(min(tnl,[],2)==nmax,:);
tnu(max(tnu,[],2)==-nmax,:)=tnuo(max(tnu,[],2)==-nmax,:);
sdn{ii}=std(tnl,[],2);
sdnu{ii}=std(tnu,[],2);
omegan{ii}=corr(tnl');
omeganu{ii}=corr(tnu');
omeganu{ii}(isnan(omeganu{ii}) & eye(size(tnl,1))==1)=1;
omegan{ii}(isnan(omegan{ii}) & eye(size(tnl,1))==1)=1;
omeganu{ii}(isnan(omeganu{ii}))=0;
omegan{ii}(isnan(omegan{ii}))=0;
omeganu{ii}=nearestSPD(omeganu{ii});
omegan{ii}=nearestSPD(omegan{ii});
%sometimess that particular ineq. is not
%meaningful--so we are plugging in a lower bound of the support--then it
%has sdn close to 0
sdnu{ii}(sdnu{ii}==0 & nbounds{ii,2}==nmax)=0.01;
sdn{ii}((sdn{ii}==0) & nbounds{ii,1}==-nmax)=0.01;
%enforce the support bounds
nbounds{ii,1}(nbounds{ii,1}<-nmax)=-nmax;
nbounds{ii,2}(nbounds{ii,2}>nmax)=nmax;
nbounds{ii,1}(nbounds{ii,1}>nmax)=nmax;
nbounds{ii,2}(nbounds{ii,2}<-nmax)=-nmax;
end


%Point estimates: use median alpha of 50 
clev=50;
rdrawss=1000;
for jj=1:size(aucidfs,1)
rng(200);
c1malpha=prctile(max(mvnrnd(zeros(1,size(nbounds{jj,1},1)),omegan{jj},rdrawss)',[],1),clev);
%when all bind:
LFB(jj,1)=max(nbounds{jj,1}-c1malpha.*sdn{jj});
[sjo,jorder]=sort(nbounds{jj,1}+sdn{jj}*(log(size(aucidfs,1))),'descend');
clear jthquantile thetaj
for kk=1:size(nbounds{jj,1},1) 
    cormt=[];
    for aa=1:kk
        cormt(aa,:)=omegan{jj}(jorder(aa),jorder(1:kk)');
    end
    jthquantile(kk,1)=prctile(max(mvnrnd(zeros(1,kk),cormt,rdrawss)',[],1),clev);
    thetaj(kk,1)=max(nbounds{jj,1}-jthquantile(kk,1).*(sdn{jj}));
end
%adjusting for the fact that many inequalities are far from binding
try
LGMS(jj,1)=min(thetaj(((sjo>=thetaj).*(thetaj>[sjo(2:end);-inf]))==1));
catch
LGMS(jj,1)=-nmax;
end
gamma=1-0.1./log(size(aucidfs,1));
ghat=-1.*sdn{jj}.*sqrt(size(aucidfs,1));
ghat(isinf(nbounds{jj,1}))=NaN;
sn=sqrt(ghat.^2)./sqrt(size(aucidfs,1));
Zr=randn([size(sdn{jj},1),rdrawss]);
tzqk=(ghat.*Zr)./sqrt(ghat.^2);
tzqk(ghat==0 | isnan(ghat),:)=[];
if isempty(tzqk)==0 
kngamma=prctile(max(tzqk),gamma*100);
tvc=min(-nbounds{jj,1}+kngamma*sn)+2*kngamma*sn;
Vhat=(-nbounds{jj,1}<=tvc);
tzqk=(ghat.*Zr)./sqrt(ghat.^2);
Vhat(sn==0)=0;
tzqk=tzqk(Vhat==1,:);
knvnp=prctile(max(tzqk,[],1),clev);
if isempty(tzqk)==0
Lb_hat(jj,1)=-min(-nbounds{jj,1}+knvnp.*(sqrt(ghat.^2)./sqrt(size(aucidfs,1))));
else
    Lb_hat(jj,1)=-nmax;
end
else
Lb_hat(jj,1)=-nmax;
end

c1malpha=prctile(max(mvnrnd(zeros(1,size(nbounds{jj,1},1)),omeganu{jj},rdrawss)',[],1),clev);
%when all bind:
UFB(jj,1)=-max(-nbounds{jj,2}-c1malpha.*sdnu{jj});
[sjo,jorder]=sort(-nbounds{jj,2}+sdnu{jj}*(log(size(aucidfs,1))),'descend');
clear jthquantile thetaj
for kk=1:size(nbounds{jj,2},1) 
    cormt=[];
    for aa=1:kk
        cormt(aa,:)=omegan{jj}(jorder(aa),jorder(1:kk)');
    end
    jthquantile(kk,1)=prctile(max(mvnrnd(zeros(1,kk),cormt,rdrawss)',[],1),clev);
    thetaj(kk,1)=max(-nbounds{jj,2}-jthquantile(kk,1).*(sdnu{jj}));
end
%adjusting for the fact that many inequalities are far from binding
try
UGMS(jj,1)=-min(thetaj(((sjo>=thetaj).*(thetaj>[sjo(2:end);-inf]))==1));
catch
UGMS(jj,1)=nmax;
end

%CLR Procedure
gamma=1-0.1./log(size(aucidfs,1));
ghat=1.*sdnu{jj}.*sqrt(size(aucidfs,1));
ghat(isinf(nbounds{jj,2}))=NaN;
sn=sqrt(ghat.^2)./sqrt(size(aucidfs,1));
Zr=randn([size(sdnu{jj},1),rdrawss]);
tzqk=(ghat.*Zr)./sqrt(ghat.^2);
tzqk(ghat==0 | isnan(ghat),:)=[];
if isempty(tzqk)==0 
kngamma=prctile(max(tzqk),gamma*100);
tvc=min(nbounds{jj,2}+kngamma*sn)+2*kngamma*sn;
Vhat=(nbounds{jj,2}<=tvc);
tzqk=(ghat.*Zr)./sqrt(ghat.^2);
Vhat(sn==0)=0;
tzqk=tzqk(Vhat==1,:);
if isempty(tzqk)==0
knvnp=prctile(max(tzqk,[],1),clev);
Ub_hat(jj,1)=min(nbounds{jj,2}+knvnp.*(sqrt(ghat.^2)./sqrt(size(aucidfs,1))));
else
    Ub_hat(jj,1)=nmax;
end
else
    Ub_hat(jj,1)=nmax;

end
end
LGMS(LGMS<=-300)=-300;
UGMS(UGMS>=300)=300;
LFB(LFB<=-300)=-300;
UFB(UFB>=300)=300;
Ub_hat(Ub_hat>300)=300;
Lb_hat(Lb_hat<-300)=-300;
Lgms=Lb_hat; Ugms=Ub_hat;
%now plug in to get point estimates of v!
[vout,nout]=complex_estimator_step2(Lgms,Ugms,extrainfo,supplyp,supplyq,idfs,idss,ndraw,NOItotexp,noi,Npossibleexp,supplyp2, supplyq2,drawnids,[],[],carriedoverp, carriedoverq,immcap2,NOIlong,eta,[],100*ones(size(bondvols)),imm1cap,1,maxslope,zeros(size(idss)),imm);
%now you are finally ready for postestimation and Cfs.
nout(:,[1:2])=[Lgms Ugms];

clev=95;
for jj=1:size(aucidfs,1)
rng(200);
c1malpha=prctile(max(mvnrnd(zeros(1,size(nbounds{jj,1},1)),omegan{jj},rdrawss)',[],1),clev);
%when all bind:
LFB_CI(jj,1)=max(nbounds{jj,1}-c1malpha.*sdn{jj});
[sjo,jorder]=sort(nbounds{jj,1}+sdn{jj}*(log(size(aucidfs,1))),'descend');
clear jthquantile thetaj
for kk=1:size(nbounds{jj,1},1) 
    cormt=[];
    for aa=1:kk
        cormt(aa,:)=omegan{jj}(jorder(aa),jorder(1:kk)');
    end
    jthquantile(kk,1)=prctile(max(mvnrnd(zeros(1,kk),cormt,rdrawss)',[],1),clev);
    thetaj(kk,1)=max(nbounds{jj,1}-jthquantile(kk,1).*(sdn{jj}));
end
%adjusting for the fact that many inequalities are far from binding
try
LGMS_CI(jj,1)=min(thetaj(((sjo>=thetaj).*(thetaj>[sjo(2:end);-inf]))==1));
catch
LGMS_CI(jj,1)=-nmax;
end
gamma=1-0.1./log(size(aucidfs,1));
ghat=-1.*sdn{jj}.*sqrt(size(aucidfs,1));
ghat(isinf(nbounds{jj,1}))=NaN;
sn=sqrt(ghat.^2)./sqrt(size(aucidfs,1));
Zr=randn([size(sdn{jj},1),rdrawss]);
tzqk=(ghat.*Zr)./sqrt(ghat.^2);
tzqk(ghat==0 | isnan(ghat),:)=[];
if isempty(tzqk)==0 
kngamma=prctile(max(tzqk),gamma*100);
tvc=min(-nbounds{jj,1}+kngamma*sn)+2*kngamma*sn;
Vhat=(-nbounds{jj,1}<=tvc);
tzqk=(ghat.*Zr)./sqrt(ghat.^2);
Vhat(sn==0)=0;
tzqk=tzqk(Vhat==1,:);
knvnp=prctile(max(tzqk,[],1),clev);
if isempty(tzqk)==0
LCLR_CI(jj,1)=-min(-nbounds{jj,1}+knvnp.*(sqrt(ghat.^2)./sqrt(size(aucidfs,1))));
else
LCLR_CI(jj,1)=-nmax;
end
else
LCLR_CI(jj,1)=-nmax;
end


c1malpha=prctile(max(mvnrnd(zeros(1,size(nbounds{jj,1},1)),omeganu{jj},rdrawss)',[],1),clev);
%when all bind:
UFB_CI(jj,1)=-max(-nbounds{jj,2}-c1malpha.*sdnu{jj});
[sjo,jorder]=sort(-nbounds{jj,2}+sdnu{jj}*(log(size(aucidfs,1))),'descend');
clear jthquantile thetaj
for kk=1:size(nbounds{jj,2},1) 
    cormt=[];
    for aa=1:kk
        cormt(aa,:)=omegan{jj}(jorder(aa),jorder(1:kk)');
    end
    jthquantile(kk,1)=prctile(max(mvnrnd(zeros(1,kk),cormt,rdrawss)',[],1),clev);
    thetaj(kk,1)=max(-nbounds{jj,2}-jthquantile(kk,1).*(sdnu{jj}));
end
try
UGMS_CI(jj,1)=-min(thetaj(((sjo>=thetaj).*(thetaj>[sjo(2:end);-inf]))==1));
catch
UGMS_CI(jj,1)=nmax;
end

gamma=1-0.1./log(size(aucidfs,1));
ghat=1.*sdnu{jj}.*sqrt(size(aucidfs,1));
ghat(isinf(nbounds{jj,2}))=NaN;
sn=sqrt(ghat.^2)./sqrt(size(aucidfs,1));
Zr=randn([size(sdnu{jj},1),rdrawss]);
tzqk=(ghat.*Zr)./sqrt(ghat.^2);
tzqk(ghat==0 | isnan(ghat),:)=[];
if isempty(tzqk)==0 
kngamma=prctile(max(tzqk),gamma*100);
tvc=min(nbounds{jj,2}+kngamma*sn)+2*kngamma*sn;
Vhat=(nbounds{jj,2}<=tvc);
tzqk=(ghat.*Zr)./sqrt(ghat.^2);
Vhat(sn==0)=0;
tzqk=tzqk(Vhat==1,:);
if isempty(tzqk)==0
knvnp=prctile(max(tzqk,[],1),clev);
UCLR_CI(jj,1)=min(nbounds{jj,2}+knvnp.*(sqrt(ghat.^2)./sqrt(size(aucidfs,1))));
else
UCLR_CI(jj,1)=nmax;
end
else
UCLR_CI(jj,1)=nmax;
end

end
LGMS_CI(LGMS_CI<=-300)=-300;
UGMS_CI(UGMS_CI>=300)=300;
LFB_CI(LFB_CI<=-300)=-300;
UFB_CI(UFB_CI>=300)=300;
LCLR_CI(LCLR_CI<=-300)=-300;
UCLR_CI(UCLR_CI>=300)=300;


%% Checkpoint: save before v_correction (allows splitting across jobs)
save(fullfile(int_path,'pre_vcorrection'),'-v7.3');
fprintf('  Saved pre_vcorrection.mat checkpoint\n');

if exist('skip_vcorrection','var') && skip_vcorrection
    fprintf('  skip_vcorrection=1 — deferring v_correction to next job\n');
else
%now run through the bootstrap output: to get the vout bounds this time.
v_correction

save(fullfile(int_path,'bsinprogressCCC'))

%now you need to make the figures
complex_bootstrap_pe_outputs
end


