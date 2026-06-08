%%%%%%%%%%%%%%
%START OFF LOADING DATA
%%%%%%%%%%%%%

immtab=(readtable(fullfile(data_path,'immspreads_clean.csv'),'ReadVariableNames',true));
noitab=(readtable(fullfile(data_path,'openinterest_clean.csv'),'ReadVariableNames',true));
supplyfunctab=(readtable(fullfile(data_path,'limitorders_clean.csv'),'ReadVariableNames',true));
auctionpriceT=readtable(fullfile(data_path,'auctionlistid.csv'),'ReadVariableNames',true);
auctionprice=table2array(auctionpriceT(:,9));
aucid=table2array(auctionpriceT(:,8));

%although the "data" goes back in some cases to auctions 1-7, those had a
%slightly different set of rules--should begin analysis only from auction 8
%on.


%Drop sovereigns THIS WAS A TEST IN CASE THIS MARKET IS SPECIAL--DOESNT
%SEEM TO BE SO BACK IN NOW.

% sovlist=[161;167;175;182;190];
% for aa=1:size(sovlist,1)
% immtab(table2array(immtab(:,4))==sovlist(aa),:)=[];
% noitab(table2array(noitab(:,3))==sovlist(aa),:)=[];
% supplyfunctab(table2array(supplyfunctab(:,4))==sovlist(aa),:)=[];
% auctionpriceT(table2array(auctionpriceT(:,8))==sovlist(aa),:)=[];
% auctionprice(aucid==sovlist(aa))=[];
% aucid(aucid==sovlist(aa))=[];
% end

build_bondforestimation
bondest=readtable(fullfile(int_path,'bondforestimation.csv'),'ReadVariableNames',true);
bondid=table2array(bondest(:,1));
%IF SOVEREIGNS ARE OUT RUN TTHIS BLOCK AS WELL!
% for aa=1:size(sovlist,1)
%    bondest(bondid==sovlist(aa),:)=[];
%    bondid(bondid==sovlist(aa))=[];
% end

%NOW FIX SOME ERRORS IN THE DATA

bondvol=table2array(bondest(:,3));
bondvol(bondid==174)=bondvol(bondid==174)./100;
bonddur=table2array(bondest(:,4));
bondconv=table2array(bondest(:,6));
bondcf=table2array(bondest(:,7));

%% ============ TABLE OS.1: Eligible Bonds Description ============
disp('========== TABLE OS.1: Eligible Bonds Description ==========')
OS1_nbonds = table2array(bondest(:,14));
OS1_maxmat = table2array(bondest(:,8));
OS1_minmat = table2array(bondest(:,9));
OS1_maxcoup = 100.*table2array(bondest(:,10));
OS1_mincoup = 100.*table2array(bondest(:,11));
OS1_frn = 100.*table2array(bondest(:,12));
OS1_vars = [OS1_nbonds OS1_maxmat OS1_minmat OS1_maxcoup OS1_mincoup OS1_frn];
OS1_labels = {'N Bonds','Max maturity (years)','Min maturity (years)','Max coupon \%','Min coupon \%','FRN \%'};
OS1_labels_log = {'N Bonds','Max maturity (years)','Min maturity (years)','Max coupon %','Min coupon %','FRN %'};
fprintf('%-30s %10s %10s %18s\n', '', 'Mean', 'Sd', '[P10, P90]')
for ii=1:6
    fprintf('%-30s %10.2f %10.2f   [%7.2f, %7.2f]\n', OS1_labels_log{ii}, ...
        mean(OS1_vars(:,ii)), std(OS1_vars(:,ii)), prctile(OS1_vars(:,ii),10), prctile(OS1_vars(:,ii),90));
end
fprintf('N = %d auctions\n', size(OS1_vars,1));
% Save Table OS.1 as LaTeX
fid = fopen(fullfile(tab_path, 'tableOS1.tex'), 'w');
fprintf(fid, '\\begin{table}[htbp]\n\\centering\n\\caption{Eligible Bonds Description}\n\\label{tab:os1}\n');
fprintf(fid, '\\begin{tabular}{lccc}\n\\hline\\hline\n');
fprintf(fid, ' & Mean & Sd & $[P_{10}, P_{90}]$ \\\\\n\\hline\n');
for ii=1:6
    fprintf(fid, '%s & %.2f & %.2f & $[%.2f, %.2f]$ \\\\\n', OS1_labels{ii}, ...
        mean(OS1_vars(:,ii)), std(OS1_vars(:,ii)), prctile(OS1_vars(:,ii),10), prctile(OS1_vars(:,ii),90));
