function [vout,shad]=complex_estimator_step2b(nlow,nup,kk,extrainfo,supplyp,supplyq,idfs,idss,ndraw,NOItotexp,noi,Npossibleexp,supplyp2, supplyq2,drawnids,trueaucidd,idsstrue,carriedoverp, carriedoverq,immcap2,NOIlong,eta,idfstrue,Bondvol,imm1cap,orig,maxSlope,prsel,imm)
maxSlope=0;
%set some global parameters:bounds tightness and grid points
ng=100;
rng(200)
entrybound=1;
sc_bound=10000;
carriedoverq(isnan(carriedoverq))=0;

rhoM=0.02;
badcount=0;
crossf=0;
nmax=300;
vmaxda=8; %take p90 of the spread abs((imm1cap(kk)-imm(kk))) * 4
vminda=-8;

kft=size(idfs,1);
%store original input matricies so that resampling restrictions don't
%overwrite
supplypt=supplyp;
supplyqt=supplyq;
supplyp2t=supplyp2;
supplyq2t=supplyq2;
carriedqt=carriedoverq;
carriedpt=carriedoverp;


    vmind=max(vminda+imm1cap(kk),0);
    vmaxd=min(vmaxda+imm1cap(kk),100);
    if NOItotexp(kk)~=0
        %%%the goal here is to resample over residual supply.
        Pclsample=extrainfo{kk,10};
        %1. the Pr(bk<Pc<bk+1|play)
        %2. Expectation of Pc when its in the rangebk bk+1
        %3. dE[p when its in the range bk bk+1]/dqk
        direction=1.*(NOItotexp(kk)>0);
        direction(direction==0)=-1;
     
        %CALCULATE PRICE LEVEL FOR CURRENT AUCTION
        imp=immcap2(idss==idfs(kk));
        if isempty(imp)==0
            imp=imp(1);
        else
            imp=imm1cap(kk);
        end
        impout(kk,1)=imp;
        %now get the clearing prices at -epsilon, +epsilon on i's prices: because
        %we only care about this conditional on some range we can perturb the
        %entire bid function and then condition out the changes not in the right
        %region--the price changes at earlier steps will never effect the object of interest
        
        if direction>0
            [ownbids,ica]=sort([supplyp(idss==idfs(kk));carriedoverp(kk)],'descend');
        else
            [ownbids,ica]=sort([supplyp(idss==idfs(kk));carriedoverp(kk)]);
        end

        ownbidq=[supplyq(idss==idfs(kk));direction.*abs(carriedoverq(kk))];
        ownbidq=ownbidq(ica);
        [~,cc]=max(ica);
        coind=zeros(size(ownbidq));
        coind(cc)=1;

        prselT=[prsel(idss==idfs(kk));0];
        prselT=prselT(ica);

        [ownbids,ia, ic]=unique(ownbids,'stable');
        for ii=1:size(ia,1) %added ,1
            ownbidq(ia(ii))=sum(ownbidq(ic==ii));
            prselT(ia(ii))=max(prselT(ic==ii));
            coind(ia(ii))=min(coind(ic==ii));
        end
        ownbidq=ownbidq(ia);
        prselT=prselT(ia);
        coind=coind(ia);


        %RESCALE QUANTITIES FROM NORMALIZED RESAMPLING QUANTITIES TO ACTUAL
        ownbidq=ownbidq.*(abs(NOIlong(kk)));
        ownbids(ownbidq==0)=[];
        coind(ownbidq==0)=[];
        prselT(ownbidq==0)=[];
        ownbidq(ownbidq==0)=[];


        if direction>0
            ownbidq(ownbidq>NOIlong(kk))=NOIlong(kk);
        else
            ownbidq(ownbidq<NOIlong(kk))=NOIlong(kk);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        nopartflag=0;
        if size(ownbids,1)==1 | ownbids==0
            if direction>0
                [ownbids,ia2]=sort([ownbids; prctile(Pclsample(Pclsample~=0),2)]);
                ownbidq=[ownbidq; 0.01];
                prselT=[prselT;0];
                ownbidq=ownbidq(ia2);
                ownbidq=cumsum(ownbidq);
            elseif direction<0
                [ownbids,ia2]=sort([prctile(Pclsample,95);ownbids],'descend');
                ownbidq=[ownbidq;-0.01];
                prselT=[prselT;0];
                ownbidq=ownbidq(ia2);
                ownbidq=cumsum(ownbidq,'reverse');
            end
            coind=1;
            nopartflag=1;
        end

        nsimSel=1;
        ownbidsF=ownbids;
        ownbidqF=ownbidq;
        for jkl=1:nsimSel
            ownbids=ownbidsF;
            ownbidq=ownbidqF;
            prselT(coind==1)=0;
            dealerOWN=(rand(size(ownbids))>prselT);
            ownbids(dealerOWN==0)=[];
            ownbidq(dealerOWN==0)=[];
            coind(dealerOWN==0)=[];
            if isempty(ownbids)==1 %| sum(coind==0)<1
                if direction>0
                    ownbids=prctile(Pclsample(Pclsample~=0),2);
                    ownbidq=0.01;
                elseif direction<0
                    ownbids=prctile(Pclsample(Pclsample~=0),2);
                    ownbidq=0.01;
                end
                nopartflag=1;
                coind=0;
            end


            ownbids=ownbids.*imp;
            ownbidq_cum=cumsum(ownbidq);

            posib=(abs(ownbidq_cum)<=abs(NOIlong(kk)));
            posib=[1; posib(1:end-1)];
            ilisti=find(abs(ownbidq_cum)>=abs(NOIlong(kk)));
             if size(ilisti,1)>0
                ilisti=ilisti(1);
             end
            badcount=badcount+sum((coind==0).*(posib==0));
            invert_at=((coind==0).*(posib==1));
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if nopartflag==0
           Epcl=extrainfo{kk,1};
           dEpcl=extrainfo{kk,2};
           Prob=extrainfo{kk,3};
           dpq=extrainfo{kk,4}; dpp=extrainfo{kk,5}; dq=extrainfo{kk,6};
           dpq_2=extrainfo{kk,7}; dpp_2=extrainfo{kk,8}; dq_2=extrainfo{kk,9};

