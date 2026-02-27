%% Figure 7: Estimated and actual process for commodity prices
% Replicates Figure 7 from Drechsel & Tenreyro (2018)
%
% Plots two series:
%   - Blue solid line: Actual real commodity price index (Grilli-Yang, log deviations from mean)
%   - Black dashed line: Model-implied commodity price process (from Kalman smoother)
%
% Data sources:
%   - Actual prices: DataVAR.xlsx column 6
%   - Model-implied: oo_.SmoothedVariables.ptil_dev_obs from DTest estimation
%
% Methodology (confirmed by NotebookLM):
%   The model-implied series is the smoothed state variable ptil_dev_obs
%   from the Kalman smoother, which is mathematically equivalent to feeding
%   the smoothed shocks into the AR(2) commodity price equation (Eq. 16).

clear; close all; clc;

%% Load actual commodity prices from data
data = readmatrix('../DataVAR.xlsx', 'Range', 'A2');
years_full = data(:, 1);        % 1900-2015 (116 obs)
pcom_actual = data(:, 6);       % Real commodity price index (log deviations from mean)

%% Load model-implied commodity prices from estimation results
% SmoothedVariables have 115 observations (1901-2015, one lost to lag)
results_path = '../Table 8/DTest/Output/DTest_results.mat';
if ~isfile(results_path)
    error('DTest_results.mat not found. Run Bayesian estimation first (dynare DTest in Table 8/).');
end

load(results_path, 'oo_');

% Extract smoothed commodity price (in log deviations from steady state)
pcom_model = oo_.SmoothedVariables.ptil_dev_obs;  % 115 x 1

% The smoothed variables correspond to years 1901-2015 (first obs lost to differencing)
years_model = (1901:2015)';

% Trim actual data to match model sample (1901-2015)
idx_start = find(years_full == 1901);
idx_end = find(years_full == 2015);
years_actual_trimmed = years_full(idx_start:idx_end);
pcom_actual_trimmed = pcom_actual(idx_start:idx_end);

% Verify alignment
assert(length(pcom_model) == length(pcom_actual_trimmed), ...
    'Length mismatch between model and actual series');
assert(all(years_model == years_actual_trimmed), ...
    'Year alignment mismatch');

%% Also plot full actual series (1900-2015) for completeness
% The paper figure shows 1900-2015 range on x-axis

%% Create Figure 7
fig = figure('Position', [100, 100, 900, 450]);

% Plot actual commodity prices (full sample 1900-2015)
plot(years_full, pcom_actual, '-', 'Color', [0 0.4470 0.7410], 'LineWidth', 1.5);
hold on;

% Plot model-implied commodity prices (1901-2015)
plot(years_model, pcom_model, '--k', 'LineWidth', 1.5);

% Formatting
xlabel('');
ylabel('');
xlim([1900 2015]);
ylim([-0.8 0.6]);
set(gca, 'XTick', 1910:10:2010);
grid off;
box on;

% Legend (bottom-right as in paper)
legend('Actual commodity price', 'Model implied commodity price', ...
    'Location', 'southeast', 'FontSize', 10);

set(gca, 'FontSize', 11);

% Save
print(fig, 'Figure7_commodity_prices', '-dpng', '-r300');
fprintf('Figure 7 saved: Figure7_commodity_prices.png\n');

%% Display summary statistics
fprintf('\n=== Figure 7 Summary ===\n');
fprintf('Actual commodity price (1900-2015): mean=%.4f, std=%.4f\n', mean(pcom_actual), std(pcom_actual));
fprintf('Model implied price (1901-2015):    mean=%.4f, std=%.4f\n', mean(pcom_model), std(pcom_model));

% Correlation between the two series (1901-2015)
corr_val = corr(pcom_actual_trimmed, pcom_model);
fprintf('Correlation (1901-2015): %.4f\n', corr_val);

% Post-1950 correlation
idx_1950 = find(years_model == 1950);
corr_post1950 = corr(pcom_actual_trimmed(idx_1950:end), pcom_model(idx_1950:end));
fprintf('Correlation (1950-2015): %.4f\n', corr_post1950);
