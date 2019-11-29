function [ Ai ] = action( Pi )
% Action based on opinion(subjective possiblity)
% Pi is a number
if (Pi>0.5)
    Ai=1;
elseif (Pi<0.5)
    Ai=-1;
else
    Ai=-1+2*(rand>0.5);
end

