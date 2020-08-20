%% Info
% Run this script before "ArevB_noise_cube_paper.m".

%% load data
load data/ArevB_noisy.mat


%% execute hard model approach
addpath('hardmodel')
addpath('hardmodel/kineticmodels_ode')

%initial guess for reaction rates
kinit=[1 10];
KM='ArevB';
s=2;
zadd=0;
NoR=2;
epsA=0.0;
epsC=0.0;

%weights of constraints
W=[1 ...   C>0
    1 ...   A>0
    1 ...    Recon
    0.1 ...    Kinetic Fit
    -1 ...   Known Conc
    -1 ...   Known Spec
    ];

CompType=ones(1,s);

argin.kinit=kinit;
argin.method=1;
argin.D=D;
argin.T=T;
argin.X=X;
argin.initC=initC;
argin.KM=KM;
argin.s=s;
argin.zadd=zadd;
argin.NoR=NoR;
argin.epsA=epsA;
argin.epsC=epsC;
argin.W=W;
argin.Cpath=cd;
argin.CompType=CompType;
argin.kC=[];
argin.kA=[];


% program execution
argout = MFKM(argin);

% process output - return C,S,Code,kopt
F=fieldnames(argout);
for i=1:length(F)
    eval([F{i} '=argout.' F{i} ';'])
end
    
save results_noisy

%% plotting

figure;
subplot(1,3,1)
mesh(X,T,D)
axis tight
title('D')
xlabel('channel')
ylabel('time')
zlabel('intensity')

subplot(1,3,2)
plot(T,C,'linewidth',2)
hold on
plot(T,Code,'k--','linewidth',2)
axis tight
title('concentrations C')
xlabel('time')
ylabel('conc')

subplot(1,3,3)
plot(X,S,'linewidth',2)
axis tight
title('spectra S')
xlabel('channel')
ylabel('intensity')








