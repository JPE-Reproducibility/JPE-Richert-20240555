function [nbounds,extrainfo]=complex_estimator_step1(supplyp,supplyq,idfs,idss,ndraw,NOItotexp,noi,Npossibleexp,supplyp2, supplyq2, supplyp2oth, supplyq2oth, drawnids,trueaucidd,idsstrue,carriedoverp, carriedoverq,carriedoverpoth, carriedoverqoth,immcap2,NOIlong,eta,idfstrue,Bondvol,imm1cap,orig,maxSlope,prsel,imm)
maxSlope=0;
%set some global parameters:bounds tightness and grid points
ng=100;
rng(200)
entrybound=1;
sc_bound=10000;
carriedoverq(isnan(carriedoverq))=0;
carriedoverqoth(isnan(carriedoverqoth))=0;

badcount=0;
nmax=300;
vmaxda=8; %take p90 of the spread abs((imm1cap(kk)-imm(kk))) * 4
vminda=-8;
kft=size(idfs,1);

%First loop through the data: calculate value and position estimates%
for kk=1:kft

dpq=0; dpp=0; dq=0;
dpq_2=0; dpp_2=0; dq_2=0;
    
vmind=max(vminda+imm1cap(kk),0);
    vmaxd=min(vmaxda+imm1cap(kk),100);
    if NOItotexp(kk)~=0
        %%%the goal here is to resample over residual supply...
        %1. the Pr(bk<Pc<bk+1|play)
        %2. Expectation of Pc when its in the rangebk bk+1
        %3. dE[p when its in the range bk bk+1]/dqk
        direction=1.*(NOItotexp(kk)>0);
        direction(direction==0)=-1;
        %%%%ADD IN YOUR OWN BID!!!!!!
        [bidsp, ic]=sort(direction.*[reshape(supplyp2oth(drawnids{kk},:),ndraw,(Npossibleexp(kk)-1)*size(supplyp2,2)) repmat(supplyp(idss==idfs(kk))',ndraw,1) reshape(carriedoverpoth(drawnids{kk},:),ndraw,[])],2,'descend');
        bidsp=abs(bidsp);
        bidsq=[reshape(supplyq2oth(drawnids{kk},:),ndraw,(Npossibleexp(kk)-1)*size(supplyp2,2)) repmat(supplyq(idss==idfs(kk))',ndraw,1) direction.*reshape(carriedoverqoth(drawnids{kk},:),ndraw,[])];
        bidsq=bidsq(sub2ind(size(bidsp),repmat([1:1:size(ic,1)]',1,size(ic,2)),ic));
        if direction>0
            bidsq(bidsq<0)=0;
            bidsq(isnan(bidsq))=0;
        else
            bidsq(bidsq>0)=0;
            bidsq(isnan(bidsq))=0;
        end

        % calculate the clearing price
        if direction>0
            sma=[sign(direction).*ones(size(bidsq,1),1) sign(1-cumsum(bidsq,2))]; 
            [~,ic]=min((1-cumsum(bidsq,2))+1000*(sma(:,1:end-1)~=sign(direction)),[],2);
        else
            [~,ic]=min(abs(1+cumsum(bidsq,2))+1000*(sign(cumsum(bidsq,2)+1)==1),[],2);
        end
        Pclsample=bidsp(sub2ind(size(bidsp),[1:1:size(ic,1)]',ic));
        Epunc=mean(Pclsample);
        bidsqa=cumsum(bidsq,2);
        qclsample=bidsqa(sub2ind(size(bidsp),[1:1:size(ic,1)]',max(ic-1,1)));
        qclsample(ic==1)=0;

        Eqnn=mean(1./(1+(sum(bidsq.*(bidsp>=1),2))));
        if direction<0
            Eqnn=mean(-1./(-1+(sum(bidsq.*(bidsp>0).*(bidsp<=1),2))));
        end

        if direction>0
            [qrem,icq]=min((1-cumsum(bidsq,2))+10000*(cumsum(bidsq,2)>1),[],2);
        else
            [qrem,icq]=min((1+cumsum(bidsq,2))+10000*(1+cumsum(bidsq,2)>0),[],2);
            qrem_neg=(1+cumsum(bidsq,2));
            qrem=qrem_neg(sub2ind(size(bidsq),[1:1:size(bidsq,1)]',icq));
        end
        empdir=max(0.005,1./NOIlong(kk));

        %get clearing price if q+epsilon here bid instead
        if direction>0
            sma=[sign(direction).*ones(size(bidsq,1),1) sign((1-empdir)-cumsum(bidsq,2))]; 
            [~,icp]=min(((1-empdir)-cumsum(bidsq,2))+1000*(sma(:,1:end-1)~=sign(direction)),[],2);
        else
            [~,icp]=min(abs(1-empdir+cumsum(bidsq,2))+1000*(sign(cumsum(bidsq,2)+1-empdir)==1),[],2);
        end
        Pclsamplepl=bidsp(sub2ind(size(bidsp),[1:1:size(icp,1)]',icp));

        %adding 2 epsilon
        if direction>0
            sma=[sign(direction).*ones(size(bidsq,1),1) sign((1-2*empdir)-cumsum(bidsq,2))]; 
            [~,icpp]=min(((1-2*empdir)-cumsum(bidsq,2))+1000*(sma(:,1:end-1)~=sign(direction)),[],2);
        else
            [~,icpp]=min(abs(1-2*empdir+cumsum(bidsq,2))+1000*(sign(cumsum(bidsq,2)+1-2*empdir)==1),[],2);
        end
        Pclsampleplpl=bidsp(sub2ind(size(bidsp),[1:1:size(icp,1)]',icpp));

        %and instead subtracting epsilon...
        if direction>0
            sma=[sign(direction).*ones(size(bidsq,1),1) sign((1+empdir)-cumsum(bidsq,2))]; 
            [~,icm]=min(((1+empdir)-cumsum(bidsq,2))+1000*(sma(:,1:end-1)~=sign(direction)),[],2);
        else
            [~,icm]=min(abs(1+empdir+cumsum(bidsq,2))+1000*(sign(cumsum(bidsq,2)+1+empdir)==1),[],2);
        end
        Pclsamplem=bidsp(sub2ind(size(bidsp),[1:1:size(icm,1)]',icm));

        %subtracting 2 epsilon
        if direction>0
            sma=[sign(direction).*ones(size(bidsq,1),1) sign((1+2*empdir)-cumsum(bidsq,2))]; 
            [~,icmm]=min(((1+2*empdir)-cumsum(bidsq,2))+1000*(sma(:,1:end-1)~=sign(direction)),[],2);
        else
            [~,icmm]=min(abs(1+2*empdir+cumsum(bidsq,2))+1000*(sign(cumsum(bidsq,2)+1+2*empdir)==1),[],2);
        end
        Pclsamplemm=bidsp(sub2ind(size(bidsp),[1:1:size(icmm,1)]',icmm));

        %now get the clearing prices without i
        [bidsp, ic]=sort(direction.*[reshape(supplyp2oth(drawnids{kk},:),ndraw,(Npossibleexp(kk)-1)*size(supplyp2,2)) reshape(carriedoverpoth(drawnids{kk},:),ndraw,[])],2,'descend');
        bidsp=abs(bidsp);
        bidsq=[reshape(supplyq2oth(drawnids{kk},:),ndraw,(Npossibleexp(kk)-1)*size(supplyp2,2)) direction.*reshape(carriedoverqoth(drawnids{kk},:),ndraw,[])];
        bidsq=bidsq(sub2ind(size(bidsp),repmat([1:1:size(ic,1)]',1,size(ic,2)),ic));
        if direction>0
            bidsq(bidsq<0)=0;
            bidsq(isnan(bidsq))=0;
        else
            bidsq(bidsq>0)=0;
            bidsq(isnan(bidsq))=0;
        end
        % calculate the clearing price
        if direction>0
            sma=[sign(direction).*ones(size(bidsq,1),1) sign(1-cumsum(bidsq,2))];
            [~,ic]=min((1-cumsum(bidsq,2))+1000*(sma(:,1:end-1)~=sign(direction)),[],2);
        else
            [~,ic]=min(abs(1+cumsum(bidsq,2))+1000*(sign(cumsum(bidsq,2)+1)==1),[],2);
        end
        Pclsamplenobid=bidsp(sub2ind(size(bidsp),[1:1:size(ic,1)]',ic));
       %for rare draws where the market fails to clear without i's bid
        if direction>0
            Pclsamplenobid=min(Pclsamplenobid,Pclsample);
       else
        Pclsamplenobid=max(Pclsamplenobid,Pclsample);
       end

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
        epsilonp=0.125./imp;
        [bidsp, ic]=sort(direction.*[reshape(supplyp2oth(drawnids{kk},:),ndraw,(Npossibleexp(kk)-1)*size(supplyp2,2)) repmat(supplyp(idss==idfs(kk))',ndraw,1)+epsilonp.*(repmat(supplyp(idss==idfs(kk))',ndraw,1)~=0) reshape(carriedoverpoth(drawnids{kk},:),ndraw,[])],2,'descend');
        bidsp=abs(bidsp);
        bidsq=[reshape(supplyq2oth(drawnids{kk},:),ndraw,(Npossibleexp(kk)-1)*size(supplyp2,2)) repmat(supplyq(idss==idfs(kk))',ndraw,1) direction.*reshape(carriedoverqoth(drawnids{kk},:),ndraw,[])];
        bidsq=bidsq(sub2ind(size(bidsp),repmat([1:1:size(ic,1)]',1,size(ic,2)),ic));
        if direction>0
            bidsq(bidsq<0)=0;
            bidsq(isnan(bidsq))=0;
        else
            bidsq(bidsq>0)=0;
            bidsq(isnan(bidsq))=0;
        end
        % calculate the clearing price
        if direction>0
            sma=[sign(direction).*ones(size(bidsq,1),1) sign(1-cumsum(bidsq,2))]; 
            [~,icap]=min((1-cumsum(bidsq,2))+1000*(sma(:,1:end-1)~=sign(direction)),[],2);
        else
            [~,icap]=min(abs(1+cumsum(bidsq,2))+1000*(sign(cumsum(bidsq,2)+1)==1),[],2);
        end
        Pclsamplepl_price=bidsp(sub2ind(size(bidsp),[1:1:size(ic,1)]',icap));
        qclsamplepl_price=bidsqa(sub2ind(size(bidsp),[1:1:size(ic,1)]',max(icap-1,1)));
        qclsamplepl_price(icap==1)=0;
        %and minus epsilonp
        [bidsp, ic]=sort(direction.*[reshape(supplyp2oth(drawnids{kk},:),ndraw,(Npossibleexp(kk)-1)*size(supplyp2,2)) repmat(supplyp(idss==idfs(kk))',ndraw,1)-epsilonp.*(repmat(supplyp(idss==idfs(kk))',ndraw,1)~=0) reshape(carriedoverpoth(drawnids{kk},:),ndraw,[])],2,'descend');
        bidsp=abs(bidsp);
        bidsq=[reshape(supplyq2oth(drawnids{kk},:),ndraw,(Npossibleexp(kk)-1)*size(supplyp2,2)) repmat(supplyq(idss==idfs(kk))',ndraw,1) direction.*reshape(carriedoverqoth(drawnids{kk},:),ndraw,[])];
        bidsq=bidsq(sub2ind(size(bidsp),repmat([1:1:size(ic,1)]',1,size(ic,2)),ic));
        if direction>0
            bidsq(bidsq<0)=0;
            bidsq(isnan(bidsq))=0;
        else
            bidsq(bidsq>0)=0;
            bidsq(isnan(bidsq))=0;
        end
        % calculate the clearing price
        if direction>0
            sma=[sign(direction).*ones(size(bidsq,1),1) sign(1-cumsum(bidsq,2))];
            [~,icap]=min((1-cumsum(bidsq,2))+1000*(sma(:,1:end-1)~=sign(direction)),[],2);
        else
            [~,icap]=min(abs(1+cumsum(bidsq,2))+1000*(sign(cumsum(bidsq,2)+1)==1),[],2);
        end
        bidsqa=cumsum(bidsq,2);
        Pclsamplem_price=bidsp(sub2ind(size(bidsp),[1:1:size(ic,1)]',icap));
        qclsamplem_price=bidsqa(sub2ind(size(bidsp),[1:1:size(ic,1)]',max(icap-1,1)));
        qclsamplem_price(icap==1)=0;

%get own bids
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
            if isempty(ownbids)==1 
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
            Pclsample=Pclsample.*imp;
            Pclsamplenobid=Pclsamplenobid.*imp;
            Pclsamplepl=Pclsamplepl.*imp;
            Pclsampleplpl=Pclsampleplpl.*imp;
            Pclsamplem=Pclsamplem.*imp;
            Pclsamplemm=Pclsamplemm.*imp;
            Pclsamplem_price=Pclsamplem_price.*imp;
            Pclsamplepl_price=Pclsamplepl_price.*imp;
            ownbidq_cum=cumsum(ownbidq);

            posib=(abs(ownbidq_cum)<=abs(NOIlong(kk)));
            posib=[1; posib(1:end-1)];
            badcount=badcount+sum((coind==0).*(posib==0));
            invert_at=((coind==0).*(posib==1));
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if nopartflag==0
                %calculate probabilities and derivative
                %loop through ownbids, get each step
                clear Prob Epcl dEpcl Epclpl dEpclpl dEpclm dEpclplpl dEpclmm dProb dEpcond Epclplpl Epclmm Epclm Probpl Probm Probplpl Probmm
                bwp=1.06*max(0.01,std(Pclsample))*max(size(Pclsample))^(-1./5);
                bwp=max(bwp,1.4826*max(0.01,median(abs(Pclsample-median(Pclsample))))*(4/(3*max(size(Pclsample))))^(1./5));
                bwpm=1.06*max(0.01,std(Pclsamplem))*max(size(Pclsamplem))^(-1./5);
                bwpm=max(bwpm,1.4826*max(0.01,median(abs(Pclsamplem-median(Pclsamplem))))*(4/(3*max(size(Pclsamplem))))^(1./5));
                bwpp=1.06*max(0.01,std(Pclsamplepl))*max(size(Pclsamplepl))^(-1./5);
                bwpp=max(bwpp,1.4826*max(0.01,median(abs(Pclsamplepl-median(Pclsamplepl))))*(4/(3*max(size(Pclsamplepl))))^(1./5));
                bwppp=1.06*max(0.01,std(Pclsampleplpl))*max(size(Pclsampleplpl))^(-1./5);
                bwppp=max(bwppp,1.4826*max(0.01,median(abs(Pclsampleplpl-median(Pclsampleplpl))))*(4/(3*max(size(Pclsampleplpl))))^(1./5));
                bwpmm=1.06*max(0.01,std(Pclsamplemm))*max(size(Pclsamplemm))^(-1./5);
                bwpmm=max(bwpmm,1.4826*max(0.01,median(abs(Pclsamplemm-median(Pclsamplemm))))*(4/(3*max(size(Pclsamplemm))))^(1./5));

                for aa=1:size(ownbids,1)
                    if aa<size(ownbids,1)
                        Prob(aa,1)=abs((1./max(size(Pclsample))).*sum(normcdf((ownbids(aa)-Pclsample)./bwp))-(1./max(size(Pclsample))).*sum(normcdf((ownbids(aa+1)-Pclsample)./bwp)));
                        if direction<0
                            Prob(aa,1)=(1-(1./max(size(Pclsample))).*sum(normcdf((ownbids(aa)-Pclsample)./bwp)))-(1-(1./max(size(Pclsample))).*sum(normcdf((ownbids(aa+1)-Pclsample)./bwp)));
                        end

                        %set a grid between this point and the next point-integrate for Ep
                        pgrid=linspace(ownbids(aa+1),ownbids(aa),10);
                        if direction<0
                            pgrid=linspace(ownbids(aa),ownbids(aa+1),10);
                        end
                        Epcl(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsample))*bwp)).*(sum(normpdf((pgrid-Pclsample)./bwp)))))./abs(trapz(pgrid,(1./(max(size(Pclsample))*bwp)).*(sum(normpdf((pgrid-Pclsample)./bwp)))));
                        Epclpl(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsamplepl))*bwpp)).*(sum(normpdf((pgrid-Pclsamplepl)./bwpp)))))./abs(trapz(pgrid,(1./(max(size(Pclsamplepl))*bwpp)).*(sum(normpdf((pgrid-Pclsamplepl)./bwpp)))));

                        Prob(aa,1)=abs((1./max(size(Pclsample))).*sum(normcdf((ownbids(aa)-Pclsample)./bwp))-(1./max(size(Pclsample))).*sum(normcdf((ownbids(aa+1)-Pclsample)./bwp)));

                      %five point star no decomposition
                        dEpp(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsampleplpl))*bwppp)).*(sum(normpdf((pgrid-Pclsampleplpl)./bwppp)))));
                        dEp(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsamplepl))*bwpp)).*(sum(normpdf((pgrid-Pclsamplepl)./bwpp)))));
                        dEm(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsamplem))*bwpm)).*(sum(normpdf((pgrid-Pclsamplem)./bwpm)))));
                        dEmm(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsamplemm))*bwpmm)).*(sum(normpdf((pgrid-Pclsamplemm)./bwpmm)))));
                        dEpcl(aa,1)=(-dEpp(aa,1)+8*dEp(aa,1)-8*dEm(aa,1)+dEmm(aa,1))./(12.*empdir.*(abs(NOIlong(kk))));
         
                    else
                        if direction<=0
                            pgrid=linspace(ownbids(aa),max(ownbids(aa)+0.01,max(Pclsample)),10);
                            Epcl(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsample))*bwp)).*(sum(normpdf((pgrid-Pclsample)./bwp)))))./abs(trapz(pgrid,(1./(max(size(Pclsample))*bwp)).*(sum(normpdf((pgrid-Pclsample)./bwp)))));
                            Prob(aa,1)=abs(trapz(pgrid,(1./(max(size(Pclsample))*bwp)).*(sum(normpdf((pgrid-Pclsample)./bwp)))));

                            Probpl(aa,1)=abs(trapz(pgrid,(1./(max(size(Pclsamplepl))*bwpp)).*(sum(normpdf((pgrid-Pclsamplepl)./bwpp)))));
                            Epclpl(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsamplepl))*bwpp)).*(sum(normpdf((pgrid-Pclsamplepl)./bwpp)))))./abs(trapz(pgrid,(1./(max(size(Pclsamplepl))*bwpp)).*(sum(normpdf((pgrid-Pclsamplepl)./bwpp)))));
                        
                            %five point star no decomposition
                            dEpp(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsampleplpl))*bwppp)).*(sum(normpdf((pgrid-Pclsampleplpl)./bwppp)))));
                            dEp(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsamplepl))*bwpp)).*(sum(normpdf((pgrid-Pclsamplepl)./bwpp)))));
                            dEm(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsamplem))*bwpm)).*(sum(normpdf((pgrid-Pclsamplem)./bwpm)))));
                            dEmm(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsamplemm))*bwpmm)).*(sum(normpdf((pgrid-Pclsamplemm)./bwpmm)))));
                            dEpcl(aa,1)=(-dEpp(aa,1)+8*dEp(aa,1)-8*dEm(aa,1)+dEmm(aa,1))./(12.*empdir.*(abs(NOIlong(kk))));
                        else
                            pgrid=linspace(min(ownbids(aa)-0.1,min(Pclsamplem)),ownbids(aa),10);
                            Epcl(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsample))*bwp)).*(sum(normpdf((pgrid-Pclsample)./bwp)))))./abs(trapz(pgrid,(1./(max(size(Pclsample))*bwp)).*(sum(normpdf((pgrid-Pclsample)./bwp)))));
                            Prob(aa,1)=abs(trapz(pgrid,(1./(max(size(Pclsample))*bwp)).*(sum(normpdf((pgrid-Pclsample)./bwp)))));


                            Probpl(aa,1)=abs(trapz(pgrid,(1./(max(size(Pclsamplepl))*bwpp)).*(sum(normpdf((pgrid-Pclsamplepl)./bwpp)))));
                            Epclpl(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsamplepl))*bwpp)).*(sum(normpdf((pgrid-Pclsamplepl)./bwpp)))))./abs(trapz(pgrid,(1./(max(size(Pclsamplepl))*bwpp)).*(sum(normpdf((pgrid-Pclsamplepl)./bwpp)))));
                          
                          
                            %five point star no decomposition
                            dEpp(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsampleplpl))*bwppp)).*(sum(normpdf((pgrid-Pclsampleplpl)./bwppp)))));
                            dEp(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsamplepl))*bwpp)).*(sum(normpdf((pgrid-Pclsamplepl)./bwpp)))));
                            dEm(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsamplem))*bwpm)).*(sum(normpdf((pgrid-Pclsamplem)./bwpm)))));
                            dEmm(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsamplemm))*bwpmm)).*(sum(normpdf((pgrid-Pclsamplemm)./bwpmm)))));
                            dEpcl(aa,1)=(-dEpp(aa,1)+8*dEp(aa,1)-8*dEm(aa,1)+dEmm(aa,1))./(12.*empdir.*(abs(NOIlong(kk))));


                        end
                    end
                    if isnan(Epcl(aa,1))
                        Epcl(aa,1)=ownbids(aa);
                    end
                end


                %build various n-estimates--starting boundedness bounds
  %              if direction>0
                    nbu_pos=Prob.*(vmaxd-Epcl)./dEpcl-ownbidq_cum;
                    nbu=Prob.*(vmind-Epcl)./dEpcl-ownbidq_cum;
                    nbu(dEpcl>0)=nbu_pos(dEpcl>0);

                    nbl_pos=Prob.*(vmind-Epcl)./dEpcl-ownbidq_cum;
                    nbl=Prob.*(vmaxd-Epcl)./dEpcl-ownbidq_cum;
                    nbl(dEpcl>0)=nbl_pos(dEpcl>0);
                  

                    nbuo=nbu; nblo=nbl;
                %remove any non-eligible steps
                nbu=nbu(invert_at==1 & abs(ownbidq_cum)<abs(NOIlong(kk)));
                nbl=nbl(invert_at==1 & abs(ownbidq_cum)<abs(NOIlong(kk)));
                sab=size(nbu,1);
                
        
                %find any steps with qk<NOI, and with p above floor/below
                %cap: take a price deviation as well--move that whole step
                %up/down one
                if direction>0
                ilistia=find(abs(ownbidq_cum)<abs(NOIlong(kk)) & ownbids+epsilonp<=imm1cap(kk));
                for aba=1:size(ilistia,1)
                    aa=ilistia(aba); 
                  
                   %we can decompose the equation from the body into extra
                   %payments on units (1-qk) (average price change conditional on p'<=epsilon+bk) and the extra
                   %surplus-payments for the extra units won...since both
                   %bounds are looser in n-units use qk instead of qcl. qk*E[(\bar{v} - (Price-postpert)). x 1(in the interval bk>p^c'>bk+1)]. 
                   
                   %lowest possible additional gain from buying more units
                       ugain=ownbidq(aa).*mean((min(vmind,ownbids(aa))-Pclsamplepl_price).*normcdf((Pclsample-ownbids(aa))./bwp).*normcdf((ownbids(aa)+epsilonp-Pclsample)./bwp));
                   %lowest possible loss from buying less units
                       ugainU=-ownbidq(aa).*mean((max(vmaxd,ownbids(aa))-Pclsample).*normcdf((ownbids(aa)-Pclsample)./bwp).*normcdf((Pclsample-(ownbids(aa)-epsilonp))./bwp));
                   %price impact on existing bonds
                   if aa>1
                   bchange=-ownbidq_cum(aa-1).*mean((Pclsamplepl_price-Pclsample).*normcdf((Pclsample-ownbids(aa))./bwp).*normcdf((ownbids(aa)+epsilonp-Pclsample)./bwp));
                   bchangeU=-ownbidq_cum(aa-1).*mean((Pclsamplem_price-Pclsample).*normcdf((ownbids(aa)-Pclsample)./bwp).*normcdf((Pclsample-(ownbids(aa)-epsilonp))./bwp));
                   else
                   bchange=0; bchangeU=0;
                   end   
                         nblt=(ugain+bchange)./(mean((Pclsamplepl_price-Pclsample).*normcdf((Pclsample-ownbids(aa))./bwp).*normcdf((ownbids(aa)+epsilonp-Pclsample)./bwp)));
                         nbut=(ugainU+bchangeU)./(mean((Pclsamplem_price-Pclsample).*normcdf((ownbids(aa)-Pclsample)./bwp).*normcdf((Pclsample-(ownbids(aa)-epsilonp))./bwp)));
                        nbl=[nbl;nblt];
                        nbu=[nbu;nbut];
                end

                else
                     ilistia=find(abs(ownbidq_cum)<abs(NOIlong(kk)) & ownbids+epsilonp>=imm1cap(kk));
                   for aba=1:size(ilistia,1)
                    aa=ilistia(aba); 
                    
                   %biggest possible loss from selling less units
                       ugain=-ownbidq(aa).*mean((min(vmind,ownbids(aa))-Pclsample).*normcdf((Pclsample-ownbids(aa))./bwp).*normcdf((ownbids(aa)+epsilonp-Pclsample)./bwp));
                   %lowest possible gain from selling more units
                       ugainU=ownbidq(aa).*mean((max(vmaxd,ownbids(aa))-Pclsamplem_price).*normcdf((ownbids(aa)-Pclsample)./bwp).*normcdf((Pclsample-(ownbids(aa)-epsilonp))./bwp));
                   %note: plug in max(vmaxd,ownbids(aa)) is a relaxation of
                   %the bound in rare cases bidders bid above vmaxd, so to
                   %avoid giving undo weight to such bids in determining
                   %position, I take the more conservative bound.
                       
                   %price impact on existing bonds: price changes only when
                   %the original clearing price is in b_k+epsilon\geq P^c \geq b_k or  b_k-epsilon\leq P^c \leq b_k
                   if aa>1
                   bchange=-ownbidq_cum(aa-1).*mean((Pclsamplepl_price-Pclsample).*normcdf((Pclsample-ownbids(aa))./bwp).*normcdf((ownbids(aa)+epsilonp-Pclsample)./bwp));
                   bchangeU=-ownbidq_cum(aa-1).*mean((Pclsamplem_price-Pclsample).*normcdf((ownbids(aa)-Pclsample)./bwp).*normcdf((Pclsample-(ownbids(aa)-epsilonp))./bwp));
                   else
                   bchange=0; bchangeU=0;
                   end

                        nblt=(ugain+bchange)./(mean((Pclsamplepl_price-Pclsample).*normcdf((ownbids(aa)-Pclsample)./bwp).*normcdf((Pclsample-(ownbids(aa)-epsilonp))./bwp)));
                        nbut=(ugainU+bchangeU)./(mean((Pclsamplem_price-Pclsample).*normcdf((ownbids(aa)-Pclsample)./bwp).*normcdf((Pclsample-(ownbids(aa)-epsilonp))./bwp)));
                       
                        nbl=[nbl;nblt];
                        nbu=[nbu;nbut];
               
                end

                end

             
                %when abs(ownbidq_cum)>=abs(NOIlong(kk)...augment nbl,nbu
                %from price pert.- but later remove the parts associated
                %with multiple steps
                ilisti=find(abs(ownbidq_cum)>=abs(NOIlong(kk)));
                if size(ilisti,1)>0
                ilisti=ilisti(1);
                end
                flnan1=zeros(size(ownbidq_cum));flnan2=zeros(size(ownbidq_cum));
                
                for ii=1:size(ilisti,1)
                    %to get the rationed quantity we can subtract the excess at the
                    %clearing price from ownbidq (since we assumed away ties).
                    if direction>0
                    qddp=max(min(ownbidq(ilisti(ii)),-(qclsamplepl_price-1).*NOIlong(kk)),0);
                    qdd=max(min(ownbidq(ilisti(ii)),-(qclsample-1).*NOIlong(kk)),0);
                    qddp(qddp<qdd)=qdd(qddp<qdd); %for the soft averaging this is more accurate since any variation this way would be due to earlier steps
                    else
                    qddp=min(max(ownbidq(ilisti(ii)),(qclsamplepl_price+1).*NOIlong(kk)),0);
                    qdd=min(max(ownbidq(ilisti(ii)),(qclsample+1).*NOIlong(kk)),0);
                    qddp(qddp>qdd)=qdd(qddp>qdd);
                    end
                    qd=qddp-qdd;
                    qpd=qddp.*Pclsamplepl_price-qdd.*Pclsample;
                    ppd=Pclsamplepl_price-Pclsample;
                    bwdp=bwp;

                    dq(ilisti(ii))=sum(qd(Pclsample>=ownbids(ilisti(ii)).*normcdf(((ownbids(ilisti(ii))+epsilonp.*imp)-Pclsample)./bwdp)))./sum(normcdf(((ownbids(ilisti(ii))+epsilonp.*imp)-Pclsample)./bwdp));
                    dpq(ilisti(ii))=sum(qpd(Pclsample>=ownbids(ilisti(ii)).*normcdf(((ownbids(ilisti(ii))+epsilonp.*imp)-Pclsample)./bwdp)))./sum(normcdf(((ownbids(ilisti(ii))+epsilonp.*imp)-Pclsample)./bwdp));
                    dpp(ilisti(ii))=sum(ppd(Pclsample>=ownbids(ilisti(ii)).*normcdf(((ownbids(ilisti(ii))+epsilonp.*imp)-Pclsample)./bwdp)))./sum(normcdf(((ownbids(ilisti(ii))+epsilonp.*imp)-Pclsample)./bwdp));

                    if isnan(dpp(ilisti(ii)))
                        flnan1(ilisti(ii))=1;                   
                        %we know the buyer would never put a bid with no
                        %probability of clearing. therefore sometimes this
                        %cleared at bk and now would at bk+epsilonp.*imp change
                        %in q--we can bound: (0,deltaqk).
                    dpp(ilisti(ii))=epsilonp.*imp; dq(ilisti(ii))=0; dpq(ilisti(ii))=0;
                    dpp_l(ilisti(ii))=epsilonp.*imp; dq_l(ilisti(ii))=ownbidq(ilisti(ii)); dpq_l(ilisti(ii))=epsilonp.*imp.*ownbidq(ilisti(ii));
                    end
                    if direction>0
                    qddm=max(min(ownbidq(ilisti(ii)),-(qclsamplem_price-1).*NOIlong(kk)),0);
                    qdd=max(min(ownbidq(ilisti(ii)),-(qclsample-1).*NOIlong(kk)),0);
                    qddm(qddm>qdd)=qdd(qddm>qdd);
                    else
                    qddm=min(max(ownbidq(ilisti(ii)),(1+qclsamplem_price).*NOIlong(kk)),0);
                    qdd=min(max(ownbidq(ilisti(ii)),(1+qclsample).*NOIlong(kk)),0);
                     qddm(qddm<qdd)=qdd(qddm<qdd);
                    end
                    qd=qddm-qdd;
                    qpd=qddm.*Pclsamplem_price-qdd.*Pclsample;
                    ppd=Pclsamplem_price-Pclsample;
                    dq_2(ilisti(ii))=sum(qd(Pclsample>=ownbids(ilisti(ii)).*normcdf((-(ownbids(ilisti(ii))-epsilonp.*imp)+Pclsample)./bwdp)))./sum(normcdf((-(ownbids(ilisti(ii))-epsilonp.*imp)+Pclsample)./bwdp));
                    dpq_2(ilisti(ii))=sum(qpd(Pclsample>=ownbids(ilisti(ii)).*normcdf((-(ownbids(ilisti(ii))-epsilonp.*imp)+Pclsample)./bwdp)))./sum(normcdf((-(ownbids(ilisti(ii))-epsilonp.*imp)+Pclsample)./bwdp));
                    dpp_2(ilisti(ii))=sum(ppd(Pclsample>=ownbids(ilisti(ii)).*normcdf((-(ownbids(ilisti(ii))-epsilonp.*imp)+Pclsample)./bwdp)))./sum(normcdf((-(ownbids(ilisti(ii))-epsilonp.*imp)+Pclsample)./bwdp));

                    if isnan(dpp_2(ilisti(ii)))
                    flnan2(ilisti(ii))=1;
                    dpp_2(ilisti(ii))=-epsilonp.*imp; dq_2(ilisti(ii))=0; dpq_2(ilisti(ii))=0;
                    dpp_2l(ilisti(ii))=-epsilonp.*imp; dq_2l(ilisti(ii))=-ownbidq(ilisti(ii)); dpq_2l(ilisti(ii))=imp.*epsilonp.*ownbidq(ilisti(ii));
                    end
                    
                    if direction>0
                        nm_bl=(vmind.*dq(ilisti(ii))-dpq(ilisti(ii)))./dpp(ilisti(ii));
                        nm_bu=(vmaxd.*dq_2(ilisti(ii))-dpq_2(ilisti(ii)))./dpp_2(ilisti(ii));
                         if flnan1(ilisti(ii))==1
                            nm_bl=min(nm_bl,(vmind.*dq_l(ilisti(ii))-dpq_l(ilisti(ii)))./dpp_l(ilisti(ii)));
                        elseif flnan2(ilisti(ii))==1
                            nm_bu=max(nm_bu,(vmaxd.*dq_2l(ilisti(ii))-dpq_2l(ilisti(ii)))./dpp_2l(ilisti(ii)));
                        end
                       
                    else
                       
                        nm_bl=(vmaxd.*dq(ilisti(ii))-dpq(ilisti(ii)))./dpp(ilisti(ii));
                        nm_bu=(vmind.*dq_2(ilisti(ii))-dpq_2(ilisti(ii)))./dpp_2(ilisti(ii));
                    if flnan1(ilisti(ii))==1
                            nm_bl=min(nm_bl,(vmaxd.*dq_l(ilisti(ii))-dpq_l(ilisti(ii)))./dpp_l(ilisti(ii)));
                       elseif flnan2(ilisti(ii))==1
                            nm_bu=max(nm_bu,(vmind.*dq_2l(ilisti(ii))-dpq_2l(ilisti(ii)))./dpp_2l(ilisti(ii)));
                       end
                    end
                    nbu=[nbu;nm_bu];
                    nbl=[nbl;nm_bl];
                end
                
        
     
                  
                %remove nan--uninformative
                nbl(isnan(nbl))=-nmax;
                nbu(isnan(nbu))=nmax;

                if max(size(ownbids))>1
                    %now build monotonicity bounds
                    for ii=1:max(size(ownbids))-1
                        for jj=ii+1
                            if invert_at(ii)==1 & invert_at(jj)==1 & abs(ownbidq_cum(ii))<abs(NOIlong(kk)) & abs(ownbidq_cum(jj))<abs(NOIlong(kk))
                                tdel=(dEpcl(jj)./Prob(jj))-(dEpcl(ii)./Prob(ii));
                                if tdel>0
                                    %you plug in -maxSlope here since
                                    %maxslope variable stores
                                    %|maxslope|--don't do this since it
                                    %would be a bound on the minimum slope!
                                    if direction>=0
                                    nut=((Epcl(ii)-Epcl(jj))-(ownbidq_cum(jj).*dEpcl(jj)./Prob(jj))+(ownbidq_cum(ii).*dEpcl(ii)./Prob(ii)))./tdel;                                  
                                    nbu=[nbu;nut];
                                    nbl=[nbl; nblo(ii)];
                                    end
                                    if direction<0
                                    %when direction is negative, we have to
                                    %switch tdel=-tdel: since monotonicity is still left to right but the points are swapped in ii,jj space. this introduces the
                                    %negtive sign here
                                    nlt=-((Epcl(jj)-Epcl(ii))-(ownbidq_cum(ii).*dEpcl(ii)./Prob(ii))+(ownbidq_cum(jj).*dEpcl(jj)./Prob(jj)))./tdel;
                                    nbl=[nbl;nlt];
                                    nbu=[nbu; nbuo(ii)];
                                    end
                                    
                                elseif tdel<0
                                    if direction>=0
                                    nlt=((Epcl(ii)-Epcl(jj))-(ownbidq_cum(jj).*dEpcl(jj)./Prob(jj))+(ownbidq_cum(ii).*dEpcl(ii)./Prob(ii)))./tdel;                                   
                                    nbu=[nbu; nbuo(ii)];
                                    nbl=[nbl;nlt];
                                    end
                                    if direction<0
                                          nut=-((Epcl(jj)-Epcl(ii))-(ownbidq_cum(ii).*dEpcl(ii)./Prob(ii))+(ownbidq_cum(jj).*dEpcl(jj)./Prob(jj)))./tdel;
                                          nbu=[nbu;nut];
                                          nbl=[nbl; nblo(ii)];
                                    end
                                    
                                else
                                    nbu=[nbu;nmax];
                                    nbl=[nbl;-nmax];
                                end
                            end
                        end
                    end
                end


                %Finally, add the restrictions for not cornering the mkt at floor/ceiling being optimal AND
                %entry
                pceil=imp;
                pfloor=imp;
                if direction>0
                    nblt=(sum((vmind).*(Prob).*ownbidq)-vmind.*(NOIlong(kk).*Eqnn)-sum(Epcl.*Prob.*ownbidq)+pceil.*NOIlong(kk).*Eqnn)./(mean(Pclsample)-pceil);                  
                     %anyone with a large sell position would buy all
                    nbut=(sum((vmaxd-Epcl).*Prob.*ownbidq))./(mean(Pclsample)-mean(Pclsamplenobid));
                    if (mean(Pclsample)-mean(Pclsamplenobid))==0
                        nbut=nmax;
                    end
                    %any buyer would stay home
                    nbl=[nbl;nblt];
                    nbu=[nbu;nbut];
                else
                    nbut=(sum((vmaxd).*(Prob).*ownbidq)-vmaxd.*(NOIlong(kk).*Eqnn)-sum(Epcl.*Prob.*ownbidq)+pfloor.*NOIlong(kk).*Eqnn)./(mean(Pclsample)-pfloor);
                    %Anyone with a large position would prefer to sell all
                    %at the floor pushing prices down
                    nbu=[nbu;nbut];
                    nblt=(sum((vmind-Epcl).*Prob.*ownbidq))./(mean(Pclsample)-mean(Pclsamplenobid));
                    if (mean(Pclsample)-mean(Pclsamplenobid))==0
                        nblt=-nmax;
                    end
                    nbl=[nbl;nblt];                                        
                end


                if isempty(nbl)
                    nbl=-nmax;
                end
                if isempty(nbu)
                    nbu=nmax;
                end

           extrainfo{kk,1}=Epcl;
           extrainfo{kk,2}=dEpcl;
           extrainfo{kk,3}=Prob;
           try
           extrainfo{kk,4}=dpq; extrainfo{kk,5}=dpp; extrainfo{kk,6}=dq;
           extrainfo{kk,7}=dpq_2; extrainfo{kk,8}=dpp_2; extrainfo{kk,9}=dq_2;
           extrainfo{kk,10}=Pclsample;
           end

             

            else %non-participating bidders
                extrainfo{kk,10}=Pclsample;
              
                %perturb their carried over q1, bid to a slightly larger quantity (adding
                %more demand)
                aa=1;
                clear Prob Epcl Probpl Epclpl
                if direction>0
                    bwp=1.06*max(0.01,std(Pclsample))*max(size(Pclsample))^(-1./5);
                    Prob(aa,1)=(1./max(size(Pclsample))).*sum(normcdf((ownbids(aa)-Pclsample)./bwp));
                    pgrid=linspace(ownbids(aa),min(ownbids(aa)-1e-5,min(Pclsample)),10);
                    Epcl(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsample))*bwp)).*(sum(normpdf((pgrid-Pclsample)./bwp)))))./abs(trapz(pgrid,(1./(max(size(Pclsample))*bwp)).*(sum(normpdf((pgrid-Pclsample)./bwp)))));

                    Probpl(aa,1)=(1./max(size(Pclsamplepl))).*sum(normcdf((ownbids(aa)-Pclsamplepl)./bwp));
                    pgrid=linspace(ownbids(aa),min(ownbids(aa)-1e-5,min(Pclsamplepl)),10);
                    Epclpl(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsamplepl))*bwp)).*(sum(normpdf((pgrid-Pclsamplepl)./bwp)))))./abs(trapz(pgrid,(1./(max(size(Pclsamplepl))*bwp)).*(sum(normpdf((pgrid-Pclsamplepl)./bwp)))));

                    noadj=(ownbidq(aa)).*(vmind).*Prob-Epcl.*(ownbidq(aa)).*Prob;
                    adjout=(ownbidq(aa)+empdir.*NOIlong(kk)).*(vmind).*Probpl-Epclpl.*(ownbidq(aa)+empdir.*NOIlong(kk)).*Probpl;
                    nlowo=min(max(((adjout-noadj))./(mean(Pclsamplepl)-mean(Pclsample)),0),nmax);
                    nupo=nmax;
                    nlowo(isnan(nlowo))=0;
                    nupo(isnan(nupo))=nmax;
                    nbl=nlowo;
                    nbu=nmax;
                    vlow=vmind; vup=vmaxd;
                    vlowo=vmind; vupo=vmaxd;
                    EsurpU=0; EsurpL=0;
                    nup=nupo; nlow=nlowo;
                else
                    bwp=1.06*max(0.01,std(Pclsample))*max(size(Pclsample))^(-1./5);
                    Prob(aa,1)=(1./max(size(Pclsample))).*sum(normcdf((ownbids(aa)-Pclsample)./bwp));
                    Prob(aa,1)=1-Prob(aa,1);
                    pgrid=linspace(ownbids(aa),max(ownbids(aa)+1e-5,max(Pclsample)),10);
                    Epcl(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsample))*bwp)).*(sum(normpdf((pgrid-Pclsample)./bwp)))))./abs(trapz(pgrid,(1./(max(size(Pclsample))*bwp)).*(sum(normpdf((pgrid-Pclsample)./bwp)))));

                    Probpl(aa,1)=(1./max(size(Pclsamplepl))).*sum(normcdf((ownbids(aa)-Pclsamplepl)./bwp));
                    Probpl(aa,1)=1-Probpl(aa,1);
                    pgrid=linspace(ownbids(aa),max(ownbids(aa)+1e-5,max(Pclsamplepl)),10);
                    Epclpl(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsamplepl))*bwp)).*(sum(normpdf((pgrid-Pclsamplepl)./bwp)))))./abs(trapz(pgrid,(1./(max(size(Pclsamplepl))*bwp)).*(sum(normpdf((pgrid-Pclsamplepl)./bwp)))));

                    noadj=(ownbidq(aa)).*(vmaxd).*Prob-Epcl.*(ownbidq(aa)).*Prob;
                    adjout=(ownbidq(aa)+empdir.*NOIlong(kk)).*(vmaxd).*Probpl-Epclpl.*(ownbidq(aa)+empdir.*NOIlong(kk)).*Probpl;
                    nbu=max(min(0,((adjout-noadj))./(mean(Pclsamplepl)-mean(Pclsample))),-nmax);
                   nbl=-nmax;
                    
          
                end
            end
        end
    else
        nbl=-nmax;
        nbu=nmax;
    end
    nbounds{kk,1}=nbl;
    nbounds{kk,2}=nbu;

 end
