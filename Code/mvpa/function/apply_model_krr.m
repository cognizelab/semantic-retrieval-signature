function out_apply = apply_model_krr(xtest,ytest,out_train)

out_apply.pv = KernelPrediction(out_train.model,xtest);
out_apply.tv = ytest;
out_apply.dp = [];
