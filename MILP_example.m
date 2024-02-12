%% Heading
%
clc
close all
clearvars
%
%% General inputs
%
N_periods = 1;
%
horizon=24*1*3600; %[s] Optimized time horizon
dt=3600/1; %[s]
N_timeSteps=horizon/dt;
%
%% Electric and thermal demand & Energy prices
%
% price_el_abs = 0.22 * ones(N_periods,N_timeSteps);
price_el_abs = 0.22 * ones(N_periods,N_timeSteps);
price_el_inj = price_el_abs * 0.1;
%
price_f_abs = 0.07 * ones(N_periods,N_timeSteps);
%
% W_dem = 60 * ones(N_periods,N_timeSteps);
W_dem = 60 *[   0.4 0.3 0.2,...
                0.2 0.1 0.3,...
                0.5 0.6 0.5,...
                0.4 0.3 0.3,...
                0.3 0.3 0.3,...
                0.3 0.4 0.5,...
                0.7 0.8 0.7,...
                0.6 0.5 0.4];
%
% Q_dem = 200 *ones(N_periods,N_timeSteps);
Q_dem = 200 *[  0.3 0.2 0.1,...
                0.1 0.1 0.3,...
                0.5 0.7 0.5,...
                0.4 0.3 0.3,...
                0.3 0.2 0.2,...
                0.2 0.3 0.5,...
                0.7 0.8 0.7,...
                0.6 0.5 0.4];
%
figure
%
stairs(W_dem,"LineWidth",2)
hold on
stairs(Q_dem,"LineWidth",2)
%
ylabel("Demand (kW)")
xlabel("t (h)")
%
grid on
box on
set(gca,"FontName","Times New Roman","FontSize",28)
pbaspect([1 1 1])
legend("$\dot{W}_{dem}$","$\dot{Q}_{dem}$","FontSize",28,"Interpreter","Latex","Location","northwest")
%
%% Optimization problem setup
%
% ---- % Problem
%
problem=optimproblem('ObjectiveSense','minimize');
%
% ---- % Options
%
options=optimoptions('intlinprog','Display','iter','AbsoluteGapTolerance',0,'RelativeGapTolerance',0);
%
%% CHP
%
W_chp_nom = 40; %(kW_el)
%
eta_el_chp_nom = 0.3;   %(-)
eta_th_chp_nom = 0.6;   %(-)
%
F_chp_nom = W_chp_nom/eta_el_chp_nom;   %(kW_f)
Q_chp_nom = F_chp_nom*eta_th_chp_nom;   %(kW_th)
%
f_chp_min = 0.3;    %(-)
%
% Variables
%
w_chp = optimvar('w_chp',N_periods,N_timeSteps,'Type','continuous','LowerBound',0,'UpperBound',1);  %(-) W_chp/W_chp_nom
q_chp = optimvar('q_chp',N_periods,N_timeSteps,'Type','continuous','LowerBound',0,'UpperBound',1);  %(-) Q_chp/Q_chp_nom
f_chp = optimvar('f_chp',N_periods,N_timeSteps,'Type','continuous','LowerBound',0,'UpperBound',1);  %(-) F_chp/F_chp_nom
%
k_onoff_chp = optimvar('k_onoff_chp',N_periods,N_timeSteps,'Type','integer','LowerBound',0,'UpperBound',1);
%
% Constraints
%
problem.Constraints.CHP_Binary = [  w_chp <= k_onoff_chp;...
                                    q_chp <= k_onoff_chp;...
                                    f_chp <= k_onoff_chp];
%
problem.Constraints.CHP_MinLoad = [ f_chp >= f_chp_min * k_onoff_chp];
%
load("CHP_linearisation.mat")
problem.Constraints.CHP_performance = [ w_chp <= A_el_chp * f_chp + B_el_chp - B_el_chp * (1-k_onoff_chp);...
                                        q_chp <= A_th_chp * f_chp + B_th_chp - B_el_chp * (1-k_onoff_chp)];
%
%% Boiler
%
Q_bl_nom = 200;  %(kW_th)
%
eta_bl_nom = 0.95;  %(-)
%
F_bl_nom = Q_bl_nom/eta_bl_nom; %(kW_f)
%
f_bl_min = 0.2; %(-)
%

%
% Variables
%
q_bl = optimvar('q_bl',N_periods,N_timeSteps,'Type','continuous','LowerBound',0,'UpperBound',1);  %(-) Q_bl/Q_bl_nom
f_bl = optimvar('f_bl',N_periods,N_timeSteps,'Type','continuous','LowerBound',0,'UpperBound',1);  %(-) F_bl/F_bl_nom
%
k_onoff_bl = optimvar('k_onoff_bl',N_periods,N_timeSteps,'Type','integer','LowerBound',0,'UpperBound',1);
%
% Constraints
%
problem.Constraints.BL_Binary = [  q_bl <= k_onoff_bl;...
                                    f_bl <= k_onoff_bl];
