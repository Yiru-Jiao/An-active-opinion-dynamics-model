function [ decision ] = similarity_effect( Fi,Fj,r )
% generate interactive willingness based on Similarity Effect
if (Fi==0 || Fj==0)
    if (rand<=0.5+13*atan(10*r)/30/pi)
        decision=true;
    else
        decision=false;
    end
elseif (Fi==Fj)
    if (rand<=0.8+atan(10*r)/5/pi)
        decision=true;
    else
        decision=false;
    end
else
    if (rand<=0.2+atan(10*r)/2/pi)
        decision=true;
    else
        decision=false;
    end
end

