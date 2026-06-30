function [modeResolved, modeRequested, modeApplied] = resolve_covariate_mode(model, y, param, c)
% RESOLVE_COVARIATE_MODE  Resolve covariateMode for MAT CV routines.
%
%   modeRequested is the user-facing setting. modeResolved is the concrete
%   mode after expanding 'auto'. modeApplied is 'none' when no covariates
%   are available, otherwise it matches modeResolved.

if nargin < 4
    c = [];
end
if nargin < 3 || isempty(param)
    param = struct();
end

if isfield(param, 'covariateMode') && ~isempty(param.covariateMode)
    modeRequested = normalizeMode(param.covariateMode);
elseif isfield(param, 'covariates') && ~isempty(param.covariates)
    modeRequested = legacyCovariatesToMode(param.covariates);
else
    modeRequested = 'auto';
end

isClass = isClassificationModel(model, y);

if strcmp(modeRequested, 'auto')
    if isClass
        modeResolved = 'residualizeX';
    else
        modeResolved = 'residualizeY';
    end
else
    modeResolved = modeRequested;
end

if isClass && any(strcmp(modeResolved, ...
        {'residualizeY','residualizeXY','residualizeY_addBack'}))
    error(['The selected covariateMode residualizes y, which is not valid ' ...
        'for classification. Use ''auto'', ''residualizeX'', ''none'', or ' ...
        '''includeCovariates''.']);
end

if isempty(c) || strcmp(modeResolved, 'none')
    modeApplied = 'none';
else
    modeApplied = modeResolved;
end
end

function mode = normalizeMode(mode)
if isstring(mode)
    assert(isscalar(mode), 'covariateMode must be a char vector or string scalar.');
    mode = char(mode);
end
assert(ischar(mode), 'covariateMode must be a char vector or string scalar.');

key = lower(strtrim(mode));
switch key
    case 'auto'
        mode = 'auto';
    case 'none'
        mode = 'none';
    case {'residualizey', 'residualise_y', 'residualize_y'}
        mode = 'residualizeY';
    case {'residualizex', 'residualise_x', 'residualize_x'}
        mode = 'residualizeX';
    case {'residualizexy', 'residualise_xy', 'residualize_xy'}
        mode = 'residualizeXY';
    case {'includecovariates', 'include_covariates', 'include'}
        mode = 'includeCovariates';
    case {'residualizey_addback', 'residualize_y_addback', ...
            'residualisey_addback', 'residualise_y_addback'}
        mode = 'residualizeY_addBack';
    otherwise
        error(['covariateMode must be ''auto'', ''none'', ''residualizeY'', ' ...
            '''residualizeX'', ''residualizeXY'', ''includeCovariates'', ' ...
            'or ''residualizeY_addBack''.']);
end
end

function mode = legacyCovariatesToMode(covariates)
switch covariates
    case 0
        mode = 'none';
    case 1
        mode = 'residualizeY';
    case 2
        mode = 'residualizeX';
    otherwise
        error('Legacy param.covariates must be 0, 1, or 2.');
end
end

function tf = isClassificationModel(model, y)
u = unique(y(:));
u = u(isfinite(u));
tf = strcmpi(model, 'svm') || (strcmpi(model, 'tpls') && numel(u) == 2);
end
