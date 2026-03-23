function [Y,Z,Yprime,Ydblprime,Ytrplprime] = BsplineBasis3(knotvec,dom,warn)
% © Brent R. Hickman, Timothy P. Hubbard, and Harry J. Paarsch
% hickmanbr@uchicago.edu, timothy.hubbard@colby.edu, hjpaarsch@gmail.com
%
% please cite our Quantitative Economics paper "Identification and
% Estimation of a Bidding Model for Electronic Auctions" if this code is
% helpful to you.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This function computes cubic B-spline basis functions based on knot vector 
%knotvec (K+1x1), and evaluates them at the points in dom (Tx1).  The
%default output is a matrix Y (TxK+3) in which the jth column contains
%functional values for the jth B-spline basis function, call it Bj(dom), 
%j=1,...,K+3 evaluated at each point x in dom.  A spline function, call it
%f(dom), is simply a weighted sum of these basis functions, say
%f(dom)=alpha_{1}B1(dom)+...+alpha_{J}BJ(dom), j=1,...,J=K+3.  Although alpha
%does not enter this program, to evaluate f at each point in dom, simply
%construct a weighting vector alpha (K+3x1) and take the product Y*alpha to
%get a Tx1 vector containing f(dom) for each point in dom.
%
%%%%%%%%SYNTAX:                  Y = BsplineBasis3(knotvec,dom,warn)
%                            [Y,Z] = BsplineBasis3(knotvec,dom,warn)
%                     [Y,Z,Yprime] = BsplineBasis3(knotvec,dom,warn)
%           [Y,Z,Yprime,Ydblprime] = BsplineBasis3(knotvec,dom,warn)
%[Y,Z,Yprime,Ydblprime,Ytrplprime] = BsplineBasis3(knotvec,dom,warn)
%                                Y = BsplineBasis3(knotvec,dom)
%                            [Y,Z] = BsplineBasis3(knotvec,dom)
%                     [Y,Z,Yprime] = BsplineBasis3(knotvec,dom)
%           [Y,Z,Yprime,Ydblprime] = BsplineBasis3(knotvec,dom)
%[Y,Z,Yprime,Ydblprime,Ytrplprime] = BsplineBasis3(knotvec,dom)
%
%NOTE: The third input argument, warn, is optional.  If left unspecified, 
%the default value is set to 'on' and the program outputs warning messages 
%when the user supplies a non-ascending knot vector, or one with interior 
%knots of multiplicity>1. If the user wishes to suppress these warning 
%messages, input a value of either 0 (numeric) or 'off' (string) for warn.  
%
%The program can also produce three optional outputs: 
%
%   1) Z (KxK+3) is a matrix which indicates intervals where each of the 
%   basis functions are nonzero.  Since knotvec is K+1x1, it defines K
%   subintervals of the form [knotvec(i),knotvec(i+1)), i=1,...,K.  
%   Moreover, each cubic spline basis function is only nonzero on at most 4 
%   subintervals.  The i-jth entry Z(i,j)==1 if Bj(dom)~=0 for dom in 
%   (knotvec(i),knotvec(i+1)), and Z(i,j)==0 otherwise.  This matrix may 
%   serve as an aid in evaluating functional values or derivatives for the 
%   final spline function.
%
%   2) Yprime (TxK+3) is a matrix containing the first derivatives of the
%   spline basis functions at points x in dom.  From above, it follows that 
%   in order to compute the derivative of f(dom) for each point in dom, 
%   simply take the product Yprime*alpha.
%
%   3) Similarly, Ydblprime (TxK+3) contains second derivatives of the
%   spline basis functions at points in dom.  once again, in order to 
%   compute the derivative of f(dom) for each point in dom, simply take the
%   product Ydblprime*alpha.
%
%   4) Finally, Ytrplprime (TxK+3) contains third derivatives of the
%   spline basis functions at points in dom.  once again, in order to 
%   compute the derivative of f(dom) for each point in dom, simply take the
%   product Ytrplprime*alpha.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%  COMPUTATION ALGORITHM:  %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%Rather than working directly with knotvec, which contains elements
%%%%A=knotvec(1),knotvec(2),...,knotvec(K),knotvec(K+1)=B, we start by
%%%%constructing an extended knot vector with 3 extra copies of A and B
%%%%added onto the beginning and end, respectively, with indexing x(i)
%%%%ranging from i=-2,1,0,1,...,K,K+1,K+2,K+3,K+4. In other words, 
%%%%{x(-2),...,x(K+4)} = {A,A,A,A,knotvec(2),...,knotvec(K),B,B,B,B}. 
%%%%We use coincident boundary knots for reasons that will become  clear
%%%%in the definitions given below.
%%%%
%%%%B-spline basis functions are computed according to the Cox-de Boor 
%%%%recursion formula (see de Boor (2001, Springer), Chapter IX, Eqns 
%%%%(11)-(15).  For completeness, here it is: 
%%%% 
%%%%Begin with the order 1 (degree d=0) B-spline basis, defined by
%%%%
%%%% B_{i,0}(dom) = 1 if dom in [knotvec(i),knotvec(i+1)); 0 otherwise, i=1:K.
%%%%
%%%%Then, to compute the order d+1 spline basis (of degree d>0), we use
%%%%                         
%%%% B_{i,d+1}(dom) = B_{i,d}(dom)*[dom-x(i)]/[x(i+d)-x(i)] +
%%%%                B_{i+1,d}(dom)*[x(i+1)-dom]/[x(i+d+1)-x(i+1)],
%%%%                         WITH
%%%%                i=3-d+1:K+d, d=1,2,3.
%%%%IMPORTANT NOTE:
%%%%For any knot pair where the denominator (knotvec(i+d)-knotvec(i))==0, 
%%%%or where (knotvec(i+d+1)-knotvec(i+1))==0, the convention will be to 
%%%%assign the corresponding term in B_{i,d+1}(x) a value of zero, and 
%%%%evaluate the remainder of the formula as usual.
%%%%
%%%%To obtain derivatives, we use the following well-known formula:
%%%%
%%%% B_{i,d+1}'(dom) = d*( B_{i,d}(dom)/[x(i+d)-x(i)] +
%%%%                     B_{i+1,d}(dom)/[x(i+d+1)-x(i+1)] ),
%%%%                          WITH
%%%%                 i=3-d+1:K+d, d=2,3.
%%%%
%%%%Once again, we use the same caveat as above to deal with zeros in 
%%%%denominators.                 
if nargin==2
    warn='on';
