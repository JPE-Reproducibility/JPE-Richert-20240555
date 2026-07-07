%normalizes prices by price cap/floor
imm1cap=[];
imm2cap=[];
imm2=[];
imm=[];
aucpricefs2=[];
for kk=1:size(aucidfslist,1)
    imm1cap(aucidfs==aucidfslist(kk))=IMMcap(kk);
    imm2cap(aucidsupply==aucidfslist(kk))=IMMcap(kk);
    imm2(aucidsupply==aucidfslist(kk))=IMM(kk);
    imm(aucidfs==aucidfslist(kk))=IMM(kk);
    aucpricefs2(aucidfs==aucidfslist(kk))=aucpricefs(kk);
end
imm2=imm2';
imm=imm';
imm1cap=imm1cap';
imm2cap=imm2cap';
aucpricefs2=aucpricefs2';

for i=1:size(aucidfslist,1)
NOItotsupply(aucidsupply==aucidfslist(i))=NOItot(i);
end

%expresses NOI as a share of outstanding bonds/outstandingCDS.
for k=1:size(aucidfslist,1)
NOItemp=noi(aucidfs==aucidfslist(k));
NOIabs(k,1)=sum(abs(NOItemp));
NOI(k,1)=sum(NOItemp);
NOIabslong(aucidfs==aucidfslist(k))=NOIabs(k,1);
NOIlong(aucidfs==aucidfslist(k))=NOI(k,1);
end
[aa,aaa]=unique(aucidfs,'stable');
NOIsh=(NOIlong(aaa)'./(Bondvol(aaa)));

customerorder_frequency

supplyq_RAW=supplyq;
for k=1:size(aucidfslist,1)
   supplyq(aucidsupply==aucidfslist(k))=supplyq(aucidsupply==aucidfslist(k))./NOI(k); 
end
supplyq(supplyq>1)=1;
supplyq(supplyq<-1)=-1;

supplypRAW=supplyp;
supplyqRAW=supplyq;

for k=1:size(aucidfslist,1)
    direction=(NOI(k)>0);
    if direction==1
        supplyp(aucidsupply==aucidfslist(k))=supplyp(aucidsupply==aucidfslist(k))./mean(imm2cap(aucidsupply==aucidfslist(k)));
    else
        supplyp(aucidsupply==aucidfslist(k))=((supplyp(aucidsupply==aucidfslist(k))))./mean(imm2cap(aucidsupply==aucidfslist(k)));
    end
    noiSS(aucidsupply==aucidfslist(k))=NOI(kk).*ones(size(supplyp(aucidsupply==aucidfslist(k))));
end

%generate unique ids for bidder/auction and throw these on the initial
%round quantities AND the big vector of p/q
%idco for carryovers.

idn=1;
 clear tempfs tempss tempco tempfsnoi
for iauc=1:size(aucidfslist,1)
    auc=aucidfslist(iauc);
    fsbidlist=immbidderid(aucidfs==auc);
    fsbidlistnoi=noibidderid(aucidfs==auc);
    ssbidlist=supplyid(aucidsupply==auc);
    cobidlist=carried_id(carried_aucid==auc);
    for bidd=1:size(fsbidlist,1)
       tempfs(strcmp(fsbidlist,fsbidlist(bidd)))=idn;
       tempfsnoi(strcmp(fsbidlistnoi,fsbidlist(bidd)))=idn;
       tempss(strcmp(ssbidlist,fsbidlist(bidd)))=idn;
       tempco(strcmp(cobidlist,fsbidlist(bidd)))=idn;
        idn=idn+1;
    end
    idfs(aucidfs==auc)=tempfs;
    idfsnoi(aucidfs==auc)=tempfsnoi;
    idss(aucidsupply==auc)=tempss;
    idco(carried_aucid==auc)=tempco;
    clear tempfs tempss tempco tempfsnoi
end
idfs=idfs';
idss=idss';
idco=idco';
idfsnoi=idfsnoi';

for aa=1:size(idfs,1)
 if isempty(carried_p(idco==idfs(aa)))==0
    copn(aa,1)=carried_p(idco==idfs(aa));
    coqn(aa,1)=carried_q(idco==idfs(aa));
    else
        coqn(aa,1)=0;
        copn(aa,1)=0;
    end
end

carriedoverp=copn;
carriedoverq=coqn;
carriedoverp(NOIlong'>0,:)=carriedoverp(NOIlong'>0,:)./imm1cap(NOIlong'>0);
carriedoverp(NOIlong'<0,:)=((carriedoverp(NOIlong'<0,:))./imm1cap(NOIlong'<0));
carriedoverq=carriedoverq./abs(NOIlong');
carriedoverq(isinf(carriedoverq))=0;
carriedoverq(isnan(carriedoverq))=0;

supplyp(fromimm==1)=[];
supplypRAW2=supplypRAW;
supplypRAW2(fromimm==1)=[];
supplyq(fromimm==1)=[];
idss(fromimm==1)=[];
aucidsupply(fromimm==1)=[];
imm2cap(fromimm==1)=[];
immcap2=imm2cap;
imm2(fromimm==1)=[];

%reorder the noi so that it matches idfs
for aa=1:length(idfs)
    if isempty(noi(idfsnoi==idfs(aa)))==0
    noinew(aa,1)=noi(idfsnoi==idfs(aa));
    else
        noinew(aa,1)=0;
    end
end
noi=noinew;


supplyp2=zeros(size(idfs,1),118);
supplyq2=zeros(size(idfs,1),118);
carriedq2=zeros(size(idfs,1),20);
carriedp2=zeros(size(idfs,1),20);
for k=1:size(idfs,1)
   supplyp2(k,:)=[supplyp(idss==idfs(k))' zeros(1,118-size(supplyp(idss==idfs(k)),1))];
   supplyq2(k,:)=[supplyq(idss==idfs(k))' zeros(1,118-size(supplyp(idss==idfs(k)),1))];
end


%estimate the first stage of this.

for kl=1:size(aucidfslist,1)
    st=supplyp(aucidsupply==aucidfslist(kl));
    ties(aucidsupply==aucidfslist(kl),1)=sum((st-st')==0,2)';
end
ties=ties-1;

supplyq(isinf(supplyq)==1)=0;
supplyq(isnan(supplyq)==1)=0;

bondvols=[];
for kk=1:size(aucidfs,1)
bondvols=[bondvols;max(Bondvol(br_auc_id==aucidfs(kk)))];
end
bondvols=100*bondvols;

figure
scatter(imm,noi)
saveas(gcf,fullfile(fig_path,'immnoiscatter.png'))




%LAWSUIT REGRESSIONS SCREENS

for aa=1:size(supplyp,1)
s2_noi(aa)=NOI(aucidfslist==aucidsupply(aa));
s2_imm(aa)=IMM(aucidfslist==aucidsupply(aa));
s2_noiown(aa)=noi(idfs==idss(aa));
s2_immown(aa)=(immhigh(idfs==idss(aa))+immlow(idfs==idss(aa)))./2;
s2_immvar(aa)=std((immhigh(aucidfs==aucidsupply(aa))+immlow(aucidfs==aucidsupply(aa)))./2);
end


for aa=1:size(aucidfslist,1)
s2_dominantdealer(aucidsupply==aucidfslist(aa))=(abs(s2_noiown(aucidsupply==aucidfslist(aa)))==max(abs(s2_noiown(aucidsupply==aucidfslist(aa)))));
s2_dominantdealer_fake(aucidsupply==aucidfslist(aa))=(idss(aucidsupply==aucidfslist(aa))==min(idss(aucidsupply==aucidfslist(aa))));
end

for aa=1:size(aucidfslist,1)
temp=s2_dominantdealer(aucidsupply==aucidfslist(aa)).*(s2_immown(aucidsupply==aucidfslist(aa))-s2_imm(aucidsupply==aucidfslist(aa)));
temp(temp==0)=[];
temp(isempty(temp))=0;
s2_dominantdealerIMM(aucidsupply==aucidfslist(aa))=max(temp);
temp=s2_dominantdealer_fake(aucidsupply==aucidfslist(aa)).*(s2_immown(aucidsupply==aucidfslist(aa))-s2_imm(aucidsupply==aucidfslist(aa)));
temp(temp==0)=[];
temp(isempty(temp))=0;
s2_dominantdealer_fakeIMM(aucidsupply==aucidfslist(aa))=max(temp); 
end




%%%Construct variables for Table 3 and Section 2 in-text statistics
%N-dealers
for ii=1:size(aucidfslist,1)
    ndeal(ii,1)=sum(aucidfs==aucidfslist(ii));
end
%Within auction deviations in IMM
for ii=1:size(aucidfslist,1)
    sd_imm_within(ii,1)=std(immhigh(aucidfs==aucidfslist(ii)));
end
%total size of first stage orders
for ii=1:size(aucidfslist,1)
    NOI_totalsize(ii,1)=sum(abs(noi(aucidfs==aucidfslist(ii))));
end
%bidder shares of total size
for ii=1:size(aucidfs,1)
    ishare_r1(ii,1)=(abs(noi(ii)))./NOI_totalsize(aucidfslist==aucidfs(ii));
end
%maximum stage 2 quantities (shares)
for ii=1:size(aucidfs,1)
    maxQi(ii,1)=sum(abs(supplyq2(ii,:)));
end
maxQi(isinf(maxQi))=0;
%stage 2 steps
nstepA=max(nstepA-1,0);
%Auction coverage
aucidsupplyRAW=table2array(supplyfunctab(:,4));
for ii=1:size(aucidfslist,1) %added ,1
    total_coverage(ii,1)=sum(supplyq_RAW(aucidsupplyRAW==aucidfslist(ii)))./NOI(ii);
end
total_coverage(isnan(total_coverage))=1;
total_coverage(isinf(total_coverage))=1;

%% ============ TABLE 3: Auction Description ============
disp('========== TABLE 3: Auction Description ==========')
T3_mean = [mean(ndeal); mean(aucpricefs); mean(IMM); mean(sd_imm_within); ...
           mean(abs(NOI)); mean(NOI_totalsize); mean(abs(total_coverage)); ...
           nanmean(ishare_r1); nanmean(maxQi)];
T3_sd   = [std(ndeal); std(aucpricefs); std(IMM); std(sd_imm_within); ...
           std(abs(NOI)); std(NOI_totalsize); std(abs(total_coverage)); ...
           nanstd(ishare_r1); nanstd(maxQi)];
T3_p10  = [prctile(ndeal,10); prctile(aucpricefs,10); prctile(IMM,10); prctile(sd_imm_within,10); ...
           prctile(abs(NOI),10); prctile(NOI_totalsize,10); prctile(abs(total_coverage),10); ...
           prctile(ishare_r1,10); prctile(maxQi,10)];
T3_p90  = [prctile(ndeal,90); prctile(aucpricefs,90); prctile(IMM,90); prctile(sd_imm_within,90); ...
           prctile(abs(NOI),90); prctile(NOI_totalsize,90); prctile(abs(total_coverage),90); ...
           prctile(ishare_r1,90); prctile(maxQi,90)];
T3_labels = {'Number of Dealers'; 'Price (cents)'; 'IMM (cents)'; ...
    'Within-Auction deviation in Quotes (cents)'; '|NOI| ($millions)'; ...
    'Total Commitments ($millions)'; 'Auction Coverage (shares)'; ...
    'Individual Shares of Total Commitment'; 'Maximum Quantity Stage 2 (shares)'};
fprintf('%-50s %10s %10s %18s\n', '', 'Mean', 'Sd', '[P10, P90]')
for ii=1:9
    fprintf('%-50s %10.2f %10.2f   [%7.2f, %7.2f]\n', T3_labels{ii}, T3_mean(ii), T3_sd(ii), T3_p10(ii), T3_p90(ii))
end
fprintf('N = %d auctions (rows 1-7), %d bidder-level observations (rows 8-9)\n', size(aucidfslist,1), size(aucidfs,1))
% Save Table 3 as LaTeX
fid = fopen(fullfile(tab_path, 'table3.tex'), 'w');
fprintf(fid, '\\begin{table}[htbp]\n\\centering\n\\caption{Auction Description}\n\\label{tab:auctiondesc}\n');
fprintf(fid, '\\begin{tabular}{lccc}\n\\hline\\hline\n');
fprintf(fid, ' & Mean & Sd & $[P_{10}, P_{90}]$ \\\\\n\\hline\n');
T3_texlabels = {'Number of Dealers'; 'Price (\\$.01)'; 'IMM (\\$.01)'; ...
    'Within-Auction deviation in Quotes (\\$.01)'; '$|$NOI$|$ (\\$millions)'; ...
    'Total Commitments $\\sum |y_i|$ (\\$millions)'; 'Auction Coverage (shares)'; ...
    'Individual Shares of Total Commitment'; 'Maximum Quantity Stage 2 (shares)'};
for ii=1:9
    fprintf(fid, '%s & %.2f & %.2f & $[%.2f, %.2f]$ \\\\\n', T3_texlabels{ii}, T3_mean(ii), T3_sd(ii), T3_p10(ii), T3_p90(ii));
end
fprintf(fid, '\\hline\\hline\n\\end{tabular}\n');
fprintf(fid, '\\begin{tablenotes}\\small\n');
fprintf(fid, '\\item $N = %d$ auctions (rows 1--7), $%d$ bidder-level observations (rows 8--9).\n', size(aucidfslist,1), size(aucidfs,1));
fprintf(fid, '\\end{tablenotes}\n\\end{table}\n');
fclose(fid);
disp('Table 3 saved to output/tables/table3.tex')

%% ============ SECTION 2: In-Text Descriptive Statistics ============
disp('========== SECTION 2: In-Text Descriptive Statistics ==========')
fprintf('  Total auctions in sample: %d\n', size(aucidfslist,1))
fprintf('  Total bidder-auction observations: %d\n', size(aucidfs,1))
fprintf('  Median eligible bonds per auction: %.0f\n', median(OS1_nbonds))
fprintf('  Requests to buy (y_i < 0): %d\n', sum(noi<0))
fprintf('  Requests to sell (y_i > 0): %d\n', sum(noi>0))
fprintf('  Requests of zero: %d\n', sum(noi==0))
fprintf('  Fraction excess supply auctions: %.1f%%\n', 100*mean(NOItot>0))
fprintf('  Auctions with no second stage (NOI=0): %d\n', sum(NOI==0))
fprintf('  Fraction bidders submitting first stage quantity: %.1f%%\n', 100*mean(noi~=0))
repurchase_rate = sum((sign(maxQi)'~=sign(NOIlong))'.*(sign(NOIlong')==sign(noi)))./sum((sign(NOIlong')==sign(noi)));
fprintf('  Repurchase/resell rate (change directions): %.0f%%\n', 100*repurchase_rate)
fprintf('  Fraction submitting beyond carried-over bid: %.0f%%\n', 100*mean(maxQi~=0))
fprintf('  Mean quantity conditional on bidding (shares): %.2f\n', mean(maxQi(maxQi~=0)))

qw_newbid=sum(supplyp2.*imm.*supplyq2,2)./sum(supplyq2,2);
bwimm=1.06.*(std(imm)).*(max(size(imm))).^(-1./5);
bwNOI=1.06.*((prctile(NOIlong,75)-prctile(NOIlong,25))./1.34).*(max(size(NOIlong))).^(-1./5);
qw_fv=nansum(qw_newbid'.*normpdf((imm-imm')./bwimm).*(normpdf((NOIlong-NOIlong')./bwNOI)),2)./sum((isnan(qw_newbid)==0).*normpdf((imm-imm')./bwimm).*(normpdf((NOIlong-NOIlong')./bwNOI)),2);

bidder_freq=sum(FSglobalID'==[1:1:max(FSglobalID)]);
globalbidder=find(bidder_freq>140);
global_bidder=max(FSglobalID'==globalbidder,[],2);
%% ============ TABLE OS.4: Bond Traits (Bidder Level) ============
disp('========== TABLE OS.4: Bond Traits -- Bidder Level ==========')
disp('Column 1: IMM Submission. Column 2: Residualized bid.')
disp('Rows: Duration, Conversion, Convexity, Volume, Global Dealer')
[b,ci,~,~,stats1]=regress(immhigh,[Bonddur' Bondcf' Bondconv' (Bondvol./1e6)' NOIlong' global_bidder ones(size(immhigh))]);
se=(ci(:,2)-b)./1.96;
OS4_col1 = [b([1:4,6]) se([1:4,6])]; %indices: Duration, Conversion, Convexity, Volume, Global Dealer (skip NOI)
OS4_N1 = size(immhigh,1); OS4_R2_1 = stats1(1);
disp('  IMM Submission regression [coef, se]:')
OS4_varnames = {'Duration','Conversion','Convexity','Volume','Global Dealer'};
for ii=1:5; fprintf('  %-20s %8.3f (%6.3f)\n', OS4_varnames{ii}, OS4_col1(ii,1), OS4_col1(ii,2)); end
y=qw_fv;
X=[Bonddur' Bondcf' Bondconv' (Bondvol./1e6)' global_bidder ones(size(immhigh))];
X(isinf(y),:)=[];X(isnan(y),:)=[];
y(isinf(y))=[]; y(isnan(y))=[];
[b,ci,~,~,stats2]=regress(y,X);
se=(ci(:,2)-b)./1.96;
OS4_col2 = [b(1:5) se(1:5)];
OS4_N2 = size(y,1); OS4_R2_2 = stats2(1);
disp('  Residualized bid regression [coef, se]:')
for ii=1:5; fprintf('  %-20s %8.3f (%6.3f)\n', OS4_varnames{ii}, OS4_col2(ii,1), OS4_col2(ii,2)); end
% Save Table OS.4 as LaTeX
fid = fopen(fullfile(tab_path, 'tableOS4.tex'), 'w');
fprintf(fid, '\\begin{table}[htbp]\n\\centering\n\\caption{Bond Traits: Bidder Level}\n\\label{tab:os4}\n');
fprintf(fid, '\\begin{tabular}{lcc}\n\\hline\\hline\n');
fprintf(fid, ' & IMM Submission & Residualized bid \\\\\n\\hline\n');
for ii=1:5
    fprintf(fid, '%s & %.2f & %.2f \\\\\n', OS4_varnames{ii}, OS4_col1(ii,1), OS4_col2(ii,1));
    fprintf(fid, ' & (%.2f) & (%.2f) \\\\\n', OS4_col1(ii,2), OS4_col2(ii,2));
end
fprintf(fid, '\\hline\n');
fprintf(fid, '$N$ & %d & %d \\\\\n', OS4_N1, OS4_N2);
fprintf(fid, '$R^2$ & %.3f & %.3f \\\\\n', OS4_R2_1, OS4_R2_2);
fprintf(fid, '\\hline\\hline\n\\end{tabular}\n');
fprintf(fid, '\\begin{tablenotes}\\small\\item Standard errors in parentheses. Controls: NOI, constant (col.\\ 1); constant (col.\\ 2).\\end{tablenotes}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);
disp('Table OS.4 saved to output/tables/tableOS4.tex')
%across round linkage regression (diagnostic, not reported)
y=qw_fv;
X=[((immhigh+immlow)./2)-imm noi ones(size(immhigh))];
X(isinf(y),:)=[];X(isnan(y),:)=[];
y(isinf(y))=[]; y(isnan(y))=[];
[b,ci]=regress(y,X);
se=(ci(:,2)-b)./1.96;
%% ============ TABLE OS.5: Bond Traits (Auction Level) ============
disp('========== TABLE OS.5: Bond Traits -- Auction Level ==========')
disp('Column 1: Auction Price. Column 2: Auction IMM.')
X=[bonddur bondcf bondconv bondvol./1e9];
for ii=1:max(size(aucidfslist))
    if isempty(find(bondid==aucidfslist(ii)))==0
Xout(ii,:)=X(find(bondid==aucidfslist(ii)),:);
    else
        Xout(ii,:)=NaN.*ones(1,size(X,2));
    end
end
[b1,ci1,~,~,stats5_1]=regress(aucpricefs,[Xout NOI IMM IMM.^2 ones(size(NOI))]);
se1=(ci1(:,2)-b1)./1.96;
[b2,ci2,~,~,stats5_2]=regress(IMM,[Xout NOI ones(size(NOI))]);
se2=(ci2(:,2)-b2)./1.96;
OS5_varnames = {'Duration','Conversion','Convexity','Volume','NOI','IMM','IMM^2','Constant'};
disp('  Auction Price regression [coef, se]:')
for ii=1:8; fprintf('  %-15s %10.4f (%8.4f)\n', OS5_varnames{ii}, b1(ii), se1(ii)); end
OS5b_varnames = {'Duration','Conversion','Convexity','Volume','NOI','Constant'};
disp('  Auction IMM regression [coef, se]:')
for ii=1:6; fprintf('  %-15s %10.4f (%8.4f)\n', OS5b_varnames{ii}, b2(ii), se2(ii)); end
% Save Table OS.5 as LaTeX
fid = fopen(fullfile(tab_path, 'tableOS5.tex'), 'w');
fprintf(fid, '\\begin{table}[htbp]\n\\centering\n\\caption{Bond Traits: Auction Level}\n\\label{tab:os5}\n');
fprintf(fid, '\\begin{tabular}{lcc}\n\\hline\\hline\n');
fprintf(fid, 'VARIABLES & (1) Auction Price & (2) Auction IMM \\\\\n\\hline\n');
for ii=1:4
    fprintf(fid, '%s & %.3f & %.2f \\\\\n', OS5_varnames{ii}, b1(ii), b2(ii));
    fprintf(fid, ' & (%.3f) & (%.2f) \\\\\n', se1(ii), se2(ii));
end
fprintf(fid, 'NOI & %.3f & %.2f \\\\\n', b1(5), b2(5));
fprintf(fid, ' & (%.3f) & (%.2f) \\\\\n', se1(5), se2(5));
fprintf(fid, 'IMM & %.2f &  \\\\\n', b1(6));
fprintf(fid, ' & (%.2f) &  \\\\\n', se1(6));
fprintf(fid, 'IMM$^2$ & %.4f &  \\\\\n', b1(7));
fprintf(fid, ' & (%.4f) &  \\\\\n', se1(7));
fprintf(fid, 'Constant & %.2f & %.2f \\\\\n', b1(8), b2(6));
fprintf(fid, ' & (%.2f) & (%.3f) \\\\\n', se1(8), se2(6));
fprintf(fid, '\\hline\n');
fprintf(fid, '$N$ & %d & %d \\\\\n', size(aucpricefs,1), size(IMM,1));
fprintf(fid, '$R^2$ & %.3f & %.3f \\\\\n', stats5_1(1), stats5_2(1));
fprintf(fid, '\\hline\\hline\n\\end{tabular}\n');
fprintf(fid, '\\begin{tablenotes}\\small\\item Standard errors in parentheses.\\end{tablenotes}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);
disp('Table OS.5 saved to output/tables/tableOS5.tex')

%% ============ TABLE A.1: Evidence of Independent Private Values ============
disp('========== TABLE A.1: Evidence of Independent Private Values ==========')
for ii=1:max(size(br_auc_id))
    br_sd_imm_within(ii,1)=std(br_imm(br_auc_id==br_auc_id(ii)));
end

% Panel 1: Slope of bids on IMM variance
disp('--- Panel 1: Slope of bids on IMM variance ---')
disp('  Dep var: Average slope of stage-2 bid')
X=[br_Nsteps' br_auc_noi' br_noi' ones(size(NOIlong'))];
[b,ci]=regress(br_beta',[br_sd_imm_within,X]);
se=(ci(:,2)-b)./1.96;
A1_P1_varnames = {'IMM var.','N steps','Auction NOI','Own NOI','Constant'};
for ii=1:5; fprintf('  %-15s %8.3f (%6.3f)\n', A1_P1_varnames{ii}, b(ii), se(ii)); end
fprintf('  N = %d\n', size(br_beta,2));
A1_immvar_coef = b(1); A1_immvar_se = se(1);

% Panel 2: Mean bid on own quote deviation (split by NOI sign)
disp('--- Panel 2: Mean bid on own p_i^M - p^M ---')
X=[(br_imm-br_auc_imm)' br_Nsteps' br_auc_noi' br_noi' ones(size(NOIlong')) br_maxbidq'];
[b_neg,ci_neg]=regress(meanpricesub(br_noi<0)',X(br_noi'<0,:));
se_neg=(ci_neg(:,2)-b_neg)./1.96;
fprintf('  NOI<0: p_i^M - p^M coef = %.2f (%.3f), N = %d\n', b_neg(1), se_neg(1), sum(br_noi<0));
[b_pos,ci_pos]=regress(meanpricesub(br_noi>0)',X(br_noi'>0,:));
se_pos=(ci_pos(:,2)-b_pos)./1.96;
fprintf('  NOI>0: p_i^M - p^M coef = %.2f (%.3f), N = %d\n', b_pos(1), se_pos(1), sum(br_noi>0));

% Panel 3: Mean bid on mean opposing bid
disp('--- Panel 3: Mean bid on mean opposing bid ---')
for ii=1:max(size(br_auc_id))
    br_meanopp(ii,1)=mean(meanpricesub(br_auc_id==br_auc_id(ii)));
    br_ndeal(ii,1)=sum(br_auc_id==br_auc_id(ii));
end
X=[br_meanopp br_Nsteps' br_auc_noi' br_noi' br_auc_imm' br_ndeal br_ndeal.^2 br_ndeal.^3 br_ndeal.*br_meanopp (br_ndeal.^2).*br_meanopp br_ndeal.*br_meanopp.^2];
[b,ci]=regress(meanpricesub',X);
se=(ci(:,2)-b)./1.96;
fprintf('  Mean Opp. coef = %.2f (%.2f), N = %d\n', b(1), se(1), size(meanpricesub,2));

% Save Table A.1 as LaTeX
fid = fopen(fullfile(tab_path, 'tableA1.tex'), 'w');
fprintf(fid, '\\begin{table}[htbp]\n\\centering\n\\caption{Evidence of Independent Private Values}\n\\label{tab:ipv}\n');
fprintf(fid, '\\begin{tabular}{lc|cc|c}\n\\hline\\hline\n');
fprintf(fid, ' & Slope of bids & \\multicolumn{2}{c|}{Mean bid} & Mean bid \\\\\n');
fprintf(fid, ' &  & NOI$<$0 & NOI$>$0 &  \\\\\n\\hline\n');
fprintf(fid, 'IMM var. & %.3f &  &  &  \\\\\n', A1_immvar_coef);
fprintf(fid, ' & (%.3f) &  &  &  \\\\\n', A1_immvar_se);
fprintf(fid, '$p_i^M - p^M$ &  & %.2f & %.2f &  \\\\\n', b_neg(1), b_pos(1));
fprintf(fid, ' &  & (%.3f) & (%.2f) &  \\\\\n', se_neg(1), se_pos(1));
fprintf(fid, 'Mean Opp. &  &  &  & %.2f \\\\\n', b(1));
fprintf(fid, ' &  &  &  & (%.2f) \\\\\n', se(1));
fprintf(fid, '\\hline\n');
fprintf(fid, '$N$ & %d & %d & %d & %d \\\\\n', size(br_beta,2), sum(br_noi<0), sum(br_noi>0), size(meanpricesub,2));
fprintf(fid, '\\hline\\hline\n\\end{tabular}\n');
fprintf(fid, '\\begin{tablenotes}\\small\\item Standard errors in parentheses. Each column includes additional controls (see text).\\end{tablenotes}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);
disp('Table A.1 saved to output/tables/tableA1.tex')


%make the figure 1 pretty.
%aucid=200
%get list of bidders
sid=table2array(supplyfunctab(:,4));
tid_list=supplyid(sid==200);
ptemp_raw=supplypRAW(sid==200);
qtemp_raw=supplyq_RAW(sid==200);
figure; hold on;
for jj=1:size(tid_list,1)
    ptr=ptemp_raw(strcmp(tid_list,tid_list(jj)));
    [ptr,ict]=sort(ptr,'descend');
jthc=[ptr ptr]';
qtr= qtemp_raw(strcmp(tid_list,tid_list(jj)));
qtr=cumsum(qtr(ict));
qthc=[[0;qtr(1:end-1)] qtr]';
plot(qthc(:),jthc(:),'-','LineWidth',2);
xlabel('Quantity','FontSize',14)
ylabel('Price','FontSize',14)
saveas(gcf,fullfile(fig_path,'bidderdemand.png'))
end
[allp,icp]=sort(ptemp_raw,'descend');
allp=[allp allp]';
qtr=cumsum(qtemp_raw(icp));
qthc=[[0;qtr(1:end-1)] qtr]';
figure; hold on; 
plot(qthc(:),allp(:),'k','LineWidth',2)
plot([47.397;47.397],[35;55],'r--','Linewidth',2)
xlabel('Quantity','FontSize',14)
ylabel('Price','FontSize',14)
saveas(gcf,fullfile(fig_path,'aggdemand.png'))
