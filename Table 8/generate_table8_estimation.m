%% DRECHSEL & TENREYRO (2018) - Table 8
%  Posterior estimates of parameters
%  Section 5 / Appendix D
%
%  Generates a CSV replicating the exact structure of Table 8 in the paper:
%  Parameter | Prior mean | Posterior mean | 90% HPD interval
%
%  Prerequisites: Run 'dynare DTest' first (~6-10 hours)
%  Output: Table8_estimation.csv

clear; clc;

%% Load estimation results
results_path = 'DTest/Output/DTest_results.mat';
if ~isfile(results_path)
    error('DTest_results.mat not found. Run ''dynare DTest'' first.');
end

load(results_path, 'oo_');
fprintf('Estimation results loaded from: %s\n\n', results_path);

%% Define parameters in exact paper order with prior means
%  Paper order: xi, psi, rho_a, rho_atil, rho_g, rho_nu, rho_s, rho_mu,
%               rho1_ptil, rho2_ptil, sig_a, sig_atil, sig_g, sig_nu,
%               sig_s, sig_mu, sig_ptil

% Parameter name in Dynare, display label, prior mean, type ('param' or 'shock')
spec = {
    'xi',       'xi',           0.199,  'param'
    'psi',      'psi',          2.8,    'param'
    'rhoa',     'rho_a',        0.5,    'param'
    'rhoatil',  'rho_atil',     0.5,    'param'
    'rhog',     'rho_g',        0.5,    'param'
    'rhom',     'rho_nu',       0.5,    'param'
    'rhos',     'rho_s',        0.5,    'param'
    'rhol',     'rho_mu',       0.5,    'param'
    'rhoptil1', 'rho1_ptil',    0.8,    'param'
    'rhoptil2', '-rho2_ptil',   0.15,   'param'
    'ea',       'sigma_a',      0.10,   'shock'
    'eatil',    'sigma_atil',   0.10,   'shock'
    'eg',       'sigma_g',      0.10,   'shock'
    'em',       'sigma_nu',     0.10,   'shock'
    'es',       'sigma_s',      0.10,   'shock'
    'el',       'sigma_mu',     0.10,   'shock'
    'eptil',    'sigma_ptil',   0.10,   'shock'
};

n = size(spec, 1);

%% Extract posterior statistics
post_mean = zeros(n, 1);
hpd_low   = zeros(n, 1);
hpd_high  = zeros(n, 1);

for ii = 1:n
    dyn_name = spec{ii, 1};
    type     = spec{ii, 4};

    if strcmp(type, 'param')
        post_mean(ii) = oo_.posterior_mean.parameters.(dyn_name);
        hpd_low(ii)   = oo_.posterior_hpdinf.parameters.(dyn_name);
        hpd_high(ii)  = oo_.posterior_hpdsup.parameters.(dyn_name);
    else  % shock
        post_mean(ii) = oo_.posterior_mean.shocks_std.(dyn_name);
        hpd_low(ii)   = oo_.posterior_hpdinf.shocks_std.(dyn_name);
        hpd_high(ii)  = oo_.posterior_hpdsup.shocks_std.(dyn_name);
    end
end

prior_mean = cell2mat(spec(:, 3));

%% Display to console (matching paper format)
fprintf('TABLE 8: Posterior estimates of parameters\n');
fprintf('================================================================\n');
fprintf('%-14s %12s %16s %10s %10s\n', ...
    'Parameter', 'Prior mean', 'Posterior mean', 'HPD low', 'HPD high');
fprintf('----------------------------------------------------------------\n');

for ii = 1:n
    fprintf('%-14s %12.4f %16.4f %10.4f %10.4f\n', ...
        spec{ii, 2}, prior_mean(ii), post_mean(ii), hpd_low(ii), hpd_high(ii));
end
fprintf('================================================================\n');

%% Save to CSV
fid = fopen('Table8_estimation.csv', 'w');
fprintf(fid, 'Parameter,Prior_Mean,Posterior_Mean,HPD_90_Low,HPD_90_High\n');

for ii = 1:n
    fprintf(fid, '%s,%.4f,%.4f,%.4f,%.4f\n', ...
        spec{ii, 2}, prior_mean(ii), post_mean(ii), hpd_low(ii), hpd_high(ii));
end

fclose(fid);
fprintf('\nTable saved: Table8_estimation.csv\n');
