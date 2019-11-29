function [ Pinew ] = dynamic_coda( Pi,A,F,Aj,r )
% Dynamic CODA Rule
d=0.75-atan(10*r)/2/pi;
len=length(A);
switch len
    case 1
        P_p_I_p=d;
        P_p_I_m=1-d;
        P_m_I_p=1-d;
        P_m_I_m=d;
    otherwise
        F=F(1:end-1);
        CA=A*2+F;
        f_p=sum(F==1)+0.5*sum(F==0);
        a_p_f_p=sum(CA==3);
        a_m_f_p=sum(CA==-1);
        f_m=sum(F==-1)+0.5*sum(F==0);
        a_p_f_m=sum(CA==1);
        a_m_f_m=sum(CA==-3);
        a_p_f_mi=sum(CA==2);
        a_m_f_mi=sum(CA==-2);
        if (f_p==0 || f_m==0 || a_p_f_p==0 || a_p_f_m==0 || a_m_f_p==0 || a_m_f_m==0)
            P_p_I_p=d;
            P_p_I_m=1-d;
            P_m_I_p=1-d;
            P_m_I_m=d;
        else
            P_p_I_p=(a_p_f_p+0.5*a_p_f_mi)/f_p;
            P_p_I_m=(a_p_f_m+0.5*a_p_f_mi)/f_m;
            P_m_I_p=(a_m_f_p+0.5*a_m_f_mi)/f_p;
            P_m_I_m=(a_m_f_m+0.5*a_m_f_mi)/f_m;
        end
end
switch Aj
    case 1
        switch Pi
            case 1
                Pinew=1;
            otherwise
                O=P_p_I_p/P_p_I_m*Pi/(1-Pi);
                Pinew=O/(1+O);
        end
    case -1
        switch Pi
            case 1
                Pinew=1;
            otherwise
                O=P_m_I_p/P_m_I_m*Pi/(1-Pi);
                Pinew=O/(1+O);
        end
end

