function [out,log] = mat_cv(x,y,c,model,cv,param)
%% MAT Cross-validation Framework <Core>
%% -------------------------------------------------------------------------------------------------------------------------------
%% Input
%  (1) x: subjects * features of interest (double) 
%  (2) y: subjects * target variable 
%  (3) c: subjects * covariates to be controlled
%                 <covariate handling is controlled by param.covariateMode>
%  (4) model: model selection
%             # regression
%             >>> 'lm', linear regression --- [doc model_lm] 
%             >>> 'ridge', ridge regression --- [doc model_ridge]
%             >>> 'krr', kernel ridge regression --- [doc model_krr]   
%             >>> 'rvr', relevant vector regression --- [doc model_rvr]   
%             >>> 'svr', support vector regression --- [doc model_svr]   
%             # classification
%             >>> 'svm', support vector machine --- [doc model_svm]      
%             # compatible
%             >>> 'tpls', thresholded partial least squares --- [doc model_tpls]     
%  (5) cv: cross-validation setting
%             -- cv(1), number of folds in outer CV
%                                   >>> 1, no cross-validation
%                                   >>> [] or cv(1) = size(data,1), leave-one-out cross-validation (LOOCV)
%                                   >>> K ∩ 1<K<size(data,1), K-folds
%             -- cv(2), repetation time in outer CV 
%                    [note, if "cv(2)==0", the subsets will be arranged according to the order of y]
%  (6) param: corresponding parameters
%          <a> process monitoring
%             -- param.text, if report progress information
%                                   >>> 1 = YES; 0 = NO   
%             -- param.progress, if display progress bar
%                                   >>> 1 = YES (default)
%                                   >>> 0 = NO  
%             -- param.savefolds, if save outcomes in each fold
%                                   >>> 1 = YES (default)   
%                                   >>> 0 = NO  
%             -- param.savelarge, if save process files
%                                   >>> 1 = YES 
%                                   >>> 0 = NO (default)     
%          ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%          <b> data manipulation
%             -- param.covariateMode, covariate handling strategy
%                                   >>> 'auto' = regression uses 'residualizeY';
%                                                classification uses 'residualizeX' (default)
%                                   >>> 'none' = do not use covariates
%                                   >>> 'residualizeY' = regress covariates from y
%                                   >>> 'residualizeX' = regress covariates from x
%                                   >>> 'residualizeXY' = regress covariates from both x and y
%                                   >>> 'includeCovariates' = append covariates to x
%                                   >>> 'residualizeY_addBack' = train on y residuals
%                                                and add the covariate baseline back to predictions
%                                   Note: y-residualization modes are for regression.
%                                   Classification uses x-side control by default.
%             -- param.scale, if scale the variates
%                                   >>> 1 = YES (default)
%                                   >>> 0 = NO  
%             -- param.interp, data cleaning
%                                   >>> 0 = NO (default) 
%                                   >>> 1 = YES-interpolate missing values with the median 
%                                   >>> 2 = YES-simply remove data with any missing value 
%             -- param.random, randomize data
%                                   >>> = 0 --- non-execution (default)   
%                                   >>> = 1 --- randomize data before cross-validation  
%                                   >>> = 2 --- randomize data before repetition   
%                                   >>> = 3 --- randomize data separately for trainning and test sets 
%             -- param.corrtype, correlation type
%                                   >>> 'Pearson' (default)   
%                                   >>> 'Spearman'  
%             -- param.ID, participant ID
%          ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%          <c> parameter optimization
%             -- param.po, parameter optimization methods
%                                   >>> = 0 --- non-execution        
%                                   >>> = 1 --- accuracy (r)
%                                   >>> = 2 --- mean absolute error (MAE) or AUC
%                                   >>> = 3 --- absolute Pearson's correlation between feature weights
%                                   >>> = 4 --- corrected pairwise overlap
%                                   >>> = 5 --- accuracy (r) + absolute correlation between feature weights (default)
%                                   >>> = 6 --- accuracy (r) + corrected pairwise overlap
%                                   >>> = 7 --- MAE/AUC + absolute correlation between feature weights (default)
%                                   >>> = 8 --- MAE/AUC + corrected pairwise overlap
%             -- param.po_folds, define how to evaluate the performance of parameter optimization
%                                   >>> 1 = evaluation metric will be calculated in each fold and averaged across all folds 
%                                   >>> 0 = evaluation metric is calculated based on the merged data of all folds (default)  
%             -- param.icv, setting of inner cross-validation for parameter optimization (same rule as outer CV, default = [5 3])
%             -- param.iscale, if scale the features within inner cross-validation
%                                   >>> 1 = YES (default)
%                                   >>> 0 = NO  
%             -- param.samerule, if kee the same rule as outer cross-validation
%                                   >>> 1 = YES (default)
%                                   >>> 0 = NO  
%          ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%          <d> cross-validation strategy
%             -- param.groupCV, numerical label for group-based cross-validation
%             -- param.groupCVinner, numerical label for inner loop of group-based cross-validation
%             -- param.stratifyCV, numerical label for stratified cross-validation 
%             -- param.keepOrder, if the data for each fold is determined based on the order of y
%                                   >>> 1 = YES 
%                                   >>> 0 = NO (default) 
%             -- param.indexCV, enter a given CV folds (if not, folds will be randomly assigned)
%                                   >>> [] = NO (default)  
%          ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%          <e> 'virtual lesion' analysis  
%             -- param.mask, a set of numerical indices corresponding exactly to the features, 
%                            specifying the group of variables of interest to be examined   
%          ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Output
%  (1) out 
%          <a> out.feature_weight: the feature weights generated in multiple runs.
%          <b> TV/PV: true and predicted values in each loop
%          <c> out.model_quality
%             -- accuracy_correlation, correlation between true and predicted values in each loop (regression momdel)
%             -- R2, coefficient of determination in each loop (regression momdel)
%             -- MAE, mean absolute rrror between true and predicted values in each loop (regression momdel)
%             -- RMSE, root mean square error between true and predicted values in each loop (regression momdel)
%             -- pattern_similarity, the similarity of the model between multiple runs
%             -- pattern_overlap, the overlap rate of non-zero features
%             -- pattern_overlap_corrected, the corrected overlap rate of non-zero features
%             -- accuracy_correlation_folds, average correlation between true and predicted values across folds in each loop (regression momdel)
%             -- R2_folds, average coefficient of determination across folds in each loop (regression momdel)
%             -- MAE_folds, average mean absolute rrror between true and predicted values across folds in each loop (regression momdel)
%             -- RMSE_folds, average root mean square error between true and predicted values across folds in each loop (regression momdel)
%          <d> out.parameter_label: the label of the hyperparameters in the model    
%          <e> out.opt_parameter: selected parameters in each fold    
%          <f> out.parameter_optimization: complete parameter optimization results
%          <g> out.outcomes_each_fold: the actual values and predicted values in each fold.
%          <h> out.assessment_each_fold: the model evaluation results in each fold
%          <i> out.virtual_lesion_analysis: results from virtual 'lesion' analysis
%  (2) log 
%          <a> log.param: input parameters
%          <b> log.data
%             -- log.data.xgood, features (columns) retained in x
%             -- log.data.ygood, features (columns) retained in y
%             -- log.data.cgood, features (columns) retained in y
%             -- log.data.row_removed, deleted data points (row numbers)
%          <c> log.folds
%             -- log.folds.cv, number of cross-validations
%             -- log.folds.index, index of the subject in cross-validation
%          <d> log.ID: subject ID in each fold
%% Dependency
%% -------------------------------------------------------------------------------------------------------------------------------
% - Z.K.X. 2023/09/27 (MATLAB R2022b)
%% -------------------------------------------------------------------------------------------------------------------------------