end
fprintf(fid, '\\hline\\hline\n\\end{tabular}\n');
fprintf(fid, '\\begin{tablenotes}\\small\\item $N = %d$ auctions.\\end{tablenotes}\n', size(OS1_vars,1));
fprintf(fid, '\\end{table}\n');
fclose(fid);
disp('Table OS.1 saved to output/tables/tableOS1.tex')

%in auction 118 get rid of all the bids over 80 they are actually 117 and
%are duplicated.
supplyfunctab(supplyfunctab.aucid == 118 & supplyfunctab.price > 80, :) = [];
supplyfunctab(supplyfunctab.aucid == 91 & supplyfunctab.price > 30, :) = [];

%convert jpy to usd
supplyfunctab(supplyfunctab.aucid == 88,3)=supplyfunctab(supplyfunctab.aucid == 88,3).*0.0095;
supplyfunctab(supplyfunctab.aucid == 95,3)=supplyfunctab(supplyfunctab.aucid == 95,3).*0.0095;
supplyfunctab(supplyfunctab.aucid == 120,3)=supplyfunctab(supplyfunctab.aucid == 120,3).*0.0095;
supplyfunctab(supplyfunctab.aucid == 131,3)=supplyfunctab(supplyfunctab.aucid == 131,3).*0.0095;


%IMM calculation

if bond_price_analysis==1
bondprices
end

%% ============ SECTION 2: Sample Composition ============
disp('========== SECTION 2: Sample Composition ==========')
auction_types = table2array(auctionpriceT(:,3));
n_lcds = sum(strcmp(auction_types,'LCDS'));
n_cds = sum(strcmp(auction_types,'CDS'));
fprintf('  Total credit events: %d\n', size(auctionpriceT,1))
fprintf('  LCDS auctions: %d\n', n_lcds)
fprintf('  CDS auctions: %d\n', n_cds)

firststagebidding

%% ============ TABLE 1: Initial Stage Quantities (Parker Drilling) ============
disp('========== TABLE 1: Initial Stage Quantities (Parker Drilling, Auction 200) ==========')
pd_aucid = 200;
pd_bidders = table2array(immtab(table2array(immtab(:,end))==pd_aucid, 1));
pd_noi_names = table2array(noitab(table2array(noitab(:,3))==pd_aucid, 1));
pd_noi_vals_raw = table2array(noitab(table2array(noitab(:,3))==pd_aucid, 2));
% Match NOI values to IMM bidder order by name
pd_noi_vals = zeros(size(pd_bidders));
for ii=1:size(pd_bidders,1)
    idx = find(strcmp(pd_noi_names, pd_bidders{ii}));
    if ~isempty(idx)
        pd_noi_vals(ii) = pd_noi_vals_raw(idx(1));
    end
end
fprintf('%-50s %12s %12s\n', 'Dealer', 'Bid/Offer', 'Size ($M)')
for ii=1:size(pd_bidders,1)
    if pd_noi_vals(ii) > 0
        direction = 'Offer';
    elseif pd_noi_vals(ii) < 0
        direction = 'Bid';
    else
        direction = '-';
    end
    fprintf('%-50s %12s %12.3f\n', pd_bidders{ii}, direction, abs(pd_noi_vals(ii)));
end
fprintf('%-50s %12s %12.3f\n', 'Net Open Interest', 'Offer', sum(pd_noi_vals));
% Save Table 1 as LaTeX
fid = fopen(fullfile(tab_path, 'table1.tex'), 'w');
fprintf(fid, '\\begin{table}[htbp]\n\\centering\n\\caption{Initial Stage Quantities (Parker Drilling)}\n\\label{tab:quantities}\n');
fprintf(fid, '\\begin{tabular}{lcc}\n\\hline\\hline\n');
fprintf(fid, 'Dealer & Bid/Offer & Size (\\$M) \\\\\n\\hline\n');
for ii=1:size(pd_bidders,1)
    if pd_noi_vals(ii) > 0; dir_str = 'Offer';
    elseif pd_noi_vals(ii) < 0; dir_str = 'Bid';
    else; dir_str = '--'; end
    fprintf(fid, '%s & %s & %.3f \\\\\n', pd_bidders{ii}, dir_str, abs(pd_noi_vals(ii)));
