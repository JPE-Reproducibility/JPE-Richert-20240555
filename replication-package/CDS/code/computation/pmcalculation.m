function [pM, Efine]=pmcalculation(x,noi_i,noi_sim,immh_sim,imml_sim,Nbidders,nsim)
%from this build a function that computes pM (vector simulated) given any input of price for
%bidder i.--and computes the expected fine from that choice.
xhi=x+2; xlo=x-2;
rng(123);
for aa=1:nsim
%draw Nbidders-1 from immhtemp
tri=randi(size(immh_sim,1),Nbidders,1);
thigh=[xhi; immh_sim(tri)]; tlow=[xlo; imml_sim(tri)];
noisim=sum(noi_sim(tri))+noi_i;
[ths,ich]=sort(thigh,'ascend');
[tls,icl]=sort(tlow,'descend');
crossing=(tls>=ths);
ntoaverage=ceil(sum(crossing==0)./2);
tls(crossing==1)=[]; ths(crossing==1)=[];
pM(aa)=sum((ths(1:ntoaverage))+(tls(1:ntoaverage)))./(2.*ntoaverage);
xhcross=crossing(ich==1);
xlcross=crossing(icl==1);
Efine(aa)=2000000.*max(pM(aa)-xhi,0).*(xhcross).*(noisim<0)+2000000.*max(xlo-pM(aa),0).*(xlcross).*(noisim>0);
end
Efine=mean(Efine);
end

