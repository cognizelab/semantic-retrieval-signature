function out = organize_results_lm(model,opt_parameter,opt_records,out_train,out_apply,out_assess,out_assess_full)

if ~isempty(opt_parameter)
    out.opt_parameter = cell2mat(opt_parameter(:));
end

out.feature_weight = [];
for i = 1:size(out_train,2)
    TV = []; PV = [];
    for j = 1:size(out_train,1)
        out.feature_weight = [out.feature_weight,out_train{j,i}.feature_weight];
        TV = [TV;out_apply{j,i}.tv]; PV = [PV;out_apply{j,i}.pv];
        curr(j,:) = [out_assess{j,i}.accuracy,out_assess{j,i}.R2,out_assess{j,i}.MAE,out_assess{j,i}.RMSE];  
    end
    out.TV(:,i) = TV; out.PV(:,i) = PV;
    currvalue(i,:) = [out_assess_full{i}.accuracy,out_assess_full{i}.R2,out_assess_full{i}.MAE,out_assess_full{i}.RMSE];  
    currvalue_folds(i,:) = mean(curr);
end

currvalue = currvalue;
[pattern_correlation, mean_O, std_O, mean_OC] = mat_assess_stability(out.feature_weight);

out.model_quality.accuracy_correlation = currvalue(:,1);
out.model_quality.R2 = currvalue(:,2);
out.model_quality.MAE = currvalue(:,3);
out.model_quality.RMSE = currvalue(:,4);
out.model_quality.pattern_similarity = pattern_correlation;
out.model_quality.pattern_overlap = mean_O;
out.model_quality.pattern_overlap_corrected = mean_OC;
out.model_quality.accuracy_correlation_folds = currvalue_folds(:,1);
out.model_quality.R2_folds = currvalue_folds(:,2);
out.model_quality.MAE_folds = currvalue_folds(:,3);
out.model_quality.RMSE_folds = currvalue_folds(:,4);    
out.parameter_label = out_train{1}.parameter_label;  