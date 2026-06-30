function model_quality = mat_assess_classification(TV,PV,w,param)
%%
% Classification metrics for binary labels or continuous decision scores.

if nargin < 3 || isempty(w); w = 0; end
if nargin < 4 || isempty(param); param = struct(); end

TV = TV(:);
PV = PV(:);
n = min(numel(TV),numel(PV));
TV = TV(1:n);
PV = PV(1:n);

if w ~= 1
    model_quality = local_confusion_metrics(TV,PV,param);
else
    model_quality = local_score_metrics(TV,PV,param);
end

end

function model_quality = local_confusion_metrics(TV,PV,param)

model_quality.accuracy = NaN;
model_quality.error_rate = NaN;
model_quality.precision = NaN;
model_quality.specificity = NaN;
model_quality.sensitivity = NaN;
model_quality.TPR = NaN;
model_quality.FNR = NaN;
model_quality.FPR = NaN;
model_quality.TNR = NaN;

I = isfinite(TV) & isfinite(PV);
TV = TV(I);
PV = PV(I);
if isempty(TV)
    return
end

pos_label = local_positive_label([TV;PV],param);
truth = TV == pos_label;
pred = PV == pos_label;

TP = sum(truth & pred);
TN = sum(~truth & ~pred);
FP = sum(~truth & pred);
FN = sum(truth & ~pred);

model_quality.sensitivity = local_divide(TP,TP + FN);
model_quality.specificity = local_divide(TN,TN + FP);
model_quality.TPR = model_quality.sensitivity;
model_quality.FNR = local_divide(FN,TP + FN);
model_quality.FPR = local_divide(FP,FP + TN);
model_quality.TNR = model_quality.specificity;
model_quality.accuracy = local_divide(TP + TN,TP + TN + FP + FN);
model_quality.error_rate = 1 - model_quality.accuracy;
model_quality.precision = local_divide(TP,TP + FP);

end

function model_quality = local_score_metrics(TV,PV,param)

model_quality.AUC = NaN;
model_quality.specificity = NaN;
model_quality.sensitivity = NaN;
model_quality.accuracy = NaN;
model_quality.accuracy_p = NaN;
model_quality.accuracy_se = NaN;
model_quality.Cohen_d = NaN;

I = isfinite(TV) & isfinite(PV);
TV = TV(I);
PV = PV(I);
if isempty(TV)
    return
end

pos_label = local_positive_label(TV,param);
truth = TV == pos_label;
if numel(unique(truth)) < 2
    return
end

ROC = [];
if exist('roc_plot_2020','file') == 2
    try
        if isfield(param,'twochoice') && param.twochoice == 1
            ROC = roc_plot_2020(PV,truth,'noplot','nooutput','twochoice');
        else
            ROC = roc_plot_2020(PV,truth,'noplot','nooutput');
        end
    catch
        ROC = [];
    end
end

if ~isempty(ROC)
    model_quality.AUC = local_getfield(ROC,'AUC',NaN);
    model_quality.specificity = local_getfield(ROC,'specificity',NaN);
    model_quality.sensitivity = local_getfield(ROC,'sensitivity',NaN);
    model_quality.accuracy = local_getfield(ROC,'accuracy',NaN);
    model_quality.accuracy_p = local_getfield(ROC,'accuracy_p',NaN);
    model_quality.accuracy_se = local_getfield(ROC,'accuracy_se',NaN);
    if isfield(ROC,'Gaussian_model') && isfield(ROC.Gaussian_model,'d_a')
        model_quality.Cohen_d = ROC.Gaussian_model.d_a;
    end
else
    threshold = local_default_threshold(PV);
    pred = PV >= threshold;
    label_metrics = local_confusion_metrics(double(truth),double(pred),struct('positiveClass',1));
    model_quality.AUC = local_auc_binary(truth,PV);
    model_quality.specificity = label_metrics.specificity;
    model_quality.sensitivity = label_metrics.sensitivity;
    model_quality.accuracy = label_metrics.accuracy;
    model_quality.accuracy_se = sqrt(model_quality.accuracy * (1 - model_quality.accuracy) / numel(truth));
    model_quality.Cohen_d = local_cohens_d(PV(truth),PV(~truth));
end

end

function pos_label = local_positive_label(labels,param)

labels = labels(:);
labels = labels(isfinite(labels));
u = unique(labels);
if isfield(param,'positiveClass') && any(u == param.positiveClass)
    pos_label = param.positiveClass;
elseif any(u == 1)
    pos_label = 1;
elseif isempty(u)
    pos_label = 1;
else
    pos_label = u(end);
end

end

function x = local_divide(a,b)

if b == 0
    x = NaN;
else
    x = a / b;
end

end

function v = local_getfield(S,fieldname,default_value)

if isfield(S,fieldname)
    v = S.(fieldname);
else
    v = default_value;
end

end

function threshold = local_default_threshold(scores)

if min(scores) >= 0 && max(scores) <= 1
    threshold = 0.5;
else
    threshold = 0;
end

end

function auc = local_auc_binary(truth,scores)

pos = scores(truth);
neg = scores(~truth);
if isempty(pos) || isempty(neg)
    auc = NaN;
    return
end
cmp = bsxfun(@minus,pos(:),neg(:)');
auc = (sum(cmp(:) > 0) + 0.5*sum(cmp(:) == 0)) / numel(cmp);

end

function d = local_cohens_d(pos,neg)

if numel(pos) < 2 || numel(neg) < 2
    d = NaN;
    return
end
sp = sqrt(((numel(pos)-1)*var(pos) + (numel(neg)-1)*var(neg)) / (numel(pos) + numel(neg) - 2));
if sp == 0
    d = NaN;
else
    d = (mean(pos) - mean(neg)) / sp;
end

end
