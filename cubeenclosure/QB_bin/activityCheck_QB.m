function [ NewActivity ] = activityCheck_QB( L,level,base,opt )
NewActivity = L.Activity;
AI          = L.AI;
Cubes       = L.Cubes;
OP          = L.OP;
lenC        = length(Cubes);

method='interp';

lenq=length(OP(1,:));

switch method
    case 'hess'
        % work in progress
        delta=opt.adapt_hess*base.initH/2^(level-1);
        H=zeros(lenq);
        for i=1:lenC
            C=Cubes(i,:);
            op=OP(i,:);
            fun=@(y) sum((F_QB(y,level,AI,base)).^2);
            for ii=1:lenq
                for jj=1:lenq
                    d1=zeros(1,lenq);
                    d1(ii)=1;
                    d2=zeros(1,lenq);
                    d2(jj)=1;
                    if ii==jj
                        H(ii,ii)=(  fun(op+delta*d1) + fun(op-delta*d1)-2*fun(op) )./(delta^2);
                    elseif ii<jj
                        H(ii,jj)=1/(4*delta^2) *(  fun(op+delta*d1+delta*d2) + ...
                            fun(op+delta*d1-delta*d2) + ...
                            fun(op-delta*d1+delta*d2) + ...
                            fun(op-delta*d1-delta*d2));
                        H(jj,ii)=H(ii,jj);
                    end
                    [EV,EW]=eig(H);
                    [mi,Id]=min(abs(diag(EW)));
                    EV_min=EV(:,Id(1))';
                    eval_plus =fun(op+(0.2*base.initH/2^(level-1))*EV_min);
                    eval_minus=fun(op-(0.2*base.initH/2^(level-1))*EV_min);
                    if eval_plus<=base.epsOpt && eval_minus<=base.epsOpt
                        NewActivity(i)=0;
                    end
                end
            end
            
        end
    case 'interp'
        NewActivity=zeros(lenC,1);
        parfor i=1:lenC
            C=Cubes(i,:);
            op=OP(i,:);
            fun=@(y) sum((F_QB(y,level,AI,base)).^2);
            Can=zeros(2*(lenq),lenq);
            for j=1:lenq
                Can(2*(j)-1,:)=C;
                Can(2*(j)-1,j)=Can(2*(j)-1,j)-1;
                Can(2*(j),:)=C;
                Can(2*(j),j)=Can(2*(j),j)+1;
            end
            
            for j=1:size(Can,1)
                cCan=Can(j,:);
                [mi,id]=min(sum(abs(Cubes-ones(lenC,1)*cCan )'));
                if mi==0
                    % cCan is neighbour of C and in Cubes
                    opCan=OP(id,:);
                    testPoint=2/3*op+1/3*opCan;
                    eval =fun(testPoint);
                    
                    if eval>base.epsOpt
                        NewActivity(i)=1;
                    end
                end
            end
            
            
        end
end

end




























