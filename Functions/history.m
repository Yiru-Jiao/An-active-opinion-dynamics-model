function [ hi ] = history( P,s )
% History attitude considering conservative degree of the issue
%  P is a one demension array
len=length(P);
if (len==1)
    hi=P(1);
elseif (len<s)
    hi=sum(P)/len;
else
    hi=sum(P(len-s+1:len))/s;
end

