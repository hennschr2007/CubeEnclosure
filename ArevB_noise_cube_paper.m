%% Info
% Run "ArevB_noise_fkm_paper.m" first! The result file is needed for this script

% Further information on the algorithm can be found in the file
% "../cubeenclosure/QB.m".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath ./cubeenclosure
addpath ./cubeenclosure/QB_bin/
addpath ./cubeenclosure/kineticmodels
load results_noisy.mat
clear KM;ArB;



[U,S,V]=svds(D,2);
K=sum(kopt);
epsA=0.01;              % epsilon
epsDGL=0.01;            % theta

f=@(k,IDX) tar_Keps_multi(k,T,KM.M,initC,kopt,pinv(U*S),U*S,V',epsA,epsDGL,IDX);
Kinit=perms(kopt);
Kinit=Kinit(:,1:end);

opt.info        =2;
opt.initH       =K/40;  % initial cube edge length
opt.maxLevel    =2;     % 1+refinement levels
opt.adaptive    =0;     % enable adaptive refinement

opt.epsOpt  = 1E-12;
opt.TolFun  = 1E-10;
opt.TolX    = 1E-12;
opt.maxIter = 20;
opt.maxFunE = 200;
opt.TolCon  = 1E-9;
opt.isPar   = 0;        % enable parallel computing (needs parallel computing toolbox)
opt.worker  = 4;        % parallel compute threads
tic;
R=QB(f,Kinit,...
    zeros(1,length(kopt)),...
    1.5*K*ones(1,length(kopt)),...
    [],[],...
    ones(1,length(kopt)),1.5*K,...
    [],...
    opt);
time=toc
save results_cube_noisy


L=R{2};
base=L.base;


%% plotting
figure;
subplot(1,3,1)
plotMid_QB( L.OP,base,gcf )
hold on
plotGrid_QB( L,base,gcf )
XX=L.OP;
co = convhull(XX);
plot(XX(co,1),XX(co,2),'--r')
title('Set of feasible D-app. parameters')


subplot(1,3,2)
set(gcf,'paperpositionmode','auto')
for i=1:size(L.OP,1)
    kopt=L.OP(i,:);
    Cdgl=ArevB(kopt,T,initC);
    pT=pinv(US)*Cdgl;
    Cpcd=US*pT;
    set(gca,'colororderindex',1)
    plot(T,Cpcd,'linewidth',1)
    hold on
end
set(gca,'XTick',[0 1 2],'YTick',[0 0.5 1])
title('Bands C')
axis tight



subplot(1,3,3)
set(gcf,'paperpositionmode','auto')
for i=1:size(L.OP,1)
    kopt=L.OP(i,:);
    Cdgl=ArevB(kopt,T,initC);
    Apcd=pinv(Cdgl)*D;
    set(gca,'colororderindex',1)
    plot(X,Apcd,'linewidth',1)
    hold on
end
set(gca,'XTick',0:25:100,'YTick',[0 0.5 1])
title('Bands S')
axis tight
