function [ytrain, ytest, fittrain, fittest, beta] = mat_regress_xy(ctrain, ctest, ytrain, ytest)
% MAT_REGRESS_XY  Regress out covariates from y using train-fitted betas.
%
%   [ytrain, ytest] = mat_regress_xy(ctrain, ctest, ytrain, ytest)
%   [ytrain, ytest, fittrain, fittest, beta] = mat_regress_xy(...)
%
%   Fits a linear model y = b0 + C*beta on the training set and returns
%   the residuals. The same betas (and training-set mean) are then applied
%   to the test set to avoid data leakage.
%
%   Inputs:
%       ctrain - [n_train x p] covariates for the training set
%       ctest  - [n_test  x p] covariates for the test set (can be [])
%       ytrain - [n_train x k] target variables (training)
%       ytest  - [n_test  x k] target variables (test, can be [])
%
%   Outputs:
%       ytrain - residualized training targets
%       ytest  - residualized test targets (empty if no test set provided)
%       fittrain - covariate-fitted training values
%       fittest  - covariate-fitted test values
%       beta     - train-fitted regression coefficients

    if nargin < 4
        ytest = [];
    end

    % Training-set covariate centering
    mu_c = mean(ctrain, 1);

    Xtrain = ctrain - mu_c;
    Xtrain = [ones(size(Xtrain, 1), 1), Xtrain];

    % Fit OLS using training data only
    beta = Xtrain \ ytrain;
    fittrain = Xtrain * beta;

    % Residualize training targets
    ytrain = ytrain - fittrain;

    % Apply the same train-fitted model to test data
    if ~isempty(ytest)
        if isempty(ctest)
            error('ctest must be provided when ytest is not empty.');
        end

        Xtest = ctest - mu_c;
        Xtest = [ones(size(Xtest, 1), 1), Xtest];

        fittest = Xtest * beta;
        ytest = ytest - fittest;
    else
        ytest = [];
        fittest = [];
    end
end
