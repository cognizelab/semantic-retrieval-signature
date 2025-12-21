function model_quality = mat_assess_correlation(TV,PV,param)
%% regression
% accuracy: correlation between true value and predicted value
% p: p value from correlation
% MAE: mean absolute error 
% R2: variance explained by the model 
% RMSE: root mean square error
%% classification

if ~isfield(param,'corrtype') || isempty(param.corrtype)
    param.corrtype = 'Pearson';  
end

if isempty(TV) | isempty(PV)
    accuracy = 1; p = 1;
    return;
end

if numel(unique(TV)) == 2
    accuracy = plot_roc(PV,TV);
    p = 1;
else
    [accuracy,p] = corr(TV,PV,'Type',param.corrtype);
end

MAE = mae(TV - PV);
R2 = 1 - sum((TV - PV).^2)/sum((TV - mean(TV)).^2);
% R2 = 1 - (var(TV - PV)/var(TV));
I = ~isnan(TV) & ~isnan(PV); TV = TV(I); PV = PV(I);
RMSE = sqrt(sum((TV(:)-PV(:)).^2)/numel(TV));
model_quality.accuracy = accuracy; model_quality.p = p; model_quality.MAE = MAE; model_quality.R2 = R2; model_quality.RMSE = RMSE; 