nlowo=nlow;
nupo=nup;
                 
                %plug in for v-estimates
                vup_pos=Epcl+((ownbidq_cum+nup)./Prob).*dEpcl;
                vup=Epcl+((ownbidq_cum+nlow)./Prob).*dEpcl;
                vup(dEpcl>0)=vup_pos(dEpcl>0);
             
                vlow_pos=Epcl+((ownbidq_cum+nlow)./Prob).*dEpcl;
                vlow=Epcl+((ownbidq_cum+nup)./Prob).*dEpcl;
                vlow(dEpcl>0)=vlow_pos(dEpcl>0);
                        
                vlow(dEpcl==0)=Epcl(dEpcl==0);
                vup(dEpcl==0)=Epcl(dEpcl==0);


                %if this is q>=total supply
                %we can get an upper bound by considering a perturbation in price--up one
                %price increment=0.125 which must not be optimal, limiting mv.
                for ii=1:size(ilisti,1)
                    if direction>0
                        vup(ilisti(ii))=(dpq(ilisti(ii))+(nup).*dpp(ilisti(ii)))./dq(ilisti(ii));
                        vlow(ilisti(ii))=(dpq_2(ilisti(ii))+(nlow).*dpp_2(ilisti(ii)))./dq_2(ilisti(ii));
                       
                    else
                        vlow(ilisti(ii))=(dpq(ilisti(ii))+(nup).*dpp(ilisti(ii)))./dq(ilisti(ii));
                        vup(ilisti(ii))=(dpq_2(ilisti(ii))+(nlow).*dpp_2(ilisti(ii)))./dq_2(ilisti(ii));                          
                    end
                end
           


                vlow(isinf(vlow))=NaN;
                vup(isinf(vup))=NaN;
               for ij=1:size(ilisti,1)
                    if direction>0
                        ii=ij;
                        if isnan(vup(ilisti(ii)))
                        if ilisti(ii)>1
                            if vlow(ilisti(ii)-1)<vmaxd
                        vup(ilisti(ii))=vup(ilisti(ii)-1);
                            else
                        vup(ilisti(ii))=vmaxd;
                            end
                        else
                            vup(ilisti(ii))=vmaxd;
                        end
                        end
                        if isnan(vlow(ilisti(ii)))
                        if ilisti(ii)<size(vup,1)
                            if vlow(ilisti(ii)+1)>vmind
                        vlow(ilisti(ii))=vlow(ilisti(ii)+1);
                            else
                                vlow(ilisti(ii))=vmaxd;
                            end
                        else
                            vlow(ilisti(ii))=vmaxd;
                        end
                        end                             
                    else
                        ii=size(ilisti,1)+1-ij;
                     if isnan(vup(ilisti(ii)))
                        if ilisti(ii)<size(vup,1)
                            if vup(ilisti(ii)+1)<vmaxd
                        vup(ilisti(ii))=vup(ilisti(ii)+1);
                            else
                                vup(ilisti(ii))=vmaxd;
                            end
                        else
                            vup(ilisti(ii))=vmaxd;
                        end
                     end
                      if isnan(vlow(ilisti(ii)))
                        if ilisti(ii)>1
                            if vlow(ilisti(ii)-1)>vmind
                        vlow(ilisti(ii))=vlow(ilisti(ii)-1);
                            else
                                vlow(ilisti(ii))=vmaxd;
                            end
                        else
                        vlow(ilisti(ii))=vmaxd;
                        end
                        end                     
                    end           
               end

            
    
                vlow(isnan(vlow))=vmind;
                vup(isnan(vup))=vmaxd;
                vlow(vlow<(vmind))=vmind;
                vup((vup)<(vmind))=vmind;
                vup((vup)>(vmaxd))=vmaxd;
                vlow(vlow>(vmaxd))=vmaxd;

                EsurpU=sum(cumsum((vup-Epcl).*Prob.*ownbidq)./ownbidq_cum);
                EsurpL=sum(cumsum((vlow-Epcl).*Prob.*ownbidq)./ownbidq_cum);

                vlow=vlow(invert_at==1);
                vup=vup(invert_at==1);


                %when the only info comes from the bounds--AND with only one step, all you can get out on v is the
                %bounds!
                vupo=vup;
                vlowo=vlow;
   
                if size(vlow,1)>1
                if direction>0
                    for ii=1:size(vlow,1)
                    vlow(ii,1)=max(vlow(ii:end));
                    vup(ii,1)=min(vup(1:ii));
                    end
                else
                     for ii=size(vlow,1):-1:1
                     vlow(ii,1)=max(vlow(1:ii));
                     vup(ii,1)=min(vup(ii:end));
                     end 
                end
                end
      
                qst1=sum(dEpcl(invert_at==1 & abs(ownbidq_cum)<abs(NOIlong(kk))).*nlow.*ownbidq(invert_at==1 & abs(ownbidq_cum)<abs(NOIlong(kk))))./sum(ownbidq(invert_at==1 & abs(ownbidq_cum)<abs(NOIlong(kk))));
                qst2=sum(dEpcl(invert_at==1 & abs(ownbidq_cum)<abs(NOIlong(kk))).*nup.*ownbidq(invert_at==1 & abs(ownbidq_cum)<abs(NOIlong(kk))))./sum(ownbidq(invert_at==1 & abs(ownbidq_cum)<abs(NOIlong(kk))));
                qst1(qst1>vmaxda)=vmaxda; qst1(qst1<vminda)=vminda;
                qst2(qst2>vmaxda)=vmaxda; qst2(qst2<vminda)=vminda;
                qshad(kk,:)=[min(qst1,qst2) max(qst1,qst2)];
           
            else %non-participating bidders
                qshad(kk,1)=0;qshad(kk,2)=0;
                %perturb their carried over q1, bid to a slightly larger quantity (adding
                %more demand)
                 if direction>0
   
                nlowo=nlow;
                nupo=nup;
                  
                    vlow=vmind; vup=vmaxd;
                    vlowo=vmind; vupo=vmaxd;
                    EsurpU=0; EsurpL=0;
                    nup=nupo; nlow=nlowo;
                else
   
                nlowo=nlow;
                nupo=nup;
                    nlowo(isnan(nlowo))=-nmax;
                    nupo(isnan(nupo))=0;
                    EsurpU=0; EsurpL=0;
                    vlow=vmind; vup=vmaxd;
                    vlowo=vmind; vupo=vmaxd;
                    nup=nupo; nlow=nlowo;
                end
            end
        end
    else
nlowo=nlow; nupo=nup;vlow=vmind; vup=vmaxd; imp=imm1cap(kk);
        invert_at=1; ownbidq_cum=0; ownbids=0; nopartflag=1;vlowo=vmind; vupo=vmaxd; EsurpU=0; EsurpL=0; Pclsample=imp;
        qshad(kk,1:2)=0;
    end
    if isempty(ownbidq_cum(invert_at==1))
        obqa=0;
        obpa=0;
    else
        obqa=ownbidq_cum(invert_at==1);
        obpa=ownbids(invert_at==1);
    end
vout=[vlow vup];
    nout(kk,:)=[nlow nup NOIlong(kk) nopartflag imm1cap(kk) imm(kk) size(vlow,1) EsurpL EsurpU mean(Pclsample) nlowo nupo];
    crossf=crossf+(nlowo>nupo);
nout=[nout qshad];

shad=qshad(kk,:);
