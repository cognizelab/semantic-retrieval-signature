%% Support Vector Regression (SVR)
% Train the SVR model for regression tasks.
% The regularization parameter (C) can be fine-tuned through 'param.C'.
%% Input
%       >>> param.C
%       >>> param.svr: input in struct format consistent with the built-in 'fitcsvm' in Matlab
%                      for more information:
%                      web('https://ww2.mathworks.cn/help/stats/fitcsvm.html')
%       >>> param.twochoice: the experimental conditions were found to occur in pairs (twochoice = 1)