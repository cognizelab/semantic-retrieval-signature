function [out_train,temporary_file] = train_model_tpls(xtrain,ytrain,parameter,param)

if length(parameter) < 3
    parameter(3) = parameter(1);
end

out_train.model = TPLS(xtrain,ytrain,parameter(3),ones(numel(ytrain),1),0);
temporary_file = parameter;

[out_train.feature_weight,out_train.bias] = makePredictor(out_train.model,temporary_file(1),temporary_file(2));
class_labels = unique(ytrain(:));
out_train.isclassification = numel(class_labels) == 2;
out_train.class_labels = class_labels(:)';
if out_train.isclassification
    out_train.class_threshold = mean(out_train.class_labels);
else
    out_train.class_threshold = [];
end
