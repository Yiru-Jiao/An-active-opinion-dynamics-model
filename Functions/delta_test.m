function [ stop ] = delta_test( P_G,period,delta )
% inspect whether the evolution reaches stop condition(2)
l=length(P_G);
np=l-period;
if (np<1)
    stop=false;
else
    test=l;
    while test>np
        if (abs(P_G(test)-P_G(test-1))<=delta)
            stop=true;
            test=test-1;
        else
            stop=false;
            break
        end
    end
end

