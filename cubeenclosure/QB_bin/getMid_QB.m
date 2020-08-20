function [ mid ] = getMid_QB( IDX,level,base)
% x  : * times lenk matrix of vertices of cube IDX 

mid=ones(size(IDX,1),1)*base.RefX(level,:)+(base.initH/2^(level-1))*IDX;
end

