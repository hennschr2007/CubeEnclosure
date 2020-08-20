function [ R,base ] = QB( f, xinit,LB,UB,Aeq,beq,Ain,bin,g,opt)
%% Short Information
% The Cube Enclosure algorithm provides software for the computation of an
% enclosing set of cubes starting at an initial point. The set that is to 
% be approximated has to be connected.

%% Citation
% If you use this algorithm please cite the following publication:

% Schröder et. al., Reaction rate ambiguities for perturbed spectroscopic data: 
% Theory and implementation
% (currently in submission process, May 2020)

%% Technical requirements:
% The minimization function lsqnonlin is an essential part of the
% algorithm. Therefore the optimization toolbox is mandatory.

% For parallelization of the workload the Parallel computing toolbox is
% needed. If this is not available, set opt.isPar=0.


%% Legal Information
% Copyright (c) 2020 Henning Schröder, University of Rostock, Department of Mathematics.
% 
% The software can be used for academic, research and other similar noncommercial uses. The user
% acknowledges that this software is still in the development stage and that it is provided by the
% copyright holders and contributors "as is" and any express or implied warranties, fitness for a
% particular purpose are disclaimed. In no event shall the copyright owner or contributors be liable
% for any direct, indirect, incidental, special, exemplary, or consequential damages.
% 
% The copyright holders provide no reassurances that the source code provided does not infringe any
% patent, copyright, or any other intellectual property rights of third parties. The copyright
% holders disclaim any liability to any recipient for claims brought against recipient by any third
% party for infringement of that parties intellectual property rights.




%% Task
% Enclose all x, such that f(x)=0 holds under various constraints.

%% Objective Function
% Input: x=x(:);
% Minimization of
% F(x)=||f(x)||_2^2+||Aeq*x-beq||_2^2+||Ain*x<=bin||_2^2+||g(x)||^2_2.
% Additional constraints will be checked componentwise with respect to
% opt.TolCon.

%% Input
% f         - level function f(x), R^p -> R^q
% xinit     - initial points, R^(* x p)
% LB,UB     - lower and upper bounds for x, LB<=x<=UB
% Aeq,beq   - linear equality constraints, Aeq*x=beq
% Ain,bin   - linear inequality constraints, Ain*x<=bin
% g         - nonlinear constraints, g(x)=0
% opt       - struct, options

%% Option struct
% opt.epsOpt    - a feasible point fulfills F(X)<=epsOpt (1E-5)
% opt.TolFun    - lsqnonlin TolFun (1E-10)
% opt.TolX      - lsqnonlin TolX (1E-12)
% opt.maxIter   - lsqnonlin maximum iterations (15)
% opt.maxFunE   - lsqnonlin maximum funciton evaluations (200)
% opt.TolCon    - Constraint tolerance, e.g. ||Ax=b||_2^2<=TolCon (1E-10)
% opt.maxLevel  - maximum level of refinement (3)
% opt.initH     - initial side length of a cube on level 1
% opt.info      - show additional information (0=off, 1=important stuff, 2=all)
% opt.isAI      - use of additional info for the feasibility check of each cube (0)
% opt.sAI
% opt.isPar     - Use of multiple cores or workers (0), REQ: opt.isAI=0
% opt.worker    - Parallel worker
% opt.adaptive  - Use adaptive cube refinement



%% Output
% R             - cell of structs, each cell entry represents one level,
%                 last level is the finest.
% R{lvl}.Cubes  - index set of cubes, [-inf ... inf]^(* x p)
% R{lvl}.MP     - center points of Cubes, [-inf ... inf]^(* x p)
% R{lvl}.OP     - optimized points within Cubes, [-inf ... inf]^(* x p)
% R{lvl}.base   - basic information









%% Input Check
if ~strcmp(class(f),'function_handle')
    error('f is no function.')
else
    base.f=f;
end

if isempty(xinit)
    error('xinit is empty.')
else
    base.lenX=size(xinit,2);
end


if isempty(Aeq)
    base.Con.EQ=0;
else
    if size(Aeq,1)~=size(beq,1)
        error('size of Aeq and beq not consistent.')
    end
    if size(Aeq,2)~=size(xinit,2)
        error('size of Aeq and beq not consistent.')
    end
    base.Con.EQ=1;
    base.Con.Aeq=Aeq;
    base.Con.beq=beq;
end

if isempty(Ain)
    base.Con.IN=0;
else
    if size(Ain,1)~=size(bin,1)
        error('size of Ain and bin not consistent.')
    end
    if size(Ain,2)~=size(xinit,2)
        error('size of Ain and bin not consistent.')
    end
    base.Con.IN=1;
    base.Con.Ain=Ain;
    base.Con.bin=bin;
end

if  isempty(LB)
    base.Con.isLB=0;
else
    if length(LB)~=size(xinit,2)
        error('size of lower bound and xinit not consistent.')
    end
    base.Con.isLB=1;
    base.Con.LB=LB(:)';
end

if  isempty(UB)
    base.Con.isUB=0;
else
    if length(UB)~=size(xinit,2)
        error('size of upper bound and xinit not consistent.')
    end
    base.Con.isUB=1;
    base.Con.UB=UB(:)';
end

if base.Con.isUB && base.Con.isUB
    if max(base.Con.LB>=base.Con.UB)==1
        error('there is at least one i with LB(i)>=UB(i)')
    end
end


if isempty(g)
    base.Con.G=0;
else
    base.Con.G=1;
    base.Con.g=g;
end


%% Set default values

if isfield(opt,'epsOpt')
    base.epsOpt=opt.epsOpt;
