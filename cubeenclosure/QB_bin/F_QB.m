function [ R ] = F_QB( x,level,IDX,base )
R2=[];
R3=[];
R4=[];

R1=base.f(x,IDX);
if base.Con.EQ
    r2=base.Con.Aeq*x'-base.Con.beq;
    R2=min(r2+base.TolCon,0)+max(r2-base.TolCon,0);
end
if base.Con.IN
    R3=max((base.Con.Ain*x'-base.Con.bin)-base.TolCon,0);
end
if base.Con.G
    r4=base.Con.g(x);
    R4=min(r4+base.TolCon,0)+max(r4-base.TolCon,0);
end
R=[R1(:);R2(:);R3(:);R4(:)];
end

