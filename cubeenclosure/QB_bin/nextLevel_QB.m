function [ Cubes,OP,AI,Activity,LastLayer ] = nextLevel_QB( oldCubes,oldOP,oldAI,oldActivity,base )
LastLayer.Cubes=oldCubes(~logical(oldActivity),:);
LastLayer.OP=oldOP(logical(~oldActivity),:);
LastLayer.AI=0;
LastLayer.Activity=ones(sum(~oldActivity),1);


newLen=size(oldCubes,1)*2^(base.lenX);
Cubes=zeros(newLen,base.lenX);
OP=zeros(newLen,base.lenX);
Activity=zeros(newLen,1);

idx=1;
for i=1:size(oldCubes,1)
    IDX=2*oldCubes(i,:);
    Cubes(idx:idx+2^(base.lenX)-1,:)=ones(2^(base.lenX),1)*IDX+base.combMat;
    OP(idx:idx+2^(base.lenX)-1,:)=ones(2^(base.lenX),1)*oldOP(i,:);
    Activity(idx:idx+2^(base.lenX)-1)=oldActivity(i);
    idx=idx+2^(base.lenX);
end

if base.isAI
    LastLayer.AI.IDX=oldAI.IDX(logical(oldActivity),:);
    LastLayer.AI.cAI=oldAI.cAI(logical(oldActivity));
    LastLayer.AI.f=oldAI.f(logical(oldActivity));
    LastLayer.AI.init=0;
    
    
    
    newLen=size(oldAI.IDX,1)*2^(base.lenX);
    AI.IDX=zeros(newLen,base.lenX);
    AI.cAI=cell(newLen,1);
    AI.f=zeros(newLen,1);
    AI.init=0;
    
    idx=1;
    for i=1:size(oldAI.IDX,1)
        IDX=2*oldAI.IDX(i,:);
        AI.IDX(idx:idx+2^(base.lenX)-1,:)=ones(2^(base.lenX),1)*IDX+base.combMat;
        AI.cAI(idx:idx+2^(base.lenX)-1)={oldAI.cAI{i}};
        AI.f(idx:idx+2^(base.lenX)-1)=oldAI.f(i);
        idx=idx+2^(base.lenX);
    end
else
    AI=0;
end



end

