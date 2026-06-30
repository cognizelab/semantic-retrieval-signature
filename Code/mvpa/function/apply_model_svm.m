function out_apply = apply_model_svm(xtest,ytest,out_train,temporary_file)

[out_apply.pv,score] = predict(temporary_file,xtest);
out_apply.tv = ytest;
out_apply.dp = [];

if nargin > 3
    if size(score,2) >= 2
        out_apply.dp = score(:,2);
    elseif ~isempty(score)
        out_apply.dp = score(:,1);
    elseif strcmp(temporary_file.ModelParameters.KernelFunction,'linear')  
        out_apply.dp = xtest*out_train.feature_weight + out_train.bias;
    end
end
