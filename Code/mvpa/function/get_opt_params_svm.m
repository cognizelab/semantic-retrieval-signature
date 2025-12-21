function [opt_parameter,opt_records,param] = get_opt_params_svm(x,y,param)

if ~isfield(param,'C') || isempty(param.C)
    param.C = [0.1:0.1:1]; 
    % param.C = [0.1:0.1:1,10:10:100]; 
end

kk.text = 0;

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

for m = 1:numel(param.C)
    if param.text == 1
        disp(['C parameter: ',num2str(param.C(m)),' (number = ',num2str(m),')']);
    end
    % parameter
    clear model_quality*
    parameter = param.C(m);
    for n = 1:param.icv(2)
        idx = index(:,n); PV = []; TV = []; PW = [];
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
            [out_train,temporary_file] = train_model_svm(xtrain,ytrain,parameter,kk);
            % model generalization
            out_apply = apply_model_svm(xtest,ytest,out_train,temporary_file);
            % feature weight
            feature_weight = [feature_weight,out_train.feature_weight];
            PV = [PV;out_apply.pv]; TV = [TV;out_apply.tv]; PW = [PW;out_apply.dp];
        end
        W = mat_assess_classification(logicl(TV),PW,1,param);
        model_quality_out(n,1) = W.accuracy;
        model_quality_out(n,2) = W.AUC;   
    end
    opt_records.model_quality_accuracy(m,:) = mean(model_quality_out,1);       
    [pattern_correlation, mean_O, ~, mean_OC] = mat_assess_stability(feature_weight);
    opt_records.model_quality_stability(m,:) = [pattern_correlation,mean_O,mean_OC];
end
 
opt_records.model_quality_accuracy_label = {'accuracy','AUC'};
opt_records.model_quality_stability_label = {'pattern correlation','overlap','corrected overlap'};
        
opt_records.C = param.C;

% SVM feature weights do not exhibit sparsity. 
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
    f = find(opt_records.model_quality_accuracy(:,2)==max(opt_records.model_quality_accuracy(:,2)));
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
    a = rescale(opt_records.model_quality_accuracy(:,2)); b = rescale(opt_records.model_quality_stability(:,1));
    for i = 1:size(a,1)
        d(i,1) = pdist2([a(i),b(i)],[1 1]);
    end
    f = find(d==min(d));   
elseif param.po == 8  
    a = rescale(opt_records.model_quality_accuracy(:,2)); b = rescale(opt_records.model_quality_stability(:,3));
    for i = 1:size(a,1)
        d(i,1) = pdist2([a(i),b(i)],[1 1]);
    end
    f = find(d==min(d));       
end

f = f(1);
opt_parameter = param.C(f);

if param.text == 1
    disp('-----------------------------------------------------------------------');
    if param.po == 1
        disp(['Parameter optimization based on accuracy: accuracy = ',num2str(opt_records.model_quality_accuracy(f,1))]);
    elseif param.po == 2
        disp(['Parameter optimization based on AUC: AUC = ',num2str(opt_records.model_quality_accuracy(f,2))]);
    elseif param.po == 3
        disp(['Parameter optimization based on pattern similarity: similarity = ',num2str(opt_records.model_quality_stability(f,1))]);
    elseif param.po == 4
    elseif param.po == 5
        disp('Parameter optimization based on accuracy and pattern similarity:');     
        disp(['accuracy = ',num2str(opt_records.model_quality_accuracy(f,1)),'; similarity = ',num2str(opt_records.model_quality_stability(f,1))]);
    elseif param.po == 6
    elseif param.po == 7
        disp('Parameter optimization based on AUC and pattern similarity:');  
        disp(['accuracy = ',num2str(opt_records.model_quality_accuracy(f,2)),'; similarity = ',num2str(opt_records.model_quality_stability(f,1))]);
    elseif param.po == 8
    end    
    disp(['Optimal C = ',num2str(opt_parameter),' (number = ',num2str(f),')']);
    disp('-----------------------------------------------------------------------');
end