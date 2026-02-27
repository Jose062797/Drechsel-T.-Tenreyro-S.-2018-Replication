%% Generate Table 3: Parameter Values
%
% This script creates Table 3 from Drechsel & Tenreyro (2018), which reports
% all calibrated parameter values used in the baseline DSGE model (DT.mod).
%
% Output: Table3_parameters.csv (formatted for publication)

clear; close all;

fprintf('\n=== GENERATING TABLE 3: PARAMETER VALUES ===\n\n');

%% Define parameters organized by category (following paper's Table 3 structure)

% Technology parameters
tech_params = {
    'alphk',     0.32,      'Capital share (final goods)'
    'alphm',     0.05,      'Intermediate input share (final goods)'
    'alphktil',  0.32,      'Capital share (commodities)'
    'del',       0.1255,    'Depreciation rate'
    'phi',       6,         'Capital adjustment cost parameter'
};

% Preference parameters
pref_params = {
    'betta',     0.9224,    'Discount factor'
    'gam',       2,         'Risk aversion coefficient'
    'theta',     1.6,       'Disutility of labor (final goods)'
    'thetatil',  1.6,       'Disutility of labor (commodities)'
    'om',        1.6,       'Inverse Frisch elasticity (final goods)'
    'omtil',     1.6,       'Inverse Frisch elasticity (commodities)'
};

% Interest rate parameters
rate_params = {
    'xi',        0.199,     'Commodity price effect on interest rate'
    'psi',       2.8,       'Debt effect on interest rate'
};

% Steady state targets
ss_targets = {
    'gbar',      1.0117204, 'Average growth rate'
    'nxtil_share', 0.086,   'Commodity net exports / GDP'
    's_share',   0.0938,    'Government spending / final output'
    'tb_share',  -0.00041,  'Trade balance / GDP'
};

% Persistence parameters (AR coefficients)
persist_params = {
    'rhoa',      0.9,       'Persistence (final goods productivity)'
    'rhoatil',   0.9,       'Persistence (commodity productivity)'
    'rhog',      0.9,       'Persistence (growth rate)'
    'rhos',      0.9,       'Persistence (government spending)'
    'rhomu',     0.9,       'Persistence (interest rate premium)'
    'rhonu',     0.9,       'Persistence (discount factor)'
    'rhoptil1',  0.95,      'Persistence (commodity price, AR1)'
    'rhoptil2',  -0.13,     'Persistence (commodity price, AR2)'
};

% Volatility parameters (shock standard deviations)
vol_params = {
    'siga',      0.1,       'Std dev (final goods productivity shock)'
    'sigatil',   0.1,       'Std dev (commodity productivity shock)'
    'sigg',      0.1,       'Std dev (growth rate shock)'
    'sigs',      0.1,       'Std dev (government spending shock)'
    'sigmu',     0.1,       'Std dev (interest rate premium shock)'
    'signu',     0.1,       'Std dev (discount factor shock)'
    'sigptil',   0.1064,    'Std dev (commodity price shock)'
};

%% Combine all parameters
all_params = [
    tech_params;
    {'', nan, ''};  % Blank row separator
    pref_params;
    {'', nan, ''};
    rate_params;
    {'', nan, ''};
    ss_targets;
    {'', nan, ''};
    persist_params;
    {'', nan, ''};
    vol_params
];

%% Create table
param_table = cell2table(all_params, ...
    'VariableNames', {'Parameter', 'Value', 'Description'});

%% Display to console
fprintf('TABLE 3: PARAMETER VALUES (BASELINE CALIBRATION)\n');
fprintf('================================================\n\n');

fprintf('--- TECHNOLOGY PARAMETERS ---\n');
for i = 1:size(tech_params, 1)
    fprintf('%-12s = %8.4f  %s\n', tech_params{i,1}, tech_params{i,2}, tech_params{i,3});
end

fprintf('\n--- PREFERENCE PARAMETERS ---\n');
for i = 1:size(pref_params, 1)
    fprintf('%-12s = %8.4f  %s\n', pref_params{i,1}, pref_params{i,2}, pref_params{i,3});
end

fprintf('\n--- INTEREST RATE PARAMETERS ---\n');
for i = 1:size(rate_params, 1)
    fprintf('%-12s = %8.4f  %s\n', rate_params{i,1}, rate_params{i,2}, rate_params{i,3});
end

fprintf('\n--- STEADY STATE TARGETS ---\n');
for i = 1:size(ss_targets, 1)
    fprintf('%-12s = %9.6f  %s\n', ss_targets{i,1}, ss_targets{i,2}, ss_targets{i,3});
end

fprintf('\n--- PERSISTENCE PARAMETERS (AR COEFFICIENTS) ---\n');
for i = 1:size(persist_params, 1)
    fprintf('%-12s = %7.4f  %s\n', persist_params{i,1}, persist_params{i,2}, persist_params{i,3});
end

fprintf('\n--- VOLATILITY PARAMETERS (SHOCK STD DEVIATIONS) ---\n');
for i = 1:size(vol_params, 1)
    fprintf('%-12s = %7.4f  %s\n', vol_params{i,1}, vol_params{i,2}, vol_params{i,3});
end

%% Save to CSV
writetable(param_table, 'Table3_parameters.csv');
fprintf('\n✓ Table saved as: Table3_parameters.csv\n');

%% Notes
fprintf('\n=== NOTES ===\n');
fprintf('1. Technology parameters: Standard values from literature\n');
fprintf('2. Preference parameters: Calibrated to match average labor supply ~1/3\n');
fprintf('3. Interest rate parameters:\n');
fprintf('   - xi (0.199): From Table 2 regression (commodity price → spread)\n');
fprintf('   - psi (2.8): Standard emerging market value\n');
fprintf('4. Steady state targets: From Argentine data (1900-2015)\n');
fprintf('5. Persistence parameters: Most set to 0.9 (standard)\n');
fprintf('   - Commodity price AR(2): Estimated from SVAR (Section 2)\n');
fprintf('6. Volatility parameters: Most set to 0.1 (standard)\n');
fprintf('   - Commodity price volatility: Calibrated from data\n');
fprintf('\n');