end
if sum(knotvec==sort(knotvec))~=length(knotvec)
    if ~(strcmpi(warn,'off') | warn==0);
        warning('BsplineBasis3:NonAscendKnotVec','the user-supplied knot vector was not non-decreasing; function will use a sorted version of knotvec.')
    end
    knotvec=sort(knotvec);
end

if length(knotvec)-length(unique(knotvec))>=1 && nargout==4
    if ~(strcmpi(warn,'off') | warn==0)
        warning('BsplineBasis3:C2Fail','existence of knots with multiplicity at least two implies discontinuous second derivatives at those points!')
    end
end
if length(knotvec)-length(unique(knotvec))>=2 && nargout>=3
    if ~(strcmpi(warn,'off') | warn==0)
        warning('BsplineBasis3:C1Fail','existence of knots with multiplicity at least three implies discontinuous first derivatives at those points!')
    end
end

dimknotvec = size(knotvec);
dimdom = size(dom);
if dimknotvec(2)~=1 || dimdom(2)~=1
    error('BsplineBasis3:ColumnError','Inputs must be column vectors!')
end

if nargout==5  %%%Since the third derivative is constant, we will compute it numerically 
               %%%%from the slope of the second derivative.  To do that, we will also compute second
               %%%%derivatives at the knot vector points.  For temporary puropses then, we append
               %%%%the knot vector to the end of the domain vector, so that the levels and
               %%%%derivatives of the basis functions will be computed at the knot vector points. 
               %%%%Then at the end we will remove this terminal section from the end of these
               %%%%objects before terminaing computation.
    test1  = [unique(dom);unique(knotvec(2:end-1))];
    test2  = length(test1);
    test1  = unique([dom;knotvec(2:end-1)]);
    if test2~=length(test1) && nargout==5
        warning('BsplineBasis3: third derivativatives at knot vector points correspond to left-hand derivatives, except at the lower boundary knot, where output corresponds to the right-hand derivative.')
    end
    dom   = [dom; knotvec];
