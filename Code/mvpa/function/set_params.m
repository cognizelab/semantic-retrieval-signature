function param = set_params(model,param)
%% Set Default parameters

if ~isfield(param,'text') || isempty(param.text); param.text = 1; end
if ~isfield(param,'progress') || isempty(param.progress); param.progress = 1; end
if ~isfield(param,'savefolds') || isempty(param.savefolds); param.savefolds = 1; end
if ~isfield(param,'savelarge') || isempty(param.savelarge); param.savelarge = 0; end

if ~isfield(param,'covariates') || isempty(param.covariates); param.covariates = 1; end
if ~isfield(param,'interp') || isempty(param.interp); param.interp = 0; end
if ~isfield(param,'scale') || isempty(param.scale); param.scale = 1; end
if ~isfield(param,'random') || isempty(param.random); param.random = 0; end

if ~isfield(param,'po_folds') || isempty(param.po_folds); param.po_folds = 0; end
if ~isfield(param,'icv') || isempty(param.icv); param.icv = [5 1]; end
if ~isfield(param,'iscale') || isempty(param.iscale); param.iscale = 1; end
if ~isfield(param,'corrtype') || isempty(param.corrtype); param.corrtype = 'Pearson'; end
if ~isfield(param,'samerule') || isempty(param.samerule); param.samerule = 1; end
if ~isfield(param,'ID'); param.ID = []; end

if ~isfield(param,'groupCV'); param.groupCV = []; end
if ~isfield(param,'groupCVinner'); param.groupCVinner = param.groupCV; param.samerule = 1; end
if ~isfield(param,'stratifyCV'); param.stratifyCV = []; end
if ~isfield(param,'indexCV'); param.indexCV = []; end
if ~isfield(param,'keepOrder') || isempty(param.keepOrder); param.keepOrder = 0; end

if param.scale == 0; param.iscale = 0; end

if numel(param.icv)<2; param.icv(2) = 1; end

if ~isfield(param,'po') || isempty(param.po)  
    if strcmp(model,'krr') 
        param.po = 1;
    elseif strcmp(model,'tpls')
        param.po = 2;
        if ~isfield(param,'po_tpls'); param.po_tpls = 1; end
    elseif strcmp(model,'lm') | strcmp(model,'svm') | strcmp(model,'svr') | strcmp(model,'rvr')
        param.po = 0;
    else
        param.po = 5;
    end
end