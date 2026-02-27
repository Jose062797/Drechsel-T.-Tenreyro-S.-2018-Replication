% Replicate Figure 9: Impulse response functions to different shocks
% Generates one figure per shock (7 figures total), each with 4 panels:
%   GDP | Consumption | Investment | Trade balance
%
% Scaling (Appendix D): each shock re-scaled so its maximum positive lngdp
% response equals that of the commodity price shock (eptil).
% Exception: enu (preference shock, GHH) has purely negative GDP response —
% kept at scale=1 (natural sigma=0.1 size already matches paper magnitudes).
% Signs are preserved (no flipping) — shocks shown in natural direction.
%
% Shock order matches paper Fig. 9 (a)-(g):
%   ea, eatil, eg, eptil, emu, es, enu
%
% Output: Figure9a_ea.png ... Figure9g_enu.png
% Prerequisite: run  dynare DT_fig9  in this folder before this script.

clear; close all;

%% Load model results
% DT_fig9: identical to DT.mod (Figure 4) except rhonu=0.8 (vs 0.9)
% to enable hump-shape reversal in preference shock panel (g)
fprintf('Loading model results...\n');
load('DT_fig9/Output/DT_fig9_results.mat', 'oo_', 'M_');

%% Configuration
shocks      = {'ea',    'eatil',   'eg',    'eptil',   'emu',    'es',      'enu'};
shock_codes = {'a',     'b',       'c',     'd',       'e',      'f',       'g'};
shock_files = {'ea',    'eatil',   'eg',    'eptil',   'emu',    'es',      'enu'};

row_labels  = { ...
    '(a) Final goods sector productivity shock $\epsilon_t^a$', ...
    '(b) Commodity sector productivity shock $\epsilon_t^{\tilde{a}}$', ...
    '(c) Growth shock $\epsilon_t^g$', ...
    '(d) Commodity price shock $\epsilon_t^{\tilde{p}}$', ...
    '(e) Interest rate shock $\epsilon_t^{\mu}$', ...
    '(f) Spending shock $\epsilon_t^s$', ...
    '(g) Preference shock $\epsilon_t^{\nu}$'};

col_vars    = {'lngdp', 'lnc',         'lni',        'tby_obs'};
col_titles  = {'GDP',   'Consumption', 'Investment',  'Trade balance'};
col_ylabels = {'%',     '%',           '%',           '%'};

n_shocks = length(shocks);
irf_len  = 10;
t        = 1:irf_len;

%% Compute scaling factors
% Appendix D: re-scale each shock so its maximum GDP level response equals
% that of the commodity price shock (eptil).
%
% Anchor: max positive lngdp of eptil (10 periods)
[max_target, ~] = max(oo_.irfs.lngdp_eptil(1:irf_len));
fprintf('Anchor (eptil): max lngdp = %.4f%%\n\n', max_target * 100);

scale = zeros(1, n_shocks);
for s = 1:n_shocks
    irf_s = oo_.irfs.(['lngdp_', shocks{s}])(1:irf_len);
    peak_pos = max(irf_s);

    if peak_pos > 1e-6
        % Shock has positive GDP peak: scale by positive peak
        % (eg: ignore large negative tail at t=10 — paper scales by initial peak)
        max_s = peak_pos;
        scale(s) = max_target / max_s;
    else
        % Shock is purely negative (enu, preference shock with GHH):
        % GDP level response starts at zero (GHH) and stays negative.
        % With sigma=0.1 the natural size already matches the paper — scale=1.
        scale(s) = 1;
        max_s = max(abs(irf_s));
    end

    fprintf('  %-8s  scale = %8.4f  (lngdp peak = %+.4f%%)\n', ...
            shocks{s}, scale(s), max_s * 100);
end

%% Generate one figure per shock
for s = 1:n_shocks

    fig = figure('Position', [100, 100, 1100, 320], 'Color', 'w');

    % Manual subplot positions for square-ish panels: [left bottom width height]
    panel_w = 0.195;
    panel_h = 0.62;
    panel_b = 0.18;
    panel_gaps = [0.06, 0.295, 0.530, 0.765];

    for v = 1:length(col_vars)
        ax = axes('Position', [panel_gaps(v), panel_b, panel_w, panel_h]); %#ok<LAXES>

        raw  = oo_.irfs.([col_vars{v}, '_', shocks{s}])(1:irf_len);
        data = raw * scale(s) * 100;

        plot(t, data, 'b-', 'LineWidth', 2);
        hold on;
        plot(t, zeros(1, irf_len), 'k-', 'LineWidth', 0.5);

        title(col_titles{v}, 'FontSize', 9, 'FontWeight', 'bold');
        xlabel('Years', 'FontSize', 8);
        ylabel(col_ylabels{v}, 'FontSize', 8);
        xlim([1 irf_len]);
        set(ax, 'XTick', [2 4 6 8 10]);
        grid on; box on;
        set(ax, 'FontSize', 8);
    end

    % Shock label as sgtitle
    sgtitle(row_labels{s}, 'Interpreter', 'latex', ...
            'FontSize', 11, 'FontWeight', 'bold');

    % Save
    fname = sprintf('Figure9%s_%s.png', shock_codes{s}, shock_files{s});
    saveas(fig, fname);
    fprintf('  Saved: %s\n', fname);
end

fprintf('\nDone. 7 figures saved.\n');
