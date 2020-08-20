function [ Y ] = AzuBrevC( k ,t,C0)
%AWP

fun=@(t,Ct) dC(t,Ct,k);
[T,Y]=ode15s(fun,t,C0,odeset('RelTol',1.E-10,'AbsTol',1.E-10));
end

function [dc]=dC(t,C,k)
%kinetic model
dc = C;
dc(1) = -k(1)*C(1);
dc(2) = k(1)*C(1)-k(2)*C(2)+k(3)*C(3);
dc(3) = k(2)*C(2)-k(3)*C(3);
end