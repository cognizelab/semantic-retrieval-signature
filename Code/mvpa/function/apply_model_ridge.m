function out_apply = apply_model_ridge(xtest,ytest,out_train)

out_apply.pv = xtest*out_train.model;
out_apply.tv = ytest;
out_apply.dp = [];
