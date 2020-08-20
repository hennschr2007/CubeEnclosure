function [ Rtotal ] = Fopt( Fin,Farg )

% additional info 1=on, 0=off
info = 0;

if Farg.timeopt
    Farg.Time=Farg.Time+Fin(end);
    Fin(end)=[];
end

% start time approx 0?
if Farg.Time(1)/(Farg.Time(2)-Farg.Time(1))>1e-8
    Farg.Time=[0;Farg.Time(:)];
    Tp0=1;
else
    Farg.Time=Farg.Time(:);
    Tp0=0;
end

% step 1
% solve initial value problem
eval(['Cdgl_temp=' Farg.KM '(Fin,Farg.Time,Farg.initC);']);

if Tp0
    Cdgl_temp(1,:)=[];
end

Cdgl=Cdgl_temp(:,Farg.CompType==1);

%% D= U*S*(T^+) * T*(V^T)

% step 2
% solve (US)*T = Cdgl for T
% T^+ =(US)^+ * Cdgl 
pT=Farg.pUS*Cdgl;

% step 3
% calculate factor C
Cpcd=Farg.US*pT;

%scaling factor for C (maximum of each profil = 1)
MaC=diag(max(Cpcd).^(-1));

%error of kinetic fit (absolute)
Cerr=Cpcd-Cdgl;

% calculate factor S
T=pinv(pT);
Apcd=T*Farg.V';
RR=Farg.D-Cpcd*Apcd;

%scaling factor for S (maximum of each profil = 1)
MaA=diag(max(Apcd').^(-1));

%scaling
Cpcd=Cpcd*MaC;
Apcd=MaA*Apcd;


% step 4
%% apply constraints
idx=1;
% C>0
if Farg.W(1)>-0.5
    Temp=Farg.W(1)*min(0,Cpcd+Farg.epsC);
    R{idx}=Temp(:);
    if info
        disp([num2str(idx) 'C0: ' num2str(sum(Temp(:)))])
    end
    idx=idx+1;
end

% S>0
if Farg.W(2)>-0.5
    Temp=Farg.W(2)*min(0,Apcd+Farg.epsA);
    R{idx}=Temp(:);
    if info
        disp([num2str(idx) 'A0: ' num2str(sum(Temp(:)))])
    end
    idx=idx+1;
end

% Reconstruction
if Farg.W(3)>-0.5
    if Farg.z==Farg.s
        Temp=Farg.W(3)*(pT*T-eye(Farg.z));
    else
        Temp=Farg.W(3)*(RR);
    end
    R{idx}=Temp(:);
    if info
        disp([num2str(idx) '(Re): ' num2str(sum(Temp(:)))])
    end
    idx=idx+1;
end

% Kinetic Fit
if Farg.W(4)>-0.5
    Cerr=Cerr*MaC;
    R{idx}=Farg.W(4)*Cerr(:);
    if info
        disp([num2str(idx) '(KM): ' num2str(sqrt(sum(Cerr(:).^2)))])
    end
    idx=idx+1;
end

% Known Conc
if Farg.W(5)>-0.5
    CdglKnown=Cdgl_temp(:,Farg.CompType==3);
    Ma=diag(max(Farg.kC).^(-1));
    Temp=Farg.W(5)*(CdglKnown-Farg.kC)*Ma;
    R{idx}=Temp(:);
    if info
        disp([num2str(idx) '(kC): ' num2str(sum(Temp(:)))])
    end
    idx=idx+1;
end

% Known Spec
if Farg.W(6)>-0.5
    MaAd=diag(max(Farg.kA').^(-1));
    Temp=Apcd-MaAd*Farg.kA;
    R{idx}=Temp(:);
    if info
        disp([num2str(idx) '(kA): ' num2str(sum(Temp(:)))])
    end
    idx=idx+1;
end



idx=idx-1;
st='R{1}';
for i=1:idx
    st=[st ';R{' num2str(i) '}'];
end
eval(['Rtotal=[' st '];']);




end









