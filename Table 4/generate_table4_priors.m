%% GENERATE TABLE 4: ESTIMATED PARAMETERS AND PRIORS
% Replication of Table 4 from Drechsel & Tenreyro (2018)
% "Commodity booms and busts in emerging economies"
% Journal of International Economics, 112, 200-218
%
% This script creates a formatted table showing the prior distributions
% used in the Bayesian estimation of the DSGE model.
%
% Author: Replication project
% Date: February 2026

clear; clc;

%% Define Table 4 data structure (from paper, page 210)

% Column headers
headers = {'Parameter', 'Description', 'Prior', 'Mean', 'Std. Dev.'};

% Row data (following exact order from Table 4)
data = {
    'n (xi)',          'Sensitivity of spread to commodity prices', 'Normal',      -0.199,  0.045;
    'x (psi)',         'Elasticity of debt in spread',              'Normal',       2.8,    0.5;
    'q¹_p̃ (rhoptil1)', 'Commodity price AR(2) - lag 1',             'Beta',         0.8,    0.1;
    '-q²_p̃ (rhoptil2)','Commodity price AR(2) - lag 2 (magnitude)', 'Beta',         0.15,   0.1;
    'σ_p̃ (sigptil)',   'Std. dev. commodity price shock',           'Inv-Gamma',    0.05,   2;
    'q_a (rhoa)',      'Persistence of productivity shock (final)',  'Beta',         0.5,    0.2;
    'q_ã (rhoatil)',   'Persistence of productivity shock (comm.)',  'Beta',         0.5,    0.2;
    'q_g (rhog)',      'Persistence of growth shock',                'Beta',         0.5,    0.2;
    'q_s (rhos)',      'Persistence of government spending shock',   'Beta',         0.5,    0.2;
    'q_m (rhom)',      'Persistence of preference shock',            'Beta',         0.5,    0.2;
    'q_l (rhol)',      'Persistence of interest rate risk shock',    'Beta',         0.5,    0.2;
    'σ_a (siga)',      'Std. dev. productivity shock (final)',       'Inv-Gamma',    0.05,   2;
    'σ_ã (sigatil)',   'Std. dev. productivity shock (comm.)',       'Inv-Gamma',    0.05,   2;
    'σ_g (sigg)',      'Std. dev. growth shock',                     'Inv-Gamma',    0.05,   2;
    'σ_s (sigs)',      'Std. dev. government spending shock',        'Inv-Gamma',    0.05,   2;
    'σ_m (sigm)',      'Std. dev. preference shock',                 'Inv-Gamma',    0.05,   2;
    'σ_l (sigl)',      'Std. dev. interest rate risk shock',         'Inv-Gamma',    0.05,   2;
};

%% Create table
T = cell2table(data, 'VariableNames', headers);

%% Display to console
fprintf('\n');
fprintf('========================================================================\n');
fprintf('TABLE 4: ESTIMATED PARAMETERS AND PRIORS\n');
fprintf('Drechsel & Tenreyro (2018)\n');
fprintf('========================================================================\n\n');

disp(T);

fprintf('========================================================================\n');
fprintf('Notes:\n');
fprintf('- All rho (q) parameters use Beta distribution: bounded [0,1]\n');
fprintf('- All sigma parameters use Inverse-Gamma: strictly positive\n');
fprintf('- Structural parameters (n, x) use Normal: can be negative\n');
fprintf('- rhoptil2 is estimated as magnitude; model uses negative coefficient\n');
fprintf('- Prior mean 0.05 for all sigma as per Table 4 (Footnote 30: ptil_dev_obs excluded)\n');
fprintf('========================================================================\n\n');

%% Save to CSV
output_file = 'Table4_priors.csv';
writetable(T, output_file);

fprintf('Table saved to: %s\n\n', output_file);

%% Create LaTeX version (optional)
latex_file = 'Table4_priors.tex';
fid = fopen(latex_file, 'w');

fprintf(fid, '\\begin{table}[htbp]\n');
fprintf(fid, '\\centering\n');
fprintf(fid, '\\caption{Estimated Parameters and Priors}\n');
fprintf(fid, '\\label{tab:table4_priors}\n');
fprintf(fid, '\\begin{tabular}{llccc}\n');
fprintf(fid, '\\hline\\hline\n');
fprintf(fid, 'Parameter & Description & Prior & Mean & Std. Dev. \\\\\n');
fprintf(fid, '\\hline\n');

% Group 1: Structural parameters
fprintf(fid, '\\multicolumn{5}{l}{\\textit{Structural parameters}} \\\\\n');
for i = 1:2
    fprintf(fid, '$%s$ & %s & %s & %.3f & %.3f \\\\\n', ...
        strrep(data{i,1}, ' (', '$, '), data{i,2}, data{i,3}, data{i,4}, data{i,5});
end
fprintf(fid, '\\\\\n');

% Group 2: Commodity price process
fprintf(fid, '\\multicolumn{5}{l}{\\textit{Commodity price process (AR(2))}} \\\\\n');
for i = 3:5
    fprintf(fid, '$%s$ & %s & %s & %.3f & %.2f \\\\\n', ...
        strrep(data{i,1}, ' (', '$, '), data{i,2}, data{i,3}, data{i,4}, data{i,5});
end
fprintf(fid, '\\\\\n');

% Group 3: Other shock persistences
fprintf(fid, '\\multicolumn{5}{l}{\\textit{Persistence parameters ($q_i$)}} \\\\\n');
for i = 6:11
    fprintf(fid, '$%s$ & %s & %s & %.2f & %.2f \\\\\n', ...
        strrep(data{i,1}, ' (', '$, '), data{i,2}, data{i,3}, data{i,4}, data{i,5});
end
fprintf(fid, '\\\\\n');

% Group 4: Shock volatilities
fprintf(fid, '\\multicolumn{5}{l}{\\textit{Volatility parameters ($\\sigma_i$)}} \\\\\n');
for i = 12:17
    fprintf(fid, '$%s$ & %s & %s & %.2f & %.0f \\\\\n', ...
        strrep(data{i,1}, ' (', '$, '), data{i,2}, data{i,3}, data{i,4}, data{i,5});
end

fprintf(fid, '\\hline\\hline\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\begin{tablenotes}\n');
fprintf(fid, '\\small\n');
fprintf(fid, '\\item Notes: Prior distributions for Bayesian estimation. ');
fprintf(fid, 'Beta priors ensure persistence parameters are bounded in [0,1]. ');
fprintf(fid, 'Inverse-Gamma priors ensure shock volatilities are strictly positive. ');
fprintf(fid, 'The parameter $-q^2_{\\tilde{p}}$ is estimated as a positive magnitude; ');
fprintf(fid, 'the model uses the negative coefficient in the AR(2) process.\n');
fprintf(fid, '\\end{tablenotes}\n');
fprintf(fid, '\\end{table}\n');

fclose(fid);

fprintf('LaTeX table saved to: %s\n\n', latex_file);
