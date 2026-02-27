%% Plot Figure 6: Breakdown of IRFs - Pure Interest Rate Shock
%
% This script generates Figure 6 from Drechsel & Tenreyro (2018), showing
% the decomposition of impulse responses when ONLY the interest rate channel
% operates (no commodity price shock).
%
% Model: DT_rateonly.mod
% - Baseline parameters (psi=2.8, xi=0.199)
% - Commodity price shock turned OFF (sigptil=0)
% - Interest rate shock turned ON (sigmu calibrated, rhomu=0.9 per Footnote 25)
% - IRFs are INVERTED (multiplied by -1) to show boom effect from rate DECREASE
%
% Expected pattern (per paper):
% - GDP rises gradually (hump-shaped, no immediate jump)
% - Both sectors expand due to cheaper credit for capital
% - Trade balance falls (becomes negative deficit) due to borrowing boom
%
% Output: Figure6_rateonly.png

clear; close all;

%% Load IRF results from Dynare
% Ensure DT_rateonly.mod has been run first: dynare DT_rateonly

results_file = 'DT_rateonly/Output/DT_rateonly_results.mat';

if ~exist(results_file, 'file')
    error(['Results file not found: ' results_file newline ...
           'Please run: dynare DT_rateonly']);
end

load(results_file, 'oo_');

%% Extract IRFs to interest rate shock (emu)
% IMPORTANT: In the model, lnmu process has "-emu" term:
%   lnmu = (1-rhomu)*log(mubar) + rhomu*lnmu(-1) - emu
% This means: positive emu → lnmu falls → r falls → BOOM (not recession!)
% Therefore, NO SIGN INVERSION needed - positive emu already represents rate decrease

% Check which GDP measure has non-zero response
fprintf('\nDEBUG: Checking GDP IRF responses (first 3 quarters):\n');
if isfield(oo_.irfs, 'lngdp_emu')
    fprintf('  lngdp_emu (current prices): [%.4f, %.4f, %.4f]\n', oo_.irfs.lngdp_emu(1:3));
end
if isfield(oo_.irfs, 'lngdp2_emu')
    fprintf('  lngdp2_emu (constant prices): [%.4f, %.4f, %.4f]\n', oo_.irfs.lngdp2_emu(1:3));
end
fprintf('  lnc_emu: [%.4f, %.4f, %.4f]\n', oo_.irfs.lnc_emu(1:3));
fprintf('  lni_emu: [%.4f, %.4f, %.4f]\n', oo_.irfs.lni_emu(1:3));
fprintf('  tbaggout_emu: [%.4f, %.4f, %.4f]\n', oo_.irfs.tbaggout_emu(1:3));
fprintf('\nNote: lnmu equation has "-emu" term, so positive emu = rate DECREASE = boom\n');
fprintf('      No sign inversion needed!\n');

% Use lngdp2 (constant price GDP) if lngdp shows no response
if isfield(oo_.irfs, 'lngdp2_emu') && max(abs(oo_.irfs.lngdp2_emu)) > max(abs(oo_.irfs.lngdp_emu))
    gdp_total = 100 * oo_.irfs.lngdp2_emu;  % GDP at constant prices (NO inversion)
    fprintf('\nUsing lngdp2 (constant price GDP) for Figure 6.\n');
else
    gdp_total = 100 * oo_.irfs.lngdp_emu;   % GDP at current prices (NO inversion)
    fprintf('\nUsing lngdp (current price GDP) for Figure 6.\n');
end

tb_total = 100 * oo_.irfs.tbaggout_emu;     % TB/GDP total (pp, NO inversion)

% Sectoral decomposition (NO inversion)
gdp_final = 100 * oo_.irfs.lnva_final_emu;  % Final goods VA (percent)
gdp_comm = 100 * oo_.irfs.lnva_comm_emu;    % Commodities VA (percent)

