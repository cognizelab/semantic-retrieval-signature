function out = mat_RFE(x,y,c,model,cv,param,varargin)
%% Recursive Feature Elimination (RFE)
%% -------------------------------------------------------------------------------------------------------------------------------
%% Input
%  (1) x: subjects * features of interest (double) 
%  (2) y: subjects * target variable 
%  (3) c: subjects * covariates to be controled
%                 <regress covariates (e.g. head motion) from y (target variable)>
%  (4) model: model selection (see 'mat_cv.m')
%  (5) cv: cross-validation setting (see 'mat_cv.m')
%  (6) param: corresponding parameters (see 'mat_cv.m')
%  (7) additional inputs
%      -- n_removal, the number of features to be removed in each iteration
%                    (defult, 'n_removal', 10000)
%      -- n_finalfeat, the final number of features after elimination
%                    (defult, 'n_finalfeat', 50000)
%      -- n_initialfeat, the number of features, from which the algorithm
%                        starts the elimination by the defined step
%                    (defult, 'n_finalfeat', 100000)
%% Output
%  (1) out 
%      -- out.best_accuracy, best trial accuracy   
%      -- out.best_n_features, number of features retained in the best trial
%      -- out.cv_accuracy, accuracy of each trial
%      -- out.n_features, number of features in each trial
%         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%      -- out.bestaccuracy_stats, model outputs of the best trial
%      -- out.bestaccuracy_weight, feature weights of the best trial   
%      -- out.smallestnfeat_stats, model outputs of the final trial   
%      -- out.smallestnfeat_weight, feature weights of the final trial     
%         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%      -- out.whkeep_orginal_idx, feature indices of each trial (position in the original features)
%      -- out.removed_index, feature indices removed in each trial 
%% -------------------------------------------------------------------------------------------------------------------------------
%% Description
%  This function performs Recursive Feature Elimination (RFE). 
%  It returns details of each elimination step and a model trained on the number of features that shows the best accuracy.
%  - Repeatedly trains a desired model and eliminates least significant weights until a desired number of features is reached.       
%  - Elimination step and target number of features can be defined by user.
%  - Evaluates accuracy in each iteration.
%  Originally created by Lada Kohoutova (2/19/2019)
%% -------------------------------------------------------------------------------------------------------------------------------
% - Z.K.X. 2024/05/18 (MATLAB R2022b)
%% -------------------------------------------------------------------------------------------------------------------------------

%% Default setting
n_removal = 10000;
n_finalfeat = 50000;
init_feat = 0;

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            case 'n_removal'
                n_removal = varargin{i+1};
                varargin{i+1} = [];
            case 'n_finalfeat'
                n_finalfeat = varargin{i+1};
                varargin{i+1} = [];
            case 'n_initialfeat'
                n_initialfeat = varargin{i+1};
                init_feat = 1;
                varargin{i+1} = [];
        end
    end
end

data_dim = size(x,2);  
mask = zeros(data_dim,1);
orig_indx = 1:data_dim;  
out.descending_indx = [];
out.whkeep_orginal_idx{1} = orig_indx;
out.removed_index{1} = [];
dat_loop = x;  
i = 1;

param.progress = 0;
param.text = 0;

%% The first iteration
if init_feat == 1 
    
    n_initremoval = data_dim - n_initialfeat;    % calculate how many features to remove
    
    str = sprintf('Initial training with all features...');
    fprintf('%s\n', str);
    
    [OUT,log] = mat_cv(dat_loop,y,c,model,cv,param);

    try
        out.cv_accuracy(i,1) = OUT.model_quality.accuracy; 
    catch
        out.cv_accuracy(i,1) = OUT.model_quality.accuracy_correlation; 
    end    

    out.n_features(i,1) = size(dat_loop,2);    
    w = mean(OUT.feature_weight,2);
 
    w = abs(w);
    [~, out.ascending_idx{i}] = sort(w);
    ordered_orig_indx = orig_indx(out.ascending_idx{i});
    out.descending_indx = [ordered_orig_indx(1:n_initremoval) out.descending_indx];  % keeping ordered indices
    out.removed_index{i+1} = ordered_orig_indx(1:n_initremoval);
    
    % removal
    remove_idx = out.ascending_idx{i}(1:n_initremoval);
    dat_loop(:,remove_idx) = [];  
    
    orig_indx(out.ascending_idx{i}(1:n_initremoval)) = []; % clear removed original indices
    out.whkeep_orginal_idx{i+1} = orig_indx;    % save kept original indices
    
    data_dim = data_dim - n_initremoval;  % reduce the dimension
    
    fprintf('\n');
    str = sprintf('Eliminated %d features.', n_initremoval);
    fprintf('%s\n', str);
    
    i = i+1;
    
end

%% RFE
while 1
    
    str = sprintf('Training with %d features...', data_dim); fprintf('%s\n', str);
    
    [OUT,log] = mat_cv(dat_loop,y,c,model,cv,param);
    
    % collecting outputs (weights, accuracy) from training   
    try
        out.cv_accuracy(i,1) = OUT.model_quality.accuracy; 
    catch
        out.cv_accuracy(i,1) = OUT.model_quality.accuracy_correlation; 
    end

    out.n_features(i,1) = size(dat_loop,2);    
    w = mean(OUT.feature_weight,2);
    
    if out.n_features(i) <= n_finalfeat, break, end
    
    w = abs(w);
    [~, out.ascending_idx{i}] = sort(w);               % sorting weights in ascending order
    
    if data_dim-n_removal < n_finalfeat, n_removal = data_dim-n_finalfeat; end   % condition for the final removal
    
    ordered_orig_indx = orig_indx(out.ascending_idx{i});
    out.descending_indx = [ordered_orig_indx(1:n_removal) out.descending_indx];  % keeping ordered indices
    out.removed_index{i+1} = ordered_orig_indx(1:n_removal);
    
    % removal
    remove_idx = out.ascending_idx{i}(1:n_removal);
    dat_loop(:,remove_idx) = [];   
    
    orig_indx(out.ascending_idx{i}(1:n_removal)) = []; % clear removed original indices
    out.whkeep_orginal_idx{i+1} = orig_indx;    % save kept original indices
    
    data_dim = data_dim - n_removal;  % reduce the dimension
    
    fprintf('\n');
    str = sprintf('Eliminated %d features.', n_removal);
    fprintf('%s\n', str);
    
    % rerun predict
    i = i + 1;
    
end

out.descending_indx = [orig_indx out.descending_indx];

out.smallestnfeat_stats = OUT;  % save stats of the smallest model
indxToRemove = [];
for i=1:length(out.cv_accuracy)
    indxToRemove = [out.removed_index{i} indxToRemove];
end
 
feature_weight = mask;
feature_weight(out.whkeep_orginal_idx{end}) = mean(OUT.feature_weight,2);
out.smallestnfeat_weight = feature_weight;

[max_acc, max_idx] = max(out.cv_accuracy);

out.best_n_features = out.n_features(max_idx);    
out.best_accuracy = max_acc;   

x = x(:,out.whkeep_orginal_idx{max_idx});

fprintf('\n');
str = sprintf('Training the final model...');
fprintf('%s\n', str);

[OUT,log] = mat_cv(x,y,c,model,cv,param);

out.bestaccuracy_stats = OUT;

indxToRemove = [];
for i=1:max_idx
    indxToRemove = [out.removed_index{i} indxToRemove];
end

feature_weight = mask;
feature_weight(out.whkeep_orginal_idx{max_idx}) = mean(OUT.feature_weight,2);
out.bestaccuracy_weight = feature_weight;

end