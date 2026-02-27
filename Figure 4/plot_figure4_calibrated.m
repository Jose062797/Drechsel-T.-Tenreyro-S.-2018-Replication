% Replicate Figure 4: IRFs from CALIBRATED DSGE model
% Based on NotebookLM clarification: Figure 4 uses calibrated parameters, not estimated
% This script loads results from DT.mod (calibrated model)

clear; close all;

%% Load calibrated model results
fprintf('Loading calibrated model results...\n');
load('DT/Output/DT_results.mat', 'oo_', 'M_');

%% Extract IRFs to commodity price shock (eptil)
% Extract variables
lngdp_irf = oo_.irfs.lngdp_eptil;
lnc_irf = oo_.irfs.lnc_eptil;
lni_irf = oo_.irfs.lni_eptil;
tby_irf = oo_.irfs.tby_obs_eptil;

% Extract IRF horizon
irf_horizon = 1:length(lngdp_irf);

%% Create Figure 4
figure('Position', [100, 100, 1200, 800], 'Color', 'w');

% Panel 1: GDP
subplot(2,2,1)
plot(irf_horizon, lngdp_irf * 100, 'b-', 'LineWidth', 2);
hold on;
plot(irf_horizon, zeros(size(irf_horizon)), 'k-', 'LineWidth', 0.5);
xlabel('Years');
ylabel('Percent');
title('Output');
grid on;
xlim([1 10]);

% Panel 2: Consumption
subplot(2,2,2)
plot(irf_horizon, lnc_irf * 100, 'b-', 'LineWidth', 2);
hold on;
plot(irf_horizon, zeros(size(irf_horizon)), 'k-', 'LineWidth', 0.5);
xlabel('Years');
ylabel('Percent');
title('Consumption');
grid on;
xlim([1 10]);

% Panel 3: Investment
subplot(2,2,3)
plot(irf_horizon, lni_irf * 100, 'b-', 'LineWidth', 2);
hold on;
plot(irf_horizon, zeros(size(irf_horizon)), 'k-', 'LineWidth', 0.5);
xlabel('Years');
ylabel('Percent');
title('Investment');
grid on;
xlim([1 10]);

% Panel 4: Trade Balance (as % of GDP)
subplot(2,2,4)
plot(irf_horizon, tby_irf * 100, 'b-', 'LineWidth', 2);
hold on;
plot(irf_horizon, zeros(size(irf_horizon)), 'k-', 'LineWidth', 0.5);
xlabel('Years');
ylabel('Percent of GDP');
title('Trade Balance / GDP');
grid on;
xlim([1 10]);

% Overall title
sgtitle('Figure 4: Impulse Responses to Commodity Price Shock (Calibrated Model)', ...
        'FontSize', 14, 'FontWeight', 'bold');

%% Save figure
saveas(gcf, 'Figure4_DSGE_calibrated.png');
fprintf('Figure saved as: Figure4_DSGE_calibrated.png\n');

%% Display parameter values used
fprintf('\n===========================================\n');
fprintf('CALIBRATED PARAMETERS (from Table 3)\n');
fprintf('===========================================\n');
shock_idx = strmatch('eptil', M_.exo_names, 'exact');
fprintf('Commodity price process AR(2):\n');
fprintf('  rhoptil1 = %.4f (calibrated from SVAR)\n', M_.params(strmatch('rhoptil1', M_.param_names, 'exact')));
fprintf('  rhoptil2 = %.4f (calibrated from SVAR)\n', M_.params(strmatch('rhoptil2', M_.param_names, 'exact')));
fprintf('  sigptil  = %.4f (calibrated from SVAR)\n', sqrt(M_.Sigma_e(shock_idx, shock_idx)));
fprintf('\nInterest rate parameters:\n');
fprintf('  xi  = %.4f (from regression Table 2)\n', M_.params(strmatch('xi', M_.param_names, 'exact')));
fprintf('  psi = %.4f (calibrated)\n', M_.params(strmatch('psi', M_.param_names, 'exact')));
fprintf('\nPeak responses to 1 std dev shock:\n');
fprintf('  GDP:          %.2f%%\n', max(lngdp_irf) * 100);
fprintf('  Consumption:  %.2f%%\n', max(lnc_irf) * 100);
fprintf('  Investment:   %.2f%%\n', max(lni_irf) * 100);
fprintf('  TB/GDP:       %.2f pp (trough: %.2f pp)\n', max(tby_irf) * 100, min(tby_irf) * 100);
fprintf('===========================================\n');