tb_final = 100 * oo_.irfs.tbout_emu;        % Final goods TB (pp)
tb_comm = 100 * oo_.irfs.tbtilout_emu;      % Commodities TB (pp)

%% Create Figure 6: 2x2 layout
figure('Position', [100, 100, 1000, 800]);

% Horizons
horizons = 1:10;

%% Panel 1 (top-left): Total GDP response
subplot(2,2,1);
plot(horizons, gdp_total, 'b-', 'LineWidth', 2);
hold on;
yline(0, 'k--', 'LineWidth', 0.5);
xlabel('Quarters');
ylabel('Percent');
title('GDP (Total Response)');
grid on;

% Display peak value (max absolute value and its quarter)
[peak_val, peak_idx] = max(abs(gdp_total));
fprintf('\nFigure 6 - Total Responses:\n');
fprintf('  GDP: Peak = %.2f%% at quarter %d\n', gdp_total(peak_idx), peak_idx);

%% Panel 2 (top-right): Total Trade Balance response
subplot(2,2,2);
plot(horizons, tb_total, 'b-', 'LineWidth', 2);
hold on;
yline(0, 'k--', 'LineWidth', 0.5);
xlabel('Quarters');
ylabel('Percent of GDP');
title('Trade Balance/GDP (Total)');
grid on;

fprintf('  TB/GDP: Impact = %.2f pp, Average(1-4Q) = %.2f pp\n', ...
        tb_total(1), mean(tb_total(1:4)));

%% Panel 3 (bottom-left): GDP breakdown by sector
subplot(2,2,3);
hold on;
plot(horizons, gdp_final, 'b:', 'LineWidth', 2, 'DisplayName', 'Final goods');
plot(horizons, gdp_comm, 'r--', 'LineWidth', 2, 'DisplayName', 'Commodities');
yline(0, 'k--', 'LineWidth', 0.5);
xlabel('Quarters');
ylabel('Percent');
title('GDP Breakdown (by Sector)');
legend('Location', 'best');
grid on;

fprintf('\nFigure 6 - Sectoral Breakdown (Average 1-4Q):\n');
fprintf('  Final goods VA: %.2f%%\n', mean(gdp_final(1:4)));
fprintf('  Commodities VA: %.2f%%\n', mean(gdp_comm(1:4)));

%% Panel 4 (bottom-right): Trade Balance breakdown by sector
subplot(2,2,4);
hold on;
plot(horizons, tb_final, 'b:', 'LineWidth', 2, 'DisplayName', 'Final goods');
plot(horizons, tb_comm, 'r--', 'LineWidth', 2, 'DisplayName', 'Commodities');
yline(0, 'k--', 'LineWidth', 0.5);
xlabel('Quarters');
ylabel('Percent of GDP');
title('Trade Balance Breakdown');
legend('Location', 'best');
grid on;

fprintf('  Final goods TB: %.2f pp\n', mean(tb_final(1:4)));
fprintf('  Commodities TB: %.2f pp\n', mean(tb_comm(1:4)));

%% Save figure
saveas(gcf, 'Figure6_rateonly.png');
fprintf('\nFigure saved as: Figure6_rateonly.png\n');

%% Interpretation notes
fprintf('\n=== INTERPRETATION (per paper) ===\n');
fprintf('Figure 6 isolates the BORROWING COST EFFECT (pure interest rate channel).\n');
fprintf('When interest rates fall (but commodity prices stay constant):\n');
fprintf('  - GDP rises gradually (hump-shaped) as capital accumulates\n');
fprintf('  - Both sectors expand: cheaper credit for capital investment\n');
fprintf('  - Final goods sector benefits more (capital-intensive)\n');
fprintf('  - Trade balance falls (deficit): borrowing boom for C and I\n');
fprintf('  - Compare with Figure 4 (total) and Figure 5 (competitiveness only)\n');
fprintf('    to isolate the interest rate channel contribution.\n');
