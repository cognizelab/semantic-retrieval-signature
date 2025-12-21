function do_parameter = get_default_params(model,param)

if strcmp(model,'ridge')
    if isfield(param,'lambda') && ~isempty(param.lambda)
        do_parameter(:,1) = param.lambda;
    else
        do_parameter = 1;
    end
elseif strcmp(model,'lm') | strcmp(model,'rvr')
    do_parameter = [];
elseif strcmp(model,'svm') | strcmp(model,'svr')
    if isfield(param,'C') && ~isempty(param.C)
        do_parameter(:,1) = param.C
    else
        do_parameter = [];
    end
elseif strcmp(model,'tpls')
    if isfield(param,'compvec') && ~isempty(param.compvec)
        a(:,1) = param.compvec;
    else
        a = 10;
    end
    if isfield(param,'threshvec') && ~isempty(param.threshvec)
        b(:,1) = param.threshvec;
    else
        b = 0.2;
    end
    do_parameter = [a, b, a];
end