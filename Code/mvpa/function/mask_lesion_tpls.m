function out_lesion = mask_lesion_tpls(xtest,ytest,model,out_train,temporary_file,param);

mask = param.mask;

for i = 1:numel(unique(mask))
    xtest_temp = xtest; ytest_temp = ytest;
    f1 = find(mask == i); f2 = find(mask ~= i);
    out_train_temp = out_train; 
    out_train_temp.feature_weight = out_train_temp.feature_weight(f1);
    onlyROI = apply_model(xtest(:,f1),ytest,model,out_train_temp,temporary_file);
    out_train_temp = out_train; 
    out_train_temp.feature_weight = out_train_temp.feature_weight(f2);
    removeROI = apply_model(xtest(:,f2),ytest,model,out_train_temp,temporary_file);
    out_lesion.onlyROI{i} = assess_model(onlyROI,model,param);
    out_lesion.removeROI{i} = assess_model(removeROI,model,param);
end   