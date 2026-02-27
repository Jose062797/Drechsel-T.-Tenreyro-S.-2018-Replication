% Replicate Figure 5: Breakdown of IRFs - No Interest Rate Channel (xi = 0)
% Shows "competitiveness effect" only by shutting off borrowing cost channel
% 4 panels: GDP, Trade Balance, GDP breakdown, TB breakdown

clear; close all;

%% Load results from xi = 0 model
fprintf('Loading model results...\n');

if exist('DT_xi0/Output/DT_xi0_results.mat', 'file')
    xi0 = load('DT_xi0/Output/DT_xi0_results.mat', 'oo_', 'M_');
    fprintf('  Model with xi = 0 loaded\n');
else
    error('DT_xi0 results not found. Please run: dynare DT_xi0');
end

%% Extract IRFs from xi = 0 model (competitiveness effect only)
% Total GDP response (log)
lngdp_irf = xi0.oo_.irfs.lngdp_eptil;

% GDP breakdown by sector (VALUE ADDED - corrected per NotebookLM)
lnva_final_irf = xi0.oo_.irfs.lnva_final_eptil;  % Final goods VA: y - ptil*mtil
lnva_comm_irf = xi0.oo_.irfs.lnva_comm_eptil;    % Commodities VA: ptil*ytil

% Total trade balance response (% of GDP)
tb_total_irf = xi0.oo_.irfs.tby_obs_eptil;

% Trade balance breakdown by sector (% of GDP)
tb_final_irf = xi0.oo_.irfs.tbout_eptil;         % Final goods sector TB
tb_comm_irf = xi0.oo_.irfs.tbtilout_eptil;       % Commodity sector TB

% IRF horizon
irf_horizon = 1:length(lngdp_irf);

%% Create Figure 5 with 4 panels (2x2 layout)
figure('Position', [100, 100, 1200, 900], 'Color', 'w');

% Panel 1 (top left): Total GDP response
subplot(2,2,1)
plot(irf_horizon, lngdp_irf * 100, 'b-', 'LineWidth', 2);
hold on;
plot(irf_horizon, zeros(size(irf_horizon)), 'k-', 'LineWidth', 0.5);
xlabel('Years');
ylabel('%');
title('GDP');
grid on;
xlim([1 10]);
ylim([0 2]);

% Panel 2 (top right): Total Trade Balance response
subplot(2,2,2)
plot(irf_horizon, tb_total_irf * 100, 'b-', 'LineWidth', 2);
hold on;
plot(irf_horizon, zeros(size(irf_horizon)), 'k-', 'LineWidth', 0.5);
xlabel('Years');
ylabel('%');
title('Trade balance');
grid on;
xlim([1 10]);

% Panel 3 (bottom left): GDP breakdown by sector (VALUE ADDED)
subplot(2,2,3)
plot(irf_horizon, lnva_final_irf * 100, 'b:', 'LineWidth', 2, 'DisplayName', 'Final goods');
hold on;
plot(irf_horizon, lnva_comm_irf * 100, 'r--', 'LineWidth', 2, 'DisplayName', 'Commodities');
plot(irf_horizon, zeros(size(irf_horizon)), 'k-', 'LineWidth', 0.5, 'HandleVisibility', 'off');
xlabel('Years');
ylabel('%');
title('GDP (breakdown)');
legend('Location', 'northeast');
grid on;
xlim([1 10]);
ylim([-50 100]);

% Panel 4 (bottom right): Trade Balance breakdown by sector
subplot(2,2,4)
plot(irf_horizon, tb_final_irf * 100, 'b:', 'LineWidth', 2, 'DisplayName', 'Final goods');
hold on;
plot(irf_horizon, tb_comm_irf * 100, 'r--', 'LineWidth', 2, 'DisplayName', 'Commodities');
plot(irf_horizon, zeros(size(irf_horizon)), 'k-', 'LineWidth', 0.5, 'HandleVisibility', 'off');
xlabel('Years');
ylabel('%');
title('Trade balance (breakdown)');
legend('Location', 'northeast');
grid on;
xlim([1 10]);
ylim([-10 10]);

% Overall title
sgtitle('Figure 5: Breakdown of IRFs - No Interest Rate Channel (\xi = 0)', ...
        'FontSize', 14, 'FontWeight', 'bold');

%% Save figure
saveas(gcf, 'Figure5_decomposition_xi0.png');
fprintf('\nFigure saved as: Figure5_decomposition_xi0.png\n');

%% Display key statistics
fprintf('\n===========================================\n');
fprintf('FIGURE 5: COMPETITIVENESS EFFECT ONLY\n');
fprintf('===========================================\n');
fprintf('Model configuration:\n');
fprintf('  xi  = %.3f (interest rate channel OFF)\n', ...
    xi0.M_.params(strmatch('xi', xi0.M_.param_names, 'exact')));
fprintf('  psi = %.3f\n', ...
    xi0.M_.params(strmatch('psi', xi0.M_.param_names, 'exact')));
fprintf('\nPeak responses to 1 std dev commodity price shock:\n');
fprintf('  Total GDP:          %.2f%%\n', max(lngdp_irf) * 100);
fprintf('  Final goods VA:     %.2f%% (min: %.2f%%)\n', max(lnva_final_irf) * 100, min(lnva_final_irf) * 100);
fprintf('  Commodities VA:     %.2f%%\n', max(lnva_comm_irf) * 100);
fprintf('  Total TB/GDP:       %.2f pp (trough: %.2f pp)\n', ...
    max(tb_total_irf) * 100, min(tb_total_irf) * 100);
fprintf('  Final goods TB/GDP: %.2f pp (trough: %.2f pp)\n', ...
    max(tb_final_irf) * 100, min(tb_final_irf) * 100);
fprintf('  Commodity TB/GDP:   %.2f pp (trough: %.2f pp)\n', ...
    max(tb_comm_irf) * 100, min(tb_comm_irf) * 100);
fprintf('===========================================\n');

%% Load baseline model for comparison (if available)
if exist('../Figure 4/DT/Output/DT_results.mat', 'file')
    baseline = load('../Figure 4/DT/Output/DT_results.mat', 'oo_', 'M_');
    fprintf('\nCOMPARISON WITH BASELINE (xi = 0.199):\n');
    lngdp_baseline = baseline.oo_.irfs.lngdp_eptil;
    tby_baseline = baseline.oo_.irfs.tby_obs_eptil;

    fprintf('  GDP peak difference:      %.2f pp\n', ...
        (max(lngdp_baseline) - max(lngdp_irf)) * 100);
    fprintf('  TB/GDP trough difference: %.2f pp\n', ...
        (min(tby_baseline) - min(tb_total_irf)) * 100);
    fprintf('(Difference shows contribution of interest rate channel)\n');
    fprintf('===========================================\n');
end
