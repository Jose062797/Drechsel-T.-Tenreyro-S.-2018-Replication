%% DRECHSEL & TENREYRO (2018) - Figure 2
%  Commodity Prices
%  Section 2: Empirical Regularities

clear all;
close all;
clc;

%% Load Data
% DataVAR.xlsx is located in the parent directory
data = readmatrix('../DataVAR.xlsx', 'Range', 'A2');

yr = data(:, 1);    % Year
pcom = data(:, 6);  % P (log deviations)

%% FIGURE 2: Commodity Prices
figure('Position', [100 100 1200 500]);

% Panel (a): Comparison not available
subplot(1,2,1);
axis off;
text(0.5, 0.5, {'\bf(a) World vs. Argentina-specific index', '', ...
                'Argentina-specific index', ...
                'not available in', ...
                'replication files', '', ...
                'Paper shows comparison:', ...
                '• Grilli-Yang (world)', ...
                '• Argentina-specific', ...
                '• Period: 1962-2015', ...
                '• Both normalized to 100 in 1962'}, ...
     'HorizontalAlignment', 'center', 'Units', 'normalized', 'FontSize', 11);

% Panel (b): Real commodity price fluctuations
subplot(1,2,2);
plot(yr, pcom, 'b-', 'LineWidth', 1.5);
hold on;
yline(0, 'k--', 'Alpha', 0.5);

xlabel('Year');
ylabel('Log deviations from mean');
title('(b) Real Commodity Price Fluctuations');
legend({'Grilli-Yang index', 'Mean'}, 'Location', 'northwest');
grid on;
xlim([1900 2015]);
ylim([-0.8 0.6]);
hold off;

saveas(gcf, 'Figure2_prices.png');
fprintf('Figure saved: Figure2_prices.png\n');
