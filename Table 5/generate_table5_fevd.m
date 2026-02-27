%% GENERATE TABLE 5 - Variance Decomposition
%% Drechsel & Tenreyro (2018), "Commodity booms and busts in emerging economies"
%%
%% Extracts unconditional FEVD from Dynare results and formats as Table 5.
%% Handles Panel (a) and optionally Panel (b) if results are available.
%%
%% Usage:
%%   cd 'Table 5'
%%   dynare DTest_table5       % Panel (a): solves model at posterior mean
%%   generate_table5_fevd      % This script - formats and saves results
%%
%% For Panel (b), also run:
%%   dynare DTest_1950          % Estimate on 1950-2015 subsample (~6-10 hrs)
%%   dynare DTest_1950_fevd     % Extract FEVD from posterior mode
%%   generate_table5_fevd       % Re-run to include both panels

clear; clc;

%% ========================================================================
%% PANEL (a): 1900-2015
%% ========================================================================

results_file_a = fullfile('DTest_table5', 'Output', 'DTest_table5_results.mat');
if ~exist(results_file_a, 'file')
    error('Panel (a) results not found. Run "dynare DTest_table5" first.');
end

fprintf('Loading Panel (a) results...\n');
load(results_file_a);

% Extract shock names
shock_names = cellstr(M_.exo_names);

% Observable variables (rows in variance_decomposition follow oo_.var_list order)
obs_vars = {'y_growth_obs', 'c_growth_obs', 'i_growth_obs', 'tby_obs'};
obs_labels = {'Output growth', 'Consumption growth', 'Investment growth', 'Trade balance'};
n_obs = length(obs_vars);

% Map rows: variance_decomposition rows follow oo_.var_list order
var_list = cellstr(oo_.var_list);
obs_idx = zeros(n_obs, 1);
for j = 1:n_obs
    idx = find(strcmp(var_list, obs_vars{j}));
    if isempty(idx)
        error('Variable %s not found in var_list.', obs_vars{j});
    end
    obs_idx(j) = idx;
end

% Map shock columns to indices
shock_map = {'ea', 'eatil', 'eg', 'es', 'em', 'el', 'eptil'};
shock_idx = zeros(length(shock_map), 1);
for j = 1:length(shock_map)
    idx = find(strcmp(shock_names, shock_map{j}));
    if isempty(idx)
        error('Shock %s not found in model.', shock_map{j});
    end
    shock_idx(j) = idx;
end

% Extract variance decomposition
if ~isfield(oo_, 'variance_decomposition')
    error('Variance decomposition not computed. Check stoch_simul options.');
end

vd = oo_.variance_decomposition;

% Build Table 5 Panel (a)
% Column order: Stat.tech | Nonstat.tech | Interest rate | Comm.price | Spending | Preference
table5a = zeros(n_obs, 6);
for j = 1:n_obs
    vi = obs_idx(j);
    table5a(j, 1) = vd(vi, shock_idx(1)) + vd(vi, shock_idx(2));  % ea + eatil
    table5a(j, 2) = vd(vi, shock_idx(3));                          % eg
    table5a(j, 3) = vd(vi, shock_idx(6));                          % el
    table5a(j, 4) = vd(vi, shock_idx(7));                          % eptil
    table5a(j, 5) = vd(vi, shock_idx(4));                          % es
    table5a(j, 6) = vd(vi, shock_idx(5));                          % em
end

%% ========================================================================
%% PANEL (b): 1950-2015 (if available)
%% ========================================================================

results_file_b = fullfile('DTest_1950_fevd', 'Output', 'DTest_1950_fevd_results.mat');
has_panel_b = exist(results_file_b, 'file');

