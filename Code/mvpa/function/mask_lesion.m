function out_lesion = mask_lesion(xtest,ytest,model,out_train,temporary_file,param)

if strcmp(model,'ridge')
    out_lesion = mask_lesion_ridge(xtest,ytest,model,out_train,temporary_file,param);
elseif strcmp(model,'lm')
    out_lesion = mask_lesion_lm(xtest,ytest,model,out_train,temporary_file,param);
elseif strcmp(model,'rvr')
    out_lesion = mask_lesion_rvr(xtest,ytest,model,out_train,temporary_file,param);
elseif strcmp(model,'krr')
    disp("The current model does not support performing 'virtual lesion' analysis after completing model training.");
elseif strcmp(model,'svm')
    out_lesion = mask_lesion_svm(xtest,ytest,model,out_train,temporary_file,param);
elseif strcmp(model,'svr')
    out_lesion = mask_lesion_svr(xtest,ytest,model,out_train,temporary_file,param);    
elseif strcmp(model,'tpls')
    out_lesion = mask_lesion_tpls(xtest,ytest,model,out_train,temporary_file,param);
end
