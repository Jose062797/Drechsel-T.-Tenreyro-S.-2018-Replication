%% LABELING BLOCK
var c, N1, N2, N, k1, k2, k, i1, i2, i, mtil, y, ytil, d,               % endogenous variables (quantities)
    w1, w2, rk1, rk2, r, lam,                                           % endogenous variables (prices)
    lna, lnatil, lng, lns, lnmu, lnnu, lnptil,                          % exogenous variables
    tb, tbtil, tbagg, gdp, gdp2, tbaggout, debtout,                     % additional calculations
    tbout, tbtilout, lngdp, lngdp2, lnc, lni, lngdpfinal, lngdptil,
    va_final, va_comm, lnva_final, lnva_comm,                           % value-added measures for decomposition
    y_growth_obs, c_growth_obs, i_growth_obs, tby_obs, ptil_dev_obs;    % observables in estimation

varexo ea, eatil, eg, es, emu, enu, eptil;

%% PARAMETER BLOCK
parameters  alphk, alphm, alphktil, del, phi,                   % technology-related
            betta, theta, thetatil, om, omtil, gam,             % preference-related
            psi, xi,                                            % rate-related
            dbar, rstar, s_share, tb_share, nxtil_share,        % steady state
            abar, rhoa, siga,                                   % exogenous processes
            atilbar, rhoatil, sigatil,
            gbar, rhog, sigg,
            sbar, rhos, sigs,
            mubar, rhomu, sigmu,
            nubar, rhonu, signu,
            ptilbar, rhoptil1, rhoptil2, sigptil;

% Technology parameters
alphk = 0.32;
alphm = 0.05;
alphktil = 0.32;
del = 0.1255;
phi = 6;

% Preference parameters
betta = 0.9224;
theta = 1.6;            % this give total N approx = 1/3
thetatil = 1.6;
om = 1.6;
omtil = 1.6;
gam = 2;

