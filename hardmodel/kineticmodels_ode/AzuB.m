function [ Y ] = AzuB( k ,t,C0)
%AWP
fun=@(t,Ct) dC(t,Ct,k);
[T,Y]=ode15s(fun,t,C0,odeset('RelTol',1.E-12,'AbsTol',1.E-12));
end

function [dc]=dC(t,C,k)
%kinetic model
dc = C;
dc(1) = -k(1)*C(1);
dc(2) = k(1)*C(1);

end