end


A = min(knotvec); %%%%This is the lower bound of the domain
B = max(knotvec); %%%%This is the upper bound of the domain
K = length(knotvec)-1; %%%%This is the number of subintervals on [A,B] defined by knotvec
D = 3;  %%%%This is the degree of the spline basis functions to be computed

%%%%The following two lines extend the knot vector in order to help with
%%%%defining the B-spline basis functions.  To see why doing so is helpful,
%%%%see Judd (1998, MIT Press), Section 6.9, pp.225-228.
k = K+2*D;  %%%%This is the extended number of intervals where basis functions will be computed.
x = [A*ones(D,1); knotvec; B*ones(D,1)]; %%%%This is the extended knot vector described above in the introduction.


%%%%This first loop computes the first order basis functions (of degree 
%%%%zero), which are a set of indicators on each interval.
order1 = 1; 
d0=order1-1; %%%%d stands for "degree"
B0 = zeros(length(dom),k); %%%%This will contain the basis functions.  Note
                           %%%%that B0 has k=K+2*D=K+6 columns, with each 
                           %%%%indexed i=-2,-1,0,1,...,K,K+1,K+2,K+3.  
                           %%%%Thus, the ith basis function will be stored 
                           %%%%in column D+i-d0.
for i=1:K+d0
    indx = D+i-d0;
    if i==K+d0
        B0(:,indx) = (x(indx)<=dom).*(dom<=x(indx+1));
    else 
        B0(:,indx) = (x(indx)<=dom).*(dom<x(indx+1));
    end
end

%%%%This second loop computes the second order basis functions (of degree 
%%%%one), which are a set of continuous piecewise linear functions.
order2 = 2;
d1 = order2-1; %%%%d stands for "degree"
B1 = zeros(length(dom),k); %%%%This will contain the basis functions.  Note
                           %%%%that B1 has k=K+2*D=K+6 columns, with each 
                           %%%%indexed i=-2,-1,0,1,...,K,K+1,K+2,K+3.  
                           %%%%Thus, the ith basis function will be stored 
                           %%%%in column D+i-d1.
for i=1:K+d1
    indx = D+i-d1;
    if x(indx+d1)-x(indx)==0;  %%%%Here we check for zero denominator in the first term
        B1(:,indx) = (x(indx+d1+1)-dom)/(x(indx+d1+1)-x(indx+1)).*B0(:,indx+1);
    elseif x(indx+d1+1)-x(indx+1)==0;  %%%%Here we check for zero denominator in the second term
        B1(:,indx) = (dom-x(indx))/(x(indx+d1)-x(indx)).*B0(:,indx);
    else %%%%If neither of the above two conditions were met, we are all clear for using the full recursion formula
        B1(:,indx) = (dom-x(indx))/(x(indx+d1)-x(indx)).*B0(:,indx) + (x(indx+d1+1)-dom)/(x(indx+d1+1)-x(indx+1)).*B0(:,indx+1);
    end
end

%%%%This third loop computes the third order basis functions (of degree 
%%%%two), which are a set of C^1 piecewise quadratic functions.
order3 = 3;
d2 = order3-1; %%%%d stands for "degree"
B2 = zeros(length(dom),k); %%%%This will contain the basis functions.  Note
                           %%%%that B2 has k=K+2*D=K+6 columns, with each 
                           %%%%indexed i=-2,-1,0,1,...,K,K+1,K+2,K+3.  
                           %%%%Thus, the ith basis function will be stored 
                           %%%%in column D+i-d2.
