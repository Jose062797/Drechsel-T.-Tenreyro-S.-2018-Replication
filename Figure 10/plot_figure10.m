%% Figure 10: Simulated GDP under different price measurement
% Replicates Figure 10 from Drechsel & Tenreyro (2018)
%
% "The exercise consists of feeding observed commodity prices into the model,
%  holding all other disturbances constant, and then computing two alternative
%  GDP measures." (Section 5.3)
%
%   Solid line:   lngdp  — GDP valued at actual commodity prices (Eq. 19)
%   Dotted line:  lngdp2 — GDP valued at steady-state commodity prices (Eq. 25)
%
% Method: Counterfactual simulation using decision rules (ghx, ghu)
%   1. Run estimation(mode_compute=0) with 5 observables (incl. ptil_dev_obs)
%      to recover the exact historical commodity price shocks at posterior modes
%   2. Build a shock matrix with ONLY eptil, all others = 0
%   3. Simulate the model from steady state using the linearized decision rules
%   4. Compare lngdp (actual prices) vs lngdp2 (constant prices)
%
% Prerequisites:
%   Run 'dynare DT_fig10' in this folder (uses posterior modes with 5 observables).

clear; close all;

%% Load smoother results
results_path = 'DT_fig10/Output/DT_fig10_results.mat';
if ~isfile(results_path)
    error(['DT_fig10_results.mat not found.\n' ...
           'Run ''dynare DT_fig10'' first from this directory.']);
end
load(results_path, 'oo_', 'M_', 'options_');

%% Build counterfactual shock matrix: ONLY eptil, all others = 0
% The paper says "holding all other disturbances constant"

% Get smoothed shocks
smoothed_shocks = oo_.SmoothedShocks;
T = length(smoothed_shocks.eptil);

% Create shock matrix: T x n_shocks (all zeros)
n_shocks = M_.exo_nbr;
shock_matrix = zeros(T, n_shocks);

% Find index of eptil and fill ONLY that column
idx_eptil = find(strcmp(cellstr(M_.exo_names), 'eptil'));
if isempty(idx_eptil)
    error('Shock eptil not found in model.');
end
shock_matrix(:, idx_eptil) = smoothed_shocks.eptil;

fprintf('Counterfactual simulation: feeding ONLY eptil shock (%d periods)\n', T);
fprintf('All other shocks (ea, eatil, eg, es, em, el) set to zero.\n');

%% Simulate the model from steady state with only eptil
% Manual implementation of Dynare's simult_ for order=1:
%   y_hat(t) = ghx * y_hat_state(t-1) + ghu * u(t)
% where y_hat is deviation from steady state in DR-order.

dr = oo_.dr;
ys = dr.ys;                  % steady state (declaration order)
ghx = dr.ghx;                % state transition matrix [n_endo x n_state]
ghu = dr.ghu;                % shock impact matrix [n_endo x n_shocks]
order_var = dr.order_var;     % DR-order -> declaration order mapping
nspred = M_.nspred;          % number of state variables (predetermined + both)
n_endo = M_.endo_nbr;        % number of endogenous variables

% Allocate output: [n_endo x (T+1)] in declaration order
y_sim = zeros(n_endo, T + 1);
y_sim(:, 1) = ys;            % initial condition = steady state

% y_hat in DR-order (deviations from SS)
y_hat = zeros(n_endo, 1);

for t = 1:T
    % State vector: first nspred elements of y_hat (DR-order)
    state = y_hat(1:nspred);

    % Decision rule: y_hat(t) = ghx * state(t-1) + ghu * u(t)
    y_hat = ghx * state + ghu * shock_matrix(t, :)';

    % Convert from DR-order to declaration order and add steady state
    y_sim(order_var, t + 1) = y_hat + ys(order_var);
end

%% Extract lngdp and lngdp2 from simulation
idx_lngdp  = find(strcmp(cellstr(M_.endo_names), 'lngdp'));
idx_lngdp2 = find(strcmp(cellstr(M_.endo_names), 'lngdp2'));

if isempty(idx_lngdp) || isempty(idx_lngdp2)
    error('lngdp or lngdp2 not found in model variables.');
end

% Drop initial condition (column 1)
sim_lngdp  = y_sim(idx_lngdp,  2:end)';
sim_lngdp2 = y_sim(idx_lngdp2, 2:end)';

fprintf('Range of lngdp:  [%.4f, %.4f]\n', min(sim_lngdp), max(sim_lngdp));
fprintf('Range of lngdp2: [%.4f, %.4f]\n', min(sim_lngdp2), max(sim_lngdp2));

%% Time axis
years = (1900:(1899+T))';

%% Plot (replicating Figure 10 style from paper)
fig = figure('Position', [100, 100, 700, 500], 'Color', 'w');

% Paper style: medium blue, solid + dense dotted
blue = [0.0 0.3 0.8];

h1 = plot(years, sim_lngdp,  '-',  'Color', blue, 'LineWidth', 1.5);
hold on;
h2 = plot(years, sim_lngdp2, ':',  'Color', blue, 'LineWidth', 1.5);
hold off;

legend([h1, h2], {'Model-implied log GDP', ...
        'Model-implied log GDP at constant commodity prices'}, ...
       'Location', 'northwest', 'FontSize', 9, 'Box', 'on');

set(gca, 'XTick', 1900:20:2020, 'FontSize', 10);
box on;
xlim([1900 2015]);
ylim([-1.7 -1.35]);
% Auto-adjust if data exceeds fixed limits
data_min = min(min(sim_lngdp), min(sim_lngdp2));
data_max = max(max(sim_lngdp), max(sim_lngdp2));
if data_min < -1.7 || data_max > -1.35
    ylim([min(-1.7, floor(data_min*20)/20) max(-1.35, ceil(data_max*20)/20)]);
end

%% Save
print(fig, 'Figure10_price_measurement', '-dpng', '-r300');
fprintf('Saved: Figure10_price_measurement.png\n');

%% Summary statistics
corr_val = corr(sim_lngdp, sim_lngdp2);
fprintf('\n--- COUNTERFACTUAL SIMULATION RESULTS ---\n');
fprintf('Correlation between lngdp and lngdp2: %.4f\n', corr_val);
fprintf('(High correlation confirms quantities drive most of the response,\n');
fprintf(' not direct commodity price valuation changes)\n');
fprintf('Max absolute difference: %.4f log points\n', max(abs(sim_lngdp - sim_lngdp2)));
