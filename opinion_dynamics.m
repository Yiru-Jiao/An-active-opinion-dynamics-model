% simulate 500 times to observe opinion evolutions in different conditions
%--------------------------------------------------------
% Place this code in the same path as the "Functions" folder before running it
addpath(genpath(pwd));
%-----------------------------
% storage allocation 
mean_value=inf(500,1);
group_size=inf(500,1);
turn=inf(500,1);
cycle=inf(500,1);
conservative_degree=inf(500,1);
rejection_of_factions=inf(500,1);
degree_of_adequate_interaction=inf(500,1);
opinion_change=inf(500,1);
vote_change=inf(500,1);
opinion_convert=inf(500,1);
vote_convert=inf(500,1);
PG_AG=inf(500,1);
count_c=1;
while count_c<=500 % simulate 500 groups; the number could be altered as your need
    n=randi([50,300]); % size of the group
    mu=normrnd(0.55,0.35); % this is to make initial group opinion distribute evenly
    while mu<0||mu>1
        mu=normrnd(0.55,0.35);
    end
    if (mu<0.5) % make as more numbers in [0,1] as possible
        sigma=(1-mu)/3;
    else
        sigma=mu/3;
    end
    cd=randi(10);   % the population's conservative degree of the issue
    r=0.5*rand();   % the population's rejection to factions
    a=2/3*rand();   % degree of adequate interaction
    period=10;      % when the difference of group opinion in successive 10 cycles are less than delta(here is 1E-15), the evolution is believed as stablized
    tic  % timing
    % Initialization P=[0~1], A=[-1,1], F=[-1,0,1], h=[0~1], u=[-1,-0.1,1]
    % initiate faction distribution
    num_of_width=round(2/n^(1/3)*5000);
    F=inf(n,num_of_width);P=inf(n,num_of_width);A=inf(n,num_of_width);h=inf(n,num_of_width);u=inf(n,num_of_width);
    num_of_one=ceil((0.5-r)*n);
    Fini=[ones(num_of_one,1);-ones(num_of_one,1);zeros(n-2*num_of_one,1)];F(:,1)=Fini(randperm(n));
    % initiate opinion distribution
    Pini=normrnd(mu,sigma,round(2.5*n),1);
    Pini(Pini<0|Pini>1)=[];
    P(:,1)=Pini(1:n); % initial individual opinions
    A(:,1)=arrayfun(@action,P(:,1));  % initial individual actions
    h(:,1)=arrayfun(@history,P(:,1),cd*ones(n,1));  % initial history
    F(:,2)=arrayfun(@faction,h(:,1),r*ones(n,1));  % initial factions
    u(:,1)=0.5; % initial utility must > 0, otherwise interaction will not happen
    t=0; % turn
    c=0; % cycle
    length_P=sum(P~=inf,2); % help decide whether to enter into next cycle
    [P_G,A_G]=ca_group(P,A,n); % calculate group results
    while t>=0
        i_j=randperm(n,2); % randomly choose two individuals xi and xj
        i=i_j(1);
        j=i_j(2);
        % similarity effect determines interaction willingness
        Fi=F(i,:);
        Fi(Fi==inf)=[];
        Pi=P(i,:);
        Pi(Pi==inf)=[];
        Ai=A(i,:);
        Ai(Ai==inf)=[];
        ui=u(i,:);
        ui(ui==inf)=[];
        Fj=F(j,:);
        Fj(Fj==inf)=[];
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
                hiup=history([Pi,Piup],cd);
                P(i,length(Pi)+1)=Piup;
                A(i,length(Ai)+1)=Aiup;
                h(i,length(Pi)+1)=hiup;
                F(i,length(Fi)+1)=faction(hiup,r);
                % update xj's parameters
                Pjup=dynamic_coda(Pj(end),Aj,Fj,Ai(end),r);
                Ajup=action(Pjup);
                hjup=history([Pj,Pjup],cd);
                P(j,length(Pj)+1)=Pjup;
                A(j,length(Aj)+1)=Ajup;
                h(j,length(Pj)+1)=hjup;
                F(j,length(Fj)+1)=faction(hjup,r);
                % update utility
                u(i,length(ui)+1)=utility(Ai(end),Aiup,Ajup);
                u(j,length(uj)+1)=utility(Aj(end),Ajup,Aiup);
            end
        end
        % caculate group results on cycle-unit
        length_Pnew=sum(P~=inf,2);
        if (sum(length_Pnew-length_P)>a*n)
            c=c+1;
            [p_g,a_g]=ca_group(P,A,n);
            P_G=[P_G;p_g];
            A_G=[A_G;a_g];
            length_P=length_Pnew;
            % stop condition; if the group opi nion reached 0 or 1 it would maintain in proceeding cycles, thus this condition would also work
            if (delta_test(P_G,period,1E-15))
                break;
            end
        end
        t=t+1;
    end
    % convert
    pt=round(P_G(end))-round(P_G(1));
    at=round(A_G(end))-round(A_G(1));
    % record
    mean_value(count_c)=P_G(1);
    group_size(count_c)=n;
    turn(count_c)=t;
    cycle(count_c)=c;
    conservative_degree(count_c)=cd;
    rejection_of_factions(count_c)=r;
    degree_of_adequate_interaction(count_c)=a;
    opinion_change(count_c)=P_G(end)-P_G(1);
    vote_change(count_c)=A_G(end)-A_G(1);
    opinion_convert(count_c)=pt;
    vote_convert(count_c)=at;
    PG_AG(count_c)=P_G(end)-A_G(end);
    count_c=count_c+1;
    disp(count_c-1)
    toc
end
% output
disp('outputing')
for_correlation=table(mean_value,group_size,turn,cycle,conservative_degree,rejection_of_factions,degree_of_adequate_interaction,opinion_change,vote_change,opinion_convert,vote_convert,PG_AG);
writetable(for_correlation, 'opdy.xls', 'WriteRowNames', true,'Sheet',1);
% inspect initial group opinion distribution
[a,b]=hist(mean_value(1:50));
bar(b,a/sum(a))
