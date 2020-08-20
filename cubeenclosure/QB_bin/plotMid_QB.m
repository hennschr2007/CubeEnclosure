function [  ] = plotMid_QB( PlotMid,base,fig )
if exist('fig')

else
    fig=figure;
end



lenMid=size(PlotMid,1);
if base.lenX==1
    plot(PlotMid,zeros(lenMid,1),'x')
elseif base.lenX==2
    plot(PlotMid(:,1),PlotMid(:,2),'x')
elseif base.lenX==3
    plot3(PlotMid(:,1),PlotMid(:,2),PlotMid(:,3),'x')
end
hold on


axis tight

end

