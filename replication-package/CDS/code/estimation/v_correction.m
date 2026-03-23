
%% Section 1: Bootstrap variance of value bounds
% Parfor on kk (bootstrap draw) to avoid broadcasting full extraoutbs.
for jj=1:size(aucidfs,1)
    clear voutt vout_otherdir shadoutL shadoutU vout_otherdirU
    n_ineq_jj = size(nbounds{jj,1},1);

    % Pre-extract bootstrap n-bounds for this auction
    nbs_jj_L = cell(nbs,1);
    nbs_jj_U = cell(nbs,1);
    for kk=1:nbs
        nbs_jj_L{kk} = noutbss{kk}{jj,1};
        nbs_jj_U{kk} = noutbss{kk}{jj,2};
    end

    % Parfor: run all (ii, kk) step2b calls, collect raw outputs
    voutt_cells = cell(nbs, 1);
    shad_cells = cell(nbs, 1);
    parfor kk=1:nbs
        eobs_kk = extraoutbs{kk};
        nL_kk = nbs_jj_L{kk};
        nU_kk = nbs_jj_U{kk};
        vt_kk = cell(n_ineq_jj, 1);
        sh_kk = zeros(n_ineq_jj, 2);
        for ii=1:n_ineq_jj
            [vt, shdt] = complex_estimator_step2b(nL_kk(ii), nU_kk(ii), jj, eobs_kk, supplyp,supplyq,idfs,idss,ndraw,NOItotexp,noi,Npossibleexp,supplyp2, supplyq2,drawnids,[],[],carriedoverp, carriedoverq,immcap2,NOIlong,eta,[],100*ones(size(bondvols)),imm1cap,1,maxslope,zeros(size(idss)),imm);
            vt_kk{ii} = vt;
            sh_kk(ii,:) = shdt;
        end
        voutt_cells{kk} = vt_kk;
        shad_cells{kk} = sh_kk;
    end

    for ii=1:n_ineq_jj
    for kk=1:nbs
       voutt(:,:,kk) = voutt_cells{kk}{ii};
       shadoutL(ii,kk)=shad_cells{kk}(ii,1);
       shadoutU(ii,kk)=shad_cells{kk}(ii,2);
       for hh=1:size(voutt(:,1,kk),1)
       vout_otherdir(ii,kk,hh)=voutt(hh,1,kk);
       vout_otherdirU(ii,kk,hh)=voutt(hh,2,kk);
       end
    end
    sdbsv{jj}(ii,:)=std(voutt(:,1,:),[],3)';
    sdbsvu{jj}(ii,:)=std(voutt(:,2,:),[],3)';
    end
    sdbssh{jj}=std(shadoutL,[],2);
    sdbsshu{jj}=std(shadoutU,[],2);
    omegash{jj}=corr(shadoutL');
    omegashU{jj}=corr(shadoutU');
    omegashU{jj}(isnan(omegashU{jj}))=0;
    omegash{jj}(isnan(omegash{jj}))=0;
    omegash{jj}=nearestSPD(omegash{jj});
    omegashU{jj}=nearestSPD(omegashU{jj});
    shadL{jj}=shadoutL;
    shadU{jj}=shadoutU;
    for aa=1:size(voutt,1)
    omegav{jj}{aa}=corr(squeeze(vout_otherdir(:,:,aa))');
    omegavu{jj}{aa}=corr(squeeze(vout_otherdirU(:,:,aa))');
    omegavu{jj}{aa}(isnan(omegavu{jj}{aa}))=0;
    omegav{jj}{aa}(isnan(omegav{jj}{aa}))=0;
    omegav{jj}{aa}=nearestSPD(omegav{jj}{aa});
    omegavu{jj}{aa}=nearestSPD(omegavu{jj}{aa});
    end
    if mod(jj,100)==0 || jj==size(aucidfs,1); fprintf('  v_correction section 1: jj=%d/%d done\n', jj, size(aucidfs,1)); end
end
fprintf('  v_correction section 1 complete — saving checkpoint\n');
save(fullfile(int_path,'v_correction_s1'),'sdbsv','sdbsvu','sdbssh','sdbsshu','omegash','omegashU','omegav','omegavu','shadL','shadU','-v7.3');


vout_ci=vout;
clev=95;
rdrawss=1000;
for jj=1:size(aucidfs,1)
for ii=1:size(sdbsvu{jj},2)
    rng(200);
clear vtempL vtempU
for aa=1:size(nbounds{jj,1})
    [vtemp]=complex_estimator_step2b(nbounds{jj,1}(aa),nbounds{jj,2}(aa),jj,extrainfo,supplyp,supplyq,idfs,idss,ndraw,NOItotexp,noi,Npossibleexp,supplyp2, supplyq2,drawnids,[],[],carriedoverp, carriedoverq,immcap2,NOIlong,eta,[],100*ones(size(bondvols)),imm1cap,1,maxslope,zeros(size(idss)),imm);
vtempL(aa,1)=vtemp(ii,1); vtempU(aa,1)=vtemp(ii,2);
end
c1malpha=prctile(max(mvnrnd(zeros(1,size(nbounds{jj,1},1)),omegav{jj}{ii},rdrawss)',[],1),clev);
LFB_v(jj,1)=max(vtempL-c1malpha.*sdbsv{jj}(:,ii));
[sjo,jorder]=sort(vtempL+sdbsv{jj}(:,ii)*(log(size(aucidfs,1))),'descend');
clear jthquantile thetaj
for kk=1:size(nbounds{jj,1},1)
    cormt=[];
    for aa=1:kk
        cormt(aa,:)=omegav{jj}{ii}(jorder(aa),jorder(1:kk)');
    end
    cormt=max(cormt,eye(size(cormt)));
    cormt=nearestSPD(cormt);
    jthquantile(kk,1)=prctile(max(mvnrnd(zeros(1,kk),cormt,rdrawss)',[],1),clev);
    thetaj(kk,1)=max(vtempL-jthquantile(kk,1).*(sdbsv{jj}(:,ii)));
end
try
vout_ci{jj}(ii,2)=min(thetaj(((sjo>=thetaj).*(thetaj>[sjo(2:end);-inf]))==1));
catch
vout_ci{jj}(ii,2)=-nmax;
end

gamma=1-0.1./log(size(aucidfs,1));
ghat=1.*sdbsv{jj}(:,ii).*sqrt(size(aucidfs,1));
sn=sqrt(ghat.^2)./sqrt(size(aucidfs,1));
Zr=randn([size(sdbsv{jj}(:,ii),1),rdrawss]);
tzqk=(ghat.*Zr)./sqrt(ghat.^2);
tzqk(ghat==0 | isnan(ghat),:)=[];
try
kngamma=prctile(max(tzqk),gamma*100);
tvc=min(vtempL+kngamma*sn)+2*kngamma*sn;
Vhat=(vtempL<=tvc);
tzqk=(ghat.*Zr)./sqrt(ghat.^2);
Vhat(sn==0)=0;
tzqk=tzqk(Vhat==1,:);
knvnp=prctile(max(tzqk,[],1),clev);
vout_ci{jj}(ii,3)=min(vtempL+knvnp.*(sqrt(ghat.^2)./sqrt(size(aucidfs,1))));
catch
vout_ci{jj}(ii,3)=-nmax;
end


c1malpha=prctile(max(mvnrnd(zeros(1,size(nbounds{jj,1},1)),omegavu{jj}{ii},rdrawss)',[],1),clev);
UFB_v(jj,1)=-max(-vtempU+c1malpha.*sdbsvu{jj}(:,ii));
[sjo,jorder]=sort(-vtempU+sdbsvu{jj}(:,ii)*(log(size(aucidfs,1))),'descend');
clear jthquantile thetaj
for kk=1:size(nbounds{jj,2},1)
    cormt=[];
    for aa=1:kk
        cormt(aa,:)=omegav{jj}{ii}(jorder(aa),jorder(1:kk)');
    end
    cormt=max(cormt,eye(size(cormt)));
     cormt=nearestSPD(cormt);
    jthquantile(kk,1)=prctile(max(mvnrnd(zeros(1,kk),cormt,rdrawss)',[],1),clev);
    thetaj(kk,1)=max(-vtempU-jthquantile(kk,1).*(sdbsvu{jj}(:,ii)));
end
try
    vout_ci{jj}(ii,3)=-min(thetaj(((sjo>=thetaj).*(thetaj>[sjo(2:end);-inf]))==1));
catch
vout_ci{jj}(ii,3)=nmax;
end
gamma=1-0.1./log(size(aucidfs,1));
ghat=1.*sdbsvu{jj}(:,ii).*sqrt(size(aucidfs,1));
sn=sqrt(ghat.^2)./sqrt(size(aucidfs,1));
Zr=randn([size(sdbsvu{jj}(:,ii),1),rdrawss]);
tzqk=(ghat.*Zr)./sqrt(ghat.^2);
tzqk(ghat==0 | isnan(ghat),:)=[];
try
kngamma=prctile(max(tzqk),gamma*100);
tvc=min(vtempU+kngamma*sn)+2*kngamma*sn;
Vhat=(vtempU<=tvc);
tzqk=(ghat.*Zr)./sqrt(ghat.^2);
Vhat(sn==0)=0;
tzqk=tzqk(Vhat==1,:);
knvnp=prctile(max(tzqk,[],1),clev);
vout_ci{jj}(ii,3)=min(vtempU+knvnp.*(sqrt(ghat.^2)./sqrt(size(aucidfs,1))));
catch
vout_ci{jj}(ii,3)=nmax;
end

end
end

for jj=1:size(aucidfs,1)
rng(200);
clear shadLL shadUU
for aa=1:size(nbounds{jj,1})
    [~,shadttt]=complex_estimator_step2b(nbounds{jj,1}(aa),nbounds{jj,2}(aa),jj,extrainfo,supplyp,supplyq,idfs,idss,ndraw,NOItotexp,noi,Npossibleexp,supplyp2, supplyq2,drawnids,[],[],carriedoverp, carriedoverq,immcap2,NOIlong,eta,[],100*ones(size(bondvols)),imm1cap,1,maxslope,zeros(size(idss)),imm);
shadLL(aa,1)=min(shadttt); shadUU(aa,1)=max(shadttt);
end
c1malpha=prctile(max(mvnrnd(zeros(1,size(nbounds{jj,1},1)),omegan{jj},rdrawss)',[],1),clev);
[sjo,jorder]=sort(shadLL+sdbssh{jj}*(log(size(aucidfs,1))),'descend');
clear jthquantile thetaj
for kk=1:size(nbounds{jj,1},1)
    cormt=[];
    for aa=1:kk
        cormt(aa,:)=omegash{jj}(jorder(aa),jorder(1:kk)');
    end
     cormt=max(cormt,eye(size(cormt)));
     cormt=nearestSPD(cormt);
    jthquantile(kk,1)=prctile(max(mvnrnd(zeros(1,kk),cormt,rdrawss)',[],1),clev);
    thetaj(kk,1)=max(shadLL-jthquantile(kk,1).*(sdbssh{jj}));
end
try
LShad(jj,1)=min(thetaj(((sjo>=thetaj).*(thetaj>[sjo(2:end);-inf]))==1));
catch
LShad(jj,1)=NaN;
end
gamma=1-0.1./log(size(aucidfs,1));
ghat=1.*sdbssh{jj}.*sqrt(size(aucidfs,1));
sn=sqrt(ghat.^2)./sqrt(size(aucidfs,1));
Zr=randn([size(sdbssh{jj},1),rdrawss]);
tzqk=(ghat.*Zr)./sqrt(ghat.^2);
tzqk(ghat==0 | isnan(ghat),:)=[];
try
kngamma=prctile(max(tzqk),gamma*100);
tvc=min(shadLL+kngamma*sn)+2*kngamma*sn;
Vhat=(shadLL<=tvc);
tzqk=(ghat.*Zr)./sqrt(ghat.^2);
Vhat(sn==0)=0;
tzqk=tzqk(Vhat==1,:);
knvnp=prctile(max(tzqk,[],1),clev);
LShad_CLR(jj,1)=min(shadLL+knvnp.*(sqrt(ghat.^2)./sqrt(size(aucidfs,1))));
catch
LShad_CLR(jj,1)=NaN;
end

c1malpha=prctile(max(mvnrnd(zeros(1,size(shadU{jj},1)),omegashU{jj},rdrawss)',[],1),clev);
[sjo,jorder]=sort(-shadUU+sdbsshu{jj}*(log(size(aucidfs,1))),'descend');
clear jthquantile thetaj
for kk=1:size(nbounds{jj,2},1)
    cormt=[];
    for aa=1:kk
        cormt(aa,:)=omegashU{jj}(jorder(aa),jorder(1:kk)');
    end
     cormt=max(cormt,eye(size(cormt)));
     cormt=nearestSPD(cormt);
    jthquantile(kk,1)=prctile(max(mvnrnd(zeros(1,kk),cormt,rdrawss)',[],1),clev);
    thetaj(kk,1)=max(-shadUU-jthquantile(kk,1).*(sdbsshu{jj}));
end
try
UShad(jj,1)=-min(thetaj(((sjo>=thetaj).*(thetaj>[sjo(2:end);-inf]))==1));
catch
UShad(jj,1)=NaN;
end

gamma=1-0.1./log(size(aucidfs,1));
ghat=1.*sdbsshu{jj}.*sqrt(size(aucidfs,1));
sn=sqrt(ghat.^2)./sqrt(size(aucidfs,1));
Zr=randn([size(sdbsshu{jj},1),rdrawss]);
tzqk=(ghat.*Zr)./sqrt(ghat.^2);
tzqk(ghat==0 | isnan(ghat),:)=[];
try
kngamma=prctile(max(tzqk),gamma*100);
tvc=min(shadUU+kngamma*sn)+2*kngamma*sn;
Vhat=(shadUU<=tvc);
tzqk=(ghat.*Zr)./sqrt(ghat.^2);
Vhat(sn==0)=0;
tzqk=tzqk(Vhat==1,:);
knvnp=prctile(max(tzqk,[],1),clev);
UShad_CLR(jj,1)=min(shadUU+knvnp.*(sqrt(ghat.^2)./sqrt(size(aucidfs,1))));
catch
UShad_CLR(jj,1)=NaN;
end

end
