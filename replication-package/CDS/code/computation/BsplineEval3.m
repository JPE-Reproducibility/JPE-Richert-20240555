function [f,fprime,fdblprime,ftrplprime] = BsplineEval3(knotvec,params,dom)
% © Brent R. Hickman, Timothy P. Hubbard, and Harry J. Paarsch
%
% please cite our Quantitative Economics paper "Identification and
% Estimation of a Bidding Model for Electronic Auctions" if this code is
% helpful to you.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This function evaluates cubic B-spline functions at points in domain vector 
%dom (Tx1), based on knot vector knotvec (K+1x1) and parameter vector params 
%(K+3x1).  The default output is a vector f (Tx1) which contains functional
%values.  Optional outputs include up to 3 other vectors (also Tx1) which
%contain the first, second, and/or third derivatives of f at the points in
%dom.
%
%%%%%%%%SYNTAX:                f = BsplineEval3(knotvec,params,dom)
%                     [f,fprime] = BsplineEval3(knotvec,params,dom)
%           [f,fprime,fdblprime] = BsplineEval3(knotvec,params,dom)
%[f,fprime,fdblprime,ftrplprime] = BsplineEval3(knotvec,params,dom)


if nargout==1
    Basis = BsplineBasis3(knotvec,dom,'off');
    f = Basis*params;
elseif nargout==2
    [Basis,~,Basisprime] = BsplineBasis3(knotvec,dom,'off');
    f = Basis*params;
    fprime = Basisprime*params;
elseif nargout==3
    [Basis,~,Basisprime,Basisdblprime] = BsplineBasis3(knotvec,dom,'off');
    f = Basis*params;
    fprime = Basisprime*params;
    fdblprime = Basisdblprime*params;
elseif nargout==4
    [Basis,~,Basisprime,Basisdblprime,Basistrplprime] = BsplineBasis3(knotvec,dom,'off');
    f = Basis*params;
    fprime = Basisprime*params;
    fdblprime = Basisdblprime*params;
    ftrplprime = Basistrplprime*params;
end
    
    