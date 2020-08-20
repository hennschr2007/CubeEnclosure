function [R]=tar_Keps_multi(k,T,Mk,initC,kopt,pUS,US,Vt,epsA,epsDgl,IDX)


kact=k(:);
%disp(kact)
if min(kact)<1E-6*sum(kopt)
    R=10*ones(length(initC)*(length(T)+size(Vt,2)),1);
    %R=10*ones(length(initC)*(length(T)),1);
    return
end

fun=@(t,Ct) dC(t,Ct,kact,Mk);

%pTT=U\Code;
%Cerr=(Code-U*pTT);




if T(1)/(T(2)-T(1))>1e-8
    T=[0;T(:)];
    Tp0=1;
else
    T=T(:);
    Tp0=0;
end

[T,Cdgl]=ode15s(fun,T,initC,odeset('RelTol',1.E-11,'AbsTol',1.E-11));

%disp(Cdgl)
if Tp0
    Cdgl(1,:)=[];
end





pT=pUS*Cdgl;
Cpcd=US*pT;
TT1=pinv(pT);

ms=size(US,1)*size(US,2);
% MaC=eye(2);
% diag((mean(max(Cpcd))*[1 1 1]).^(-1));

Cerr=(Cpcd-Cdgl);
R1=max(norm(Cerr,'fro')/norm(Cpcd,'fro')-epsDgl,0);

Apcd=TT1*Vt;
MaA=diag(max(Apcd').^(-1));
Apcd=MaA*Apcd;


% % % % % % % pT=pUS*Cdgl;
% % % % % % % Cpcd=US*pT;
% % % % % % %
% % % % % % % MaC=diag(max(Cpcd).^(-1));
% % % % % % %
% % % % % % % Cerr=(Cpcd-Cdgl)*MaC;
% % % % % % % %Cerrs = smooth(Cerr,15,'sgolay',2);
% % % % % % % %E1max=max(max(abs(Cerr)));
% % % % % % %
% % % % % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % % % %
% % % % % % %
% % % % % % %
% % % % % % % TT=pinv(pT);
% % % % % % % Apcd=TT*Vt;
% % % % % % %
% % % % % % % MaA=diag(max(Apcd').^(-1));
% % % % % % %
% % % % % % % %Cpcd=Cpcd*MaC;
% % % % % % % Apcd=MaA*Apcd;
% % % % % % % % Aerr=min(Apcd+epsA,0);
% % % % % % % %Aerr=min(Apcd,0);
% % % % % % % %E2max=-min(min(Aerr));
% % % % % % %
% % % % % % % %ll=E1max/(E1max+E2max);
% % % % % % % %epsDgl=ll*epsG;
% % % % % % % %epsA=epsG-epsDgl;
% % % % % % %
% % % % % % %
% % % % % % % R1=min(Cerr(:)+epsDgl,0)+max(Cerr(:)-epsDgl,0);
Aerr=min(Apcd+epsA,0);
R2=Aerr(:);
R=[R1(:);R2(:)];
%R=R1(:);
% disp(max(abs(R1)));



end

function [dc]=dC(t,C,k,Mk)
%kinetic model
dc=Mk(k)*C;
end