function out = mat_report_correlation(out,log)

results = {}; descriptions = {}; statistic = @(x) mean(x);

n = numel(out.assessment_each_fold);
v_accuracy = cellfun(@(s) s.accuracy, out.assessment_each_fold).';
v_MAE      = cellfun(@(s) s.MAE,      out.assessment_each_fold).';
v_R2       = cellfun(@(s) s.R2,       out.assessment_each_fold).';
v_RMSE     = cellfun(@(s) s.RMSE,     out.assessment_each_fold).';

%% -------------------------------------------------- Descriptions ------------------------------------------------------------------
disp('Description:');
%%
currv = sprintf(['The %d folds cross-validation (CV) has been conducted for %d times.\n'], log.ocv);
descriptions = [descriptions;currv]; disp(currv);
disp('---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------');

%% -------------------------------------------------- Overall Model ------------------------------------------------------------------
disp('Overall model evaluation:');
%% r
data = out.model_quality.accuracy_correlation;
try
    CI = bootci(1000, {statistic, data}, 'alpha', 0.05); 
    SE = std(data) / sqrt(length(data));
    
    currv = sprintf(['The overall prediction-outcome correlation coefficient (r) is %.3f (averaged across repetations); the bootstrapped 95%% confidence interval (CI) is [%.3f, %.3f]; the standard error (SE) is %.2f.\n'], mean(data), CI, SE);
    results = [results;currv]; disp(currv);
catch
    currv = sprintf(['The overall prediction-outcome correlation coefficient (r) is %.3f (averaged across repetations)'], mean(data));
end

results = [results;currv]; disp(currv);

%% r2
data = out.model_quality.R2;
try
    CI = bootci(1000, {statistic, data}, 'alpha', 0.05); 
    SE = std(data) / sqrt(length(data));
    
    currv = sprintf(['The overall prediction-outcome explained variance score (EVS, r2) is %.3f (averaged across repetations); the bootstrapped 95%% confidence interval (CI) is [%.3f, %.3f]; the standard error (SE) is %.2f.\n'], mean(data), CI, SE);
catch
    currv = sprintf(['The overall coefficient of determination (EVS, r2) is %.3f (averaged across repetations)'], mean(data));
end

results = [results;currv]; disp(currv);

%% MAE
data = out.model_quality.MAE;
try
    CI = bootci(1000, {statistic, data}, 'alpha', 0.05); 
    SE = std(data) / sqrt(length(data));
    
    currv = sprintf(['The overall prediction-outcome mean absolute error (MAE) is %.3f (averaged across repetations); the bootstrapped 95%% confidence interval (CI) is [%.3f, %.3f]; the standard error (SE) is %.2f.\n'], mean(data), CI, SE);
catch
    currv = sprintf(['The overall prediction-outcome mean absolute error (MAE) is %.3f (averaged across repetations)'], mean(data));
end

results = [results;currv]; disp(currv);

%% RMSE
data = out.model_quality.RMSE;
try
    CI = bootci(1000, {statistic, data}, 'alpha', 0.05); 
    SE = std(data) / sqrt(length(data));
    
    currv = sprintf(['The overall prediction-outcome root mean squared error (RMSE) is %.3f (averaged across repetations); the bootstrapped 95%% confidence interval (CI) is [%.3f, %.3f]; the standard error (SE) is %.2f.\n'], mean(data), CI, SE);
catch
    currv = sprintf(['The overall prediction-outcome root mean squared error (RMSE) is %.3f (averaged across repetations)'], mean(data));    
end

results = [results;currv]; disp(currv);

disp('---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------');

%% -------------------------------------------------- Model across Folds ------------------------------------------------------------------
disp('Fold-specific model evaluation:');
%% r
data = out.model_quality.accuracy_correlation_folds;
try
    CI = bootci(1000, {statistic, data}, 'alpha', 0.05); 
    SE = std(data) / sqrt(length(data));
    
    currv = sprintf(['The fold-specific prediction-outcome correlation coefficient (r) is %.3f (averaged across folds); the bootstrapped 95%% confidence interval (CI) is [%.3f, %.3f]; the standard error (SE) is %.2f.\n'], mean(data), CI, SE);
catch
    currv = sprintf(['The fold-specific prediction-outcome correlation coefficient (r) is %.3f (averaged across folds); the standard error (SE) is %.3f'], mean(v_accuracy), std(v_accuracy, 'omitnan') / sqrt(sum(~isnan(v_accuracy))));
end

results = [results;currv]; disp(currv);


%% r2
data = out.model_quality.R2_folds;
try
    CI = bootci(1000, {statistic, data}, 'alpha', 0.05); 
    SE = std(data) / sqrt(length(data));
    
    currv = sprintf(['The fold-specific prediction-outcome explained variance score (EVS, r2) is %.3f (averaged across folds); the bootstrapped 95%% confidence interval (CI) is [%.3f, %.3f]; the standard error (SE) is %.2f.\n'], mean(data), CI, SE);
catch
    currv = sprintf(['The fold-specific coefficient of determination (EVS, r2) is %.3f (averaged across folds); the standard error (SE) is %.3f'], mean(v_R2), std(v_R2, 'omitnan') / sqrt(sum(~isnan(v_R2))));    
end

results = [results;currv]; disp(currv);


%% MAE
data = out.model_quality.MAE_folds;
try
    CI = bootci(1000, {statistic, data}, 'alpha', 0.05); 
    SE = std(data) / sqrt(length(data));
    
    currv = sprintf(['The fold-specific prediction-outcome mean absolute error (MAE) is %.3f (averaged across folds); the bootstrapped 95%% confidence interval (CI) is [%.3f, %.3f]; the standard error (SE) is %.2f.\n'], mean(data), CI, SE);
catch
    currv = sprintf(['The fold-specific prediction-outcome mean absolute error (MAE) is %.3f (averaged across folds); the standard error (SE) is %.3f'], mean(v_MAE), std(v_MAE, 'omitnan') / sqrt(sum(~isnan(v_MAE))));    
end

results = [results;currv]; disp(currv);

%% RMSE
data = out.model_quality.RMSE_folds;
try
    CI = bootci(1000, {statistic, data}, 'alpha', 0.05); 
    SE = std(data) / sqrt(length(data));
    
    currv = sprintf(['The fold-specific prediction-outcome root mean squared error (RMSE) is %.3f (averaged across folds); the bootstrapped 95%% confidence interval (CI) is [%.3f, %.3f]; the standard error (SE) is %.2f.\n'], mean(data), CI, SE);
catch
    currv = sprintf(['The fold-specific prediction-outcome root mean squared error (RMSE) is %.3f (averaged across folds); the standard error (SE) is %.3f'], mean(v_RMSE), std(v_RMSE, 'omitnan') / sqrt(sum(~isnan(v_RMSE))));    
end

results = [results;currv]; disp(currv);

disp('---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------');

%%
out.results = results;
out.descriptions = descriptions;