for i=1:K+d2
    indx = D+i-d2;
    if x(indx+d2)-x(indx)==0;  %%%%Here we check for zero denominator in the first term
        B2(:,indx) = (x(indx+d2+1)-dom)/(x(indx+d2+1)-x(indx+1)).*B1(:,indx+1);
    elseif x(indx+d2+1)-x(indx+1)==0;  %%%%Here we check for zero denominator in the second term
        B2(:,indx) = (dom-x(indx))/(x(indx+d2)-x(indx)).*B1(:,indx);
    else %%%%If neither of the above two conditions were met, we are all clear for using the full recursion formula
        B2(:,indx) = (dom-x(indx))/(x(indx+d2)-x(indx)).*B1(:,indx) + (x(indx+d2+1)-dom)/(x(indx+d2+1)-x(indx+1)).*B1(:,indx+1);
    end
end

%%%%This fourth loop computes the fourth order basis functions (of degree 
%%%%three), which are a set of C^2 piecewise cubic functions.
order4 = 4;
d3 = order4-1; %%%%d stands for "degree"
B3 = zeros(length(dom),k); %%%%This will contain the basis functions.  Note
                           %%%%that B3 has k=K+2*D=K+6 columns, with each 
                           %%%%indexed i=-2,-1,0,1,...,K,K+1,K+2,K+3.  
                           %%%%Thus, the ith basis function will be stored 
                           %%%%in column D+i-d3.
%%%%This loop initiates the derivatives matrix if called for.                           
if nargout>=3
    Yprime = zeros(size(B3)); %%%%The variable Yprime here will contain the derivatives of the cubic Bspline basis functions, evaluated at the points in dom
end
%%%%This loop initiates the second derivatives matrix if called for.
if nargout==4
    Ydblprime = zeros(size(B3)); %%%%The variable Yprime here will contain the second derivatives of the cubic Bspline basis functions, evaluated at the points in dom
end

