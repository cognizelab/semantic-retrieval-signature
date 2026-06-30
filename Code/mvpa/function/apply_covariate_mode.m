function [xtrain, ytrain, xtest, ytest, info] = apply_covariate_mode( ...
    xtrain, ytrain, ctrain, xtest, ytest, ctest, param, model)
% APPLY_COVARIATE_MODE  Apply fold-wise covariate handling.
%
%   Supported modes:
%       none
%       residualizeY
%       residualizeX
%       residualizeXY
%       includeCovariates
%       residualizeY_addBack
%
%   residualizeY_addBack trains the predictive model on residualized y but
%   keeps ytest on its original scale. Use apply_covariate_addback after
%   prediction to add the test-set covariate baseline back to predictions.

if nargin < 8
    model = '';
end

[modeResolved, modeRequested, modeApplied] = ...
    resolve_covariate_mode(model, ytrain, param, ctrain);

info = struct();
info.requested = modeRequested;
info.resolved = modeResolved;
info.applied = modeApplied;
info.addBack = false;
info.yTrainCovariatePrediction = [];
info.yTestCovariatePrediction = [];
info.yTestResidual = [];
info.includeCovariates = false;

if strcmp(modeApplied, 'none')
    return;
end

switch modeApplied
    case 'residualizeY'
        [ytrain, ytest] = mat_regress_xy(ctrain, ctest, ytrain, ytest);

    case 'residualizeX'
        [xtrain, xtest] = mat_regress_xy(ctrain, ctest, xtrain, xtest);

    case 'residualizeXY'
        [xtrain, xtest] = mat_regress_xy(ctrain, ctest, xtrain, xtest);
        [ytrain, ytest] = mat_regress_xy(ctrain, ctest, ytrain, ytest);

    case 'includeCovariates'
        xtrain = [xtrain, ctrain];
        if ~isempty(xtest)
            xtest = [xtest, ctest];
        end
        info.includeCovariates = true;

    case 'residualizeY_addBack'
        ytestOriginal = ytest;
        [ytrain, ytestResidual, yfitTrain, yfitTest] = ...
            mat_regress_xy(ctrain, ctest, ytrain, ytest);
        ytest = ytestOriginal;
        info.addBack = ~isempty(yfitTest);
        info.yTrainCovariatePrediction = yfitTrain;
        info.yTestCovariatePrediction = yfitTest;
        info.yTestResidual = ytestResidual;

    otherwise
        error('Unsupported covariate mode: %s', modeApplied);
end
end
