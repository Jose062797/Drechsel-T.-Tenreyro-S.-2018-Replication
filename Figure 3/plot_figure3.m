%% DRECHSEL & TENREYRO (2018) - Figure 3
%  SVAR: Impulse responses to commodity price shock
%
%  Methodology:
%  - Cholesky decomposition with commodity prices ordered first
%  - Bayesian Monte Carlo following Sims & Zha (1999)
%  - Normal-Inverse-Wishart posterior with flat prior
%  - 80% probability bands (percentiles 10 and 90)
%  - Posterior median as central estimate

clear all;
clc;

%% Load Data
% DataVAR.xlsx is located in the parent directory
data = readmatrix('../DataVAR.xlsx', 'Range', 'A2');

yr = data(:, 1);
gdp = data(:, 2);      % Already in logs
cons = data(:, 3);     % Already in logs
inv = data(:, 4);      % Already in logs
tb = data(:, 5);       % Trade balance / GDP ratio
pcom = data(:, 6);     % Commodity price (log deviations from mean)

%% Verify data
fprintf('Data loaded: %d observations (1900-2015)\n', length(yr));

%% Prepare VAR data
% Following the paper (Section 2.3, page 203):
% Z_t = [pcom_t, gdp_t, cons_t, inv_t, tb_t]'
% Commodity price ordered first (exogenous to Argentina)
Z = [pcom, gdp, cons, inv, tb];
T = size(Z, 1);

%% Estimate VAR(2) with trend
% Specification: Z_t = c + Γ*t + A_1*Z_{t-1} + A_2*Z_{t-2} + e_t
p = 2;
model = varm(5, p);
model.Trend = NaN(5, 1);  % Linear trend
model = estimate(model, Z);
res = infer(model, Z);

fprintf('VAR(%d) estimated with %d observations\n', p, T);

%% Compute IRFs using Cholesky identification
% Commodity prices ordered first (exogenous to Argentina)
nsteps = 10;
Response = irf(model, 'NumObs', nsteps);
irf_pcom = squeeze(Response(:, 1, :));

% Extract responses and convert to percentage
irf_gdp_pct = irf_pcom(:, 2) * 100;
irf_cons_pct = irf_pcom(:, 3) * 100;
irf_inv_pct = irf_pcom(:, 4) * 100;
irf_tb_pct = irf_pcom(:, 5) * 100;

%% Compute probability bands via Bayesian Monte Carlo (Sims & Zha 1999)
% Normal-Inverse-Wishart posterior with flat prior
nboot = 1000;
rng(123);

irf_boot_gdp = zeros(nsteps, nboot);
irf_boot_cons = zeros(nsteps, nboot);
irf_boot_inv = zeros(nsteps, nboot);
irf_boot_tb = zeros(nsteps, nboot);

fprintf('Computing probability bands (%d draws from posterior)...\n', nboot);

