function [xout]=normalizeXs(x,A,lb,ub)

ub(3)=ub(3)-sum(ub(1:2));
xout=(lb + ub.*exp(x))./(1+exp(x));
xout(1:3)=cumsum(xout(1:3));

