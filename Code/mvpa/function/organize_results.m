function out = organize_results(model,opt_parameter,opt_records,out_train,out_apply,out_assess,out_assess_full,param,out_lesion)

if strcmp(model,'ridge') | strcmp(model,'lm') | strcmp(model,'rvr') | strcmp(model,'svr')
    out = organize_results_lm(model,opt_parameter,opt_records,out_train,out_apply,out_assess,out_assess_full);
elseif strcmp(model,'krr')  
    out = organize_results_krr(model,opt_parameter,opt_records,out_train,out_apply,out_assess,out_assess_full);
elseif strcmp(model,'svm') 
    out = organize_results_svm(model,opt_parameter,opt_records,out_train,out_apply,out_assess,out_assess_full);
elseif strcmp(model,'tpls') 
    out = organize_results_tpls(model,opt_parameter,opt_records,out_train,out_apply,out_assess,out_assess_full,param);
end            
 
if param.savefolds == 1
    out.outcomes_each_fold = out_apply;
    out.assessment_each_fold = out_assess;
    out.outcomes_label = 'k folds × n repetations';
    out.parameter_optimization = opt_records;
end

if ~isempty(out_lesion)
    out_lesion = out_lesion(:);
    for i = 1:length(out_lesion)
        out.virtual_lesion_analysis.onlyROI(i,:) = out_lesion{i}.onlyROI;  
        out.virtual_lesion_analysis.removeROI(i,:) = out_lesion{i}.removeROI;  
    end
end