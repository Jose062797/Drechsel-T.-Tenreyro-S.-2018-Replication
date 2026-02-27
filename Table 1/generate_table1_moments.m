%% DRECHSEL & TENREYRO (2018) - Table 1
%  Business cycle moments 1900-2015

clear all;
clc;

%% Load Data
% DataVAR.xlsx is located in the parent directory
data = readmatrix('../DataVAR.xlsx', 'Range', 'A2');

yr = data(:, 1);
gdp = data(:, 2);
cons = data(:, 3);
inv = data(:, 4);
tb = data(:, 5);

%% Calculate Growth Rates (in percentage)
gdp_g = diff(gdp) * 100;
cons_g = diff(cons) * 100;
inv_g = diff(inv) * 100;
tb_level = tb(2:end) * 100;  % Convert to percentage (match paper format)

%% Calculate Statistics
% Mean
mean_gdp = mean(gdp_g);
mean_cons = mean(cons_g);
mean_inv = mean(inv_g);
mean_tb = mean(tb_level);

% Standard Deviation
std_gdp = std(gdp_g);
std_cons = std(cons_g);
std_inv = std(inv_g);
std_tb = std(tb_level);

% Persistence (AR(1) coefficient without intercept)
% Following the paper's methodology: y_t = rho * y_{t-1} + epsilon
mdl_gdp = fitlm(gdp_g(1:end-1), gdp_g(2:end), 'Intercept', false);
mdl_cons = fitlm(cons_g(1:end-1), cons_g(2:end), 'Intercept', false);
mdl_inv = fitlm(inv_g(1:end-1), inv_g(2:end), 'Intercept', false);
mdl_tb = fitlm(tb_level(1:end-1), tb_level(2:end), 'Intercept', false);

pers_gdp = mdl_gdp.Coefficients.Estimate(1);
pers_cons = mdl_cons.Coefficients.Estimate(1);
pers_inv = mdl_inv.Coefficients.Estimate(1);
pers_tb = mdl_tb.Coefficients.Estimate(1);

% Correlations
corr_gdp_gdp = 1;
corr_cons_gdp = corr(cons_g, gdp_g);
corr_inv_gdp = corr(inv_g, gdp_g);
corr_tb_gdp = corr(tb_level, gdp_g);

corr_gdp_cons = corr(gdp_g, cons_g);
corr_cons_cons = 1;
corr_inv_cons = corr(inv_g, cons_g);
corr_tb_cons = corr(tb_level, cons_g);

corr_gdp_inv = corr(gdp_g, inv_g);
corr_cons_inv = corr(cons_g, inv_g);
corr_inv_inv = 1;
corr_tb_inv = corr(tb_level, inv_g);

corr_gdp_tb = corr(gdp_g, tb_level);
corr_cons_tb = corr(cons_g, tb_level);
corr_inv_tb = corr(inv_g, tb_level);
corr_tb_tb = 1;

%% Print Table
fprintf('\nTable 1: Business Cycle Moments (1900-2015)\n\n');
fprintf('%-25s %10s %10s %10s %10s\n', '', 'GDP', 'Cons.', 'Inv.', 'TB');
fprintf('%-25s %10s %10s %10s %10s\n', '', 'growth', 'growth', 'growth', '');
fprintf('--------------------------------------------------------------------\n');
fprintf('%-25s %9.2f%% %9.2f%% %9.2f%% %9.2f%%\n', 'Mean', mean_gdp, mean_cons, mean_inv, mean_tb);
fprintf('%-25s %10.2f %10.2f %10.2f %10.2f\n', 'Std. deviation', std_gdp, std_cons, std_inv, std_tb);
fprintf('%-25s %10.2f %10.2f %10.2f %10.2f\n', 'Persistence (AR1)', pers_gdp, pers_cons, pers_inv, pers_tb);
fprintf('\n%-25s\n', 'Correlation with:');
fprintf('%-25s %10.2f %10.2f %10.2f %10.2f\n', '  GDP growth', corr_gdp_gdp, corr_cons_gdp, corr_inv_gdp, corr_tb_gdp);
fprintf('%-25s %10.2f %10.2f %10.2f %10.2f\n', '  Cons. growth', corr_gdp_cons, corr_cons_cons, corr_inv_cons, corr_tb_cons);
fprintf('%-25s %10.2f %10.2f %10.2f %10.2f\n', '  Inv. growth', corr_gdp_inv, corr_cons_inv, corr_inv_inv, corr_tb_inv);
fprintf('%-25s %10.2f %10.2f %10.2f %10.2f\n', '  Trade balance', corr_gdp_tb, corr_cons_tb, corr_inv_tb, corr_tb_tb);
fprintf('--------------------------------------------------------------------\n');

%% Save to CSV
T = table(...
    {'Mean'; 'Standard deviation'; 'Persistence'; ''; 'Correlation with GDP growth'; ...
     'Correlation with Cons. growth'; 'Correlation with Inv. growth'; 'Correlation with TB'}, ...
    [mean_gdp; std_gdp; pers_gdp; NaN; corr_gdp_gdp; corr_gdp_cons; corr_gdp_inv; corr_gdp_tb], ...
    [mean_cons; std_cons; pers_cons; NaN; corr_cons_gdp; corr_cons_cons; corr_cons_inv; corr_cons_tb], ...
    [mean_inv; std_inv; pers_inv; NaN; corr_inv_gdp; corr_inv_cons; corr_inv_inv; corr_inv_tb], ...
    [mean_tb; std_tb; pers_tb; NaN; corr_tb_gdp; corr_tb_cons; corr_tb_inv; corr_tb_tb], ...
    'VariableNames', {'Statistic', 'GDP_growth', 'Cons_growth', 'Inv_growth', 'Trade_balance'});

writetable(T, 'Table1_moments.csv');
fprintf('Table saved to Table1_moments.csv\n');
