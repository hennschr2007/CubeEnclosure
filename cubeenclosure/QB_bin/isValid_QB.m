function [ b ] = isValid_QB( IDX,level,base )
V=getVertices_QB( IDX,level,base);

b=1;

if base.Con.isLB
    bb=0;
    for i=1:size(V,1)
        r=max(base.Con.LB-V(i,:));
        if r<=base.TolCon
            bb=1;
            break
        end
    end
    if bb==0
        b=0;
        return
    end 
end

if base.Con.isUB
    bb=0;
    for i=1:size(V,1)
        r=max(V(i,:)-base.Con.UB);
        if r<=base.TolCon
            bb=1;
            break
        end
    end
    if bb==0
        b=0;
        return
    end 
end

if base.Con.IN
    bb=0;
    for i=1:size(V,1)
        r=max(base.Con.Ain*V(i,:)'-base.Con.bin);
        if r<=base.TolCon
            bb=1;
            break
        end
    end
    if bb==0
        b=0;
        return
    end    
end
    
if base.Con.EQ
    bb=0;
    for i=1:size(V,1)
        r=max(base.Con.Aeq*V(i,:)'-base.Con.beq);
        if r<=base.TolCon
            bb=1;
            break
        end
    end
    for i=1:size(V,1)
        r=max(-base.Con.Ain*V(i,:)'+base.Con.bin);
        if r<=base.TolCon
            bb=bb+1;
            break
        end
    end
    if bb<=1
        b=0;
        return
    end    
end

end

