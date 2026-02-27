%% DRECHSEL & TENREYRO (2018) - Figure 1
%  Output per capita 1900-2015
%  Section 2: Empirical Regularities

clear all;
close all;
clc;

%% Load Data
% DataVAR.xlsx is located in the parent directory
data = readmatrix('../DataVAR.xlsx', 'Range', 'A2');

yr = data(:, 1);    % Year
gdp = data(:, 2);   % Log real GDP/capita

%% FIGURE 1: Output per capita 1900-2015
figure('Position', [100 100 1200 500]);

% Panel (a): Argentina
subplot(1,2,1);
plot(yr, gdp, 'b-', 'LineWidth', 1.5);
hold on;
p = polyfit(yr, gdp, 1);
plot(yr, polyval(p, yr), 'r--', 'LineWidth', 1.5);

growth = (gdp(end) - gdp(1)) / (yr(end) - yr(1)) * 100;

xlabel('Year');
ylabel('Log Real GDP per capita');
title('(a) Argentina');
legend({'GDP per capita', 'Linear trend'}, 'Location', 'northwest');
grid on;
xlim([1900 2015]);
ylim([7.5 10.5]);
text(1920, 10, sprintf('Growth: %.2f%%/year', growth), ...
     'FontSize', 10, 'BackgroundColor', 'w');
hold off;

% Panel (b): US (data not available)
subplot(1,2,2);
axis off;
text(0.5, 0.5, {'\bf(b) United States', '', ...
                'Data not available in', ...
                'replication files', '', ...
                'Paper shows:', ...
                '• Log GDP per capita', ...
                '• Cubic trend', ...
                '• Period: 1900-2015'}, ...
     'HorizontalAlignment', 'center', 'Units', 'normalized', 'FontSize', 11);

saveas(gcf, 'Figure1_output.png');
fprintf('Figure saved: Figure1_output.png\n');
