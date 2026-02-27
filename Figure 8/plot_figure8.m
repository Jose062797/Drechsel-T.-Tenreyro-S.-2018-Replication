%% Figure 8: Historical decomposition of Argentine output growth 1900-2015
% Replicates Figure 8 from Drechsel & Tenreyro (2018)
%
% Shows stacked bar chart decomposing output growth into contributions
% from different structural shocks, computed at the posterior mode.
%
% Shock categories (paper notation):
%   "a and a_tilde" = ea + eatil  (Stationary technology, both sectors)
%   "g"             = eg          (Nonstationary technology / trend)
%   "p_tilde"       = eptil       (Commodity price shock)
%   "Other"         = em + es + el + initial values (Preference + Spending + Interest rate)
%
% Prerequisites: Run 'dynare DTest_shockdec' first to generate oo_.shock_decomposition

clear; close all; clc;

%% Load shock decomposition results
results_path = 'DTest_shockdec/Output/DTest_shockdec_results.mat';
if ~isfile(results_path)
    error(['DTest_shockdec_results.mat not found.\n' ...
           'Run ''dynare DTest_shockdec'' first from this directory.']);
end

load(results_path, 'oo_', 'M_');

%% Extract shock decomposition
% oo_.shock_decomposition dimensions: [n_endo_vars x (n_shocks+2) x T]
%   Columns 1:n_shocks = contribution of each shock
%   Column n_shocks+1  = contribution of initial values
%   Column n_shocks+2  = smoothed observed variable (sum of all)

sd = oo_.shock_decomposition;
[n_vars, n_cols, T] = size(sd);
n_shocks = M_.exo_nbr;  % Should be 7

fprintf('Shock decomposition: %d vars x %d columns x %d periods\n', n_vars, n_cols, T);
fprintf('Number of shocks: %d\n', n_shocks);

%% Identify the row for y_growth_obs
var_name = 'y_growth_obs';
var_idx = [];
for ii = 1:size(M_.endo_names, 1)
    if strcmp(strtrim(M_.endo_names(ii,:)), var_name)
        var_idx = ii;
        break;
    end
end
if isempty(var_idx)
    error('Variable %s not found in M_.endo_names', var_name);
end
fprintf('Found %s at index %d\n', var_name, var_idx);

%% Identify shock column indices
shock_names = cellstr(M_.exo_names);
fprintf('\nShock order in varexo:\n');
for ii = 1:length(shock_names)
    fprintf('  %d: %s\n', ii, strtrim(shock_names{ii}));
end

idx_ea    = find(strcmp(strtrim(shock_names), 'ea'));
idx_eatil = find(strcmp(strtrim(shock_names), 'eatil'));
idx_eg    = find(strcmp(strtrim(shock_names), 'eg'));
idx_es    = find(strcmp(strtrim(shock_names), 'es'));
idx_em    = find(strcmp(strtrim(shock_names), 'em'));
idx_el    = find(strcmp(strtrim(shock_names), 'el'));
idx_eptil = find(strcmp(strtrim(shock_names), 'eptil'));

%% Extract contributions for y_growth_obs
sd_y = squeeze(sd(var_idx, :, :));  % (n_shocks+2) x T

contrib_ea    = sd_y(idx_ea, :);
contrib_eatil = sd_y(idx_eatil, :);
contrib_eg    = sd_y(idx_eg, :);
contrib_es    = sd_y(idx_es, :);
contrib_em    = sd_y(idx_em, :);
contrib_el    = sd_y(idx_el, :);
contrib_eptil = sd_y(idx_eptil, :);
contrib_init  = sd_y(n_shocks+1, :);
observed      = sd_y(n_shocks+2, :);

%% Group into paper categories
cat_stat_tech    = contrib_ea + contrib_eatil;   % "a and a_tilde"
cat_nonstat_tech = contrib_eg;                    % "g"
cat_comm_price   = contrib_eptil;                 % "p_tilde"
cat_other        = contrib_em + contrib_es + contrib_el + contrib_init;  % "Other"

%% Verify additivity
total_decomp = cat_stat_tech + cat_nonstat_tech + cat_comm_price + cat_other;
max_error = max(abs(total_decomp - observed));
fprintf('\nAdditivity check: max error = %.2e\n', max_error);

%% Time axis
years = (1901:(1901+T-1))';
fprintf('Time range: %d to %d (%d periods)\n', years(1), years(end), T);

%% Colors matching the paper (cyan/blue scheme)
color_stat_tech  = [0.60 0.87 0.93];  % Cyan/light blue (a and a_tilde)
color_nonstat    = [0.20 0.40 0.75];  % Medium blue (g)
color_comm_price = [0.00 0.05 0.35];  % Dark navy/black (p_tilde)
color_other      = [1.00 1.00 1.00];  % White with edge (Other)

%% Split point
split_year = 1955;
idx_split = find(years == split_year);

