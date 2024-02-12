%%
%
clc
close all
clearvars
%
%% Objective
%
fobj_lin = @(x1,x2)(2.*x1 + 5.*x2);
fobj_nlin = @(x1,x2)(2.*x1.^2 + 5.*x2);
%
np = 50;
x1_vec = linspace(-10, 10, np);
x2_vec = linspace(-10, 10 ,np);
%
[x1_mat, x2_mat] = meshgrid(x1_vec,x2_vec);
%
y_mat_lin = fobj_lin(x1_mat, x2_mat);
y_mat_nlin = fobj_nlin(x1_mat, x2_mat);
%
%% Constraints
%
triangle = nsidedpoly(3,'Center',[0 0],'Radius',5);
%
vert = triangle.Vertices;
vert = [vert; vert(1,:)];

%
%%
%
figure
tiledlayout(1,2,"TileSpacing","compact","Padding","compact")
%
nexttile
%
contourf(x1_mat, x2_mat, y_mat_lin, 10,'LineStyle','none')
hold on
%
cb = colorbar;
cb.Label.String = "$f_{obj}(x_1,x_2)$";
cb.Label.Interpreter = "latex";
%
for i = 1 : length(vert) - 1
    %
    x2_cons = vert(i+1,2) + (x1_vec - vert(i+1,1)) ./ (vert(i,1) - vert(i+1,1)) .* (vert(i,2) - vert(i+1,2));
    %
    plot(x1_vec, x2_cons,'LineWidth',2,'Color','k')


    %
end
%
plot(vert(:,1),vert(:,2),'Color','r','LineStyle','none','Marker','o','MarkerFaceColor','r','MarkerSize',10)
%
xlabel('$x_1\;(-)$','Interpreter','latex')
ylabel('$x_2\;(-)$','Interpreter','latex')
set(gca,"FontName",'Times New Roman',"FontSize",28)
pbaspect([1 1 1])
xlim([min(x1_vec) max(x1_vec)])
ylim([min(x2_vec) max(x2_vec)])
grid on
%
nexttile
%
%
contourf(x1_mat, x2_mat, y_mat_nlin, 10,'LineStyle','none')
hold on
%
cb = colorbar;
cb.Label.String = "$f_{obj}(x_1,x_2)$";
cb.Label.Interpreter = "latex";
%
for i = 1 : length(vert) - 1
    %
    x2_cons = vert(i+1,2) + (x1_vec - vert(i+1,1)) ./ (vert(i,1) - vert(i+1,1)) .* (vert(i,2) - vert(i+1,2));
    %
    plot(x1_vec, x2_cons,'LineWidth',2,'Color','k')


    %
end
%
plot(vert(:,1),vert(:,2),'Color','r','LineStyle','none','Marker','o','MarkerFaceColor','r','MarkerSize',10)
%
xlabel('$x_1\;(-)$','Interpreter','latex')
ylabel('$x_2\;(-)$','Interpreter','latex')
set(gca,"FontName",'Times New Roman',"FontSize",28)
pbaspect([1 1 1])
xlim([min(x1_vec) max(x1_vec)])
ylim([min(x2_vec) max(x2_vec)])
grid on
%
%
%