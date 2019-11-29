function [ p_g,a_g ] = ca_group( P,A,n )
% caculate group parameters
plist=zeros(n,1);
alist=zeros(n,1);
for i=1:n
    lp=P(i,:);
    lp(lp==inf)=[];
    plist(i)=lp(end);
    la=A(i,:);
    la(la==inf)=[];
    alist(i)=la(end);
end
p_g=sum(plist)/n;
a_g=sum(alist==1)/n;