else
    base.epsOpt=1E-5;
end

if isfield(opt,'TolCon')
    base.TolCon=opt.TolCon;
else
    base.TolCon=1E-10;
end

if isfield(opt,'TolFun')
    base.TolFun=opt.TolFun;
else
    base.TolFun=1E-10;
end

if isfield(opt,'TolX')
    base.TolX=opt.TolX;
else
    base.TolX=1E-12;
end

if isfield(opt,'maxLevel')
    base.maxLevel=opt.maxLevel;
else
    base.maxLevel=3;
end

if isfield(opt,'initH')
    base.initH=opt.initH;
else
    base.initH=1;
end

if isfield(opt,'info')
    base.info=opt.info;
else
    base.info=0;
end

if isfield(opt,'maxIter')
    base.maxIter=opt.maxIter;
else
    base.maxIter=15;
end

if isfield(opt,'maxFunE')
    base.maxFunE=opt.maxFunE;
else
    base.maxFunE=200;
end

if isfield(opt,'isAI')
    base.isAI=opt.isAI;
else
    base.isAI=0;
end

if isfield(opt,'isPar')
    
    base.isPar=opt.isPar;
else
    base.isPar=0;
end

if isfield(opt,'worker') && base.isPar
    base.worker=opt.worker;
else
    base.worker=3;
    
end


%% START

if base.isPar
    pool = gcp('nocreate');
    if isempty(pool)
        pool=parpool(base.worker);
    end
end

base.options = optimoptions(@lsqnonlin,'TolFun',base.TolFun,...
    'TolX',base.TolX,...
    'Display','off',...
    'maxIter',base.maxIter,...
    'maxFunEvals',base.maxFunE);

base.combMat=(dec2bin(0:(2^(base.lenX))-1)=='1') ;

if base.isAI
    AI.cAI=opt.cAI;
    AI.f=zeros(size(xinit,1),1);
else
    AI=0;
end


%Check xinit
if base.info>=2
    disp('Check initial points...')
end

X=[];
kick1=[];
for i=1:size(xinit,1)
    if base.isAI
        AI.init=i;
        [erg,AI.f(i)]=base.f(xinit(i,:),AI);
    else
        erg=base.f(xinit(i,:),AI);
    end
    
    
    
    ev=sum(erg(:).^2);
    if ev<=base.epsOpt
        X=[X;xinit(i,:)];
        if base.info>=2
            disp(sprintf('point %3.0d : |f|_2= %8.4e : OK',i,ev))
        end
    else
        kick1=[kick1 i];
        if base.info>=2
            disp(sprintf('point %3.0d : |f|_2= %8.4e : KICK',i,ev))
        end
    end
end
if base.info>=2
    disp(' ')
end


if base.isAI
    AI.cAI(kick1)=[];
    AI.f(kick1)=[];
    %cAI=sAI.cAI(ia);
end

if base.info>=1
    disp('truncated initial points:')
    disp(X)
    disp(' ')
end

%Initialize X
R=cell(base.maxLevel,1);

L.level=1;
L.Cubes=zeros(1,base.lenX);

%First row in X is set to reference cube (0,...,0), level dependent
base.RefX=ones(base.maxLevel,1)*X(1,:) - base.initH/2* ((2.^(0:(base.maxLevel-1))-1)./(2.^(0:(base.maxLevel-1))))'*ones(1,base.lenX);

for i=2:size(X,1)
    xact=X(i,:);
    L.Cubes=[L.Cubes; getCube_QB(xact,1,base)];
end
[L.Cubes,ia,ic]=unique(L.Cubes,'rows');
L.OP=X(ia,:);


if base.isAI
    AI.IDX=L.Cubes;
    AI.cAI=AI.cAI(ia);
    AI.init=0;
    AI.f=zeros(size(AI.cAI,1),1);
    L.AI=AI;
end

if base.info>=1
    disp('IDX InitCubes:')
    disp(L.Cubes);
    disp(' ')
end




L=searchCubes_QB(L,base);
currlen=size(L.Cubes,1);
L.Activity=ones(currlen,1);
L.base=base;
R{1}=L;

% activity structure
% cube 1        2        3
% act  1        1        1       (always)
% lvl2 1.1 1.2  2.1 2.2  3.1 3.2
% act  1   0    0   0    1   1

for i=2:base.maxLevel
    L=[];
    L.level=i;
    if opt.adaptive
        Ltemp=R{i-1};
        if ~isempty(Ltemp)
            lastActivity=activityCheck_QB(R{i-1},i,base,opt);
        end
    else
        lastActivity=R{i-1}.Activity;
    end
    % generate next level of cubes by subdividing current levels
    % cubes inherit activity from their parent cubes
    [L.Cubes,L.OP,L.AI,L.Activity,LastLayer] = nextLevel_QB(R{i-1}.Cubes,R{i-1}.OP,R{i-1}.AI,lastActivity,base);
    if opt.adaptive
        R{i-1}=LastLayer;
    end
    if base.info>=1
        disp(['Cube refinement on level ' num2str(i) ' ...'])
        disp(['Number of Cubes to be processed: ' num2str(size(L.Cubes,1))])
        disp(['Active cubes: ' num2str(sum(L.Activity))])
        disp('')
        tc=toc;
    end
    
    % validate only active cubes
    [L.Cubes,L.OP,L.AI,L.Activity ] = levelvalidation_QB( L.Cubes,L.OP,L.AI,L.Activity,i,base);
    if base.info>=1
        disp(['Processing time: ' num2str(toc-tc) ' s'])
        disp('')
    end
    L.base=base;
    R{i}=L;
end



end

