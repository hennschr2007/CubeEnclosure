function [ Cubes,OP,AI,Activity ] = levelvalidation_QB( allCubes,allOP,allAI,allActivity,level,base )
Cubes=[];
OP=[];
Activity=[];
if base.isAI==0
    AI=0;
else
    AI=[];
    AI.IDX=[];
    AI.cAI=cell(0,0);
    AI.f=[];
end

if base.isPar
    
    lenCan=size(allCubes,1);
    B=zeros(lenCan,1);
    X=zeros(lenCan,base.lenX);
    AIR=cell(lenCan,1);
    parfor i=1:lenCan
        if allActivity(i)
            [bb,xx,aa]=parCheck(allCubes(i,:),allOP(i,:),allAI,level,base,i);
            B(i)=bb;
            X(i,:)=xx;
            AIR{i}=aa;
        else
            B(i)=0;
            X(i,:)=NaN*ones(1,base.lenX);
            AIR{i}=NaN; 
        end
    end
    help=1:lenCan;
    help(B==0)=[];
    help=help(:);
    
    %Accept candidate
    Cubes=allCubes(help,:);
    Activity=allActivity(help,:);
    OP=X(help,:);
    if base.isAI
        for j=1:lenCan
            if sum(j==help) && ~isnumeric(AIR{j})
                AI.IDX=[AI.IDX; AIR{j}.IDX];
                AI.cAI=[AI.cAI(:); AIR{j}.cAI];
                AI.f=[AI.f; AIR{j}.f];
            end
        end
    end
    
    
    
else
    for i=1:size(allCubes,1)
        C=allCubes(i,:);
        op=allOP(i,:);
        %Fast check op in C
        V=getVertices_QB( C,level,base);

        
        
        if ~(max(op<min(V))) && ~(max(op>max(V)))
            if allActivity(i)
                Cubes=[Cubes;C];
                OP=[OP;op];
                Activity=[Activity;1];
            end
        else
            b=1;
            %Fast Check
            if ~isValid_QB(C,level,base)
                b=0;
            end
            %Optimization Check
            if b==1
                if allActivity(i)
                    [b,xopt,AIret]=isFeasible_QB(C,AI,level,base);
                else
                    b=0;
                end
            end
            if b==1
                %Accept candidate
                Cubes=[Cubes ;C];
                OP=[OP;xopt];
                Activity=[Activity;1];
                if base.isAI
                    AI.IDX=[AI.IDX; AIret.IDX];
                    AI.cAI=[AI.cAI(:); AIret.cAI];
                    AI.f=[AI.f; AIret.f];
                end
            end
        end
        
    end
    
    if base.info>=2
        disp(' ');
    end
end
end

function [b,xopt,AIret]=parCheck(C,op,AI,level,base,i)
AIret=-1;
b=1;
xopt=zeros(1,base.lenX);
V=getVertices_QB( C,level,base);
if ~(max(op<min(V))) && ~(max(op>max(V)))
    xopt=op;
    return
else
    b=1;
    %Fast Check
    if ~isValid_QB(C,level,base)
        b=0;
    end
    %Optimization Check
    if b==1
        [b,xopt,AIret]=isFeasible_QB(C,AI,level,base);
    end
end
end
