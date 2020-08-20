function [ x ] = getVertices_QB( IDX,level,base)
% x  : * times lenk matrix of vertices of cube IDX 

IDX=IDX(:)';

mid=base.RefX(level,:)+(base.initH/2^(level-1))*IDX;
e1=mid-(base.initH/2^(level-1))/2;
x=ones(size(base.combMat,1),1)*e1+(base.initH/2^(level-1))*base.combMat;
end

