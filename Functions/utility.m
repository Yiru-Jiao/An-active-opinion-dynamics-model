function [ u ] = utility( Ai,Ainew,Ajnew )
% estimate utility; i reprents oneself, j reprents i's target
if (Ajnew==Ai)
    u=1;
else
    if (Ainew==Ai)
        u=-0.1;
    else
        u=-1;
    end
end

