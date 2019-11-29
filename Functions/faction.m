function [ Fi ] = faction( hi,r )
% Faction based on history attitude and the population's rejection to faction
if (hi>0.5+r)
    Fi=1;
elseif (hi<=0.5-r)
    Fi=-1;
else
    Fi=0;
end

