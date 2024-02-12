%% Heading
%
clc
close all
clearvars
%
%%
%
f_chp_data = linspace(0,1); %(-)
%
eta_el_chp_nom = 0.3;   %(-)
eta_el_chp_data = (1 - (1 - f_chp_data).^2) * eta_el_chp_nom;  %(-)
%
eta_tot_chp_data = 0.9; %(-)
eta_th_chp_nom = eta_tot_chp_data - eta_el_chp_nom; %(-)
%
eta_th_chp_data = eta_tot_chp_data - eta_el_chp_data;   %(-)
%
w_chp_data = f_chp_data .* eta_el_chp_data / eta_el_chp_nom;
q_chp_data = f_chp_data .* eta_th_chp_data / eta_th_chp_nom;
%
%%
%
function_w_chp_data = fit(f_chp_data',w_chp_data','linearinterp');
function_q_chp_data = fit(f_chp_data',q_chp_data','linearinterp');
%
f_pieceWise = [0.3 1];
%
q_pieceWise = function_q_chp_data(f_pieceWise);
w_pieceWise = function_w_chp_data(f_pieceWise);
%
A_el_chp = (w_pieceWise(1) - w_pieceWise(2)) / (f_pieceWise(1) - f_pieceWise(2));
B_el_chp = w_pieceWise(2) - f_pieceWise(2)*(w_pieceWise(1) - w_pieceWise(2)) / (f_pieceWise(1) - f_pieceWise(2));
%
A_th_chp = (q_pieceWise(1) - q_pieceWise(2)) / (f_pieceWise(1) - f_pieceWise(2));
B_th_chp = q_pieceWise(2) - f_pieceWise(2)*(q_pieceWise(1) - q_pieceWise(2)) / (f_pieceWise(1) - f_pieceWise(2));
%
%%
%
figure
tiledlayout(1,2,"TileSpacing","compact","Padding","compact")
%
nexttile
%
plot(f_chp_data,eta_el_chp_data,...
    "LineWidth",2)
hold on
%
plot(f_chp_data,eta_th_chp_data,...
    "LineWidth",2)
%
grid on
box on
set(gca,"FontName","Times New Roman","FontSize",28)
xlabel("$f_{chp}\;=\;\dot{F}_{chp}/\dot{F}_{chp,nom}$","Interpreter","latex")
ylabel("efficiency (-)","Interpreter","latex")
legend("$\eta_{el,chp}$","$\eta_{th,chp}$","Interpreter","latex")

%
nexttile
%
plot(f_chp_data,w_chp_data,...
    "LineWidth",2)
hold on
plot(f_chp_data,A_el_chp * f_chp_data + B_el_chp,...
    "LineWidth",2,"Color","k","LineStyle","--")
%
plot(f_chp_data,q_chp_data,...
    "LineWidth",2)
plot(f_chp_data,A_th_chp * f_chp_data + B_th_chp,...
    "LineWidth",2,"Color","r","LineStyle","--")
%
line([1 0],[1 0],"LineWidth",2,"Color","b")
%
xline(0.3,"LineWidth",2,"Color","k","LineStyle",":")
%
grid on
box on
set(gca,"FontName","Times New Roman","FontSize",28)
xlabel("$f_{chp}\;=\;\dot{F}_{chp}/\dot{F}_{chp,nom}\;(-)$","Interpreter","latex")
ylabel("relative load (-)","Interpreter","latex")
legend("$w_{chp}\;=\;\dot{W}_{chp}/\dot{W}_{chp,nom}$","$w_{chp}$ linearised",...
    "$q_{chp}\;=\;\dot{Q}_{chp}/\dot{Q}_{chp,nom}$","$q_{chp}$ linearised",...
    "constant efficiencies","Minimum load",...
    "Interpreter","latex","Location","southeast")
%
















