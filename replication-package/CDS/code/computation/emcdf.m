function [ Fi] = emcdf(bos,V)
%Calculate empirical dist...transform and max
s=size(bos);
for i=1:s(2)
[ftemp, Dtemp]=ecdf(bos(:,i));
for vv=1:length(V)
if V(vv)<min(Dtemp)
    Fi(vv,i)=0;
else
     Fi(vv,i)=max(ftemp(Dtemp<=V(vv)));
end
end
end

