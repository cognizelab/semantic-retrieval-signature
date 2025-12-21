function out_apply = apply_model_svm(xtest,ytest,out_train,temporary_file)

out_apply.pv = predict(temporary_file,xtest);
out_apply.tv = ytest;

if nargin > 3
    if strcmp(temporary_file.ModelParameters.KernelFunction,'linear')  
        out_apply.dp = xtest*out_train.feature_weight + out_train.bias;
    end
end
