function [ys,params,check] = DTest_steadystate(ys,exo,M_,options_) 

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

% options=optimset('display','off'); % set options for numerical solver
% p_0=0.5249; %starting value
% [ptilbar,~,exitflag]=fsolve(@(x)calibrate_ptilbar(x,gbar,gam,betta,del,alphktil,alphk,alphm,atilbar,abar,theta,thetatil,om,omtil,nxtil_share),p_0,options); 
% if exitflag<1
%     check=1;
% end
% 
% % Block 0: The stuff that is clear
% r=rstar;
% lna=log(abar);
% lnatil=log(atilbar);
% lng=log(gbar);
% lnmu=log(mubar);
% lnnu=log(nubar);
% lnptil=log(ptilbar);
% 
% % Block 1: compute k2 and N2 analytically
% knratio2 = gbar * ((gbar^gam/betta - 1 + del)/(alphktil*ptilbar*atilbar))^(1/(alphktil-1));
% N2 = (atilbar/thetatil*ptilbar*gbar^(1-alphktil)*(1-alphktil)*(knratio2)^alphktil)^(1/(omtil-1));
% k2 = knratio2*N2;
% 
% % Block 2: k1, N1, mtil
% % Step 1: Compute N1 numerically
% syms NN
% N1 = solve(ptilbar == abar*alphm*gbar^(1-alphk-alphm)*...
%             (alphk/(1-alphk-alphm)*1/(gbar^gam/betta - 1 + del)*theta*NN^om)^alphk*...
%             (1/ptilbar*alphm/(1-alphk-alphm)*theta*NN^om)^(alphm-1)*NN^(1-alphk-alphm),NN);
% N1=double(N1);
%         
% % Step 2: Caluclate k1 and mtil analytically
% mtil = 1/ptilbar * alphm / (1-alphk-alphm) * theta*N1^om;
% k1 = ptilbar * alphk/alphm / (gbar^gam/betta - 1 +del) * mtil;
% 
% % Block 3: The rest
% % Calculate outputs
% y = abar * k1^alphk * mtil^alphm * (gbar*N1)^(1-alphk-alphm);
% ytil = atilbar * k2^alphktil * (gbar*N2)^(1-alphktil);
% gdp = y+ptilbar*ytil-ptilbar*mtil;
% 
% % Now assign the parameter value for sbar to match spendig share of output
% sbar = s_share*y;
% lns=log(sbar);
% 
% % And assign the parameter value for dbar
% dbar = (1+r)/(1+r-gbar) * tb_share * gdp;
% d = dbar;
% 
% % c from budget constraint
% c = y + ptilbar * ytil - (gbar-1+del)*(k1+k2) - ptilbar*mtil - sbar - d*((1+r-gbar)/(1+r));
% 
% % lambda from FOC
% lam = (c - theta/om*N1^om - theta/omtil*N2^omtil)^(-gam);
% 
% % Additional variables
% i1=(gbar-1+del)*k1;
% i2=(gbar-1+del)*k2;
% k=k1+k2;
% N=N1+N2;
% i=i1+i2;
% 
% tb = y - c - i - sbar;
% tbtil = ptilbar*(ytil-mtil);
% tbagg = tb+tbtil;
% tbaggout = (tb+tbtil) / gdp;
% debtout = d / gdp;
% 
% y_growth_obs = lng; 
% c_growth_obs = lng; 
% i_growth_obs = lng; 
% tby_obs = tbaggout; 
% ptil_dev_obs = lnptil - log(ptilbar);
% tbout = tb / gdp;
% tbtilout = tbtil / gdp;
% 
% lngdp = log(gdp);
% lnc = log(c);
% lni = log(i);
% lngdpfinal = log(y);
% lngdptil = log(exp(lnptil)*ytil-exp(lnptil)*mtil);
% 
% w1 = exp(lna) * exp(lng)^(1-alphk-alphm) * (1-alphk-alphm) * k1^alphk * mtil^alphm * N1^(-alphk-alphm);
% w2 = exp(lnatil) * exp(lnptil) * exp(lng)^(1-alphktil) * (1-alphktil) * k2^alphktil * N2^(-alphktil);
% rk1 = exp(lna) * alphk * exp(lng)^(1-alphk-alphm) * k1^(alphk-1) * mtil^(alphm) * N1^(1-alphk-alphm);
% rk2 = rk1;

%% ALTERNATVE: Numerical values (faster for estimation)
% Needs to be changed when I change calibration of parameters that affect SS

% Assign steady state values for new shock processes
mbar = 1;
lbar = 1;

c=0.158500154666342;
N1=0.205116299496287;
N2=0.0641034129159146;
N=0.269219712412201;
k1=0.273974795935186;
k2=0.0394776976071633;
k=0.313452493542350;
i1=0.0375949310881446;
i2=0.00541714545673400;
i=0.0430120765448786;
mtil=0.0191991370998019;
y=0.201363017050567;
ytil=0.0553290112805671;
% d=-0.00102312202143094;
w1=0.618472062207586;
w2=0.307785867105779;
rk1=0.235190121179705;
rk2=0.235190121179705;
r=0.109690121179705;
lam=223.552583641474;
lna=0;
lnatil=0;
lng=0.0116522481066762;
% lns=-3.96923636787134;
sbar = s_share*y;
lns=log(sbar);
lnm=0;
lnl=0;
lnptil=-0.645488274778364;
tb=-0.0190370651599972;
tbtil=0.0189467381603607;
tbagg=-9.03269996365003e-05;
gdp=0.220309755210928;
tbaggout=-0.000410000000000090;
debtout=-0.00464401596947618;
tbout=-0.0864104503305850;
tbtilout=0.0860004503305849;
lngdp=-1.51272074467022;
lnc=-1.84199970985239;
lni=-3.14627435283862;
lngdpfinal=-1.60264594490138;
lngdptil=-3.96612349101041;
y_growth_obs=0.0116522481066762;
c_growth_obs=0.0116522481066762;
i_growth_obs=0.0116522481066762;
tby_obs=-0.000410000000000090;
ptil_dev_obs=0;
dbar = (1+r)/(1+r-gbar) * tb_share * gdp;
d = dbar;
ptilbar = exp(lnptil);

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
