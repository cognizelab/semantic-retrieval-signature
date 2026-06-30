function model_quality = mat_assess_correlation(TV,PV,param)
%% regression
% accuracy: correlation between true value and predicted value
% p: p value from correlation
% MAE: mean absolute error
% R2: variance explained by the model
% RMSE: root mean square error

if nargin < 3 || isempty(param)
    param = struct();
end
if ~isfield(param,'corrtype') || isempty(param.corrtype)
    param.corrtype = 'Pearson';
end

model_quality.accuracy = NaN;
model_quality.p = NaN;
model_quality.MAE = NaN;
model_quality.R2 = NaN;
model_quality.RMSE = NaN;

if isempty(TV) || isempty(PV)
    return
end

TV = TV(:);
PV = PV(:);
n = min(numel(TV),numel(PV));
TV = TV(1:n);
PV = PV(1:n);

I = isfinite(TV) & isfinite(PV);
TV = TV(I);
PV = PV(I);

if isempty(TV)
    return
end

err = TV - PV;
model_quality.MAE = mean(abs(err));
denom = sum((TV - mean(TV)).^2);
if denom > 0
    model_quality.R2 = 1 - sum(err.^2)/denom;
end
model_quality.RMSE = sqrt(mean(err.^2));

u = unique(TV);
if numel(TV) < 2 || numel(u) < 2 || std(PV) == 0
    return
end

if numel(u) == 2
    model_quality.accuracy = local_auc(TV,PV);
    model_quality.p = NaN;
else
    try
        [model_quality.accuracy,model_quality.p] = corr(TV,PV,'Type',param.corrtype);
    catch
        model_quality.accuracy = corr(TV,PV);
        model_quality.p = NaN;
    end
end

end

function auc = local_auc(labels,scores)

labels = labels(:);
scores = scores(:);
u = unique(labels);
if any(u == 1)
    pos_label = 1;
else
    pos_label = u(end);
end
pos = scores(labels == pos_label);
neg = scores(labels ~= pos_label);
if isempty(pos) || isempty(neg)
    auc = NaN;
    return
end

cmp = bsxfun(@minus,pos(:),neg(:)');
auc = (sum(cmp(:) > 0) + 0.5*sum(cmp(:) == 0)) / numel(cmp);

end
