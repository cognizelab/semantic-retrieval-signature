function [out_train,temporary_file] = train_model(xtrain,ytrain,model,parameter,param)

if strcmp(model,'ridge')
    out_train = train_model_ridge(xtrain,ytrain,parameter);
elseif strcmp(model,'lm')
    out_train = train_model_lm(xtrain,ytrain);
elseif strcmp(model,'rvr')
    out_train = train_model_rvr(xtrain,ytrain);
elseif strcmp(model,'krr')
    out_train = train_model_krr(xtrain,ytrain,parameter);
elseif strcmp(model,'svm')
    [out_train,temporary_file] = train_model_svm(xtrain,ytrain,parameter,param);
elseif strcmp(model,'svr')
    [out_train,temporary_file] = train_model_svr(xtrain,ytrain,parameter,param);    
elseif strcmp(model,'tpls')
    [out_train,temporary_file] = train_model_tpls(xtrain,ytrain,parameter,param);
end

if ~exist('temporary_file', 'var') 
    temporary_file = [];
end