%% ===== PANEL 1: 1901-1955 =====
fig1 = figure('Position', [50, 400, 1100, 420]);

years1 = years(1:idx_split);
all_data1 = [cat_stat_tech(1:idx_split); cat_nonstat_tech(1:idx_split); ...
             cat_comm_price(1:idx_split); cat_other(1:idx_split)]';

b1 = bar(years1, all_data1, 'stacked', 'BarWidth', 0.85);

% Colors and edges
b1(1).FaceColor = color_stat_tech;
b1(1).EdgeColor = [0.35 0.65 0.72];
b1(1).LineWidth = 0.4;
b1(2).FaceColor = color_nonstat;
b1(2).EdgeColor = [0.12 0.25 0.55];
b1(2).LineWidth = 0.4;
b1(3).FaceColor = color_comm_price;
b1(3).EdgeColor = [0.00 0.00 0.20];
b1(3).LineWidth = 0.4;
b1(4).FaceColor = color_other;
b1(4).EdgeColor = [0.50 0.50 0.50];
b1(4).LineWidth = 0.4;

hold on;
% Observed GDP growth — thick black line
plot(years1, observed(1:idx_split), '-k', 'LineWidth', 2.0);
hold off;

xlim([years1(1)-1 years1(end)+1]);
ylim([-0.22 0.22]);
set(gca, 'XTick', 1910:10:1950, 'FontSize', 11);
set(gca, 'YTick', -0.20:0.05:0.20);
ylabel('');
% Horizontal grid lines (tenue)
set(gca, 'YGrid', 'on', 'XGrid', 'on', 'GridAlpha', 0.15, 'GridLineStyle', '-');
box on;

% Save Panel 1
print(fig1, 'Figure8_panel1', '-dpng', '-r300');
fprintf('Figure 8 Panel 1 saved: Figure8_panel1.png\n');

%% ===== PANEL 2: 1956-2015 =====
fig2 = figure('Position', [50, 50, 1100, 420]);

years2 = years(idx_split+1:end);
all_data2 = [cat_stat_tech(idx_split+1:end); cat_nonstat_tech(idx_split+1:end); ...
             cat_comm_price(idx_split+1:end); cat_other(idx_split+1:end)]';

b2 = bar(years2, all_data2, 'stacked', 'BarWidth', 0.85);

b2(1).FaceColor = color_stat_tech;
b2(1).EdgeColor = [0.35 0.65 0.72];
b2(1).LineWidth = 0.4;
b2(2).FaceColor = color_nonstat;
b2(2).EdgeColor = [0.12 0.25 0.55];
b2(2).LineWidth = 0.4;
b2(3).FaceColor = color_comm_price;
b2(3).EdgeColor = [0.00 0.00 0.20];
b2(3).LineWidth = 0.4;
b2(4).FaceColor = color_other;
b2(4).EdgeColor = [0.50 0.50 0.50];
b2(4).LineWidth = 0.4;

hold on;
plot(years2, observed(idx_split+1:end), '-k', 'LineWidth', 2.0);
hold off;

xlim([years2(1)-1 years2(end)+1]);
ylim([-0.14 0.10]);
set(gca, 'XTick', 1960:10:2010, 'FontSize', 11);
set(gca, 'YTick', -0.12:0.02:0.10);
ylabel('');
set(gca, 'YGrid', 'on', 'XGrid', 'on', 'GridAlpha', 0.15, 'GridLineStyle', '-');
box on;

% Legend matching paper style (horizontal, inside bottom-left)
legend([b2(1) b2(2) b2(3) b2(4)], ...
    {'$a$ and $\tilde{a}$', '$g$', '$\tilde{p}$', 'Other'}, ...
    'Interpreter', 'latex', 'Location', 'southwest', 'FontSize', 12, ...
    'Orientation', 'horizontal', 'EdgeColor', [0.3 0.3 0.3]);

% Save Panel 2
print(fig2, 'Figure8_panel2', '-dpng', '-r300');
fprintf('Figure 8 Panel 2 saved: Figure8_panel2.png\n');

%% Display summary statistics
fprintf('\n=== Figure 8 Summary Statistics ===\n');
fprintf('Mean contribution to output growth (1901-2015):\n');
fprintf('  Stationary tech (a,atil): %.4f (%.1f%%)\n', mean(cat_stat_tech), 100*var(cat_stat_tech)/var(observed));
fprintf('  Nonstationary tech (g):   %.4f (%.1f%%)\n', mean(cat_nonstat_tech), 100*var(cat_nonstat_tech)/var(observed));
fprintf('  Commodity price (ptil):   %.4f (%.1f%%)\n', mean(cat_comm_price), 100*var(cat_comm_price)/var(observed));
fprintf('  Other (m,s,l,init):       %.4f (%.1f%%)\n', mean(cat_other), 100*var(cat_other)/var(observed));
fprintf('  Observed GDP growth:      %.4f\n', mean(observed));
