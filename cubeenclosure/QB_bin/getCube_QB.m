function [ IDX ] = getCube_QB( x,level,base)
IDX=zeros(1,base.lenX);

for i=1:base.lenX
    d=x(i)-base.RefX(level,i);
    IDX(i)=round(d/(base.initH/2^(level-1))); 
end
end

