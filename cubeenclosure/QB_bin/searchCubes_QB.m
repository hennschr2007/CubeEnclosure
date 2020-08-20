function [ L ] = searchCubes_QB( L,base )
Cubes=L.Cubes;
OP=L.OP;
level=L.level;

if base.isAI
    AI=L.AI;
else
    AI=0;
end


if base.info>=1
    disp(['search cubes in level ' num2str(level)])
    disp(' ')
end

if base.info>=2
    ff=figure(1337);
    xtrack=[0];
    ytrack=[size(Cubes,1)];
    plot(xtrack,ytrack,'b*-');
    drawnow;
end





Next=Cubes;

while size(Next,1)>0
    NewNext=[];
    CanList=[];
    XNext=[];
    for i=1:size(Next,1)
        Can=zeros(2*(base.lenX),base.lenX);
        Pre=zeros(2*(base.lenX),base.lenX);
        for j=1:base.lenX
            Can(2*(j)-1,:)=Next(i,:);
            Can(2*(j)-1,j)=Can(2*(j)-1,j)-1;
            Can(2*(j),:)=Next(i,:);
            Can(2*(j),j)=Can(2*(j),j)+1;
            Pre(2*(j)-1,:)=Next(i,:);
            Pre(2*(j),:)=Next(i,:);
        end
        CanList=[CanList;Can];
    end
    %Reject equal candidates
    [CanList,ai,~]=unique(CanList,'rows');
    
    %Reject candidates already in Cubes
    kick=[];
    for i=1:size(CanList,1)
        ai=find(sum(abs(Cubes-ones(size(Cubes,1),1)*CanList(i,:))',1)==0,1);
        if ~isempty(ai)
            kick=[kick;i];
        end
    end
    CanList(kick,:)=[];
    
    if base.info>=2
        disp('Cubes:')
        disp(size(Cubes,1));
        disp('Candidate Cubes:')
        disp(size(CanList,1));
        disp(' ')
    end
    
    
    
    
    %Check candidates
    if base.isPar
        lenCan=size(CanList,1);
        B=zeros(lenCan,1);
        X=zeros(lenCan,base.lenX);
        AIR=cell(lenCan,1);
        parfor j=1:lenCan
            [B(j),X(j,:),AIR{j}]=parCheck(CanList(j,:),AI,level,base);
        end
        help=1:lenCan;
        help(B==0)=[];
        help=help(:);
        NewNext=[NewNext ;CanList(help,:)];
        XNext=[XNext;X(help,:)];
        if base.isAI
            for j=1:lenCan
                if sum(j==help)
                    AI.IDX=[AI.IDX; AIR{j}.IDX];
                    AI.cAI=[AI.cAI(:); AIR{j}.cAI];
                    AI.f=[AI.f; AIR{j}.f];
                end
            end
        end
        
        
        
        
    else
        for j=1:size(CanList,1)
            b=1;
            %Fast Check
            if ~isValid_QB(CanList(j,:),level,base)
                b=0;
            end
            %Optimization Check
            if b==1
                [b,xopt,AIret]=isFeasible_QB(CanList(j,:),AI,level,base);
            end
            if b==1
                %Accept candidate
                NewNext=[NewNext ;CanList(j,:)];
                XNext=[XNext;xopt];
                if base.isAI
                    AI.IDX=[AI.IDX; AIret.IDX];
                    AI.cAI=[AI.cAI(:); AIret.cAI];
                    AI.f=[AI.f; AIret.f];
                end
            end
        end
    end
    Next=NewNext;
    Cubes=[Cubes; NewNext];
    OP=[OP;XNext];
    
    if base.info>=2
        figure(ff);
        clf;
        xtrack=[xtrack length(xtrack)];
        ytrack=[ytrack size(Next,1)];
        plot(xtrack,ytrack,'b*-');
        drawnow;
    end
    
end


L.Cubes=Cubes;
L.OP=OP;
L.level=level;

if base.isAI
    L.AI=AI;
else
    L.AI=0;
end
end

function [b,xopt,AIret]=parCheck(IDX,AI,level,base)
AIret=0;
b=1;
xopt=zeros(1,base.lenX);
%Fast Check
if ~isValid_QB(IDX,level,base)
    b=0;
end
%Optimization Check
if b==1
    [b,xopt,AIret]=isFeasible_QB(IDX,AI,level,base);
end
end