%
problem.Constraints.BL_MinLoad = [ f_bl >= f_bl_min * k_onoff_bl];
%
problem.Constraints.BL_performance = [ q_bl <= f_bl];
%
%% TES
%
cap_tes_nom = 100;  %(kWh_th)
t_dis_tes = 2;  %(h)
t_ch_tes = t_dis_tes; %(h)
%
Q_ch_tes_nom = cap_tes_nom / t_ch_tes;  %(kW_th)
Q_dis_tes_nom = cap_tes_nom / t_dis_tes;  %(kW_th)
%
eta_ch_tes_nom = 0.98;  %(-)
eta_dis_tes_nom = 0.98;  %(-)
%
q_ch_tes_min = 0.1; %(-)
q_dis_tes_min = 0.1; %(-)
%
soc_tes_min = 0.1;  %(-)
soc_tes_max = 1;    %(-)
soc_tes_0 = soc_tes_min;    %(-)
%
% Variables
%
q_ch_tes = optimvar('q_ch_tes',N_periods,N_timeSteps,'Type','continuous','LowerBound',0,'UpperBound',1);  %(-) Q_ch_tes/Q_ch_tes_nom
q_dis_tes = optimvar('q_dis_tes',N_periods,N_timeSteps,'Type','continuous','LowerBound',0,'UpperBound',1);  %(-) Q_dis_tes/Q_dis_tes_nom
%
k_onoff_tes = optimvar('k_onoff_tes',N_periods,N_timeSteps,'Type','integer','LowerBound',0,'UpperBound',1);
k_ch_tes = optimvar('k_ch_tes',N_periods,N_timeSteps,'Type','integer','LowerBound',0,'UpperBound',1);
k_dis_tes = optimvar('k_dis_tes',N_periods,N_timeSteps,'Type','integer','LowerBound',0,'UpperBound',1);
%
% Constraints
%
problem.Constraints.TES_Binary = [  q_ch_tes <= k_ch_tes;...
                                    q_dis_tes <= k_dis_tes;...
                                    k_ch_tes + k_dis_tes <= k_onoff_tes];
%
problem.Constraints.TES_MinLoad = [ q_ch_tes >= q_ch_tes_min * k_ch_tes;...
                                    q_dis_tes >= q_dis_tes_min * k_dis_tes];
%
Q_charged_tes = Q_ch_tes_nom * cumsum(q_ch_tes,2) * dt/3600 * eta_ch_tes_nom; %(kWh_th)
Q_discharged_tes = Q_dis_tes_nom * cumsum(q_dis_tes,2) * dt/3600 / eta_dis_tes_nom; %(kWh_th)
Q_initial_tes = cap_tes_nom * soc_tes_0;    %(kWh_th)
soc_tes = (Q_charged_tes - Q_discharged_tes + Q_initial_tes) / cap_tes_nom; %(-)
problem.Constraints.TES_soc = [  soc_tes >= soc_tes_min;...
                                 soc_tes_max >= soc_tes];
%
problem.Constraints.TES_cyclic = [  soc_tes(:,end) == soc_tes_0];
%
%% Electric grid
%
W_abs_grid_nom = 60;    %(kW_el)
W_inj_grid_nom = W_abs_grid_nom;    %(kW_el)
%
% Variables
%
w_abs_grid = optimvar('w_abs_grid',N_periods,N_timeSteps,'Type','continuous','LowerBound',0,'UpperBound',1);  %(-) W_abs_grid/W_abs_grid_nom
w_inj_grid = optimvar('w_inj_grid',N_periods,N_timeSteps,'Type','continuous','LowerBound',0,'UpperBound',1);  %(-) W_inj_grid/W_inj_grid_nom
%
k_absinj_grid = optimvar('k_absinj_grid',N_periods,N_timeSteps,'Type','integer','LowerBound',0,'UpperBound',1);
%
% Constraints
%
problem.Constraints.Grid_Binary = [ w_abs_grid <= k_absinj_grid;...
                                    w_inj_grid <= (1 - k_absinj_grid)];
