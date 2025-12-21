function [premodel,out_apply,Data] = mat_model_applly(premodel,xtrain,ytrain,model,param,varargin)

%% Default Setting
N = 10000; p_type = 'nan'; p = 0.05;
ctrain = []; xtest = []; ytest = []; ctest = [];

if isempty(premodel)
    premodel = 'zmap'; % 'weight' or double array of pre-trained model
end

if nargin < 5; param = []; end
param = set_params(model,param);  
param.groupCV = []; param.stratifyCV = []; 

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            case {'N'}
                N = varargin{i+1};
            case {'p_unc'}  
                p_type = 'p_unc';         
            case {'FDR'}  
                p_type = 'FDR';                     
            case {'pvalue'}
                p = varargin{i+1};                       
            case {'ctrain'}
                ctrain= varargin{i+1};           
            case {'xtest'}
                xtest= varargin{i+1};        
            case {'ytest'}
                ytest= varargin{i+1};     
            case {'ctest'}
                ctest= varargin{i+1};                       
        end
    end
end

%% Data Preparation
% data filtering
if param.interp > 0
    [xtrain,~,f1] = mat_data_filtering(xtrain, param.interp, 0.1); ytrain(f1,:) = []; 
    [ytrain,~,f2] = mat_data_filtering(ytrain, 0, 0.1); xtrain(f2,:) = []; 
    if ~isempty(ctrain)  
        ctrain(f1,:) = []; ctrain(f2,:) = [];
    end
    
    if ~isempty(xtest)  
        [xtest,~,f1] = mat_data_filtering(xtest, param.interp, 0.1); ytest(f1,:) = [];
        [ytest,~,f2] = mat_data_filtering(ytest, 0, 0.1); xtest(f2,:) = [];  
        if ~isempty(ctest)  
            ctest(f1,:) = []; ctest(f2,:) = [];
        end
    end
end

% covariates regression  
if param.covariates > 0 && ~isempty(ctrain) && ~isempty(ctest) 
   ctest = c(ftest,:); ctrain = c(ftrain,:); 
   if param.covariates == 1 
      [ytrain,ytest] = mat_regress_xy(ctrain,ctest,ytrain,ytest);
   elseif param.covariates == 2 
      [xtrain,xtest] = mat_regress_xy(ctrain,ctest,xtrain,xtest);
   end
end     

% feature scaling 
if param.scale == 1 
    [xtrain,xtest] = mat_scale(xtrain,xtest); 
end

% parameter optimization  
if param.po > 0 && ~isa(premodel, 'double')
    [opt_parameter,opt_records,param] = get_opt_params(xtrain,ytrain,model,param);
    do_parameter = opt_parameter;
    disp('Parameter optimization has been performed.');
    disp(['Model training was based on the parameter value: ',num2str(do_parameter)]);    
else
    opt_parameter = []; opt_records = [];
    do_parameter = get_default_params(model,param);
    disp('Parameter optimization was not performed.');
    disp(['Model training was based on the parameter value: ',num2str(do_parameter)]);
end  

Data.xtrain = xtrain; Data.ytrain = ytrain; Data.ctrain = ctrain;
Data.xtest = xtest; Data.ytest = ytest; Data.ctest = ctest;

%% Model Training & Generalization
if isa(premodel, 'double') 
    f = find(~isnan(premodel));
    out_apply.pv = xtest(:,f)*premodel(f);
    out_apply.tv = ytest;
else    
    if strcmp(premodel,'weight')
        % model training  
        [out_train,temporary_file] = train_model(xtrain,ytrain,model,do_parameter,param);
        premodel = out_train.feature_weight;
        % model generalization
        if ~isempty(xtest) & ~isempty(ytest)
            out_apply = apply_model(xtest,ytest,model,out_train,temporary_file);
        else
            out_apply = [];
        end
    elseif strcmp(premodel,'zmap')
        in = [1:size(xtrain,1)]'; s = size(in);  
        for n = 1:N
            f = in(ceil(max(s)*rand(max(s),1)));    
            bx = xtrain(f,:); by = ytrain(f,:); 
            % model training  
            out_train = train_model(bx,by,model,do_parameter,param);
            %
            bootweight(:,n) = out_train.feature_weight;
        end
        bootmean = nanmean(bootweight');
        bootste = nanstd(bootweight');
        boot_Z = bootmean./bootste;
        boot_p_z = 2 * (1 - normcdf(abs(boot_Z)));
        premodel = boot_Z';
        if strcmp(p_type,'p_unc')
            f = find(boot_p_z>p);
            premodel(f) = 0;
        elseif strcmp(p_type,'FDR')
            a = makeFDR(boot_p_z,p);
            f = find(boot_p_z>a);
            premodel(f) = 0;
        end
        if ~isempty(xtest) & ~isempty(ytest)
            if mean(premodel) ~= 0 
                out_apply.pv = xtest*premodel;
                out_apply.tv = ytest;
            else
                out_apply = [];
                disp('No significant features were found under the current threshold.');
            end
        end
    end
end

if ~isempty(out_apply)
    out_apply.assessment = assess_model(out_apply,model,param);
end