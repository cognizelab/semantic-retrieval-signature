function out = mat_report_classification(out,log)

results = {}; descriptions = {}; statistic = @(x) mean(x);

%% -------------------------------------------------- Descriptions ------------------------------------------------------------------
disp('Description:');
%%
currv = sprintf(['The %d folds cross-validation (CV) has been conducted for %d times.\n'], log.ocv);
descriptions = [descriptions;currv]; disp(currv);
disp('---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------');

%% -------------------------------------------------- Overall Model ------------------------------------------------------------------
disp('Overall model evaluation:');
%% accuracy
data = out.model_quality.accuracy;

if numel(data) > 2
    CI = bootci(1000, {statistic, data}, 'alpha', 0.05); 
    SE = std(data) / sqrt(length(data));    
    currv = sprintf(['The overall prediction-outcome accuracy is %.3f (averaged across repetations); the bootstrapped 95%% confidence interval (CI) is [%.3f, %.3f]; the standard error (SE) is %.2f.\n'], mean(data), CI, SE);
else
    currv = sprintf(['The overall prediction-outcome accuracy is %.3f (averaged across repetations)'], mean(data));
end

results = [results;currv]; disp(currv);

%% AUC
data = out.model_quality.AUC;

if numel(data) > 2
    CI = bootci(1000, {statistic, data}, 'alpha', 0.05); 
    SE = std(data) / sqrt(length(data));
    currv = sprintf(['The overall area Under the curve (AUC) is %.3f (averaged across repetations); the bootstrapped 95%% confidence interval (CI) is [%.3f, %.3f]; the standard error (SE) is %.2f.\n'], mean(data), CI, SE);
else
    currv = sprintf(['The overall area Under the curve (AUC) is %.3f (averaged across repetations)'], mean(data));    
end

results = [results;currv]; disp(currv);

%% Cohen's d 
data = out.model_quality.Cohen_d;

if numel(data) > 2
    CI = bootci(1000, {statistic, data}, 'alpha', 0.05); 
    SE = std(data) / sqrt(length(data));
    currv = sprintf(['The overall Cohen’s d is %.3f (averaged across repetations); the bootstrapped 95%% confidence interval (CI) is [%.3f, %.3f]; the standard error (SE) is %.2f.\n'], mean(data), CI, SE);
else
    currv = sprintf(['The overall Cohen’s d is %.3f (averaged across repetations)'], mean(data));
end

results = [results;currv]; disp(currv);

disp('---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------');

%% -------------------------------------------------- Model across Folds ------------------------------------------------------------------
disp('Fold-specific model evaluation:');
%% accuracy
data = out.model_quality.accuracy_folds;
CI = bootci(1000, {statistic, data}, 'alpha', 0.05); 
SE = std(data) / sqrt(length(data));

currv = sprintf(['The fold-specific prediction-outcome correlation coefficient (r) is %.3f (averaged across folds); the bootstrapped 95%% confidence interval (CI) is [%.3f, %.3f]; the standard error (SE) is %.2f.\n'], mean(data), CI, SE);
results = [results;currv]; disp(currv);

%% AUC
data = out.model_quality.AUC_folds;
CI = bootci(1000, {statistic, data}, 'alpha', 0.05); 
SE = std(data) / sqrt(length(data));

currv = sprintf(['The fold-specific area Under the curve (AUC) is %.3f (averaged across folds); the bootstrapped 95%% confidence interval (CI) is [%.3f, %.3f]; the standard error (SE) is %.2f.\n'], mean(data), CI, SE);
results = [results;currv]; disp(currv);

%% Cohen's d 
data = out.model_quality.Cohen_d_folds;
CI = bootci(1000, {statistic, data}, 'alpha', 0.05); 
SE = std(data) / sqrt(length(data));

currv = sprintf(['The fold-specific Cohen’s d is %.3f (averaged across folds); the bootstrapped 95%% confidence interval (CI) is [%.3f, %.3f]; the standard error (SE) is %.2f.\n'], mean(data), CI, SE);
results = [results;currv]; disp(currv);

disp('---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------');

%%
out.results = results;
out.descriptions = descriptions;