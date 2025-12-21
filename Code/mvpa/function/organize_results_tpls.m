function out = organize_results_tpls(model,opt_parameter,opt_records,out_train,out_apply,out_assess,out_assess_full,param)

if ~isempty(opt_parameter)
    out.opt_parameter = opt_parameter;
end
out.parameter_label = {'optimal component number','optimal threshold','maxium component number'};  

out.feature_weight = [];

for i = 1:size(out_train,2)
    TV = []; PV = []; PW = [];
    for j = 1:size(out_train,1)
        out.feature_weight = [out.feature_weight,out_apply{j,i}.feature_weight];
        TV = [TV;out_apply{j,i}.tv]; PV = [PV;out_apply{j,i}.pv]; PW = [PW;out_apply{j,i}.dp];
        if numel(unique(TV)) == 2
            curr(j,:) = [out_assess{j,i}.W.AUC,out_assess{j,i}.W.accuracy,out_assess{j,i}.W.accuracy_p,out_assess{j,i}.W.accuracy_se,out_assess{j,i}.W.Cohen_d];    
        else
            curr(j,:) = [out_assess{j,i}.accuracy,out_assess{j,i}.R2,out_assess{j,i}.MAE,out_assess{j,i}.RMSE];  
        end
    end
    out.TV(:,i) = TV; out.PV(:,i) = PV; out.PW(:,i) = PW;
    if numel(unique(TV)) == 2
        currvalue(i,:) = [out_assess_full{i}.W.AUC,out_assess_full{i}.W.accuracy,out_assess_full{i}.W.accuracy_p,out_assess_full{i}.W.accuracy_se,out_assess_full{i}.W.Cohen_d]; 
    else
        currvalue(i,:) = [out_assess_full{i}.accuracy,out_assess_full{i}.R2,out_assess_full{i}.MAE,out_assess_full{i}.RMSE];  
    end
    currvalue_folds(i,:) = mean(curr);
end

[pattern_correlation, mean_O, std_O, mean_OC] = mat_assess_stability(out.feature_weight);

out.model_quality.pattern_similarity = pattern_correlation;
out.model_quality.pattern_overlap = mean_O;
out.model_quality.pattern_overlap_corrected = mean_OC;

if numel(unique(TV)) == 2
    out.model_quality.AUC = currvalue(:,1);
    out.model_quality.accuracy = currvalue(:,2);
    out.model_quality.accuracy_p = currvalue(:,3);
    out.model_quality.accuracy_se = currvalue(:,4);
    out.model_quality.Cohen_d = currvalue(:,5);

    out.model_quality.AUC_folds = currvalue_folds(:,1);
    out.model_quality.accuracy_folds = currvalue_folds(:,2);
    out.model_quality.accuracy_p_folds = currvalue_folds(:,3);
    out.model_quality.accuracy_se_folds = currvalue_folds(:,4);    
    out.model_quality.Cohen_d_folds = currvalue_folds(:,5);
else
    out.model_quality.accuracy_correlation = currvalue(:,1);
    out.model_quality.R2 = currvalue(:,2);
    out.model_quality.MAE = currvalue(:,3);
    out.model_quality.RMSE = currvalue(:,4);
    out.model_quality.accuracy_correlation_folds = currvalue_folds(:,1);
    out.model_quality.R2_folds = currvalue_folds(:,2);
    out.model_quality.MAE_folds = currvalue_folds(:,3);
    out.model_quality.RMSE_folds = currvalue_folds(:,4);    
end

if param.po_tpls == 1
    out.parameter_performance = [];
    for i = 1:size(opt_records,1)
        for j = 1:size(opt_records,2)
            out.parameter_performance = cat(3, out.parameter_performance, opt_records{i,j}{2}.perfmat);
        end
    end
    currv = mean(out.parameter_performance,3);
    [f1,f2] = find(currv==max(max(currv)));
    out.parameter_suggest = [param.compvec(f1(end)),param.threshvec(f2(end))];
end