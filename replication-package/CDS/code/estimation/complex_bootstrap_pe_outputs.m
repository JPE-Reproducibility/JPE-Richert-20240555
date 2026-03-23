%GET SOME KEY QUANTITIES WITH STANDARD ERRORS
boundwidthCI=[UGMS_CI-LGMS_CI]; boundwidthCI(nout(:,4)==0);
boundwidthCI=[UCLR_CI-LCLR_CI]; boundwidthCI(nout(:,4)==0);
boundwidth=[Ugms-Lgms]; boundwidth(nout(:,4)==0);

%now loop over v-hats: collect all the v-bounds from active bidders
vupbb=[]; vlowbb=[]; vupbb_ci=[]; vlowbb_ci=[];
for aa=1:size(aucidfs,1)
    if nout(aa,4)==0
        vupbb=[vupbb;vout{aa}(:,3)];
        vlowbb=[vlowbb;vout{aa}(:,2)];
        vupbb_ci=[vupbb_ci;vout_ci{aa}(:,3)];
        vlowbb_ci=[vlowbb_ci;vout_ci{aa}(:,2)];
    end
end
boundwidthCI=[vupbb_ci-vlowbb_ci];
boundwidth=[vupbb-vlowbb];




%shading stats bootstrap
shhad=[LShad UShad];
qshad=nout(:,13:14);


load(fullfile(int_path,'bsinprogressCCC'),'nout','vout')
[ncdf,averagesn,wi_lbout,wi_ubout]=cdf_estimator_imm(nout,nout,noi,median(IMM),auc,-300,300);
close;
save(fullfile(int_path,'temp2'))



