function [opt_parameter,opt_records,param,d] = get_opt_params_ridge(x,y,param)

if ~isfield(param,'lambda') || isempty(param.lambda)
    % param.lambda = power(2,-10:10); 
    param.lambda = [ 0 0.00001 0.0001 0.001 0.004 0.007 0.01 0.04 0.07 0.1 0.4 0.7 1 1.5 2 2.5 3 3.5 4 ...
                    5 10 15 20 30 40 50 60 70 80 100 150 200 300 500 700 1000 10000 100000 1000000];    
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

feature_weight = []; 

for m = 1:numel(param.lambda)
    % disp(['Lambda parameter: ',num2str(m)]);
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
            out_train = train_model_ridge(xtrain,ytrain,parameter);
            % model generalization
            out_apply = apply_model_ridge(xtest,ytest,out_train);
            % feature weight
            feature_weight = [feature_weight,out_train.feature_weight];
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
    [pattern_correlation, mean_O, ~, mean_OC] = mat_assess_stability(feature_weight);
    opt_records.model_quality_stability(m,:) = [pattern_correlation,mean_O,mean_OC];
end
 
opt_records.model_quality_accuracy_label = {'correlation','MAE','RE','RMSE'};
opt_records.model_quality_stability_label = {'pattern correlation','overlap','corrected overlap'};
        
opt_records.lambda = param.lambda;

% Ridge feature weights do not exhibit sparsity. 
if param.po == 4
    param.po = 3;
elseif param.po == 6
    param.po = 5;
elseif param.po == 8
    param.po = 7;
end

if param.po == 1
    f = find(opt_records.model_quality_accuracy(:,1)==max(opt_records.model_quality_accuracy(:,1)));
elseif param.po == 2
    f = find(opt_records.model_quality_accuracy(:,2)==min(opt_records.model_quality_accuracy(:,2)));
elseif param.po == 3
    f = find(opt_records.model_quality_stability(:,1)==max(opt_records.model_quality_stability(:,1)));
elseif param.po == 4
    f = find(opt_records.model_quality_stability(:,3)==max(opt_records.model_quality_stability(:,3)));
elseif param.po == 5
    a = rescale(opt_records.model_quality_accuracy(:,1)); b = rescale(opt_records.model_quality_stability(:,1));
    for i = 1:size(a,1)
        d(i,1) = pdist2([a(i),b(i)],[1 1]);
    end
    f = find(d==min(d));
elseif param.po == 6
    a = rescale(opt_records.model_quality_accuracy(:,1)); b = rescale(opt_records.model_quality_stability(:,3));
    for i = 1:size(a,1)
        d(i,1) = pdist2([a(i),b(i)],[1 1]);
    end
    f = find(d==min(d));     
elseif param.po == 7
    a = 1 - rescale(opt_records.model_quality_accuracy(:,2)); b = rescale(opt_records.model_quality_stability(:,1));
    for i = 1:size(a,1)
        d(i,1) = pdist2([a(i),b(i)],[1 1]);
    end
    f = find(d==min(d));     
elseif param.po == 8
    a = 1 - rescale(opt_records.model_quality_accuracy(:,2)); b = rescale(opt_records.model_quality_stability(:,3));
    for i = 1:size(a,1)
        d(i,1) = pdist2([a(i),b(i)],[1 1]);
    end
    f = find(d==min(d));   
end

opt_parameter = param.lambda(f);

if param.text == 1
    disp('-----------------------------------------------------------------------');
    if param.po == 1 
        disp(['Parameter optimization based on accuracy: accuracy = ',num2str(opt_records.model_quality_accuracy(f,1))]);
    elseif param.po == 2
        disp(['Parameter optimization based on MAE: MAE = ',num2str(opt_records.model_quality_accuracy(f,2))]);
    elseif param.po == 3
        disp(['Parameter optimization based on pattern similarity: similarity = ',num2str(opt_records.model_quality_stability(f,1))]);
    elseif param.po == 4
        disp(['Parameter optimization based on pattern overlap: overlap = ',num2str(opt_records.model_quality_stability(f,3))]);
    elseif param.po == 5
        disp('Parameter optimization based on accuracy and pattern similarity:');     
        disp(['accuracy = ',num2str(opt_records.model_quality_accuracy(f,1)),'; similarity = ',num2str(opt_records.model_quality_stability(f,1))]);
    elseif param.po == 6
        disp('Parameter optimization based on accuracy and pattern overlap:'); 
        disp(['accuracy = ',num2str(opt_records.model_quality_accuracy(f,1)),'; similarity = ',num2str(opt_records.model_quality_stability(f,3))]);    
    elseif param.po == 7
        disp('Parameter optimization based on MAE and pattern similarity:');  
        disp(['accuracy = ',num2str(opt_records.model_quality_accuracy(f,2)),'; similarity = ',num2str(opt_records.model_quality_stability(f,1))]);
    elseif param.po == 8
        disp('Parameter optimization based on MAE and pattern overlap:'); 
        disp(['accuracy = ',num2str(opt_records.model_quality_accuracy(f,2)),'; similarity = ',num2str(opt_records.model_quality_stability(f,3))]);        
    end    
    disp(['Optimal lambda = ',num2str(opt_parameter),' (number = ',num2str(f),')']);
    disp('-----------------------------------------------------------------------');
end
  