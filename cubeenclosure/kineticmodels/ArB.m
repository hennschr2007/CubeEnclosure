KM.name         = 'A <=> B';
KM.subscount    = 2;
KM.defaultC0    = [1 0];
KM.NoR          = 2;            %Number of Reactions
KM.compCell     = {'A','B'};    %in order of C0
KM.ReacSys      = 2;
KM.type         = 1; %1=first order 2=higher order
KM.dC           = @(t,C,k) [-k(1)*C(1)+k(2)*C(2);...
                             k(1)*C(1)-k(2)*C(2)];
KM.M            = @(k) [-k(1)  k(2);...
                         k(1) -k(2)];                         