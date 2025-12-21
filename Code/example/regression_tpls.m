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
model = 'tpls'; % apply T-PLS algorithm

cv = [ ]; % leave-one-subject-out cross-validation

param.groupCV = subj; % identify subject ID
param.compvec = [1:25]; % identify number of components to be retained (default = [1:25])
param.threshvec = [0.05:0.05:1]; % identify what percentage of the most important features should be retained (default = [0.05:0.05:1])
param.icv = [5 3]; % set the number of inner cross-validation iterations for parameter optimization (5-fold cross-validation; executed 3 times)

[out,log] = mat_cv(x,y,c,model,cv,param); % perform main cross-validation

[out,bootweight] = mat_bootstrap(x,y,c,log,out,'N',5000,'opt_parameter',out.parameter_suggest,'Haufe'); % perform bootstrap and Haufe transformation

out = mat_report_correlation(out,log); % report results

opt.bins = 3;
h = mat_plot_correlation(out,opt); % display results 