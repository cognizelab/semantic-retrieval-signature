function out_apply = apply_model_tpls(xtest,ytest,out_train,temporary_file)

betamap = out_train.feature_weight;
bias = out_train.bias;

out_apply.dp = bias + xtest*betamap;  

out_apply.tv = ytest;
out_apply.feature_weight = betamap;
out_apply.bias = bias;

if numel(unique(ytest)) == 2
    out_apply.pv = out_apply.dp > 0.5;
    out_apply.pv = double(out_apply.pv);
else
    out_apply.pv = out_apply.dp;
end