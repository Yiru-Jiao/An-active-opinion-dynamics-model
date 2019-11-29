function [ p_g,a_g,fp_g,fmi_g,fm_g ] = ca_group_once( P,A,F,n )
% caculate group parameters for opdy_once 
% containing more results than function "ca_group"
plist=zeros(n,1);
alist=zeros(n,1);
flist=zeros(n,1);
for i=1:n
    lp=P(i,:);
    lp(lp==inf)=[];
    plist(i)=lp(end);
    la=A(i,:);
    la(la==inf)=[];
    alist(i)=la(end);
    lf=F(i,:);
    lf(lf==inf)=[];
    flist(i)=lf(end);
end
p_g=sum(plist)/n;
a_g=nnz(alist==1)/n;
fp_g=nnz(flist==1)/n;
fmi_g=nnz(flist==0)/n;
fm_g=1-fp_g-fmi_g;

