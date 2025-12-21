function [out_train,temporary_file] = train_model_svm(xtrain,ytrain,parameter,param)

if ~isempty(parameter) 
    if param.text == 1
        disp('Model training based on specified C parameter...');
    end
    out_svm = fitcsvm(xtrain,ytrain,"BoxConstraint",parameter);
    out_train.parameter = parameter; out_train.parameter_label = 'C';
else
    if isfield(param,'svm') && ~isempty(param.svm)
        if param.text == 1
            disp('Model training based on Matlab custom parameters...');
        end        
        p = [fieldnames(param.svm) struct2cell(param.svm)]'; p = p(:)';
        out_svm = fitcsvm(xtrain,ytrain,p{:}); 
        out_train.parameter_label = 'Matlab custom parameters';
    else
        if param.text == 1
            disp('Model training based on Matlab default parameters.');
        end        
        out_svm = fitcsvm(xtrain,ytrain);
        out_train.parameter_label = 'Matlab default parameters';
    end
    out_train.parameter = []; 
end

temporary_file = out_svm;
out_train.model = out_svm;
out_train.feature_weight = out_svm.Beta;
out_train.bias = out_svm.Bias;

% SVs = out_svm.SupportVectors; 
% Alpha = out_svm.Alpha;  
% svLabels = out_svm.SupportVectorLabels;  
% w = sum(bsxfun(@times, Alpha .* svLabels, SVs));
% out_train.feature_weight = w';