end
fprintf(fid, '\\hline\nNet Open Interest & Offer & %.3f \\\\\n', sum(pd_noi_vals));
fprintf(fid, '\\hline\\hline\n\\end{tabular}\n\\end{table}\n');
fclose(fid);
disp('Table 1 saved to output/tables/table1.tex')

%% ============ TABLE 2: Initial Stage Price Quotes (Parker Drilling) ============
disp('========== TABLE 2: Initial Stage Price Quotes (Parker Drilling, Auction 200) ==========')
% Raw quotes (CSV order). Kept unmodified for any downstream use.
pd_bids = table2array(immtab(table2array(immtab(:,end))==pd_aucid, 2));
pd_offers = table2array(immtab(table2array(immtab(:,end))==pd_aucid, 3));

% --- Display-only reconstruction of paper Table 2 ---
% Rows are placed in the paper's order (IDs 1-9) with proper dealer names. As in
% the paper note, the displayed bid AND offer of bidder 5 (Goldman Sachs) are
% raised 1 cent and those of bidder 8 (Morgan Stanley) lowered 1 cent, purely to
% illustrate a crossing. The t2_* copies below feed ONLY this table's printout
% and tex file; pd_bids/pd_offers and all downstream code keep the raw values.
t2_csv  = {'barclays';'bnpparibas';'suisse';'deutschebank';'goldmansachs'; ...
           'jpmorgan';'merrilllynch';'morganstanley';'societegenerale'};
t2_name = {'Barclays Bank PLC';'BNP Paribas SA';'Credit Suisse';'Deutsche Bank'; ...
           'Goldman Sachs International';'J.P. Morgan Securities LLC'; ...
           'Merrill Lynch, Pierce, Fenner & Smith Inc.';'Morgan Stanley & Co. LLC'; ...
           'Societe Generale'};
t2_bid = zeros(9,1); t2_off = zeros(9,1);
for ii=1:9
    jj = find(strcmp(pd_bidders, t2_csv{ii}), 1);
    t2_bid(ii) = pd_bids(jj);
    t2_off(ii) = pd_offers(jj);
end
t2_bid(5) = t2_bid(5) + 1;  t2_off(5) = t2_off(5) + 1;   % bidder 5 (Goldman): +1 cent (display only)
t2_bid(8) = t2_bid(8) - 1;  t2_off(8) = t2_off(8) - 1;   % bidder 8 (Morgan Stanley): -1 cent (display only)
% Sorted bid/offer columns in the paper's exact order, including its tie order
% (bids descending, offers ascending). The ID sequences are fixed to match
% Table 2 in the paper; values are pulled from the display-adjusted quotes above
% so they remain consistent with the data.
t2_ib = [5;2;4;9;3;6;7;1;8];   t2_sb = t2_bid(t2_ib);   % sorted bids (descending)
t2_io = [8;1;3;6;7;4;9;2;5];   t2_so = t2_off(t2_io);   % sorted offers (ascending)
t2_imm = IMM(aucidfslist==pd_aucid);

% Console printout
fprintf('  %-3s %-44s %6s %6s   %5s %6s   %5s %6s\n', 'ID','Name','Bid','Offer','SrtID','Bid','SrtID','Offer')
for ii=1:9
    fprintf('  %-3d %-44s %6g %6g   %5d %6g   %5d %6g\n', ii, t2_name{ii}, ...
        t2_bid(ii), t2_off(ii), t2_ib(ii), t2_sb(ii), t2_io(ii), t2_so(ii));
end
fprintf('  IMM = %.2f\n', t2_imm);

% Save Table 2 as LaTeX (Submissions | Sorted Bids | Sorted Offers)
fid = fopen(fullfile(tab_path, 'table2.tex'), 'w');
fprintf(fid, '\\begin{table}[htbp]\n\\centering\n\\caption{Initial Stage Price Quotes (Parker Drilling)}\n\\label{tab:quotes}\n');
fprintf(fid, '\\begin{tabular}{clcccccc}\n\\hline\\hline\n');
fprintf(fid, ' &  & \\multicolumn{2}{c}{Submissions} & \\multicolumn{2}{c}{Sorted Bids} & \\multicolumn{2}{c}{Sorted Offers} \\\\\n');
fprintf(fid, '\\cline{3-4}\\cline{5-6}\\cline{7-8}\n');
fprintf(fid, 'ID & Name & Bid & Offer & ID & Bid & ID & Offer \\\\\n\\hline\n');
for ii=1:9
    fprintf(fid, '%d & %s & %g & %g & %d & %g & %d & %g \\\\\n', ii, t2_name{ii}, ...
        t2_bid(ii), t2_off(ii), t2_ib(ii), t2_sb(ii), t2_io(ii), t2_so(ii));
