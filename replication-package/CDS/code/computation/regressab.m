function [out]=regressab(y,X)

[ya,ci]=regress(y,X);
se=((ya-ci(:,1)))./(2.02);
%counter=1;
for a=1:length(ya)
   out(a*2-1,1)=ya(a); 
   out(a*2,1)=se(a); 
end