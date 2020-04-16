%% load csv data
basicPath = pwd;
csvPath = fullfile(basicPath,'resource','dataset','temp_df_03.csv');
df = readtable(csvPath);

%% load actual_increase, fs_scale, day
actual_increase = df{:,{'actual_increase'}};
fs_scale = df{:,{'fs_scale'}};
day = 14:14+40;

%% perpare parameters
beta0=[1 1];
xdata=[fs_scale,day'];
ydata=actual_increase;
myfun = @(beta, t)(1./(beta(1).*t(:,2)+beta(2))).*((2*beta(2)./(1.+exp(t(:,1)))).^(t(:,2)./(beta(1).*t(:,2)+beta(2))));

%% fit
[ab_lsqcurvefit, res_lsqcurvefit, r_lsqcurvefit, exitflag,output] = lsqcurvefit(myfun, beta0, xdata,ydata);
% ab_lsqcurvefit: best value:  0.0139    4.1067£» 0.0350    4.8454
% res_lsqcurvefit: residual^2
% r_lsqcurvefit: residual

% [ab_nlinfit, r_nlinfit] = nlinfit(xdata, ydata, myfun, beta0); 
% ab_nlinfit: best value
% r_nlinfit: residual