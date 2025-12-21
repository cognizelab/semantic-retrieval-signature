function out_apply = apply_model(xtest,ytest,model,out_train,temporary_file)

if strcmp(model,'ridge')
    out_apply = apply_model_ridge(xtest,ytest,out_train);
elseif strcmp(model,'lm')
    out_apply = apply_model_lm(xtest,ytest,out_train);
elseif strcmp(model,'rvr')
    out_apply = apply_model_rvr(xtest,ytest,out_train);
elseif strcmp(model,'krr')
    out_apply = apply_model_krr(xtest,ytest,out_train);
elseif strcmp(model,'svm')
    out_apply = apply_model_svm(xtest,ytest,out_train,temporary_file);
elseif strcmp(model,'svr')
    out_apply = apply_model_svr(xtest,ytest,out_train,temporary_file);    
elseif strcmp(model,'tpls')
    out_apply = apply_model_tpls(xtest,ytest,out_train,temporary_file);
end