%% -------------------------------------------------- Default SETTING ------------------------------------------------------------------
%% Default Setting
if nargin < 6; param = []; end
param = set_params(model,param); out = struct;

if nargin < 5
    cv = [5 10];
elseif isempty(cv)
    if ~isempty(param.groupCV)
        cv(1) = length(unique(param.groupCV)); cv(2) = 1;
    else
        cv(1) = size(x,1); cv(2) = 1;
    end    
else
    if numel(cv)<2; cv(2) = 1; end
end

if cv(2) == 0
    param.keepOrder = 1;
    cv(2) = 1;
end

log.ocv = cv;

%% -------------------------------------------------- Data Manipulation ------------------------------------------------------------------
%% Data Filtering
log.model = model; ID = [];
opt_parameter = [];
opt_records = [];
out_train = cell(0);
out_apply = cell(0);
out_assess = cell(0);
out_assess_full = cell(1,cv(2));
out_lesion = cell(0);

if param.interp > 0
    [x, log.data.xgood,f1] = mat_data_filtering(x, param.interp, 0.1); y(f1,:) = []; 
    [y, log.data.ygood,f2] = mat_data_filtering(y, 0, 0.1); x(f2,:) = [];    
    log.removed_xy.first_step = f1; log.removed_xy.second_step = f2;  
    
    if isfield(param,'mask') && ~isempty(param.mask)
        fr = find(log.data.xgood==0); param.mask(fr) = [];        
    end

    if ~isempty(c)
        c(f1,:) = []; c(f2,:) = [];
    end
    
    if ~isempty(c)
        [c, log.data.cgood,f3] = mat_data_filtering(c, 1, 1);
    else
        log.data.cgood = [];
        f3 = [];
    end
    
    if ~isempty(param.ID) && size(param.ID,1) ~= size(x,1)
        param.ID(f1,:) = []; param.ID(f2,:) = [];
    end
    if ~isempty(param.groupCV) && size(param.groupCV,1) ~= size(x,1)
        param.groupCV(f1,:) = []; param.groupCV(f2,:) = [];
    end
    if ~isempty(param.groupCVinner) && size(param.groupCVinner,1) ~= size(x,1)
        param.groupCVinner(f1,:) = []; param.groupCVinner(f2,:) = [];
    end    
    if ~isempty(param.stratifyCV) && size(param.stratifyCV,1) ~= size(x,1)
        param.stratifyCV(f1,:) = []; param.stratifyCV(f2,:) = [];
    end
    if ~isempty(param.indexCV) && size(param.indexCV,1) ~= size(x,1)
        param.indexCV(f1,:) = []; param.indexCV(f2,:) = [];
    end
