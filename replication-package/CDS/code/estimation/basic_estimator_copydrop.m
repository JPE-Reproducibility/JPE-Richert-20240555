function [vout,nout]=basic_estimator_copydrop(supplyp,supplyq,idfs,idss,ndraw,NOItotexp,noi,Npossibleexp,supplyp2, supplyq2,drawnids,trueaucidd,idsstrue,carriedoverp, carriedoverq,immcap2,NOIlong,eta,idfstrue,Bondvol,imm1cap,orig,maxSlope,prsel,imm,drop)
maxSlope=0;
%set some global parameters:bounds tightness and grid points
ng=100;
rng(200)
entrybound=1;
sc_bound=10000;
carriedoverq(isnan(carriedoverq))=0;

rhoM=0.02;
badcount=0;
crossf=0;crossfd=0;
countbad=0; countgood=0;
countminmax=0;
tiehere=[];
tienext=[];
nmax=300;

kft=size(idfs,1);
%store original input matricies so that resampling restrictions don't
%overwrite
supplypt=supplyp;
supplyqt=supplyq;
supplyp2t=supplyp2;
supplyq2t=supplyq2;
carriedqt=carriedoverq;
carriedpt=carriedoverp;

%First loop through the data: calculate value and position estimates%
for kk=1:kft
vmaxda=abs((imm1cap(kk)-imm(kk))) * 2*4;
vminda=-abs((imm1cap(kk)-imm(kk))) * 2*4;

    vmind=max(vminda+imm1cap(kk),0);
    vmaxd=min(vmaxda+imm1cap(kk),100);
    if NOItotexp(kk)~=0
        %%%the goal here is to resample over residual supply.
        %1. the Pr(bk<Pc<bk+1|play)
        %2. Expectation of Pc when its in the rangebk bk+1
        %3. dE[p when its in the range bk bk+1]/dqk
        direction=1.*(NOItotexp(kk)>0);
        direction(direction==0)=-1;
        %%%%ADD IN YOUR OWN BID!!!!!!
        [bidsp, ic]=sort(direction.*[reshape(supplyp2(drawnids{kk},:),ndraw,(Npossibleexp(kk)-1)*size(supplyp2,2)) repmat(supplyp(idss==idfs(kk))',ndraw,1) reshape(carriedoverp(drawnids{kk},:),ndraw,[])],2,'descend');
        bidsp=abs(bidsp);
        bidsq=[reshape(supplyq2(drawnids{kk},:),ndraw,(Npossibleexp(kk)-1)*size(supplyp2,2)) repmat(supplyq(idss==idfs(kk))',ndraw,1) direction.*reshape(carriedoverq(drawnids{kk},:),ndraw,[])];
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
            [~,ic]=min(abs(1+cumsum(bidsq,2))+1000*(sign(cumsum(bidsq,2)+1)~=sign(direction)),[],2);
        end
        Pclsample=bidsp(sub2ind(size(bidsp),[1:1:size(ic,1)]',ic));
        Epunc=mean(Pclsample);
        bidsqa=cumsum(bidsq,2);
        qclsample=bidsqa(sub2ind(size(bidsp),[1:1:size(ic,1)]',ic));


        if direction>0
            [qrem,icq]=min((1-cumsum(bidsq,2))+10000*(cumsum(bidsq,2)>1),[],2);
        else
            [qrem,icq]=min((1+cumsum(bidsq,2))+10000*(1+cumsum(bidsq,2)>0),[],2);
            qrem_neg=(1+cumsum(bidsq,2));
            qrem=qrem_neg(sub2ind(size(bidsq),[1:1:size(bidsq,1)]',icq));
        end
        empdir=0.01;
        

        %get clearing price if q+epsilon here bid instead
        if direction>0
            sma=[sign(direction).*ones(size(bidsq,1),1) sign((1-empdir)-cumsum(bidsq,2))];
            [~,icp]=min(((1-empdir)-cumsum(bidsq,2))+1000*(sma(:,1:end-1)~=sign(direction)),[],2);
        else
            [~,icp]=min(abs(1-empdir+cumsum(bidsq,2))+1000*(sign(cumsum(bidsq,2)+1-empdir)~=sign(direction)),[],2);
        end
        Pclsamplepl=bidsp(sub2ind(size(bidsp),[1:1:size(icp,1)]',icp));

        %adding 2 epsilon
        if direction>0
            sma=[sign(direction).*ones(size(bidsq,1),1) sign((1-2*empdir)-cumsum(bidsq,2))];
            [~,icpp]=min(((1-2*empdir)-cumsum(bidsq,2))+1000*(sma(:,1:end-1)~=sign(direction)),[],2);
        else
            [~,icpp]=min(abs(1-2*empdir+cumsum(bidsq,2))+1000*(sign(cumsum(bidsq,2)+1-2*empdir)~=sign(direction)),[],2);
        end
        Pclsampleplpl=bidsp(sub2ind(size(bidsp),[1:1:size(icp,1)]',icpp));

        %and instead subtracting epsilon...
        if direction>0
            sma=[sign(direction).*ones(size(bidsq,1),1) sign((1+empdir)-cumsum(bidsq,2))];
            [~,icm]=min(((1+empdir)-cumsum(bidsq,2))+1000*(sma(:,1:end-1)~=sign(direction)),[],2);
        else
            [~,icm]=min(abs(1+empdir+cumsum(bidsq,2))+1000*(sign(cumsum(bidsq,2)+1+empdir)~=sign(direction)),[],2);
        end
        Pclsamplem=bidsp(sub2ind(size(bidsp),[1:1:size(icm,1)]',icm));

        %subtracting 2 epsilon
        if direction>0
            sma=[sign(direction).*ones(size(bidsq,1),1) sign((1+2*empdir)-cumsum(bidsq,2))];
            [~,icmm]=min(((1+2*empdir)-cumsum(bidsq,2))+1000*(sma(:,1:end-1)~=sign(direction)),[],2);
        else
            [~,icmm]=min(abs(1+2*empdir+cumsum(bidsq,2))+1000*(sign(cumsum(bidsq,2)+1+2*empdir)~=sign(direction)),[],2);
        end
        Pclsamplemm=bidsp(sub2ind(size(bidsp),[1:1:size(icmm,1)]',icmm));


        %now get the clearing prices without i
        [bidsp, ic]=sort(direction.*[reshape(supplyp2(drawnids{kk},:),ndraw,(Npossibleexp(kk)-1)*size(supplyp2,2)) reshape(carriedoverp(drawnids{kk},:),ndraw,[])],2,'descend');
        bidsp=abs(bidsp);
        bidsq=[reshape(supplyq2(drawnids{kk},:),ndraw,(Npossibleexp(kk)-1)*size(supplyp2,2)) direction.*reshape(carriedoverq(drawnids{kk},:),ndraw,[])];
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
            [~,ic]=min(abs(1+cumsum(bidsq,2))+1000*(sign(cumsum(bidsq,2)+1)~=sign(direction)),[],2);
        end
        Pclsamplenobid=bidsp(sub2ind(size(bidsp),[1:1:size(ic,1)]',ic));

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
        [bidsp, ic]=sort(direction.*[reshape(supplyp2(drawnids{kk},:),ndraw,(Npossibleexp(kk)-1)*size(supplyp2,2)) repmat(supplyp(idss==idfs(kk))',ndraw,1)+epsilonp.*(repmat(supplyp(idss==idfs(kk))',ndraw,1)~=0) reshape(carriedoverp(drawnids{kk},:),ndraw,[])],2,'descend');
        bidsp=abs(bidsp);
        bidsq=[reshape(supplyq2(drawnids{kk},:),ndraw,(Npossibleexp(kk)-1)*size(supplyp2,2)) repmat(supplyq(idss==idfs(kk))',ndraw,1) direction.*reshape(carriedoverq(drawnids{kk},:),ndraw,[])];
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
            [~,icap]=min(abs(1+cumsum(bidsq,2))+1000*(sign(cumsum(bidsq,2)+1)~=sign(direction)),[],2);
        end
        bidsqa=cumsum(bidsq,2);
        Pclsamplepl_price=bidsp(sub2ind(size(bidsp),[1:1:size(ic,1)]',icap));
        qclsamplepl_price=bidsqa(sub2ind(size(bidsp),[1:1:size(ic,1)]',icap));

        %and minus epsilonp
        [bidsp, ic]=sort(direction.*[reshape(supplyp2(drawnids{kk},:),ndraw,(Npossibleexp(kk)-1)*size(supplyp2,2)) repmat(supplyp(idss==idfs(kk))',ndraw,1)-epsilonp.*(repmat(supplyp(idss==idfs(kk))',ndraw,1)~=0) reshape(carriedoverp(drawnids{kk},:),ndraw,[])],2,'descend');
        bidsp=abs(bidsp);
        bidsq=[reshape(supplyq2(drawnids{kk},:),ndraw,(Npossibleexp(kk)-1)*size(supplyp2,2)) repmat(supplyq(idss==idfs(kk))',ndraw,1) direction.*reshape(carriedoverq(drawnids{kk},:),ndraw,[])];
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
            [~,icap]=min(abs(1+cumsum(bidsq,2))+1000*(sign(cumsum(bidsq,2)+1)~=sign(direction)),[],2);
        end
        bidsqa=cumsum(bidsq,2);
        Pclsamplem_price=bidsp(sub2ind(size(bidsp),[1:1:size(ic,1)]',icap));
        qclsamplem_price=bidsqa(sub2ind(size(bidsp),[1:1:size(ic,1)]',icap));




        %% Probability pclear between bk and bk+1
        %smooth how? with kernels? with bspline? no smoothing?
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
        
        if direction>0
        dropk=drop(kk,1:min(size(ownbidq,1),size(drop,2)))';
        else
        dropk=(fliplr(drop(kk,1:min(size(ownbidq,1),size(ownbidq,1)))))';
        end
        if size(dropk,1)<size(ownbidq,1)
            dropk=[dropk;zeros(size(ownbidq,1)-size(dropk,1),1)];
        end

        prselT=[prsel(idss==idfs(kk));0];
        prselT=prselT(ica);

        [ownbids,ia, ic]=unique(ownbids,'stable');
        for ii=1:size(ia,1) %added ,1
            ownbidq(ia(ii))=sum(ownbidq(ic==ii));
            prselT(ia(ii))=max(prselT(ic==ii));
            dropk(ia(ii))=max(dropk(ic==ii));
            coind(ia(ii))=min(coind(ic==ii));
        end
        ownbidq=ownbidq(ia);
        prselT=prselT(ia);
        dropk=dropk(ia);
        %ownbidq=cumsum(ownbidq);
        coind=coind(ia);
        coind=max(coind,dropk);

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
                        Probplpl(aa,1)=abs((1./max(size(Pclsampleplpl))).*sum(normcdf((ownbids(aa)-Pclsampleplpl)./bwppp))-(1./max(size(Pclsampleplpl))).*sum(normcdf((ownbids(aa+1)-Pclsampleplpl)./bwppp)));
                        Probpl(aa,1)=abs((1./max(size(Pclsamplepl))).*sum(normcdf((ownbids(aa)-Pclsamplepl)./bwpp))-(1./max(size(Pclsamplepl))).*sum(normcdf((ownbids(aa+1)-Pclsamplepl)./bwpp)));
                        Probm(aa,1)=abs((1./max(size(Pclsamplem))).*sum(normcdf((ownbids(aa)-Pclsamplem)./bwpm))-(1./max(size(Pclsamplem))).*sum(normcdf((ownbids(aa+1)-Pclsamplem)./bwpm)));
                        Probmm(aa,1)=abs((1./max(size(Pclsamplemm))).*sum(normcdf((ownbids(aa)-Pclsamplemm)./bwpmm))-(1./max(size(Pclsamplemm))).*sum(normcdf((ownbids(aa+1)-Pclsamplemm)./bwpmm)));



                        dProb(aa,1)=(-Probplpl(aa,1)+8*Probpl(aa,1)-8*Probm(aa,1)+Probmm(aa,1))./(12.*empdir.*(abs(NOIlong(kk))));
                        Epclm(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsamplem))*bwpm)).*(sum(normpdf((pgrid-Pclsamplem)./bwpm)))))./abs(trapz(pgrid,(1./(max(size(Pclsamplem))*bwpm)).*(sum(normpdf((pgrid-Pclsamplem)./bwpm)))));
                        Epclmm(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsamplemm))*bwpmm)).*(sum(normpdf((pgrid-Pclsamplemm)./bwpmm)))))./abs(trapz(pgrid,(1./(max(size(Pclsamplemm))*bwpmm)).*(sum(normpdf((pgrid-Pclsamplemm)./bwpmm)))));
                        Epclplpl(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsampleplpl))*bwppp)).*(sum(normpdf((pgrid-Pclsampleplpl)./bwppp)))))./abs(trapz(pgrid,(1./(max(size(Pclsampleplpl))*bwppp)).*(sum(normpdf((pgrid-Pclsampleplpl)./bwppp)))));

                        dEpcond(aa,1)=(-Epclplpl(aa,1)+8*Epclpl(aa,1)-8*Epclm(aa,1)+Epclmm(aa,1))./(12.*empdir.*(abs(NOIlong(kk))));
                        dEpcl(aa,1)=dProb(aa,1).*Epcl(aa,1)+dEpcond(aa,1).*Prob(aa,1);

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
       
                            %Product rule and fivepoint star
                            Probmm(aa,1)=abs(trapz(pgrid,(1./(max(size(Pclsamplemm))*bwpmm)).*(sum(normpdf((pgrid-Pclsamplemm)./bwpmm)))));
                            Probm(aa,1)=abs(trapz(pgrid,(1./(max(size(Pclsamplem))*bwpm)).*(sum(normpdf((pgrid-Pclsamplem)./bwpm)))));
                            Probpl(aa,1)=abs(trapz(pgrid,(1./(max(size(Pclsamplepl))*bwpp)).*(sum(normpdf((pgrid-Pclsamplepl)./bwpp)))));
                            Probplpl(aa,1)=abs(trapz(pgrid,(1./(max(size(Pclsampleplpl))*bwppp)).*(sum(normpdf((pgrid-Pclsampleplpl)./bwppp)))));

                            dProb(aa,1)=(-Probplpl(aa,1)+8*Probpl(aa,1)-8*Probm(aa,1)+Probmm(aa,1))./(12.*empdir.*(abs(NOIlong(kk))));
                            Epclm(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsamplem))*bwpm)).*(sum(normpdf((pgrid-Pclsamplem)./bwpm)))))./abs(trapz(pgrid,(1./(max(size(Pclsamplem))*bwpm)).*(sum(normpdf((pgrid-Pclsamplem)./bwpm)))));
                            Epclmm(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsamplemm))*bwpmm)).*(sum(normpdf((pgrid-Pclsamplemm)./bwpmm)))))./abs(trapz(pgrid,(1./(max(size(Pclsamplemm))*bwpmm)).*(sum(normpdf((pgrid-Pclsamplemm)./bwpmm)))));
                            Epclplpl(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsampleplpl))*bwppp)).*(sum(normpdf((pgrid-Pclsampleplpl)./bwppp)))))./abs(trapz(pgrid,(1./(max(size(Pclsampleplpl))*bwppp)).*(sum(normpdf((pgrid-Pclsampleplpl)./bwppp)))));


                            dEpcond(aa,1)=(-Epclplpl(aa,1)+8*Epclpl(aa,1)-8*Epclm(aa,1)+Epclmm(aa,1))./(12.*empdir.*(abs(NOIlong(kk))));
                            dEpcl(aa,1)=dProb(aa,1).*Epcl(aa,1)+dEpcond(aa,1).*Prob(aa,1);

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

                            %Product rule and fivepoint star
                            Probmm(aa,1)=abs(trapz(pgrid,(1./(max(size(Pclsamplemm))*bwpmm)).*(sum(normpdf((pgrid-Pclsamplemm)./bwpmm)))));
                            Probm(aa,1)=abs(trapz(pgrid,(1./(max(size(Pclsamplem))*bwpm)).*(sum(normpdf((pgrid-Pclsamplem)./bwpm)))));
                            Probpl(aa,1)=abs(trapz(pgrid,(1./(max(size(Pclsamplepl))*bwpp)).*(sum(normpdf((pgrid-Pclsamplepl)./bwpp)))));
                            Probplpl(aa,1)=abs(trapz(pgrid,(1./(max(size(Pclsampleplpl))*bwppp)).*(sum(normpdf((pgrid-Pclsampleplpl)./bwppp)))));

                            dProb(aa,1)=(-Probplpl(aa,1)+8*Probpl(aa,1)-8*Probm(aa,1)+Probmm(aa,1))./(12.*empdir.*(abs(NOIlong(kk))));
                            Epclm(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsamplem))*bwpm)).*(sum(normpdf((pgrid-Pclsamplem)./bwpm)))))./abs(trapz(pgrid,(1./(max(size(Pclsamplem))*bwpm)).*(sum(normpdf((pgrid-Pclsamplem)./bwpm)))));
                            Epclmm(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsamplemm))*bwpmm)).*(sum(normpdf((pgrid-Pclsamplemm)./bwpm)))))./abs(trapz(pgrid,(1./(max(size(Pclsamplemm))*bwpmm)).*(sum(normpdf((pgrid-Pclsamplemm)./bwpmm)))));
                            Epclplpl(aa,1)=abs(trapz(pgrid,pgrid.*(1./(max(size(Pclsampleplpl))*bwppp)).*(sum(normpdf((pgrid-Pclsampleplpl)./bwppp)))))./abs(trapz(pgrid,(1./(max(size(Pclsampleplpl))*bwppp)).*(sum(normpdf((pgrid-Pclsampleplpl)./bwppp)))));

                            Epclm(isnan(Epclm))=ownbids(isnan(Epclm));
                            Epclmm(isnan(Epclmm))=ownbids(isnan(Epclmm));
                            Epcl(isnan(Epcl))=ownbids(isnan(Epcl));
                            Epclpl(isnan(Epclpl))=ownbids(isnan(Epclpl));
                            Epclplpl(isnan(Epclplpl))=ownbids(isnan(Epclplpl));

                            dEpcond(aa,1)=(-Epclplpl(aa,1)+8*Epclpl(aa,1)-8*Epclm(aa,1)+Epclmm(aa,1))./(12.*empdir.*(abs(NOIlong(kk))));
                            dEpcl(aa,1)=dProb(aa,1).*Epcl(aa,1)+dEpcond(aa,1).*Prob(aa,1);

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
                    nbu_pos=Prob.*(vmaxd-Epcl)./dEpcl-ownbidq_cum;
                    nbu=Prob.*(vmind-Epcl)./dEpcl-ownbidq_cum;
                    nbu(dEpcl>0)=nbu_pos(dEpcl>0);

                    nbl_pos=Prob.*(vmind-Epcl)./dEpcl-ownbidq_cum;
                    nbl=Prob.*(vmaxd-Epcl)./dEpcl-ownbidq_cum;
                    nbl(dEpcl>0)=nbl_pos(dEpcl>0);
                    
           
                %remove any non-eligible steps
                nbu=nbu(invert_at==1 & abs(ownbidq_cum)<abs(NOIlong(kk)));
                nbl=nbl(invert_at==1 & abs(ownbidq_cum)<abs(NOIlong(kk)));
                sab=size(nbu,1);
         
                %when abs(ownbidq_cum)>=abs(NOIlong(kk)...augment nbl,nbu from price pert.
                ilisti=find(abs(ownbidq_cum)>=abs(NOIlong(kk)));
                flnan1=zeros(size(ownbidq_cum));flnan2=zeros(size(ownbidq_cum));
                
                for ii=1:size(ilisti,1)
                    %to get the rationed quantity we can subtract the excess at the
                    %clearing price from ownbidq (since we assumed away ties).
                    qddp=ownbidq_cum(ilisti(ii))-(qclsamplepl_price-1).*NOIlong(kk);
                    qdd=ownbidq_cum(ilisti(ii))-(qclsample-1).*NOIlong(kk);
                    qd=qddp-qdd;
                    qpd=qddp.*Pclsamplepl_price-qdd.*Pclsample;
                    ppd=Pclsamplepl_price-Pclsample;
                    dq(ilisti(ii))=mean(qd(Pclsample>=ownbids(ilisti(ii)) & Pclsample<(ownbids(ilisti(ii))+epsilonp.*imp)));
                    dpq(ilisti(ii))=mean(qpd(Pclsample>=ownbids(ilisti(ii)) & Pclsample<(ownbids(ilisti(ii))+epsilonp.*imp)));
                    dpp(ilisti(ii))=mean(ppd(Pclsample>=ownbids(ilisti(ii)) & Pclsample<(ownbids(ilisti(ii))+epsilonp.*imp)));
                    
                    if isnan(dpp(ilisti(ii)))
                        flnan1(ilisti(ii))=1;                   
                        %we know the buyer would never put a bid with no
                        %probability of clearing. therefore sometimes this
                        %cleared at bk and now would at bk+epsilonp.*imp change
                        %in q--we can bound: (0,deltaqk).
                    dpp(ilisti(ii))=epsilonp.*imp; dq(ilisti(ii))=0; dpq(ilisti(ii))=0;
                    dpp_l(ilisti(ii))=epsilonp.*imp; dq_l(ilisti(ii))=ownbidq(ilisti(ii)); dpq_l(ilisti(ii))=epsilonp.*imp.*ownbidq(ilisti(ii));
                    end
                    qddm=ownbidq(ilisti(ii))-(qclsamplem_price-1).*NOIlong(kk);
                    qdd=ownbidq(ilisti(ii))-(qclsample-1).*NOIlong(kk);
                    qd=qddm-qdd;
                    qpd=qddm.*Pclsamplem_price-qdd.*Pclsample;
                    ppd=Pclsamplem_price-Pclsample;
                    dq_2(ilisti(ii))=mean(qd(Pclsample>=(ownbids(ilisti(ii))-epsilonp.*imp) & Pclsample<ownbids(ilisti(ii))));
                    dpq_2(ilisti(ii))=mean(qpd(Pclsample>=(ownbids(ilisti(ii))-epsilonp.*imp) & Pclsample<ownbids(ilisti(ii))));
                    dpp_2(ilisti(ii))=mean(ppd(Pclsample>=(ownbids(ilisti(ii))-epsilonp.*imp) & Pclsample<ownbids(ilisti(ii))));
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
                        for jj=ii+1%:max(size(ownbids))
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
                                    end
                                    if direction<0
                                    %when direction is negative, we have to
                                    %switch tdel=-tdel: since monotonicity is still left to right but the points are swapped in ii,jj space. this introduces the
                                    %negtive sign here
                                    nlt=-((Epcl(jj)-Epcl(ii))-(ownbidq_cum(ii).*dEpcl(ii)./Prob(ii))+(ownbidq_cum(jj).*dEpcl(jj)./Prob(jj)))./tdel;
                                    nbl=[nbl;nlt];
                                    end
                                    
                                elseif tdel<0
                                    if direction>=0
                                    nlt=((Epcl(ii)-Epcl(jj))-(ownbidq_cum(jj).*dEpcl(jj)./Prob(jj))+(ownbidq_cum(ii).*dEpcl(ii)./Prob(ii)))./tdel;
                                    nbl=[nbl;nlt];
                                    end
                                    if direction<0
                                          nut=-((Epcl(jj)-Epcl(ii))-(ownbidq_cum(ii).*dEpcl(ii)./Prob(ii))+(ownbidq_cum(jj).*dEpcl(jj)./Prob(jj)))./tdel;
                                          nbu=[nbu;nut];
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
                    nblt=(sum((vmaxd-Epcl).*Prob.*ownbidq)-(vmind-pceil).*NOIlong(kk))./(mean(Pclsample)-pceil);
                    nbut=(sum((vmaxd-Epcl).*Prob.*ownbidq))./(mean(Pclsample)-mean(Pclsamplenobid));
                    nbl=[nbl;nblt];
                    nbu=[nbu;nbut];
                else
                    nbut=(sum((vmind-Epcl).*Prob.*ownbidq)-(vmaxd-pfloor).*NOIlong(kk))./(mean(Pclsample)-pfloor);
                    nbu=[nbu;nbut];
                    nblt=(sum((vmind-Epcl).*Prob.*ownbidq))./(mean(Pclsample)-mean(Pclsamplenobid));
                    nbl=[nbl;nblt];
                end


                nbl(isnan(nbl))=-nmax;
                nbl(isinf(nbl))=-nmax;
                nbu(isnan(nbu))=nmax;
                nbu(isinf(nbu))=nmax;

                if isempty(nbl)
                    nbl=-nmax;
                end
                if isempty(nbu)
                    nbu=nmax;
                end
                nbl(nbl<=-nmax)=-nmax;
                nbu(nbu<=-nmax)=-nmax;
                nbl(nbl>=nmax)=nmax;
                nbu(nbu>=nmax)=nmax;

                %compute the minimum/maximum
                if mean(nbl)>mean(nbu)
                nbl=nbl(1:sab);
                nbu=nbu(1:sab);
                if isempty(nbl)
                    nbl=-nmax;
                end
                if isempty(nbu)
                    nbu=nmax;
                end
                countminmax=countminmax+1;
                end
                if size(nbl,1)<7
                rho=rhoM;
                nlow=sum((nbl.*exp((nmax+nbl).*rho)./sum(exp((nmax+nbl).*rho))));
                 else
                 rho=0.1*rhoM;
                 nlow=sum((nbl.*exp((nmax+nbl).*rho)./sum(exp((nmax+nbl).*rho))));
                 end
                 if size(nbu,1)<7
                rho=-rhoM;
                nup=sum((nbu.*exp((nmax+nbu).*rho)./sum(exp((nmax+nbu).*rho))));
                 else
                 rho=-0.1*rhoM;
                 nup=sum((nbu.*exp((nmax+nbu).*rho)./sum(exp((nmax+nbu).*rho))));
                 end
               
                nlowo=nlow;
                nupo=nup;

            
               
                %smooth until they stop crossing?    
                rhoMA=rhoM;
                while nlow>nup
                rhoMA=0.95.*rhoMA;
                rho=rhoMA;
                nlow=sum((nbl.*exp((nmax+nbl).*rho)./sum(exp((nmax+nbl).*rho))));
                rho=-rhoMA;
                nup=sum((nbu.*exp((nmax+nbu).*rho)./sum(exp((nmax+nbu).*rho))));
                end
                
                 

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
                        vup(ilisti(ii))=vup(ilisti(ii)-1);
                        else
                            vup(ilisti(ii))=vmaxd;
                        end
                        if isnan(vlow(ilisti(ii)))
                        if ilisti(ii)<size(vup,1)
                        vlow(ilisti(ii))=vlow(ilisti(ii)+1);
                        else
                            vlow(ilisti(ii))=vmind;
                        end
                        end     

                        end
                        

                    else
                        ii=size(ilisti,1)+1-ij;
                     if isnan(vup(ilisti(ii)))
                        if ilisti(ii)<size(vup,1)
                        vup(ilisti(ii))=vup(ilisti(ii)+1);
                        else
                            vup(ilisti(ii))=vmaxd;
                        end
                     end
                      if isnan(vlow(ilisti(ii)))
                        if ilisti(ii)>1
                        vlow(ilisti(ii))=vlow(ilisti(ii)-1);
                        else
                        vlow(ilisti(ii))=vmind;
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
               
                rhoV=1;
                if size(vup,1)>1
                for ii=1:size(vup,1)
                   if direction>0
                        vlow(ii)=sum(vlow(ii:end).*exp((vlow(ii:end).*rhoV)))./sum(exp((vlow(ii:end).*rhoV)));
                        vup(ii)=sum(vup(1:ii).*exp((vup(1:ii).*-rhoV)))./sum(exp((vup(1:ii).*-rhoV)));
                   else
                        vlow(ii)=sum(vlow(1:ii).*exp((vlow(1:ii).*rhoV)))./sum(exp((vlow(1:ii).*rhoV)));
                        vup(ii)=sum(vup(ii:end).*exp((vup(ii:end).*-rhoV)))./sum(exp((vup(ii:end).*-rhoV)));
                   end
                end
                end

                qshad(kk,1)=sum(dEpcl.*nlow.*ownbidq)./sum(ownbidq);
                qshad(kk,2)=sum(dEpcl.*nup.*ownbidq)./sum(ownbidq);
            else %non-participating bidders
                qshad(kk,1)=0;qshad(kk,2)=0;
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
                    nupo=max(min(0,((adjout-noadj))./(mean(Pclsamplepl)-mean(Pclsample))),-nmax);
                    nlowo=-nmax;

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
        nlowo=-nmax; nupo=nmax; nlow=-nmax; nup=nmax; vlow=vmind; vup=vmaxd; imp=imm1cap(kk);
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

    vout{kk}=[obqa, vlow, vup, vlowo,vupo, imp*ones(size(vlow)) obpa];
    nout(kk,:)=[nlow nup NOIlong(kk) nopartflag imm1cap(kk) imm(kk) size(vlow,1) EsurpL EsurpU mean(Pclsample) nlowo nupo];
    crossf=crossf+(nlowo>nupo);
 end
nout=[nout qshad];
