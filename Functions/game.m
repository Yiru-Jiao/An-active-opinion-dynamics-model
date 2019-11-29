function [ interaction ] = game( Pi,A,F,Fj,u,r )
% Interaction choice based on imperfect information game
switch Fj
    case 0
        Aj=-1+2*(rand<0.5);
    otherwise
        Aj=Fj;
end
Ainew=action(dynamic_coda(Pi, A, F, Aj, r));
u_i=utility(A(end), Ainew, Aj);
switch F(end)
    case 0
        Ai=-1+2*(rand<0.5);
    otherwise
        Ai=F(end);
end
u_j=utility(Aj, Aj, Ai);
if (u_i>=0 && u_j>=0)
    if (rand<sum(u)/length(u))
        interaction=true;
    else
        interaction=false;
    end
else
    interaction=false;
end

