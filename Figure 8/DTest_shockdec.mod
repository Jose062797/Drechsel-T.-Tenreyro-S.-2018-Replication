%% DTest_shockdec.mod — Generate shock decomposition for Figure 8
% This file loads the posterior mode from the existing DTest estimation
% and computes the historical shock decomposition using the Kalman smoother.
%
% Usage: dynare DTest_shockdec
% (Run from Figure 8/ directory)
%
% Output: oo_.shock_decomposition saved in DTest_shockdec/Output/DTest_shockdec_results.mat

%% LABELING BLOCK
var c, N1, N2, N, k1, k2, k, i1, i2, i, mtil, y, ytil, d,               % endogenous variables (quantities)
    w1, w2, rk1, rk2, r, lam,                                           % endogenous variables (prices)
    lna, lnatil, lng, lns, lnm, lnl, lnptil,                            % exogenous variables
    tb, tbtil, tbagg, gdp, tbaggout, debtout,                           % additional calculations
    tbout, tbtilout, lngdp, lnc, lni, lngdpfinal, lngdptil,
    y_growth_obs, c_growth_obs, i_growth_obs, tby_obs, ptil_dev_obs;    % observables in estimation

varexo ea, eatil, eg, es, em, el, eptil;

%% PARAMETER BLOCK
parameters  alphk, alphm, alphktil, del, phi,                   % technology-related
            betta, theta, thetatil, om, omtil, gam,             % preference-related
            psi, xi,                                            % rate-related
            dbar, rstar, s_share, tb_share, nxtil_share,        % steady state
            abar, rhoa, siga,                                   % exogenous processes
            atilbar, rhoatil, sigatil,
            gbar, rhog, sigg,
            sbar, rhos, sigs,
            mbar, rhom, sigm,
            lbar, rhol, sigl,
            ptilbar, rhoptil1, rhoptil2, sigptil;

alphk = 0.32;
alphm = 0.05;
alphktil = 0.32;
del = 0.1255;
phi = 6;

betta = 0.9224;
theta = 1.6;
thetatil = 1.6;
om = 1.6;
omtil = 1.6;
gam = 2;

psi = 2.8;
xi = 0.199;

nxtil_share=0.086;
s_share = 0.0938;
tb_share = -0.00041;

gbar = 1.0117204;
rstar = 1/betta*gbar^gam - 1;

abar = 1;
atilbar = 1;
mbar = 1;
lbar = 1;

rhoa = 0.9;
rhoatil = 0.9;
rhog = 0.9;
rhos = 0.9;
rhom = 0.9;
rhol = 0.9;
rhoptil1 = 0.95;
rhoptil2 = -0.13;

siga = 0;
sigatil = 0;
sigg = 0;
sigs = 0;
sigm = 0;
sigl = 0;
sigptil  = 0.1064;

%% MODEL BLOCK
model;

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

lam = betta*(1+r)*exp(lng)^(-gam)*exp(lnm(+1)-lnm)*lam(+1);

r=rstar + psi*(exp(d-dbar) - 1) - xi*ptil_dev_obs + (exp(lnl) - 1);

d/(1+r)*exp(lng) = d(-1) - w1*N1 - w2*N2 - rk1*k1 - rk2*k2 + c + i + exp(lns) + phi/2*(k/k(-1)*exp(lng) - gbar)^2 * k(-1);

lam * (1+phi*(k/k(-1)*exp(lng)-gbar))  = betta * exp(lng)^-gam * exp(lnm(+1)-lnm)* lam(+1) *(rk1(+1) + 1 - del
                            + phi*(k(+1)/k*exp(lng(+1))-gbar)*(k(+1)/k)*exp(lng(+1))
                            - phi/2*(k(+1)/k*exp(lng(+1))-gbar)^2);

rk1 = exp(lna) * alphk * exp(lng)^(1-alphk-alphm) * k1(-1)^(alphk-1) * mtil^(alphm) * N1^(1-alphk-alphm);

lam * (1+phi*(k/k(-1)*exp(lng)-gbar))  = betta * exp(lng)^-gam * exp(lnm(+1)-lnm)* lam(+1) *(rk2(+1) + 1 - del
                            + phi*(k(+1)/k*exp(lng(+1))-gbar)*(k(+1)/k)*exp(lng(+1))
                            - phi/2*(k(+1)/k*exp(lng(+1))-gbar)^2);

rk2 = exp(lnptil) * exp(lnatil) * alphktil * exp(lng)^(1-alphktil) * k2(-1)^(alphktil-1) * N2^(1-alphktil);