if has_panel_b
    fprintf('Loading Panel (b) results...\n');
    load(results_file_b);

    % Re-extract names (same model structure)
    shock_names_b = cellstr(M_.exo_names);
    var_list_b = cellstr(oo_.var_list);

    obs_idx_b = zeros(n_obs, 1);
    for j = 1:n_obs
        obs_idx_b(j) = find(strcmp(var_list_b, obs_vars{j}));
    end

    shock_idx_b = zeros(length(shock_map), 1);
    for j = 1:length(shock_map)
        shock_idx_b(j) = find(strcmp(shock_names_b, shock_map{j}));
    end

    vd_b = oo_.variance_decomposition;

    table5b = zeros(n_obs, 6);
    for j = 1:n_obs
        vi = obs_idx_b(j);
        table5b(j, 1) = vd_b(vi, shock_idx_b(1)) + vd_b(vi, shock_idx_b(2));
        table5b(j, 2) = vd_b(vi, shock_idx_b(3));
        table5b(j, 3) = vd_b(vi, shock_idx_b(6));
        table5b(j, 4) = vd_b(vi, shock_idx_b(7));
        table5b(j, 5) = vd_b(vi, shock_idx_b(4));
        table5b(j, 6) = vd_b(vi, shock_idx_b(5));
    end
else
    fprintf('Panel (b) results not found. Showing Panel (a) only.\n');
    fprintf('To generate Panel (b), run:\n');
    fprintf('  dynare DTest_1950        %% ~6-10 hours\n');
    fprintf('  dynare DTest_1950_fevd   %% ~1 minute\n\n');
end

%% ========================================================================
%% PAPER TARGET VALUES
%% ========================================================================

% Panel (a): 1900-2015
paper_a = [
    51.15, 20.55,  1.12, 21.67,  0.19,  5.33;   % Output growth
    35.32, 10.87,  3.24, 24.02,  1.51, 25.05;   % Consumption growth
    11.68,  2.15, 23.80, 34.11,  1.90, 26.35;   % Investment growth
     1.19,  2.53, 64.71, 16.33,  2.08, 13.16    % Trade balance (corrected pref.)
];

% Panel (b): 1950-2015
paper_b = [
    39.14, 20.57,  0.69, 37.97,  0.08,  1.54;   % Output growth
    28.47, 11.72,  2.01, 42.28,  1.14, 14.39;   % Consumption growth
     9.48,  2.57, 15.35, 61.11,  0.50, 10.99;   % Investment growth
     1.28,  3.03, 52.83, 31.56,  0.42, 10.87    % Trade balance
];

%% ========================================================================
%% DISPLAY RESULTS
%% ========================================================================

col_labels = {'Stat.tech', 'Nonstat.tech', 'Int.rate', 'Comm.price', 'Spending', 'Pref.'};

% --- Panel (a) ---
fprintf('\n');
fprintf('================================================================================\n');
fprintf('  TABLE 5: Variance Decomposition\n');
fprintf('  Drechsel & Tenreyro (2018)\n');
fprintf('================================================================================\n');
fprintf('\n  Panel (a): 1900-2015\n');
fprintf('  Parameters at posterior mean (Table 8 replication, 1M draws)\n\n');

fprintf('%-22s', 'Variable');
for c = 1:6
    fprintf('%12s', col_labels{c});
end
fprintf('%10s\n', 'Sum');
fprintf('%s\n', repmat('-', 1, 100));

for j = 1:n_obs
    fprintf('%-22s', obs_labels{j});
    for c = 1:6
        fprintf('%12.2f', table5a(j, c));
    end
    fprintf('%10.2f\n', sum(table5a(j,:)));
end

fprintf('\n  Paper values:\n');
fprintf('%-22s', '');
for c = 1:6
    fprintf('%12s', col_labels{c});
end
fprintf('\n');
for j = 1:n_obs
    fprintf('%-22s', obs_labels{j});
    for c = 1:6
        fprintf('%12.2f', paper_a(j, c));
    end
    fprintf('\n');
end

fprintf('\n  Differences (ours - paper):\n');
for j = 1:n_obs
    fprintf('%-22s', obs_labels{j});
    for c = 1:6
        fprintf('%12.2f', table5a(j, c) - paper_a(j, c));
    end
    fprintf('\n');
end