end

if any(isnan(x(:)) | isinf(x(:))) 
    warning('The current data x contains NaN or Inf. Please clean the data before allowing the program to run. Alternatively, you can set param.interp to 1, which will allow the program to automatically interpolate these variables.');
    return
elseif any(isnan(y(:)) | isinf(y(:)))
    warning('The current data y contains NaN or Inf. Please clean the data before allowing the program to run. Alternatively, you can set param.interp to 1, which will allow the program to automatically interpolate these variables.');
    return    
elseif any(isnan(c(:)) | isinf(c(:)))
    warning('The current data c contains NaN or Inf. Please clean the data before allowing the program to run. Alternatively, you can set param.interp to 1, which will allow the program to automatically interpolate these variables.');
    return    
end

[param.covariateModeResolved, param.covariateModeRequested, ...
    param.covariateModeApplied] = ...
    resolve_covariate_mode(model, y, param, c);
log.covariateMode.requested = param.covariateModeRequested;
log.covariateMode.resolved = param.covariateModeResolved;
log.covariateMode.applied = param.covariateModeApplied;

%% Data Packing
[index,cv] = mat_sample(x,y,c,cv,param);
log.folds.cv = cv; log.folds.index = index; 
log.ocv = cv;
param.nSubjectCV = size(x, 1);

%% Data Permutation
if param.random == 1 
    if isempty(param.groupCV)
        y = y(randperm(size(y,1)),:);
    else
        id = unique(param.groupCV);  
        for i = 1:length(id)
            f = find(param.groupCV==id(i)); curr = y(f); y(f) = curr(randperm(length(curr)));
        end
    end
elseif param.random > 1
    Y = y;    
end
    
%% Process Begins
if  param.text == 1; disp('--------- Cross Validation ---------'); end
if  param.progress == 1
    mwb('CLOSEALL');
    mwb( 'Total Progress', 0, 'CancelFcn', @(a,b) disp( ['Cancel ',a] ), 'Color', 'b');
end

%% -------------------------------------------------- Cross Validation ------------------------------------------------------------------
%% Repetition ★★★
for n = 1:cv(2) 
    if  param.progress == 1
        label = ['CV:',num2str(n,'%02d')];
        mwb(label, 0, 'CancelFcn', @(a,b) disp( ['Cancel ',a] ), 'Color', 'r');
    end
    % n = 1
    if param.random == 2
        y = Y(randperm(size(Y,1)),:);
    end 
    idx = index(:,n); id = [];
    fold_values = unique(idx(~isnan(idx)));
    if isempty(fold_values)
        error('mat_cv:InvalidCVIndex','No valid fold labels were found in the cross-validation index.');
    end
    n_folds = numel(fold_values);
