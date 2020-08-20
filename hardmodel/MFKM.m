function [ argout ] = MFKM( argin )

% Reading: D,T,X,initC,kinit,KM,s,zadd,NoR,epsA,epsC,W,Cpath,method
F=fieldnames(argin);
for i=1:length(F)
    eval([F{i} '=argin.' F{i} ';'])
end


%% 
addpath([Cpath filesep 'hardmodel/kineticmodels_ode']);

if length(kinit)~=NoR
    kinit=ones(NoR,1);
else
    kinit=kinit(:);
end




%% Calculation
z=s+zadd;
[U, S, V]=svds(D,z);

%unify orientation of svd factors
if min(V(:,1))<0
    V(:,1)=-V(:,1);
    U(:,1)=-U(:,1);
end
for i=2:z
    idx=find(abs(V(:,i))==max(abs(V(:,i))));
    if sign(V(idx,i))==-1
        V(:,i)=-V(:,i);
        U(:,i)=-U(:,i);
    end
end


% Optimization
optopt=optimset('Display','Iter','MaxIter',100,'MaxFunEvals',2000,'TolFun',1e-7,'TolX',1e-7);

Farg.D=D;
Farg.US=U*S;
Farg.pUS=pinv(Farg.US);
Farg.V=V;
Farg.Time=T;
Farg.s=s;
Farg.z=z;
Farg.NoR=NoR;
Farg.epsA=epsA;
Farg.epsC=epsC;
Farg.initC=initC;
Farg.KM=KM;
Farg.W=W;
Farg.method=method;
Farg.CompType=CompType;
Farg.kC=kC;
Farg.kA=kA;


disp('OPT start')
Farg.timeopt=0;
Finit=kinit;

FoptII=@(Fin2)Fopt(Fin2,Farg);
[kopt,fev]=lsqnonlin(FoptII,Finit,...
    zeros(NoR,1),...
    inf(NoR,1),...
    optopt);
topt=0;
Fin=kopt;
disp(['kopt=' mat2str(kopt)]);




%% Postprocessing;

if Farg.timeopt
    Farg.Time=Farg.Time+Fin(end);
    Fin(end)=[];
end

if Farg.Time(1)/(Farg.Time(2)-Farg.Time(1))>1e-8
    Farg.Time=[0;Farg.Time(:)];
    Tp0=1;
else
    Farg.Time=Farg.Time(:);
    Tp0=0;
end

eval(['Cdgl_temp=' Farg.KM '(Fin,Farg.Time,Farg.initC);']);
if Tp0
    Cdgl_temp(1,:)=[];
end

Cdgl=Cdgl_temp(:,Farg.CompType==1);

pT=Farg.pUS*Cdgl;
Cpcd=Farg.US*pT;
T=pinv(pT);
Apcd=T*Farg.V';

for i=1:s
    alpha=Cpcd(:,i)\Cdgl(:,i);
    Cpcd(:,i)=alpha*Cpcd(:,i);
    Apcd(i,:)=1/alpha*Apcd(i,:);
end


%% Output
argout.kopt=kopt;
argout.Code=Cdgl;
argout.C=Cpcd;
argout.S=Apcd;
argout.topt=topt;
argout.fev=fev;
argout.US=Farg.US;
argout.V=Farg.V;