% --- Panel (b) ---
if has_panel_b
    fprintf('\n--------------------------------------------------------------------------------\n');
    fprintf('\n  Panel (b): 1950-2015\n');
    fprintf('  Parameters at posterior mean (subsample estimation)\n\n');

    fprintf('%-22s', 'Variable');
    for c = 1:6
        fprintf('%12s', col_labels{c});
    end
    fprintf('%10s\n', 'Sum');
    fprintf('%s\n', repmat('-', 1, 100));

    for j = 1:n_obs
        fprintf('%-22s', obs_labels{j});
        for c = 1:6
            fprintf('%12.2f', table5b(j, c));
        end
        fprintf('%10.2f\n', sum(table5b(j,:)));
    end

    fprintf('\n  Paper values:\n');
    fprintf('%-22s', '');
    for c = 1:6
        fprintf('%12s', col_labels{c});
    end
    fprintf('\n');
    for j = 1:n_obs
        fprintf('%-22s', obs_labels{j});
        for c = 1:6
            fprintf('%12.2f', paper_b(j, c));
        end
        fprintf('\n');
    end

    fprintf('\n  Differences (ours - paper):\n');
    for j = 1:n_obs
        fprintf('%-22s', obs_labels{j});
        for c = 1:6
            fprintf('%12.2f', table5b(j, c) - paper_b(j, c));
        end
        fprintf('\n');
    end
end

%% ========================================================================
%% SAVE TO CSV
%% ========================================================================

csv_file = 'Table5_variance_decomposition.csv';
fid = fopen(csv_file, 'w');

% Panel (a)
fprintf(fid, 'TABLE 5: Variance Decomposition - Drechsel & Tenreyro (2018)\n\n');
fprintf(fid, 'Panel (a): 1900-2015 (parameters at posterior mean)\n');
fprintf(fid, 'Variable,Stat. technology,Nonstat. technology,Interest rate,Commodity price,Spending,Preference,Sum\n');
for j = 1:n_obs
    fprintf(fid, '%s', obs_labels{j});
    for c = 1:6
        fprintf(fid, ',%.2f', table5a(j, c));
    end
    fprintf(fid, ',%.2f\n', sum(table5a(j,:)));
end

fprintf(fid, '\nPaper values (Panel a)\n');
fprintf(fid, 'Variable,Stat. technology,Nonstat. technology,Interest rate,Commodity price,Spending,Preference\n');
for j = 1:n_obs
    fprintf(fid, '%s', obs_labels{j});
    for c = 1:6
        fprintf(fid, ',%.2f', paper_a(j, c));
    end
    fprintf(fid, '\n');
end

% Panel (b) if available
if has_panel_b
    fprintf(fid, '\nPanel (b): 1950-2015 (parameters at posterior mean)\n');
    fprintf(fid, 'Variable,Stat. technology,Nonstat. technology,Interest rate,Commodity price,Spending,Preference,Sum\n');
    for j = 1:n_obs
        fprintf(fid, '%s', obs_labels{j});
        for c = 1:6
            fprintf(fid, ',%.2f', table5b(j, c));
        end
        fprintf(fid, ',%.2f\n', sum(table5b(j,:)));
    end

    fprintf(fid, '\nPaper values (Panel b)\n');
    fprintf(fid, 'Variable,Stat. technology,Nonstat. technology,Interest rate,Commodity price,Spending,Preference\n');
    for j = 1:n_obs
        fprintf(fid, '%s', obs_labels{j});
        for c = 1:6
            fprintf(fid, ',%.2f', paper_b(j, c));
        end
        fprintf(fid, '\n');
    end
end

fclose(fid);
fprintf('\nResults saved to: %s\n', csv_file);

%% ========================================================================
%% SUMMARY
%% ========================================================================

fprintf('\n================================================================================\n');
fprintf('  REPLICATION QUALITY SUMMARY\n');
fprintf('================================================================================\n');

fprintf('\n  Panel (a): 1900-2015\n');
max_diff_a = max(abs(table5a(:) - paper_a(:)));
mean_diff_a = mean(abs(table5a(:) - paper_a(:)));
fprintf('    Max absolute difference:  %.2f pp\n', max_diff_a);
fprintf('    Mean absolute difference: %.2f pp\n', mean_diff_a);

if has_panel_b
    fprintf('\n  Panel (b): 1950-2015\n');
    max_diff_b = max(abs(table5b(:) - paper_b(:)));
    mean_diff_b = mean(abs(table5b(:) - paper_b(:)));
    fprintf('    Max absolute difference:  %.2f pp\n', max_diff_b);
    fprintf('    Mean absolute difference: %.2f pp\n', mean_diff_b);
end

fprintf('\n  Note: Differences expected due to using OUR posterior means vs paper values.\n');
fprintf('  Paper uses THEIR posterior mode; we use our posterior mean from MCMC.\n');
fprintf('================================================================================\n');
