function [ b,x,AIreturn ] = isFeasible_QB( IDX,AI,level,base )
b=1;
xinit=getMid_QB(IDX,level,base);
V=getVertices_QB( IDX,level,base);


if base.isAI
    global AItrans;
    global AIret;
    AItrans=AI;
end


LB=min(V);
if base.Con.isLB
    LB=max(LB,base.Con.LB);
end

UB=max(V);
if base.Con.isUB
    UB=min(UB,base.Con.UB);
end

%get feasible init point
xinit=max(xinit,LB);
xinit=min(xinit,UB) ;

optopt=optimoptions(@lsqnonlin,'Display','off',...
    'TolFun',base.TolFun,...
    'TolX',base.TolX,...
    'maxIter',base.maxIter,...
    'maxFunEvals',base.maxFunE);


act=(UB-LB)>1E-12;

try
    if max(act)==1
        if min(act)==0
            act2=1:length(act);
            actN2=act2;
            act2(act==0)=[];
            actN2(act==1)=[];
            
            len=length(xinit);
            Id=eye(len);
            IdA=Id(:,act2);
            IdN=Id(:,actN2);
            
            trunInit=xinit(act2);
            trunLB=LB(act2);
            trunUB=UB(act2);
            
            NtrunInit=xinit(actN2);
            trunFun=@(x) F_QB((IdA*x'+IdN*NtrunInit')',level,IDX,base);
            
            [trunX,resN]=lsqnonlin(trunFun,trunInit,trunLB,trunUB,optopt);
            x=(IdA*trunX'+IdN*NtrunInit')';
            
            
        else
            
            [x,resN] = lsqnonlin(@(x) F_QB(x,level,IDX,base),...
                xinit,...
                LB,...
                UB,...
                optopt);
            
        end
        
    else
        x=xinit;
        resNv=F_QB(x,level,IDX,base);
        resN=sum(resNv.^2);
    end
catch
    b=0;
    x=zeros(1,base.lenX);
    resN=0;
end


if resN>base.epsOpt
    b=0;
    x=zeros(1,base.lenX);
end

if base.isAI
    AIreturn=AIret;
else
    AIreturn=0;
end

end

