function out_apply = apply_model_tpls(xtest,ytest,out_train,temporary_file)

betamap = out_train.feature_weight;
bias = out_train.bias;

out_apply.dp = bias + xtest*betamap;  

out_apply.tv = ytest;
out_apply.feature_weight = betamap;
out_apply.bias = bias;
out_apply.isclassification = isfield(out_train,'isclassification') && out_train.isclassification;

if out_apply.isclassification
    class_labels = out_train.class_labels;
    out_apply.pv = class_labels(1) * ones(size(out_apply.dp));
    out_apply.pv(out_apply.dp > out_train.class_threshold) = class_labels(2);
else
    out_apply.pv = out_apply.dp;
end
