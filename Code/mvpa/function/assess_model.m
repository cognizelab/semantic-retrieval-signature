function out_assess = assess_model(out_apply,model,param)

pw = [];
if isstruct(out_apply)
    tv = out_apply.tv;
    pv = out_apply.pv;
    if isfield(out_apply,'dp'); pw = out_apply.dp; end
else 
    tv = out_apply(:,1);
    pv = out_apply(:,2);
    if size(out_apply,2) >= 3; pw = out_apply(:,3); end
end

if isempty(pw)
    pw = pv;
end

if strcmp(model,'ridge') || strcmp(model,'lm') || strcmp(model,'krr') || strcmp(model,'rvr') || strcmp(model,'svr')
    out_assess = mat_assess_correlation(tv,pv,param);
elseif strcmp(model,'svm')
    out_assess.B = mat_assess_classification(tv,pv,0,param);
    out_assess.W = mat_assess_classification(tv,pw,1,param);
    out_assess.accuracy = out_assess.W.accuracy;    
elseif strcmp(model,'tpls') && (numel(unique(tv)) == 2 || ...
        (isstruct(out_apply) && isfield(out_apply,'isclassification') && out_apply.isclassification))
    out_assess.B = mat_assess_classification(tv,pv,0,param);
    out_assess.W = mat_assess_classification(tv,pw,1,param);
    out_assess.accuracy = out_assess.W.accuracy;    
else
    out_assess = mat_assess_correlation(tv,pv,param);    
end
 