exp(lnptil) = exp(lna) * alphm * exp(lng)^(1-alphk-alphm) * k1(-1)^alphk * mtil^(alphm-1) * N1^(1-alphk-alphm);

y = exp(lna) * k1(-1)^alphk * mtil^alphm * (exp(lng)*N1)^(1-alphk-alphm);
ytil = exp(lnatil) * k2(-1)^alphktil * (exp(lng)*N2)^(1-alphktil);

tb = y - c - i - exp(lns) - phi/2*(k/k(-1)*exp(lng) - gbar)^2 * k(-1);
tbtil = exp(lnptil)*(ytil-mtil);
tbagg = tb+tbtil;
gdp = y+exp(lnptil)*ytil-exp(lnptil)*mtil;
tbaggout = (tb+tbtil) / gdp;
tbout = tb / gdp;
tbtilout = tbtil / gdp;
debtout = d(-1) / gdp;
lngdp = log(gdp);
lnc = log(c);
lni = log(i);
lngdpfinal = log(y);
lngdptil = log(exp(lnptil)*ytil-exp(lnptil)*mtil);

% Exogenous processes
lna = (1-rhoa)*log(abar) + rhoa*lna(-1) + ea;
lnatil = (1-rhoatil)*log(atilbar) + rhoatil*lnatil(-1) + eatil;
lng = (1-rhog)*log(gbar) + rhog*lng(-1) + eg;
lns = (1-rhos)*log(sbar) + rhos*lns(-1) - es;
lnm = (1-rhom)*log(mbar) + rhom*lnm(-1) + em;
lnl = (1-rhol)*log(lbar) + rhol*lnl(-1) - el;
lnptil = (1-rhoptil1+rhoptil2)*log(ptilbar) + rhoptil1*lnptil(-1) - rhoptil2*lnptil(-2) + eptil;

% Measurement equations
y_growth_obs = log(gdp) - log(gdp(-1)) + lng(-1);
c_growth_obs = log(c) - log(c(-1)) + lng(-1);
i_growth_obs = log(i) - log(i(-1)) + lng(-1);
tby_obs = tbaggout;
ptil_dev_obs = lnptil - log(ptilbar);

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
var em; stderr sigm;
var el; stderr sigl;
var eptil; stderr sigptil;
end;

estimated_params;
xi,0.2212,0,1,NORMAL_PDF,0.199,0.045;
psi,2.8,0,6,NORMAL_PDF,2.8,0.5;
rhoptil1,0.8,0.01,0.99,BETA_PDF,0.8,0.10;
rhoptil2,0.1278,0.01,0.99,BETA_PDF,0.15,0.10;
rhoa,0.5,0.01,0.99,BETA_PDF,0.5,0.20;
rhoatil,0.5,0.01,0.99,BETA_PDF,0.5,0.20;
rhog,0.5,0.01,0.99,BETA_PDF,0.5,0.20;
rhos,0.5,0.01,0.99,BETA_PDF,0.5,0.20;
rhom,0.5,0.01,0.99,BETA_PDF,0.5,0.20;
rhol,0.5,0.01,0.99,BETA_PDF,0.5,0.20;
stderr eptil,0.1765,0.001,0.5,INV_GAMMA_PDF,0.10,2;
stderr ea,0.1,0.001,0.5,INV_GAMMA_PDF,0.10,2;
stderr eatil,0.1,0.001,0.5,INV_GAMMA_PDF,0.10,2;
stderr eg,0.1,0.001,0.5,INV_GAMMA_PDF,0.10,2;
stderr es,0.1,0.001,0.5,INV_GAMMA_PDF,0.10,2;
stderr em,0.1,0.001,0.5,INV_GAMMA_PDF,0.10,2;
stderr el,0.1,0.001,0.5,INV_GAMMA_PDF,0.10,2;

end;

varobs y_growth_obs c_growth_obs i_growth_obs tby_obs;

%% ESTIMATION: Load existing posterior mode and compute shock decomposition
% mode_compute=0: Skip mode finding, load saved mode from DTest estimation
% mh_replic=0: No MCMC draws needed
% smoother: Compute Kalman smoother (smoothed variables and shocks)
estimation(datafile=DTDATA, mode_compute=0, mode_file='../Table 8/DTest/Output/DTest_mh_mode', mh_replic=0, smoother);

%% SHOCK DECOMPOSITION: Compute historical decomposition at the posterior mode
shock_decomposition y_growth_obs c_growth_obs i_growth_obs tby_obs ptil_dev_obs;
