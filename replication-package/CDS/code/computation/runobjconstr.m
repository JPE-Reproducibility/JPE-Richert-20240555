function [x,f,eflag,outpt] = runobjconstr(x0,Outerfitfun)
opts=optimoptions('fmincon','MaxFunctionEvaluations',500,'Display','iter','Algorithm','sqp');

xLast = []; % Last place computeall was called
myf = []; % Use for objective at xLast
myc = []; % Use for nonlinear inequality constraint
myceq = []; % Use for nonlinear equality constraint

fun = @objfun; % The objective function, nested below
cfun = @constr; % The constraint function, nested below

% Call fmincon
[x,f,eflag,outpt] = fmincon(fun,x0,[],[],[],[],[],[],cfun,opts);
%[x,f,eflag,outpt] = patternsearch(fun,x0,[],[],[],[],[],[],cfun,opts);

    function y = objfun(x)
        if ~isequal(x,xLast) % Check if computation is necessary
            [myf,myc,myceq] = Outerfitfun(x);
            xLast = x;
        end
        % Now compute objective function
        y = myf; %+ 20*(x(3) - x(4)^2)^2 + 5*(1 - x(4))^2;
    end

    function [c,ceq] = constr(x)
        if ~isequal(x,xLast) % Check if computation is necessary
            [myf,myc,myceq] = Outerfitfun(x);
            xLast = x;
        end
        % Now compute constraint function
        c = myc; % In this case, the computation is trivial
        ceq = myceq;
    end

end