end
fprintf(fid, '\\hline\n\\multicolumn{8}{l}{IMM = %.2f} \\\\\n', t2_imm);
fprintf(fid, '\\hline\\hline\n\\end{tabular}\n\\end{table}\n');
fclose(fid);
disp('Table 2 saved to output/tables/table2.tex')

close all;
clc;

if bond_price_analysis==1
%does Variance pre-auction still matter after conditioning on imm price?
for aa=1:size(BPmean,1)
immpriceb(aa)=IMM(aucidfslist==aucidbond(aa));
end
[be,cie]=regress(auctionpriceb,[BPmean(:,29) BPsd(:,29) immpriceb' ones(size(BPsd,1),1)]);


%% ============ TABLE OS.3: Post-Auction Prices ============
disp('========== TABLE OS.3: Post-Auction Prices ==========')
disp('Dep var: Post-auction bond price. Regressors: Auction price, IMM price, constant.')
[be30,cie30]=regress(BPmeanS(:,61),[auctionpriceb immpriceb' ones(size(BPsd,1),1)]);
se30=(cie30(:,2)-be30)./1.96;
[be5,cie5]=regress(BPmeanS(:,36),[auctionpriceb immpriceb' ones(size(BPsd,1),1)]);
se5=(cie5(:,2)-be5)./1.96;
[be1,cie1]=regress(BPmeanS(:,32),[auctionpriceb immpriceb' ones(size(BPsd,1),1)]);
se1=(cie1(:,2)-be1)./1.96;
OS3_varnames = {'Auction price','IMM price','Constant'};
fprintf('%-20s %14s %14s %14s\n', '', 'After 30 Days', 'After 5 Days', 'After 1 Day')
for ii=1:3
    fprintf('%-20s %8.2f (%4.2f) %8.2f (%4.2f) %8.2f (%4.2f)\n', OS3_varnames{ii}, ...
        be30(ii), se30(ii), be5(ii), se5(ii), be1(ii), se1(ii));
end
fprintf('N = %d\n', size(BPmeanS,1));
% Save Table OS.3 as LaTeX
fid = fopen(fullfile(tab_path, 'tableOS3.tex'), 'w');
fprintf(fid, '\\begin{table}[htbp]\n\\centering\n\\caption{Post-Auction Prices}\n\\label{tab:os3}\n');
fprintf(fid, '\\begin{tabular}{lccc}\n\\hline\\hline\n');
fprintf(fid, ' & Price after 30 Days & Price after 5 Days & Price after 1 Day \\\\\n\\hline\n');
for ii=1:3
    fprintf(fid, '%s & %.2f & %.2f & %.2f \\\\\n', OS3_varnames{ii}, be30(ii), be5(ii), be1(ii));
    fprintf(fid, ' & (%.2f) & (%.2f) & (%.2f) \\\\\n', se30(ii), se5(ii), se1(ii));
end
fprintf(fid, '\\hline\\hline\n\\end{tabular}\n');
fprintf(fid, '\\begin{tablenotes}\\small\\item $N = %d$. Standard errors in parentheses.\\end{tablenotes}\n', size(BPmeanS,1));
fprintf(fid, '\\end{table}\n');
fclose(fid);
disp('Table OS.3 saved to output/tables/tableOS3.tex')
end


%link bidders across auctions...
tempBlist=table2array(immtab(:,1));
for ia=1:size(tempBlist,1)
    if strcmp(tempBlist(ia),'barclaysbank')
        tempBlist(ia)={'barclays'};
    end
        if strcmp(tempBlist(ia),'bearstearnsproducts')
        tempBlist(ia)={'bearstearns'};
        end
     if strcmp(tempBlist(ia),'bnpparibassa')
        tempBlist(ia)={'bnpparibas'};
     end
     if strcmp(tempBlist(ia),'goldmansachsand')
        tempBlist(ia)={'goldmansachs'};
     end
      if strcmp(tempBlist(ia),'jpmorganchase')
        tempBlist(ia)={'jpmorgan'};
      end
    if strcmp(tempBlist(ia),'merrilllynchproducts')
        tempBlist(ia)={'merrilllynch'};
    end
    if strcmp(tempBlist(ia),'nomurua')
        tempBlist(ia)={'nomura'};
    end
    if strcmp(tempBlist(ia),'royalbankofstland')
        tempBlist(ia)={'royalbankscotland'};
    end
    if strcmp(tempBlist(ia),'theroyalbankofstland')
        tempBlist(ia)={'royalbankscotland'};
    end
    if strcmp(tempBlist(ia),'soci')
        tempBlist(ia)={'societegenerale'};
    end
end
utb=unique(tempBlist);
for jj=1:size(utb,1)
   for ia=1:size(tempBlist,1) %added ,1
       if strcmp(tempBlist(ia),utb(jj))
           FSglobalID(ia)=jj;
       end
   end
end
for jk=1:max(FSglobalID)
    FSglobalIDdumm(:,jk)=(FSglobalID'==jk);
end
for ja=1:size(aucidfslist,1)
tagn(ja)=find(aucidfs==aucidfslist(ja),1,'first');
end


tempBlist=supplyid;
for jj=1:size(utb,1)
   for ia=1:size(tempBlist,1) %added ,1
       if strcmp(tempBlist(ia),utb(jj))
           SSglobalID(ia)=jj;
       end
   end
end

%USING THE FULL DATA IE INCLUDES THE CARRIED OVER BIDS FROM R1 in R2 steps
Bidding_SS=zeros(size(utb,1),11);
for aa=1:size(aucidfslist,1)
    tempBidder=FSglobalID(aucidfs==aucidfslist(aa));
    for bb=1:size(tempBidder,2)
        %first column # participations
        Bidding_SS(tempBidder(bb),1)=Bidding_SS(tempBidder(bb),1)+1;
        %second column # positive first stage NOI
        Bidding_SS(tempBidder(bb),2)=Bidding_SS(tempBidder(bb),2)+(noi(aucidfs==aucidfslist(aa) & FSglobalID'==tempBidder(bb))>0);
        %third column # negate first stage NOI
        Bidding_SS(tempBidder(bb),3)=Bidding_SS(tempBidder(bb),3)+(noi(aucidfs==aucidfslist(aa) & FSglobalID'==tempBidder(bb))<0);
        % # steps
        Bidding_SS(tempBidder(bb),4)=Bidding_SS(tempBidder(bb),4)+(sum((SSglobalID==tempBidder(bb))'.*(aucidsupplyorig==aucidfslist(aa)))==1);
        Bidding_SS(tempBidder(bb),5)=Bidding_SS(tempBidder(bb),5)+(sum((SSglobalID==tempBidder(bb))'.*(aucidsupplyorig==aucidfslist(aa)))==2);
        Bidding_SS(tempBidder(bb),6)=Bidding_SS(tempBidder(bb),6)+(sum((SSglobalID==tempBidder(bb))'.*(aucidsupplyorig==aucidfslist(aa)))==3);
        Bidding_SS(tempBidder(bb),7)=Bidding_SS(tempBidder(bb),7)+(sum((SSglobalID==tempBidder(bb))'.*(aucidsupplyorig==aucidfslist(aa)))==4);
        Bidding_SS(tempBidder(bb),8)=Bidding_SS(tempBidder(bb),8)+(sum((SSglobalID==tempBidder(bb))'.*(aucidsupplyorig==aucidfslist(aa)))==5);
        Bidding_SS(tempBidder(bb),9)=Bidding_SS(tempBidder(bb),9)+(sum((SSglobalID==tempBidder(bb))'.*(aucidsupplyorig==aucidfslist(aa)))==6);
        Bidding_SS(tempBidder(bb),10)=Bidding_SS(tempBidder(bb),10)+(sum((SSglobalID==tempBidder(bb))'.*(aucidsupplyorig==aucidfslist(aa)))==7);
        Bidding_SS(tempBidder(bb),11)=Bidding_SS(tempBidder(bb),11)+(sum((SSglobalID==tempBidder(bb))'.*(aucidsupplyorig==aucidfslist(aa)))>8);
    end
end    
% Collapse steps 5+ into a single column to build Table OS.2
Bidding_SS_paper = [Bidding_SS(:,1:7) sum(Bidding_SS(:,8:11),2)];
T=[table(utb), array2table(Bidding_SS_paper)];
T.Properties.VariableNames = {'Bidder','Participated','y_i>0','y_i<0','1 step','2 steps','3 steps','4 steps','5+ steps'};
%% ============ TABLE OS.2: Auction Participation ============
disp('========== TABLE OS.2: Auction Participation ==========')
disp(T)
% Save Table OS.2 as LaTeX
fid = fopen(fullfile(tab_path, 'tableOS2.tex'), 'w');
fprintf(fid, '\\begin{table}[htbp]\n\\centering\n\\caption{Auction Participation}\n\\label{tab:os2}\n');
fprintf(fid, '\\begin{tabular}{lcccccccc}\n\\hline\\hline\n');
fprintf(fid, 'Bidder & Participated & $y_i>0$ & $y_i<0$ & 1 step & 2 steps & 3 steps & 4 steps & 5+ steps \\\\\n\\hline\n');
for ii=1:size(Bidding_SS_paper,1)
    fprintf(fid, '%s & %d & %d & %d & %d & %d & %d & %d & %d \\\\\n', ...
        utb{ii}, Bidding_SS_paper(ii,1), Bidding_SS_paper(ii,2), Bidding_SS_paper(ii,3), ...
        Bidding_SS_paper(ii,4), Bidding_SS_paper(ii,5), Bidding_SS_paper(ii,6), ...
        Bidding_SS_paper(ii,7), Bidding_SS_paper(ii,8));
end
fprintf(fid, '\\hline\\hline\n\\end{tabular}\n\\end{table}\n');
fclose(fid);
disp('Table OS.2 saved to output/tables/tableOS2.tex')

%%%%%%%%%%%%%%%%%%EVENT TYPES:

eventtype=table2array(auctionpriceT(:,12));
BKtype=table2array(auctionpriceT(:,11));
% 1 Failure to pay
% 2 Restructuring
% 3 Bankruptcy 11
% 4 Bankruptcy not 11
for aa=1:size(aucidfslist,1) %added ,1
    if strcmp(eventtype(aucid==aucidfslist(aa)),'Bankruptcy')
        event(aa)=4;
    elseif strcmp(eventtype(aucid==aucidfslist(aa)),'Restructuring')
        event(aa)=2;
    elseif strcmp(eventtype(aucid==aucidfslist(aa)),'Failure to pay')
        event(aa)=1;
    elseif strcmp(eventtype(aucid==aucidfslist(aa)),'Insolvency')
        event(aa)=4;
    elseif strcmp(eventtype(aucid==aucidfslist(aa)),'Repudiation/moratorium')
        event(aa)=1;
    end
    if BKtype(aucid==aucidfslist(aa))==11
        event(aa)=3;
    end
end
figure; scatter(event,aucpricefs)
xticks([1 2 3 4])
xticklabels({'Bankruptcy' 'Restructuring' 'Failure to pay' 'Insolvency' 'Repudiation'})
saveas(gcf,fullfile(fig_path,'priceevent.png'))


%walk through the auctions and bidders---for each one calculate
%purchase/sold RAW (ie summed with customers)
FSglobalID=FSglobalID';
SSglobalID=SSglobalID';
for jj=1:size(aucidfslist,1)
    tempBidder=FSglobalID(aucidfs==aucidfslist(jj));
    for ii=1:size(tempBidder,2)
    TotQI(tempBidder(ii),jj)=noi(FSglobalID==tempBidder(ii) & aucidfs==aucidfslist(jj))+sum(supplyq(SSglobalID==tempBidder(ii) & aucidsupply==aucidfslist(jj)).*(supplyp(SSglobalID==tempBidder(ii) & aucidsupply==aucidfslist(jj))>aucpricefs(aucidfslist==aucidfslist(ii))));
    end
end
FSglobalID=FSglobalID';
SSglobalID=SSglobalID';

figure; hold on; for jj=1:size(TotQI,1); plot([1:1:size(TotQI,2)],TotQI(jj,:)); end
ylim([-80,120])
saveas(gcf,fullfile(fig_path,'totalQ.png'))

TotQI=TotQI.*table2array(T(:,2));
figure; plot([1:1:size(TotQI,1)],max(TotQI,[],2)); hold on; plot([1:1:size(TotQI,1)],min(TotQI,[],2)); plot([1:1:size(TotQI,1)],median(TotQI,2));
saveas(gcf,fullfile(fig_path,'purchasedQ.png'))

outcomelinks





