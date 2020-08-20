function [  ] = plotGrid_QB( L,base,fig )
disp('Plotting:')
disp('Generating links...')
Cubes=L.Cubes;
level=L.level;
lenCub=size(Cubes,1);
Es=[];
Ee=[];
for i=1:lenCub
    IDX=Cubes(i,:);
    VIDX=ones(size(base.combMat,1),1)*IDX+base.combMat;
    if base.lenX==1
        Es=[Es;VIDX(1,:)];
        Ee=[Ee;VIDX(2,:)];
    elseif base.lenX==2
        Es=[Es;VIDX(1,:);VIDX(1,:);VIDX(2,:);VIDX(3,:)];
        Ee=[Ee;VIDX(2,:);VIDX(3,:);VIDX(4,:);VIDX(4,:)];
    elseif base.lenX==3
        Es=[Es;VIDX(1,:);VIDX(1,:);VIDX(1,:);VIDX(5,:);VIDX(5,:);VIDX(2,:);VIDX(2,:);VIDX(3,:);VIDX(6,:);VIDX(7,:);VIDX(3,:);VIDX(4,:)];
        Ee=[Ee;VIDX(2,:);VIDX(3,:);VIDX(5,:);VIDX(7,:);VIDX(6,:);VIDX(6,:);VIDX(4,:);VIDX(4,:);VIDX(8,:);VIDX(8,:);VIDX(7,:);VIDX(8,:)];
    end
end

lenE=size(Es,1);
disp('Truncate links...')


if base.lenX==1
    Ls=Es;
    Le=Ee;
elseif base.lenX==2
    Ls=[];
    Le=[];
    for i=1:lenE
        acts=Es(i,:);
        acte=Ee(i,:);
        midx=find( 0==sum(abs(ones(lenE,1)*acts-Es),2));
        ActE=Ee(midx,:);
        midy=find( 0==sum(abs(ones(size(midx,1),1)*acte-ActE),2));
        
        if length(midy)==1
            Ls=[Ls;acts];
            Le=[Le;acte];
        end
    end
elseif base.lenX==3
    Ls=[];
    Le=[];
    for i=1:lenE
        acts=Es(i,:);
        acte=Ee(i,:);
        midx=find( 0==sum(abs(ones(lenE,1)*acts-Es),2));
        ActE=Ee(midx,:);
        midy=find( 0==sum(abs(ones(size(midx,1),1)*acte-ActE),2));
        
        if length(midy)<=3
            Ls=[Ls;acts];
            Le=[Le;acte];
        end
    end
end



disp('Plotting...')
if exist('fig')
    
else
    fig=figure;
end

for i=1:size(Ls,1)
    Ls(i,:)=base.RefX(level,:)+(base.initH/2^(level-1))*Ls(i,:);
    Ls(i,:)=Ls(i,:)-(base.initH/2^(level-1))/2;
    Le(i,:)=base.RefX(level,:)+(base.initH/2^(level-1))*Le(i,:);
    Le(i,:)=Le(i,:)-(base.initH/2^(level-1))/2;
end
Pl=zeros(base.lenX,0);
for i=1:size(Ls,1)
    Pl=[Pl Ls(i,:)' Le(i,:)' NaN(base.lenX,1)];
end
Pl(:,end)=[];

if base.lenX==1
    plot(Pl,zeros(1,length(Pl)),'-r')
elseif base.lenX==2
    plot(Pl(1,:),Pl(2,:),'-r')
elseif base.lenX==3
    plot3(Pl(1,:),Pl(2,:),Pl(3,:),'-r')
end



end

