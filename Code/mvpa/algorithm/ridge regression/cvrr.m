function [best_lambda,best_error] = cvrr(x_train,y_train,lambdas,N)
%% K-fold Cross-validation for Parameter lambda Optimization
%------------------------------------------------------------------------------------------------%
% - Z.K.X. 2019/01/09
%------------------------------------------------------------------------------------------------%
%% Input
%  (1) x_train: feature (subjects * variates double matrix) 
%  (2) y_train: label (subjects * variates double matrix) 
%  (3) lambdas: lambda parameter sessions
%  (4) N: fold number
%------------------------------------------------------------------------------------------------%
%% Output
%  (1) best_lambda: optimal lambda value
%  (2) best_error: error corresponding to optimal lambda value
%------------------------------------------------------------------------------------------------%
if (nargin < 3) | isempty(lambdas)
    lambdas = [linspace(0,1)];
end
if (nargin < 4) | isempty(N)
    N = 5;
end

test_error = zeros(size(lambdas));
train_error = zeros(size(lambdas));

folds = cvpartition(y_train, 'KFold', N);

cv_error = zeros(size(lambdas, 2), 1);
for i = 1:size(lambdas, 2)
    lambda_cv_error = zeros(5, 1);
    for j = 1:5
        train_idx = folds.training(j);
        test_idx = folds.test(j);
        w = ridge_regression(x_train(train_idx, :), y_train(train_idx),...
            lambdas(i));
        lambda_cv_error(j) = mean((y_train(test_idx) - x_train(test_idx, :) * w).^2);
    end
    cv_error(i) = mean(lambda_cv_error);
end

[best_error,best_idx] = min(cv_error);
best_lambda = lambdas(best_idx);
