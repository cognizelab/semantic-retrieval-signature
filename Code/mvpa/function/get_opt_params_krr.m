function [opt_parameter,opt_records,param] = get_opt_params_krr(x,y,param)

if ~isfield(param,'lambda') || isempty(param.lambda)
    param.lambda = power(2,-10:10); 
end

curr_param = param; curr_param.groupCV = curr_param.groupCVinner;

if param.samerule == 1
    if ~isempty(param.groupCVinner) && size(param.groupCVinner,1) ~= size(x,1)        
        curr_param.groupCV(param.ftest,:) = [];
    end
    if ~isempty(param.stratifyCV) && size(param.stratifyCV,1) ~= size(x,1)
        curr_param.stratifyCV(param.ftest,:) = [];
    end
    if ~isempty(param.indexCV) && size(param.indexCV,1) ~= size(x,1)
        curr_param.indexCV(param.ftest,:) = [];
    end
else
    curr_param.groupCV = []; curr_param.stratifyCV = []; curr_param.indexCV = []; curr_param.keepOrder = 0;    
end

index = mat_sample(x,y,[],param.icv,curr_param);
 
for m = 1:numel(param.lambda)
    % parameter
    clear model_quality*
    parameter = param.lambda(m);
    for n = 1:param.icv(2)
        idx = index(:,n); PV = []; TV = [];
        for k = 1:param.icv(1)
            % splitting data sets
            ftest = find(idx==k); ftrain = find(idx~=k);
            xtest = x(ftest,:); ytest = y(ftest,:); 
            xtrain = x(ftrain,:); ytrain = y(ftrain,:); 
            % feature scaling 
            if param.iscale == 1 
                vmin = min(xtrain); vmax = max(xtrain); v = vmax-vmin;
                xtrain = (xtrain - vmin) ./ v;
                xtest = (xtest - vmin) ./ v;    
            end
            % model training
            out_train = train_model_krr(xtrain,ytrain,parameter);
            % model generalization
            out_apply = apply_model_krr(xtest,ytest,out_train);
            PV = [PV;out_apply.pv]; TV = [TV;out_apply.tv];
            if param.po_folds == 1
                model_quality_in{k,n} = mat_assess_correlation(out_apply.tv,out_apply.pv,param);
            end
        end
        model_quality_out{n} = mat_assess_correlation(TV,PV,param);
    end
    if param.po_folds == 1
        model_quality_in = model_quality_in(:);
        for i = 1:length(model_quality_in)
            x_in(i,:) = [model_quality_in{i}.accuracy,model_quality_in{i}.MAE,model_quality_in{i}.R2,model_quality_in{i}.RMSE];
        end    
        opt_records.model_quality_accuracy(m,:) = mean(x_in,1);
    else
        for i = 1:length(model_quality_out)
            x_out(i,:)  = [model_quality_out{i}.accuracy,model_quality_out{i}.MAE,model_quality_out{i}.R2,model_quality_out{i}.RMSE];
        end
        opt_records.model_quality_accuracy(m,:) = mean(x_out,1);       
    end
end
 
opt_records.model_quality_accuracy_label = {'correlation','MAE','RE','RMSE'};
        
opt_records.lambda = param.lambda;

if param.po == 1
    f = find(opt_records.model_quality_accuracy(:,1)==max(opt_records.model_quality_accuracy(:,1)));
elseif param.po == 2
    f = find(opt_records.model_quality_accuracy(:,2)==min(opt_records.model_quality_accuracy(:,2)));
else 
    f = find(opt_records.model_quality_accuracy(:,1)==max(opt_records.model_quality_accuracy(:,1)));
end

opt_parameter = param.lambda(f);

if param.text == 1
    disp('-----------------------------------------------------------------------');
    if param.po ~= 2
        disp(['Parameter optimization based on accuracy: accuracy = ',num2str(opt_records.model_quality_accuracy(f,1))]);
    else
        disp(['Parameter optimization based on MAE: MAE = ',num2str(opt_records.model_quality_accuracy(f,2))]);
    end
    disp(['Optimal lambda = ',num2str(opt_parameter),' (number = ',num2str(f),')']);
    disp('-----------------------------------------------------------------------');
end