% Prepare matrices for Bayesian inference
T_effective = T - p;
num_vars = size(Z, 2);
Y = Z(p+1:end, :);
X = [ones(T_effective, 1), (p+1:T)'];
for lag = 1:p
    X = [X, Z(p+1-lag:end-lag, :)];
end
K = size(X, 2);

% OLS estimates
XtX = X' * X;
B_ols = XtX \ (X' * Y);
XtX_inv = XtX \ eye(K);
S = (Y - X * B_ols)' * (Y - X * B_ols);

% Monte Carlo loop
for b = 1:nboot
    if mod(b, 250) == 0
        fprintf('  %d/%d draws completed\n', b, nboot);
    end

    try
        % Draw from posterior: Sigma ~ IW, B|Sigma ~ N
        Sigma_draw = iwishrnd(S, T_effective - K);
        L_XtX = chol(XtX_inv, 'lower');
        L_Sigma = chol(Sigma_draw, 'lower');
        B_draw = B_ols + L_XtX * randn(K, num_vars) * L_Sigma';

        % Extract VAR parameters
        const_draw = B_draw(1, :)';
        trend_draw = B_draw(2, :)';
        AR_draw = cell(p, 1);
        for lag = 1:p
            idx_start = 3 + (lag-1)*num_vars;
            idx_end = 2 + lag*num_vars;
            AR_draw{lag} = B_draw(idx_start:idx_end, :)';
        end

        % Compute IRFs for this draw
        model_draw = varm('Constant', const_draw, 'Trend', trend_draw, 'AR', AR_draw);
        model_draw.Covariance = Sigma_draw;
        Response_draw = irf(model_draw, 'NumObs', nsteps);
        irf_pcom_draw = squeeze(Response_draw(:, 1, :));

        % Store results
        irf_boot_gdp(:, b) = irf_pcom_draw(:, 2) * 100;
        irf_boot_cons(:, b) = irf_pcom_draw(:, 3) * 100;
        irf_boot_inv(:, b) = irf_pcom_draw(:, 4) * 100;
        irf_boot_tb(:, b) = irf_pcom_draw(:, 5) * 100;
    catch
        irf_boot_gdp(:, b) = NaN;
        irf_boot_cons(:, b) = NaN;
        irf_boot_inv(:, b) = NaN;
        irf_boot_tb(:, b) = NaN;
    end
end

% Compute percentiles (80% probability bands + median)
gdp_lower = prctile(irf_boot_gdp, 10, 2);
gdp_median = prctile(irf_boot_gdp, 50, 2);
gdp_upper = prctile(irf_boot_gdp, 90, 2);

cons_lower = prctile(irf_boot_cons, 10, 2);
cons_median = prctile(irf_boot_cons, 50, 2);
cons_upper = prctile(irf_boot_cons, 90, 2);

inv_lower = prctile(irf_boot_inv, 10, 2);
inv_median = prctile(irf_boot_inv, 50, 2);
inv_upper = prctile(irf_boot_inv, 90, 2);

tb_lower = prctile(irf_boot_tb, 10, 2);
tb_median = prctile(irf_boot_tb, 50, 2);
tb_upper = prctile(irf_boot_tb, 90, 2);

%% Plot Figure 3
figure('Position', [100, 100, 1000, 600]);

% Include ALL periods (0 through 9)
horizons = 0:(nsteps-1);  % 0, 1, 2, ..., 9
idx_plot = 1:nsteps;       % All indices

% GDP
subplot(2, 2, 1);
hold on;
fill([horizons, fliplr(horizons)], [gdp_lower(idx_plot)', fliplr(gdp_upper(idx_plot)')], ...
    [0.8, 0.8, 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
plot(horizons, gdp_median(idx_plot), 'b-', 'LineWidth', 2);  % Use posterior median
plot(horizons, zeros(size(horizons)), 'k--', 'LineWidth', 0.5);
hold off;
xlabel('Years');
ylabel('%');
title('GDP');
grid on;
xlim([0, nsteps-1]);

% Consumption
subplot(2, 2, 2);
hold on;
fill([horizons, fliplr(horizons)], [cons_lower(idx_plot)', fliplr(cons_upper(idx_plot)')], ...
    [0.8, 0.8, 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
plot(horizons, cons_median(idx_plot), 'b-', 'LineWidth', 2);  % Use posterior median
plot(horizons, zeros(size(horizons)), 'k--', 'LineWidth', 0.5);
hold off;
xlabel('Years');
ylabel('%');
title('Consumption');
grid on;
xlim([0, nsteps-1]);

% Investment
subplot(2, 2, 3);
hold on;
fill([horizons, fliplr(horizons)], [inv_lower(idx_plot)', fliplr(inv_upper(idx_plot)')], ...
    [0.8, 0.8, 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
plot(horizons, inv_median(idx_plot), 'b-', 'LineWidth', 2);  % Use posterior median
plot(horizons, zeros(size(horizons)), 'k--', 'LineWidth', 0.5);
hold off;
xlabel('Years');
ylabel('%');
title('Investment');
grid on;
xlim([0, nsteps-1]);

% Trade balance
subplot(2, 2, 4);
hold on;
fill([horizons, fliplr(horizons)], [tb_lower(idx_plot)', fliplr(tb_upper(idx_plot)')], ...
    [0.8, 0.8, 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
plot(horizons, tb_median(idx_plot), 'b-', 'LineWidth', 2);  % Use posterior median
plot(horizons, zeros(size(horizons)), 'k--', 'LineWidth', 0.5);
hold off;
xlabel('Years');
ylabel('%');
title('Trade balance');
grid on;
xlim([0, nsteps-1]);

sgtitle('Impulse responses to 1 S.D. commodity price shock');

% Save figure
saveas(gcf, 'Figure3_SVAR.png');
fprintf('Figure saved as Figure3_SVAR.png\n\n');

%% Summary
fprintf('Analysis complete.\n');
