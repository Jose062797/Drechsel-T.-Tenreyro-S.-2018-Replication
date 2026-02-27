function [ys,params,check] = DT_steadystate(ys,exo,M_,options_) 

% read out parameters to access them with their name
NumberOfParameters = M_.param_nbr;
for ii = 1:NumberOfParameters
  paramname = char(deblank(M_.param_names(ii,:)));
  eval([ paramname ' = M_.params(' int2str(ii) ');']);
end
% initialize indicator
check = 0;


%% Enter model equations here

% First calibrate ptilbar to match ratop of commodity NX to GDP

options=optimset('display','off'); % set options for numerical solver
p_0=0.5249; %starting value
[ptilbar,~,exitflag]=fsolve(@(x)calibrate_ptilbar(x,gbar,gam,betta,del,alphktil,alphk,alphm,atilbar,abar,theta,thetatil,om,omtil,nxtil_share),p_0,options); 
if exitflag<1
    check=1;
end

% Block 0: The stuff that is clear
r=rstar;
lna=log(abar);
lnatil=log(atilbar);
lng=log(gbar);
lnmu=log(mubar);
lnnu=log(nubar);
lnptil=log(ptilbar);

% Block 1: compute k2 and N2 analytically
knratio2 = gbar * ((gbar^gam/betta - 1 + del)/(alphktil*ptilbar*atilbar))^(1/(alphktil-1));
N2 = (atilbar/thetatil*ptilbar*gbar^(1-alphktil)*(1-alphktil)*(knratio2)^alphktil)^(1/(omtil-1));
k2 = knratio2*N2;

% Block 2: k1, N1, mtil
% Step 1: Compute N1 numerically
syms NN
N1 = solve(ptilbar == abar*alphm*gbar^(1-alphk-alphm)*...
            (alphk/(1-alphk-alphm)*1/(gbar^gam/betta - 1 + del)*theta*NN^om)^alphk*...
            (1/ptilbar*alphm/(1-alphk-alphm)*theta*NN^om)^(alphm-1)*NN^(1-alphk-alphm),NN);
N1=double(N1);
        
% Step 2: Caluclate k1 and mtil analytically
mtil = 1/ptilbar * alphm / (1-alphk-alphm) * theta*N1^om;
k1 = ptilbar * alphk/alphm / (gbar^gam/betta - 1 +del) * mtil;

% Block 3: The rest
% Calculate outputs
y = abar * k1^alphk * mtil^alphm * (gbar*N1)^(1-alphk-alphm);
ytil = atilbar * k2^alphktil * (gbar*N2)^(1-alphktil);
gdp = y+ptilbar*ytil-ptilbar*mtil;
gdp2 = y+ptilbar*ytil-ptilbar*mtil;

% Now assign the parameter value for sbar to match spendig share of output
sbar = s_share*y;
lns=log(sbar);

% And assign the parameter value for dbar
dbar = (1+r)/(1+r-gbar) * tb_share * gdp;
d = dbar;

% c from budget constraint
c = y + ptilbar * ytil - (gbar-1+del)*(k1+k2) - ptilbar*mtil - sbar - d*((1+r-gbar)/(1+r));

% lambda from FOC
lam = (c - theta/om*N1^om - theta/omtil*N2^omtil)^(-gam);

% Additional variables
i1=(gbar-1+del)*k1;
i2=(gbar-1+del)*k2;
k=k1+k2;
N=N1+N2;
i=i1+i2;

tb = y - c - i - sbar;
tbtil = ptilbar*(ytil-mtil);
tbagg = tb+tbtil;
tbaggout = (tb+tbtil) / gdp;
debtout = d / gdp;

y_growth_obs = lng; 
c_growth_obs = lng; 
i_growth_obs = lng; 
tby_obs = tbaggout; 
ptil_dev_obs = lnptil - log(ptilbar);
tbout = tb / gdp;
tbtilout = tbtil / gdp;

lngdp = log(gdp);
lngdp2 = log(gdp2);
lnc = log(c);
lni = log(i);
lngdpfinal = log(y);
lngdptil = log(exp(lnptil)*ytil-exp(lnptil)*mtil);

% Value added by sector (for Figure 5 decomposition)
va_comm = exp(lnptil) * ytil;                    % Commodities: gross value of production
va_final = y - exp(lnptil) * mtil;               % Final goods: value added (net of intermediate input costs)
lnva_comm = log(va_comm);
lnva_final = log(va_final);

w1 = exp(lna) * exp(lng)^(1-alphk-alphm) * (1-alphk-alphm) * k1^alphk * mtil^alphm * N1^(-alphk-alphm);
w2 = exp(lnatil) * exp(lnptil) * exp(lng)^(1-alphktil) * (1-alphktil) * k2^alphktil * N2^(-alphktil);
rk1 = exp(lna) * alphk * exp(lng)^(1-alphk-alphm) * k1^(alphk-1) * mtil^(alphm) * N1^(1-alphk-alphm);
rk2 = rk1;

%% ALTERNATVE: Numerical values (faster for estimation)
% May need to be changed when I change calibration of parameters



%% end own model equations

params = M_.params; %initialize output
for iter = 1:length(M_.params) %update parameters set in the file
  eval([ 'params(' num2str(iter) ') = ' char(M_.param_names(iter,:)) ';' ])
end

NumberOfEndogenousVariables = M_.orig_endo_nbr; %auxiliary variables are set automatically
for ii = 1:NumberOfEndogenousVariables
  varname = char(deblank(M_.endo_names(ii,:)));
  eval(['ys(' int2str(ii) ') = ' varname ';']);
end

end



function resid=calibrate_ptilbar(ptilbar,gbar,gam,betta,del,alphktil,alphk,alphm,atilbar,abar,theta,thetatil,om,omtil,nxtil_share)

knratio2 = gbar * ((gbar^gam/betta - 1 + del)/(alphktil*ptilbar*atilbar))^(1/(alphktil-1));
N2 = (atilbar/thetatil*ptilbar*gbar^(1-alphktil)*(1-alphktil)*(knratio2)^alphktil)^(1/(omtil-1));
k2 = knratio2*N2;

% Block 2: k1, N1, mtil
% Step 1: Compute N1 numerically
syms NN
N1 = solve(ptilbar == abar*alphm*gbar^(1-alphk-alphm)*...
            (alphk/(1-alphk-alphm)*1/(gbar^gam/betta - 1 + del)*theta*NN^om)^alphk*...
            (1/ptilbar*alphm/(1-alphk-alphm)*theta*NN^om)^(alphm-1)*NN^(1-alphk-alphm),NN);
clear NN
N1=double(N1);
      
% Step 2: Caluclate k1 and mtil analytically
mtil = 1/ptilbar * alphm / (1-alphk-alphm) * theta*N1^om;
k1 = ptilbar * alphk/alphm / (gbar^gam/betta - 1 +del) * mtil;

% Block 3: The rest
% Calculate outputs
y = abar * k1^alphk * mtil^alphm * (gbar*N1)^(1-alphk-alphm);
ytil = atilbar * k2^alphktil * (gbar*N2)^(1-alphktil);
gdp = y+ptilbar*ytil-ptilbar*mtil;

% Calculate commodity NX
tbtil = ptilbar*(ytil-mtil);

% Fit to target
resid = nxtil_share - (tbtil/gdp);

end