%
%% Fuel grid
%
F_abs_grid_nom = F_bl_nom * 1.1;  %(kW_th)
%
% Variables
%
f_abs_grid = optimvar('f_abs_grid',N_periods,N_timeSteps,'Type','continuous','LowerBound',0,'UpperBound',1);  %(-) F_abs_grid/F_abs_grid_nom
%
%% Electric energy bus
%
problem.Constraints.W_balance = [W_abs_grid_nom*w_abs_grid - W_inj_grid_nom*w_inj_grid + W_chp_nom*w_chp - W_dem == 0]; %(kW)
%
problem.Constraints.Q_balance = [Q_chp_nom*q_chp + Q_bl_nom*q_bl + Q_dis_tes_nom*q_dis_tes - Q_ch_tes_nom*q_ch_tes - Q_dem == 0]; %(kW_th)
%
problem.Constraints.F_balance = [F_abs_grid_nom*f_abs_grid - F_bl_nom*f_bl - F_chp_nom*f_chp == 0]; %(kW_f)
%
%% Objective function
%
cost_el = sum(W_abs_grid_nom*w_abs_grid .* price_el_abs * dt/3600,'all');
gain_el = sum(W_inj_grid_nom*w_inj_grid .* price_el_inj * dt/3600,'all');
%
cost_fuel = sum(F_abs_grid_nom*f_abs_grid .* price_f_abs * dt/3600,'all');
%
cost_tot = cost_el - gain_el + cost_fuel;
%
case_num = 1;
%
switch case_num
    case 1  %minimise the cost
        fobj = cost_tot;
    case 2 %thermal following (badly implemented)
        %
        thermal_chp = Q_chp_nom*q_chp;
        thermal_dem = Q_dem;
        %
        aux1 = optimvar('aux1',N_periods,N_timeSteps,'Type','continuous','LowerBound',10*min(-thermal_dem),'UpperBound',10*(Q_chp_nom-min(thermal_dem)));
        %
        problem.Constraints.Auxiliary1 = [  aux1 >= thermal_chp - thermal_dem;
                                            aux1 >= -(thermal_chp - thermal_dem)];
        %
        fobj = sum(aux1,'all');
        %
    case 3 %thermal following (more reasonably implemented)
        %
        thermal_chp = Q_chp_nom*q_chp;
        thermal_dem = Q_dem;
        %
        aux1 = optimvar('aux1',N_periods,N_timeSteps,'Type','continuous','LowerBound',10*min(-thermal_dem),'UpperBound',10*(Q_chp_nom-min(thermal_dem)));
        %
        problem.Constraints.Auxiliary1 = [  aux1 >= thermal_chp - thermal_dem;
                                            aux1 >= -(thermal_chp - thermal_dem)];
        %
        alpha1 = 1;
        alpha2 = 1e-4;
        %
        fobj = alpha1*sum(aux1,'all') + alpha2*cost_tot;
        %
end
%
problem.Objective = fobj;
%
%% Problem solving
%
tic
[sol,objFunction,ip_eflag]=solve(problem,'options',options);
toc
%
cost = evaluate(cost_tot,sol)
%
%% Results
%
figure
tiledlayout(1,2,"TileSpacing","compact","Padding","compact")
%
nexttile
%
bar([-sol.w_inj_grid*W_inj_grid_nom;sol.w_chp*W_chp_nom; sol.w_abs_grid*W_abs_grid_nom]',"stacked")
hold on
stairs((1:24)-0.5,W_dem,'LineWidth',2,'Color','k')
%
grid on
box on
pbaspect([1 1 1])
xlabel("t (h)",'Interpreter','latex')
ylabel("Electric production ($kW_{el}$)",'Interpreter','latex')
legend("Grid_{inj}","CHP","Grid_{abs}","Demand","Location","northwest","FontSize",28)
set(gca,"FontName","Times New Roman","FontSize",28)
%
nexttile
%
bar([-sol.q_ch_tes*Q_ch_tes_nom; sol.q_chp*Q_chp_nom; sol.q_bl*Q_bl_nom; sol.q_dis_tes*Q_dis_tes_nom]',"stacked")
hold on
stairs((1:24)-0.5,Q_dem,'LineWidth',2,'Color','k')
%
grid on
box on
pbaspect([1 1 1])
xlabel("t (h)",'Interpreter','latex')
ylabel("Thermal production ($kW_{th}$)",'Interpreter','latex')
legend("TES_{ch}","CHP","Boiler","TES_{dis}","Demand","Location","northwest","FontSize",28)
set(gca,"FontName","Times New Roman","FontSize",28)
%
figure
tiledlayout(2,1,"TileSpacing","compact","Padding","compact")
%
nexttile
%
stairs((1:24)-0.5,evaluate(soc_tes,sol),'LineWidth',2,'Color','k')
%
grid on
box on
pbaspect([3 1 1])
xlabel("t (h)",'Interpreter','latex')
ylabel("$SOC_{tes}$ (-)",'Interpreter','latex')
set(gca,"FontName","Times New Roman","FontSize",28)
%
nexttile
%
bar([-sol.q_ch_tes*Q_ch_tes_nom; sol.q_dis_tes*Q_dis_tes_nom]',"stacked")
%
grid on
box on
pbaspect([3 1 1])
xlabel("t (h)",'Interpreter','latex')
ylabel("$\dot{Q}_{tes}$ ($kW_{th}$)",'Interpreter','latex')
legend("TES_{ch}","TES_{dis}","Location","northwest","FontSize",28)
set(gca,"FontName","Times New Roman","FontSize",28)
%
%