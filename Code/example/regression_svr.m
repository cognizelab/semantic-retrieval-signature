%% SVR regression demo for the semantic distance signature repository

%% load data
clc;
scriptFile = mfilename('fullpath');
candidateDataFiles = {};
if ~isempty(scriptFile)
    candidateDataFiles{end+1} = fullfile(fileparts(scriptFile), 'data_demo.mat');
end
candidateDataFiles{end+1} = fullfile(pwd, 'example', 'data_demo.mat');
candidateDataFiles{end+1} = fullfile(pwd, 'data_demo.mat');

dataFile = '';
for ii = 1:numel(candidateDataFiles)
    if isfile(candidateDataFiles{ii})
        dataFile = candidateDataFiles{ii};
        break
    end
end
if isempty(dataFile)
    error('Demo data file not found. Expected Code\\example\\data_demo.mat. Checked: %s', strjoin(candidateDataFiles, '; '));
end

exampleDir = fileparts(dataFile);
codeRoot = fileparts(exampleDir);
if ~isfolder(fullfile(codeRoot, 'mvpa')) && isfolder(fullfile(pwd, 'mvpa'))
    codeRoot = pwd;
end
if ~isfolder(fullfile(codeRoot, 'mvpa'))
    error('MVPA folder not found. Set the MATLAB current folder to semantic-distance-signature\\Code or run the script from Code\\example.');
end
addpath(genpath(fullfile(codeRoot, 'mvpa')));

demoData = load(dataFile);
requiredVars = {'X', 'Y', 'subj'};
missingVars = requiredVars(~isfield(demoData, requiredVars));
if ~isempty(missingVars)
    error('Demo data file is missing required variable(s): %s', strjoin(missingVars, ', '));
end

X = demoData.X;
Y = demoData.Y;
subj = demoData.subj;
if size(X, 1) ~= numel(Y) || size(X, 1) ~= numel(subj)
    error('Imported demo data dimensions do not match: rows(X) must equal numel(Y) and numel(subj).');
end
Y = Y(:);
subj = subj(:);

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
% reported. The demo default is smaller for a quick installation check.
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
