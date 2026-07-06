%% SVR regression demo for the semantic distance signature repository

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
model = 'svr'; % support vector regression
cv = []; % leave-one-subject-out cross-validation through param.groupCV

param.groupCV = subj; % subject ID for grouped cross-validation
param.po = 0; % do not perform parameter optimization
param.C = []; % use MATLAB default C parameter for SVR

[out, log] = mat_cv(x, y, c, model, cv, param);

% The manuscript analyses used N = 5000 where bootstrap/permutation tests were
% reported. The demo default is smaller for quick reviewer verification.
demoBootstrapN = 100;
[out, bootweight] = mat_bootstrap( ...
    x, y, c, log, out, 'N', demoBootstrapN, 'opt_parameter', 1);

% Permutation testing is optional and can be slow even for a demo dataset.
runPermutation = false;
if runPermutation
    demoPermutationN = 100;
    out = mat_permutation(x, y, c, log, out, 'N', demoPermutationN);
end

out = mat_report_correlation(out, log);

opt.bins = 3;
h = mat_plot_correlation(out, opt);