for i=1:K+d3
    indx = D+i-d3;
    if x(indx+d3)-x(indx)==0;  %%%%Here we check for zero denominator in the first term
        B3(:,indx) = (x(indx+d3+1)-dom)/(x(indx+d3+1)-x(indx+1)).*B2(:,indx+1);
        %%%%Here we compute the first derivatives, if called for, using the using the relevant zero denominator caveat
        if nargout>=3
            Yprime(:,indx)  = (-d3/(x(indx+d3+1)-x(indx+1)))*B2(:,indx+1);
        end
        %%%%Here we compute the second derivatives, if called for
        if nargout>=4
            %%%%First we need to compute dB2ii, the derivative of B2(:,indx+1), checking for the relevant zero denominator caveat
            if x(indx+1+d2)-x(indx+1)==0
                dB2ii = (-d2/(x(indx+1+d2+1)-x(indx+1+1)))*B1(:,indx+1+1);
            else
                dB2ii = d2*( B1(:,indx+1)/(x(indx+1+d2)-x(indx+1)) - B1(:,indx+1+1)/(x(indx+1+d2+1)-x(indx+1+1)) );
            end
            Ydblprime(:,indx)  = (-d3/(x(indx+d3+1)-x(indx+1)))*dB2ii;
        end
    elseif x(indx+d3+1)-x(indx+1)==0;  %%%%Here we check for zero denominator in the second term
        B3(:,indx) = (dom-x(indx))/(x(indx+d3)-x(indx)).*B2(:,indx);
        %%%%Here we compute the first derivatives, if called for, using the using the relevant zero denominator caveat
        if nargout>=3
            Yprime(:,indx)  = (d3/(x(indx+d3)-x(indx)))*B2(:,indx);
        end
        %%%%Here we compute the second derivatives, if called for
        if nargout>=4
            %%%%First we need to compute dB2i, the derivative of B2(:,indx), checking for the relevant zero denominator caveat
            if x(indx+d2+1)-x(indx+1)==0
                dB2i = (d2/(x(indx+d2)-x(indx)))*B1(:,indx);
            else
                dB2i = d2*( B1(:,indx)/(x(indx+d2)-x(indx)) - B1(:,indx+1)/(x(indx+d2+1)-x(indx+1)) );
            end
            Ydblprime(:,indx)  = (d3/(x(indx+d3)-x(indx)))*dB2i;
        end
    else %%%%If neither of the above two conditions were met, we are all clear for using the full recursion formula
        B3(:,indx) = (dom-x(indx))/(x(indx+d3)-x(indx)).*B2(:,indx) + (x(indx+d3+1)-dom)/(x(indx+d3+1)-x(indx+1)).*B2(:,indx+1);
        %%%%Here we compute the first derivatives, if called for, using the full derivative formula
        if nargout>=3
            Yprime(:,indx)  = d3*( B2(:,indx)/(x(indx+d3)-x(indx)) - B2(:,indx+1)/(x(indx+d3+1)-x(indx+1)) );
        end
        %%%%Here we compute the second derivatives, if called for, checking for the relevant zero denominator caveats
        if nargout>=4
            %%%%First we need to compute dB2i, the derivative of B2(:,indx)
            if x(indx+d2)-x(indx)==0 
                dB2i  = -d2*B1(:,indx+1)/(x(indx+d2+1)-x(indx+1));
            else
                dB2i  = d2*( B1(:,indx)/(x(indx+d2)-x(indx)) - B1(:,indx+1)/(x(indx+d2+1)-x(indx+1)) );
            end
            %%%%Next we compute dB2ii, the derivative of B2(:,indx+1)
            if x(indx+1+d2+1)-x(indx+1+1)==0
                dB2ii = d2*B1(:,indx+1)/(x(indx+1+d2)-x(indx+1));
            else
                dB2ii = d2*( B1(:,indx+1)/(x(indx+1+d2)-x(indx+1)) - B1(:,indx+1+1)/(x(indx+1+d2+1)-x(indx+1+1)) );
            end
            
            Ydblprime(:,indx)  = d3*( dB2i/(x(indx+d3)-x(indx)) - dB2ii/(x(indx+d3+1)-x(indx+1)));
        end
    end
end


Y      = B3(:,1:K+D); %%%%Finally, get rid of superfluous extra columns to have a finished product of dimensions TxK+3
%%%%Here we compute the indicator matrix Z, if called for
if nargout >=2
    Z      = diag(ones(K+D,1))+diag(ones(K+D-1,1),1)+diag(ones(K+D-1,1),-1)+diag(ones(K+D-2,1),-2);
    Z      = Z(:,2:K+1)';
end
if nargout>=3
    Yprime = Yprime(:,1:K+D); %%%%Finally, get rid of superfluous extra columns to have a finished product of dimensions TxK+3
end
if nargout==4
    Ydblprime = Ydblprime(:,1:K+D); %%%%Finally, get rid of superfluous extra columns to have a finished product of dimensions TxK+3
end

if nargout==5
    dom         = dom(1:dimdom(1),1);
    Y           = Y(1:dimdom(1),:);
    Yprime      = Yprime(1:dimdom(1),:);
    Y2primetemp = Ydblprime(dimdom(1)+1:end,:);
    Ydblprime   = Ydblprime(1:dimdom(1),:);
    Ytrplprime  = zeros(size(Ydblprime));
    for i=1:K+D 
        for k=1:K
            if k==1
                Ytrplprime(:,i) = Ytrplprime(:,i) +... 
                                  ((Y2primetemp(k+1,i)-Y2primetemp(k,i))/(knotvec(k+1)-knotvec(k)))*...
                                  ((knotvec(k)<=dom).*(dom<=knotvec(k+1)));
            else
                Ytrplprime(:,i) = Ytrplprime(:,i) +... 
                                  ((Y2primetemp(k+1,i)-Y2primetemp(k,i))/(knotvec(k+1)-knotvec(k)))*...
                                  ((knotvec(k)<dom).*(dom<=knotvec(k+1)));
            end
        end
    end
end
