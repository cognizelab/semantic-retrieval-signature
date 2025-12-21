function [opt_parameter,opt_records,param] = get_opt_params(x,y,model,param)

if strcmp(model,'ridge')
    [opt_parameter,opt_records,param] = get_opt_params_ridge(x,y,param);
elseif strcmp(model,'krr')
    [opt_parameter,opt_records,param] = get_opt_params_krr(x,y,param);
elseif strcmp(model,'svm')
    [opt_parameter,opt_records,param] = get_opt_params_svm(x,y,param);
elseif strcmp(model,'svr')
    [opt_parameter,opt_records,param] = get_opt_params_svr(x,y,param);    
elseif strcmp(model,'tpls')
    [opt_parameter,opt_records,param] = get_opt_params_tpls(x,y,param);
end