% ------------------------------------------------------------------------------------------------------
%% Outer CV ★★★
% ------------------------------------------------------------------------------------------------------
    for k = 1:n_folds
        % data allocation
        fold_value = fold_values(k);
        if n_folds == 1 && fold_value == 0
            ftest = (1:size(x,1))';
            ftrain = ftest;
        else
            ftest = find(idx==fold_value);
            ftrain = find(idx~=fold_value & ~isnan(idx));
        end
        param.ftest = ftest; param.ftrain = ftrain;
        xtest = x(ftest,:); ytest = y(ftest,:); 
        xtrain = x(ftrain,:); ytrain = y(ftrain,:); 
        if ~isempty(param.ID); id = [id;param.ID(ftest,:)]; log.ID{k,n} = param.ID(ftest,:); end
        if param.random == 3
            f1 = randperm(size(ytest,1)); ytest = ytest(f1,:);               
            f2 = randperm(size(ytrain,1)); ytrain = ytrain(f2,:); 
        end                
        % fold-wise covariate handling
        ctrain = []; ctest = [];
        if ~isempty(c)
           ctest = c(ftest,:); ctrain = c(ftrain,:);
           if param.random == 3; ctest = ctest(f1,:); ctrain = ctrain(f2,:); end
        end
        [xtrain,ytrain,xtest,ytest,covariateInfo] = ...
            apply_covariate_mode(xtrain,ytrain,ctrain,xtest,ytest, ...
            ctest,param,model);
        log.covariateMode.fold{k,n}.applied = covariateInfo.applied;
        log.covariateMode.fold{k,n}.addBack = covariateInfo.addBack;
        % feature scaling 
        if param.scale == 1 
            [xtrain,xtest] = mat_scale(xtrain,xtest); 
        end
        % parameter optimization  
        if param.po > 0
            [opt_parameter{k,n},opt_records{k,n},param] = get_opt_params(xtrain,ytrain,model,param);
            do_parameter = opt_parameter{k,n};
        else
            do_parameter = get_default_params(model,param);
        end   
        % model training  
        [out_train{k,n},temporary_file] = train_model(xtrain,ytrain,model,do_parameter,param);
        % model generalization
        out_apply{k,n} = apply_model(xtest,ytest,model,out_train{k,n},temporary_file);
        out_apply{k,n} = apply_covariate_addback(out_apply{k,n},covariateInfo);
        out_apply{k,n}.subject_index = ftest(:);
        out_apply{k,n}.n_subject = size(x, 1);
        % model evaluation (fold level)
        out_assess{k,n} = assess_model(out_apply{k,n},model,param);
        % 'virtual lesion' analysis
        out_lesion{k,n} = [];
        if isfield(param,'mask') && ~isempty(param.mask)
            ytest_lesion = ytest;
            if covariateInfo.addBack && ~isempty(covariateInfo.yTestResidual)
                ytest_lesion = covariateInfo.yTestResidual;
            end
            result_lesion_analysis = mask_lesion(xtest,ytest_lesion,model,out_train{k,n},temporary_file,param);
            if ~isempty(result_lesion_analysis); out_lesion{k,n} = result_lesion_analysis; end
        end
        % loop labels
        if  param.text == 1; disp(['--------->>> Repetition: ',num2str(n),'; Folds: ',num2str(k)]); end 
        if  param.progress == 1; mwb(label, k/n_folds); end
        if  param.text == 1
            disp(['The accuracy in current fold: ',num2str(get_display_accuracy(out_assess{k,n}))]);
            disp('-------------------------------------');
        end
    end 
% ------------------------------------------------------------------------------------------------------
%% Model Assessment ★★★
% ------------------------------------------------------------------------------------------------------   
    [TV,PV,PW] = collect_ordered_outcomes(out_apply(:,n), size(x, 1));
    out_assess_full{n} = assess_model([TV,PV,PW],model,param);
    if  param.progress == 1; mwb('Total Progress', n/cv(2)); mwb(label,'Close'); end
    if ~isempty(param.ID)
        if isnumeric(id) || islogical(id)
            ID(:,n) = id;
        else
            if ~iscell(ID); ID = cell(1,cv(2)); end
            ID{n} = id;
        end
    end
end

%% -------------------------------------------------- Result Report ------------------------------------------------------------------
%% Result Organization
out = organize_results(model,opt_parameter,opt_records,out_train,out_apply,out_assess,out_assess_full,param,out_lesion);
out.ID = ID; log.param = param; 
if  param.progress == 1; mwb('CloseAll'); end

end

function value = get_display_accuracy(out_assess)

value = NaN;
if isfield(out_assess,'accuracy')
    value = out_assess.accuracy;
elseif isfield(out_assess,'W') && isfield(out_assess.W,'accuracy')
    value = out_assess.W.accuracy;
elseif isfield(out_assess,'B') && isfield(out_assess.B,'accuracy')
    value = out_assess.B.accuracy;
end

end
