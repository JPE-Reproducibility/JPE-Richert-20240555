function [a]=tabstat(x)

a=[size(x,1);nanmean(x);nanstd(x);prctile(x,10);prctile(x,50);prctile(x,90)];