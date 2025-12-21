function out = organize_results_svm(model,opt_parameter,opt_records,out_train,out_apply,out_assess,out_assess_full)

if ~isempty(opt_parameter)
    out.opt_parameter = cell2mat(opt_parameter(:));
end

out.feature_weight = [];
currvalue_folds = [];

for i = 1:size(out_train,2)
    TV = []; PV = []; PW = [];
    for j = 1:size(out_train,1)
        out.feature_weight = [out.feature_weight,out_train{j,i}.feature_weight];
        TV = [TV;out_apply{j,i}.tv]; PV = [PV;out_apply{j,i}.pv]; PW = [PW;out_apply{j,i}.dp];
        curr(j,:) = [out_assess{j,i}.W.AUC,out_assess{j,i}.W.accuracy,out_assess{j,i}.W.accuracy_p,out_assess{j,i}.W.accuracy_se,out_assess{j,i}.W.Cohen_d];  
    end
    out.TV(:,i) = TV; out.PV(:,i) = PV; out.PW(:,i) = PW;
    currvalue(i,:) = [out_assess_full{i}.W.AUC,out_assess_full{i}.W.accuracy,out_assess_full{i}.W.accuracy_p,out_assess_full{i}.W.accuracy_se,out_assess_full{i}.W.Cohen_d]; 
    currvalue_folds = [currvalue_folds;curr];
end

[pattern_correlation, mean_O, std_O, mean_OC] = mat_assess_stability(out.feature_weight);

out.model_quality.AUC = currvalue(:,1);
out.model_quality.accuracy = currvalue(:,2);
out.model_quality.accuracy_p = currvalue(:,3);
out.model_quality.accuracy_se = currvalue(:,4);
out.model_quality.Cohen_d = currvalue(:,5);

out.model_quality.pattern_similarity = pattern_correlation;
out.model_quality.pattern_overlap = mean_O;
out.model_quality.pattern_overlap_corrected = mean_OC;

out.model_quality.AUC_folds = currvalue_folds(:,1);
out.model_quality.accuracy_folds = currvalue_folds(:,2);
out.model_quality.accuracy_p_folds = currvalue_folds(:,3);
out.model_quality.accuracy_se_folds = currvalue_folds(:,4);    
out.model_quality.Cohen_d_folds = currvalue_folds(:,5);

out.parameter_label = out_train{1}.parameter_label;  