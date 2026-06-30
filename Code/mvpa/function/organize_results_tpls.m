function out = organize_results_tpls(~,opt_parameter,opt_records,out_train,out_apply,out_assess,out_assess_full,param)

if ~isempty(opt_parameter)
    out.opt_parameter = opt_parameter;
end
out.parameter_label = {'optimal component number','optimal threshold','maximum component number'};  

out.feature_weight = [];
is_classification = ~isempty(out_assess_full) && isfield(out_assess_full{1},'W');
if ~is_classification
    for ii = 1:numel(out_apply)
        if isstruct(out_apply{ii}) && isfield(out_apply{ii},'isclassification') && out_apply{ii}.isclassification
            is_classification = true;
            break
        end
    end
end

for i = 1:size(out_train,2)
    curr = [];
    for j = 1:size(out_train,1)
        out.feature_weight = [out.feature_weight,out_apply{j,i}.feature_weight];
        if is_classification
            curr(j,:) = [out_assess{j,i}.W.AUC,out_assess{j,i}.W.accuracy,out_assess{j,i}.W.accuracy_p,out_assess{j,i}.W.accuracy_se,out_assess{j,i}.W.Cohen_d];    
        else
            curr(j,:) = [out_assess{j,i}.accuracy,out_assess{j,i}.R2,out_assess{j,i}.MAE,out_assess{j,i}.RMSE];  
        end
    end
    [TV,PV,PW] = collect_ordered_outcomes(out_apply(:,i));
    out.TV(:,i) = TV; out.PV(:,i) = PV; out.PW(:,i) = PW;
    if is_classification
        currvalue(i,:) = [out_assess_full{i}.W.AUC,out_assess_full{i}.W.accuracy,out_assess_full{i}.W.accuracy_p,out_assess_full{i}.W.accuracy_se,out_assess_full{i}.W.Cohen_d]; 
    else
        currvalue(i,:) = [out_assess_full{i}.accuracy,out_assess_full{i}.R2,out_assess_full{i}.MAE,out_assess_full{i}.RMSE];  
    end
    currvalue_folds(i,:) = mean(curr,1);
end

[pattern_correlation, mean_O, ~, mean_OC] = mat_assess_stability(out.feature_weight);

out.model_quality.pattern_similarity = pattern_correlation;
out.model_quality.pattern_overlap = mean_O;
out.model_quality.pattern_overlap_corrected = mean_OC;

if is_classification
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

if ~isempty(opt_records)
    [parameterPerformance, parameterPerformanceMean, performanceLabel] = ...
        local_collect_tpls_parameter_performance(opt_records,param,is_classification);
    if ~isempty(parameterPerformance)
        out.parameter_performance = parameterPerformance;
        out.parameter_performance_mean = parameterPerformanceMean;
        out.parameter_performance_label = performanceLabel;
        [f1,f2] = local_best_parameter_index(parameterPerformanceMean);
        if ~isempty(f1)
            compvec = local_get_param_vector(param,'compvec',size(parameterPerformanceMean,1));
            threshvec = local_get_param_vector(param,'threshvec',size(parameterPerformanceMean,2));
            out.parameter_suggest = [compvec(f1),threshvec(f2),max(compvec)];
            out.parameter_suggest_index = [f1,f2];
            out.parameter_suggest_label = out.parameter_label;
        end
    end
end

end

function [performance,performanceMean,label] = local_collect_tpls_parameter_performance(opt_records,param,is_classification)

performance = [];
label = '';

for i = 1:numel(opt_records)
    if isempty(opt_records{i})
        continue
    end
    [score,currLabel] = local_tpls_record_score(opt_records{i},param,is_classification);
    if isempty(score)
        continue
    end
    performance = cat(3,performance,score);
    if isempty(label)
        label = currLabel;
    end
end

if isempty(performance)
    performanceMean = [];
else
    performanceMean = mean(performance,3,'omitnan');
end

end

function [score,label] = local_tpls_record_score(record,param,is_classification)

score = [];
label = '';

if iscell(record)
    if numel(record) >= 2 && local_has_member(record{2},'perfmat')
        score = record{2}.perfmat;
        label = local_get_member(record{2},'type','optimization_score');
    end
    return
end

if ~isstruct(record)
    return
end

po = 2;
if isfield(param,'po') && ~isempty(param.po)
    po = param.po;
end

switch po
    case 1
        if isfield(record,'accuracy')
            score = record.accuracy;
            label = 'accuracy';
        end
    case 2
        if is_classification && isfield(record,'AUC')
            score = record.AUC;
            label = 'AUC';
        elseif isfield(record,'MAE')
            score = -record.MAE;
            label = 'negative_MAE';
        end
    case 3
        if isfield(record,'pattern_correlation')
            score = record.pattern_correlation;
            label = 'pattern_correlation';
        end
    case 4
        if isfield(record,'corrected_overlap')
            score = record.corrected_overlap;
            label = 'corrected_overlap';
        end
    case {5,6,7,8}
        if isfield(record,'d')
            score = -record.d;
            label = 'negative_combined_distance';
        end
end

if isempty(score)
    if is_classification && isfield(record,'AUC')
        score = record.AUC;
        label = 'AUC';
    elseif isfield(record,'accuracy')
        score = record.accuracy;
        label = 'accuracy';
    elseif isfield(record,'MAE')
        score = -record.MAE;
        label = 'negative_MAE';
    end
end

end

function [f1,f2] = local_best_parameter_index(performanceMean)

f1 = [];
f2 = [];
if isempty(performanceMean)
    return
end

valid = isfinite(performanceMean);
if ~any(valid(:))
    return
end

bestValue = max(performanceMean(valid));
[row,col] = find(performanceMean == bestValue);
f1 = row(end);
f2 = col(end);

end

function values = local_get_param_vector(param,fieldName,n)

if isfield(param,fieldName) && ~isempty(param.(fieldName))
    values = param.(fieldName);
else
    values = 1:n;
end
values = values(:)';
if numel(values) < n
    values = [values,values(end)+1:values(end)+n-numel(values)];
elseif numel(values) > n
    values = values(1:n);
end

end

function tf = local_has_member(S,fieldName)

tf = (isstruct(S) && isfield(S,fieldName)) || ...
    (isobject(S) && isprop(S,fieldName));

end

function value = local_get_member(S,fieldName,defaultValue)

if local_has_member(S,fieldName) && ~isempty(S.(fieldName))
    value = S.(fieldName);
else
    value = defaultValue;
end

end
