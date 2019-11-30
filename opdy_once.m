% simulate once to observe one-time opinion evolution
% *note*: if you meet the bug "Matrix dimensions must agree. error dynamic_coda(line 13) CA=A*2+F"
%         look at line 49~53 and 62~66
%--------------------------------------------------------
% Place this code in the same path as the "Functions" folder before running it
addpath(genpath(pwd));
%--------------------------
% storage allocation
oncedata=zeros(10000,60);
countn=1;
for n=[100,200,300];   % size of the group
    countmu=1;
    oncedata0=zeros(10000,20);
    for mu=[0 0.41 0.51 0.6 1];
        if (mu<0.5) % make as more numbers in [0,1] as possible
            sigma=(1-mu)/3;
        else
            sigma=mu/3;
        end
        c=10;       % the population's conservative degree of the issue
        r=0.1;     % the population's rejection to factions
        a=0.3;      % degree of adequate interaction 
        period=10;  % % when the difference of group opinion in successive 10 cycles are less than delta(here is 1E-15), the evolution is believed as stablized
        % Initialization P=[0~1], A=[-1,1], F=[-1,0,1], h=[0~1], u=[-1,-0.1,1]
        % initiate faction distribution
        num_of_width=round(2/n^(1/3)*5000);
        F=inf(n,num_of_width);P=inf(n,num_of_width);A=inf(n,num_of_width);h=inf(n,num_of_width);u=inf(n,num_of_width);
        num_of_one=ceil((0.5-r)*n);
        Fini=[ones(num_of_one,1);-ones(num_of_one,1);zeros(n-2*num_of_one,1)];F(:,1)=Fini(randperm(n));
        % initiate opinion distribution
        Pini=normrnd(mu,sigma,2.5*n,1);
        Pini(Pini<0|Pini>1)=[];
        P(:,1)=Pini(1:n);  % initial individual opinions
        A(:,1)=arrayfun(@action,P(:,1));  % initial individual actions
        h(:,1)=arrayfun(@history,P(:,1),c*ones(n,1));  % initial history
        F(:,2)=arrayfun(@faction,h(:,1),r*ones(n,1));  % initial factions
        u(:,1)=0.5; % initial utility > 0, otherwise interaction will not happen
        t=0; % turn
        c=0; % cycle
        length_P=sum(P~=inf,2); % help decide whether to enter into next cycle
        [P_G,A_G,Fp_G,Fmi_G,Fm_G]=ca_group_once(P,A,F,n);  % calculate group results
        while t>=0
            i_j=randperm(n,2); % randomly choose two individuals xi and xj
            i=i_j(1);
            j=i_j(2);
            % similarity effect determines interaction willingness
            Fi=F(i,:);
            Fi(Fi==inf)=[];
            % if you meet the bug "Matrix dimensions must agree. error dynamic_coda(line 13) CA=A*2+F"
            % just uncomment the code below. It is a strange bug that matlab add a 0 at the end of Fi
            if length(Fi)==find(F(i,:)==inf,1)
                Fi=Fi(1:find(F(i,:)==inf,1)-1);
            end
            Pi=P(i,:);
            Pi(Pi==inf)=[];
            Ai=A(i,:);
            Ai(Ai==inf)=[];
            ui=u(i,:);
            ui(ui==inf)=[];
            Fj=F(j,:);
            Fj(Fj==inf)=[];
            % if you meet the bug "Matrix dimensions must agree. error dynamic_coda(line 13) CA=A*2+F"
            % just uncomment the code below. It is a strange bug that matlab add a 0 at the end of Fi
            if length(Fj)==find(F(j,:)==inf,1)
                Fj=Fj(1:find(F(j,:)==inf,1)-1);
            end
            Pj=P(j,:);
            Pj(Pj==inf)=[];
            Aj=A(j,:);
            Aj(Aj==inf)=[];
            uj=u(j,:);
            uj(uj==inf)=[];
            simi_effect=similarity_effect(Fi(end),Fj(end),r);
            if (simi_effect)
            % interaction games
                % from xi's perpective
                x_game=game(Pi(end),Ai,Fi,Fj(end),ui,r);
                % from xj's perspective
                y_game=game(Pj(end),Aj,Fj,Fi(end),uj,r);
                if (x_game&&y_game)
                    % interaction happens
                    % update xi's parameters
                    Piup=dynamic_coda(Pi(end),Ai,Fi,Aj(end),r);
                    Aiup=action(Piup);
                    hiup=history([Pi,Piup],c);
                    P(i,length(Pi)+1)=Piup;
                    A(i,length(Ai)+1)=Aiup;
                    h(i,length(Pi)+1)=hiup;
                    F(i,length(Fi)+1)=faction(hiup,r);
                    % update xj's parameters
                    Pjup=dynamic_coda(Pj(end),Aj,Fj,Ai(end),r);
                    Ajup=action(Pjup);
                    hjup=history([Pj,Pjup],c);
                    P(j,length(Pj)+1)=Pjup;
                    A(j,length(Aj)+1)=Ajup;
                    h(j,length(Pj)+1)=hjup;
                    F(j,length(Fj)+1)=faction(hjup,r);
                    % update utility
                    u(i,length(ui)+1)=utility(Ai(end),Aiup,Ajup);
                    u(j,length(uj)+1)=utility(Aj(end),Ajup,Aiup);
                end
            end
            % caculate group parameters on cycle-unit
            length_Pnew=sum(P~=inf,2);
            if (sum(length_Pnew-length_P)>a*n)
                c=c+1;
                [p_g,a_g,fp_g,fmi_g,fm_g]=ca_group_once(P,A,F,n);
                P_G=[P_G;p_g];
                A_G=[A_G;a_g];
                Fp_G=[Fp_G;fp_g];
                Fmi_G=[Fmi_G;fmi_g];
                length_P=length_Pnew;
                % stop condition; if the group opi nion reached 0 or 1 it would maintain in proceeding cycles, thus this condition would also work
                if (delta_test(P_G,period,1E-15))
                    break;
                end
            end
            t=t+1;
        end
        oncedata0(1:length(P_G),countmu:countmu+3)=[P_G A_G Fp_G Fmi_G];
        countmu=countmu+4;
    end
    oncedata(:,countn:countn+19)=oncedata0;
    countn=countn+20;
end
% output
save('oncedata')
