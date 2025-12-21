function [out_train,temporary_file] = train_model_svr(xtrain,ytrain,parameter,param)

if ~isempty(parameter) 
    if param.text == 1
        disp('Model training based on specified C parameter...');
    end
    out_svr = fitrsvm(xtrain,ytrain,"BoxConstraint",parameter);
    out_train.parameter = parameter; out_train.parameter_label = 'C';
else
    if isfield(param,'svr') && ~isempty(param.svr)
        if param.text == 1
            disp('Model training based on Matlab custom parameters...');
        end        
        p = [fieldnames(param.svr) struct2cell(param.svr)]'; p = p(:)';
        out_svr = fitrsvm(xtrain,ytrain,p{:}); 
        out_train.parameter_label = 'Matlab custom parameters';
    else
        if param.text == 1
            disp('Model training based on Matlab default parameters.');
        end        
        out_svr = fitrsvm(xtrain,ytrain);
        out_train.parameter_label = 'Matlab default parameters';
    end
    out_train.parameter = []; 
end

temporary_file = out_svr;
out_train.model = out_svr;
out_train.feature_weight = out_svr.Beta;
out_train.bias = out_svr.Bias;
 