% Interest rate parameters - BASELINE VALUES (both channels active structurally)
psi = 2.8;   % Baseline: debt-interest rate elasticity
xi = 0.199;  % Baseline: commodity-interest rate sensitivity (but won't matter since no price shock)

% Calibration targets
nxtil_share=0.086;     % Ratio of net exports of commodities relative to GDP
s_share = 0.0938;      % Ratio of govt spending to final output
tb_share = -0.00041;   % Ratio of trade balance to total GDP
gbar = 1.0117204;      % Average growth rate of output

rstar = 1/betta*gbar^gam - 1;

% Steady state values
abar = 1;
atilbar = 1;
mubar = 1;
nubar = 1;

% Persistence parameters
rhoa = 0.9;
rhoatil = 0.9;
rhog = 0.9;
rhos = 0.9;
rhomu = 0.9;     % Per Footnote 25: persistence of interest rate shock
rhonu = 0.9;
rhoptil1 = 0.95; % calibrated based on data (VAR)
rhoptil2 = -0.13; % calibrated based on data (VAR)

% Volatility parameters
siga = 0.1;
sigatil = 0.1;
sigg = 0.1;
sigs = 0.1;
sigmu = 0.094;   % Calibrated to match Figure 4 baseline GDP peak of 1.96%: 0.082 * (1.96/1.71) ≈ 0.094
signu = 0.1;
sigptil = 0;     % TURN OFF commodity price shock for Figure 6

%% MODEL BLOCK
model;

% Model equations (normalised model in levels)
(c - theta/om*N1^om - thetatil/omtil*N2^omtil)^(-gam) = lam;
(c - theta/om*N1^om - thetatil/omtil*N2^omtil)^(-gam)*theta*N1^(om-1) = lam * w1;
(c - theta/om*N1^om - thetatil/omtil*N2^omtil)^(-gam)*theta*N2^(omtil-1) = lam * w2;

w1 = exp(lna) * exp(lng)^(1-alphk-alphm) * (1-alphk-alphm) * k1(-1)^alphk * mtil^alphm * N1^(-alphk-alphm);
w2 = exp(lnatil) * exp(lnptil) * exp(lng)^(1-alphktil) * (1-alphktil) * k2(-1)^alphktil * N2^(-alphktil);

i = i1+i2;
k = k1+k2;
N = N1+N2;
i1 = k1*exp(lng) - (1-del)*k1(-1);
i2 = k2*exp(lng) - (1-del)*k2(-1);

lam = betta*(1+r)*exp(lng)^(-gam)*exp(lnnu(+1)-lnnu)*lam(+1);

r=rstar + psi*(exp(d-dbar) - 1) - xi*ptil_dev_obs + (exp(exp(lnmu) - 1) - 1);

%d/(1+r)*exp(lng) = d(-1) - y - exp(lnptil)*ytil + c + i + exp(lns) + exp(lnptil)*mtil + phi/2*(k/k(-1)*exp(lng) - gbar)^2 * k(-1);
d/(1+r)*exp(lng) = d(-1) - w1*N1 - w2*N2 - rk1*k1 - rk2*k2 + c + i + exp(lns) + phi/2*(k/k(-1)*exp(lng) - gbar)^2 * k(-1);

lam * (1+phi*(k/k(-1)*exp(lng)-gbar))  = betta * exp(lng)^-gam * exp(lnnu(+1)-lnnu)* lam(+1) *(rk1(+1) + 1 - del
                            + phi*(k(+1)/k*exp(lng(+1))-gbar)*(k(+1)/k)*exp(lng(+1))
                            - phi/2*(k(+1)/k*exp(lng(+1))-gbar)^2);

rk1 = exp(lna) * alphk * exp(lng)^(1-alphk-alphm) * k1(-1)^(alphk-1) * mtil^(alphm) * N1^(1-alphk-alphm);

lam * (1+phi*(k/k(-1)*exp(lng)-gbar))  = betta * exp(lng)^-gam * exp(lnnu(+1)-lnnu)* lam(+1) *(rk2(+1) + 1 - del
                            + phi*(k(+1)/k*exp(lng(+1))-gbar)*(k(+1)/k)*exp(lng(+1))
                            - phi/2*(k(+1)/k*exp(lng(+1))-gbar)^2);

rk2 = exp(lnptil) * exp(lnatil) * alphktil * exp(lng)^(1-alphktil) * k2(-1)^(alphktil-1) * N2^(1-alphktil);

exp(lnptil) = exp(lna) * alphm * exp(lng)^(1-alphk-alphm) * k1(-1)^alphk * mtil^(alphm-1) * N1^(1-alphk-alphm);

y = exp(lna) * k1(-1)^alphk * mtil^alphm * (exp(lng)*N1)^(1-alphk-alphm);
ytil = exp(lnatil) * k2(-1)^alphktil * (exp(lng)*N2)^(1-alphktil);

% Additional calculations
tb = y - c - i - exp(lns) - phi/2*(k/k(-1)*exp(lng) - gbar)^2 * k(-1);
tbtil = exp(lnptil)*(ytil-mtil);
tbagg = tb+tbtil;
gdp = y+exp(lnptil)*ytil-exp(lnptil)*mtil;
gdp2 = y+exp(steady_state(lnptil))*ytil-exp(steady_state(lnptil))*mtil;
tbaggout = (tb+tbtil) / gdp;
tbout = tb / gdp;
tbtilout = tbtil / gdp;
debtout = d(-1) / gdp;
lngdp = log(gdp);
lngdp2 = log(gdp2);
lnc = log(c);
lni = log(i);
lngdpfinal = log(y);
lngdptil = log(exp(lnptil)*ytil-exp(lnptil)*mtil);

% Value-added measures for decomposition (Figure 6)
va_comm = exp(lnptil) * ytil;          % Commodities sector value added (gross value)
va_final = y - exp(lnptil) * mtil;     % Final goods sector value added (net of intermediate costs)
lnva_comm = log(va_comm);
lnva_final = log(va_final);

% Exogenous processes
lna = (1-rhoa)*log(abar) + rhoa*lna(-1) + ea;
lnatil = (1-rhoatil)*log(atilbar) + rhoatil*lnatil(-1) + eatil;
lng = (1-rhog)*log(gbar) + rhog*lng(-1) + eg;
lns = (1-rhos)*log(sbar) + rhos*lns(-1) - es;
lnmu = (1-rhomu)*log(mubar) + rhomu*lnmu(-1) - emu;
lnnu = (1-rhonu)*log(nubar) + rhonu*lnnu(-1) + enu;
lnptil = (1-rhoptil1-rhoptil2)*log(ptilbar) + rhoptil1*lnptil(-1) + rhoptil2*lnptil(-2) + eptil;

% Measurement equations
y_growth_obs = log(gdp) - log(gdp(-1)) + lng(-1);   % this is the total empirical growth rate
c_growth_obs = log(c) - log(c(-1)) + lng(-1);       % this is the total empirical growth rate
i_growth_obs = log(i) - log(i(-1)) + lng(-1);       % this is the total empirical growth rate
tby_obs = tbaggout;                                 % this is the empirical ratio
ptil_dev_obs = lnptil - log(ptilbar);               % this is the empirical log-deviation from trend

end;


// SEE STEADY STATE FILE !!!

steady;

check;


%% RANDOM SHOCKS BLOCK
shocks;
var ea; stderr siga;
var eatil; stderr sigatil;
var eg; stderr sigg;
var es; stderr sigs;
var emu; stderr sigmu;    % ACTIVE: Interest rate shock
var enu; stderr signu;
var eptil; stderr sigptil; % INACTIVE: sigptil = 0
end;

%% SOLVE THE MODEL

% IRF to interest rate shock (Figure 6)
% Note: This generates IRFs to a POSITIVE shock (rate increase),
% which we'll invert when plotting to show the boom effect (rate decrease)
stoch_simul(order=1,IRF=10,nograph) lngdp lngdp2 lnc lni tbaggout lnva_final lnva_comm tbout tbtilout;
