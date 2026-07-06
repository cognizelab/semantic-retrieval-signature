%% T-PLS regression demo for the semantic distance signature repository

% Resolve paths so the script works from the repository root or this folder.
scriptDir = fileparts(mfilename('fullpath'));
if isempty(scriptDir)
    scriptDir = pwd;
end
repoRoot = fullfile(scriptDir, '..', '..');
addpath(genpath(fullfile(repoRoot, 'Code', 'mvpa')));

%% load data
clc; clearvars -except scriptDir repoRoot;
load(fullfile(scriptDir, 'data_demo.mat'));

x = X; % input features
y = Y; % target variable
c = []; % covariates

%% run MVPA
model = 'tpls'; % thresholded partial least squares
cv = []; % leave-one-subject-out cross-validation through param.groupCV

param.groupCV = subj; % subject ID for grouped cross-validation
param.compvec = 1:25; % number of components to test
param.threshvec = 0.05:0.05:1; % percentage of strongest features retained
param.icv = [5 3]; % 5-fold inner CV, repeated 3 times

[out, log] = mat_cv(x, y, c, model, cv, param);

% The manuscript analyses used N = 5000. The demo default is smaller so that
% reviewers can quickly verify installation and expected outputs.
demoBootstrapN = 100;
[out, bootweight, Haufeweight] = mat_bootstrap( ...
    x, y, c, log, out, 'N', demoBootstrapN, ...
    'opt_parameter', out.parameter_suggest, 'Haufe');

out = mat_report_correlation(out, log);

opt.bins = 3;
h = mat_plot_correlation(out, opt);
