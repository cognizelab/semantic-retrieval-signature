function out_apply = apply_covariate_addback(out_apply, info)
% APPLY_COVARIATE_ADDBACK  Add covariate baseline to residual predictions.

if isempty(out_apply) || nargin < 2 || isempty(info) || ...
        ~isfield(info, 'addBack') || ~info.addBack || ...
        ~isfield(info, 'yTestCovariatePrediction') || ...
        isempty(info.yTestCovariatePrediction)
    return;
end

baseline = info.yTestCovariatePrediction;

if isfield(out_apply, 'pv') && ~isempty(out_apply.pv)
    out_apply.pv = out_apply.pv + baseline;
end
if isfield(out_apply, 'dp') && ~isempty(out_apply.dp)
    out_apply.dp = out_apply.dp + baseline;
end

out_apply.covariate_baseline = baseline;
out_apply.covariateMode = info.applied;
end
