%% set up toolbox  
cd('Code/example');
addpath(genpath('Code/mvpa'));  

%% load data
clc; clear;
load('data_demo.mat');

x = X; % input features
y = Y; % target variate 
c = []; % covariates 

%% run mvpa
model = 'svr'; % apply SVR algorithm

cv = [ ]; % leave-one-subject-out cross-validation

param.groupCV = subj; % identify subject ID
param.po = 0; % do not perform parameter optimization (use default parameter in SVR)
param.C = [ ]; % use default C parameter in SVR

[out,log] = mat_cv(x,y,c,model,cv,param); % perform main cross-validation

[out,bootweight] = mat_bootstrap(x,y,c,log,out,'N',5000,'opt_parameter',1); % perform bootstrap

out = mat_permutation(x,y,c,log,out,'N',5000); % perform permutation (optional, very time consuming)

out = mat_report_correlation(out,log); % report results

opt.bins = 3;
h = mat_plot_correlation(out,opt); % display results 