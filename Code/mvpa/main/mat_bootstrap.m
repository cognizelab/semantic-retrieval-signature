function [out,bootweight,Haufeweight] = mat_bootstrap(x,y,c,log,out,varargin)
%---------------------------------------------------------------------------------------------------------------------------------------------------%
% - Z.K.X. 2023/10/03
%---------------------------------------------------------------------------------------------------------------------------------------------------%
%% default setting 
N = 10000; PO = 0; opt_parameter = []; doparallel = 0; text = 0; nparpool = 12; Haufe = 0; bricks_n = []; 

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            case {'N'}
                N = varargin{i+1};
            case {'PO'}
                PO = 1;         
            case {'opt_parameter'}
                opt_parameter = varargin{i+1};
            case {'parallel'}
                doparallel = 1;
            case {'text'}
                text = 1;
            case {'Haufe'}
                Haufe = 1;     
            case {'Haufe-bricks'}
                Haufe = 2;      
                bricks_n = varargin{i+1};
            case {'parpool'}
                nparpool = varargin{i+1};
        end
    end
end

%% Data Preparation
% data filtering
[x,~,f1] = mat_data_filtering(x, log.param.interp, 0.1); y(f1,:) = []; 
[y,~,f2] = mat_data_filtering(y, 0, 0.1); x(f2,:) = [];    
 
if ~isempty(c)
    c(f1,:) = []; c(f2,:) = [];
end

[c, log.data.cgood,f3] = mat_data_filtering(c, 1, 1); 

% covariate handling
[log.param.covariateModeResolved, log.param.covariateModeRequested, ...
    log.param.covariateModeApplied] = ...
    resolve_covariate_mode(log.model, y, log.param, c);
[x,y,~,~,covariateInfo] = apply_covariate_mode(x,y,c,[],[],[], ...
    log.param,log.model);
log.covariateMode = covariateInfo;

% feature scaling 
if log.param.scale == 1 
    x = mat_scale(x); 
end

%% Bootstrap Test
if ~isempty(log.param.groupCV) && log.param.samerule == 1
    in = unique(log.param.groupCV); s = size(in);  
else
    in = (1:size(x,1))'; s = size(in);
end

mwb('CLOSEALL'); 

if doparallel == 0
    tic;
    mwb('Bootstrap Test', 0, 'CancelFcn', @(a,b) disp( ['Cancel ',a] ), 'Color', 'b');    
    for n = 1:N
        f = in(ceil(max(s)*rand(max(s),1)));   
        if ~isempty(log.param.groupCV) && log.param.samerule == 1 
            bx = []; by = [];
            for i = 1:length(f)
                ff = find(log.param.groupCV==f(i));
                bx = [bx;x(ff,:)]; by = [by;y(ff,:)]; 
            end
        else
            bx = x(f,:); by = y(f,:); 
        end
        if log.param.po > 0 && PO == 1
            [do_parameter,opt_records,param] = get_opt_params(bx,by,log.model,log.param);
        else
            if ~isempty(opt_parameter)
                do_parameter = opt_parameter;
            elseif isfield(out,'opt_parameter') && ~isempty(out.opt_parameter)
                do_parameter = median(out.opt_parameter);
            else
                do_parameter = get_default_params(log.model,log.param);
            end
        end 
        % model training  
        out_train = train_model(bx,by,log.model,do_parameter,log.param);
        %
        bootweight(:,n) = out_train.feature_weight;
        if Haufe == 1
            w = bootweight(:,n);
            Haufeweight(:,n) = cov(bx)*w/cov(w'*bx');
            % pred = bx * w;                     
            % Nn = size(bx,1);
            % 
            % Xc = bsxfun(@minus, bx, mean(bx,1));
            % sc = pred - mean(pred);
            % 
            % haufe_cov = (Xc' * sc) / (Nn - 1);          % Cov(X, s)
            % pred_var  = (sc' * sc) / (Nn - 1);          % Var(s)
            % 
            % Haufeweight(:,n) = haufe_cov / pred_var;    % Haufe pattern
        elseif Haufe == 2
            w = bootweight(:,n);
            Haufeweight(:,n) = fast_haufe(bx, w, bricks_n);
        end
        abort = mwb('Bootstrap Test', n/N);
    end    
    mwb('Bootstrap Test', 'Close');
else
    pool = gcp('nocreate');
    if isempty(pool) || pool.NumWorkers ~= nparpool
        try
            parpool(nparpool);
        catch
            delete(gcp('nocreate'));
            parpool(nparpool);
        end
    end
    tic;
    if text == 1
        parfor_progress(N);  
        parfor n = 1:N
            [bootweight{n},Haufeweight{n}] = boot_parallel(in,s,x,y,log,PO,opt_parameter,out,Haufe,bricks_n); 
            parfor_progress; 
        end
        parfor_progress(0);  
    else
        parfor n = 1:N
            [bootweight{n},Haufeweight{n}] = boot_parallel(in,s,x,y,log,PO,opt_parameter,out,Haufe,bricks_n); 
        end        
    end
    bootweight = cell2mat(bootweight);
    Haufeweight = cell2mat(Haufeweight);
end

elapsedTime = toc;
fprintf('Execution time: %.2f seconds\n', elapsedTime);

%% p value - type one
for i = 1:size(bootweight,1)
    fpos = length(find(bootweight(i,:)>0));
    fneg = length(find(bootweight(i,:)<0));
    f = max([fpos,fneg]);
    out.boot_p_ratio(i,1) = 1-f/N;
end

if Haufe > 0
    for i = 1:size(Haufeweight,1)
        fpos = length(find(Haufeweight(i,:)>0));
        fneg = length(find(Haufeweight(i,:)<0));
        f = max([fpos,fneg]);
        out.boot_haufe_p_ratio(i,1) = 1-f/N;   
    end
else
    Haufeweight = [];
end

%% p value - type two
bootmean = mean(bootweight, 2, 'omitnan');
bootste = std(bootweight, 0, 2, 'omitnan');
boot_Z = bootmean./bootste;
boot_p_z = 2 * (1 - normcdf(abs(boot_Z)));

out.boot_Z = boot_Z; out.boot_p_z = boot_p_z; out.bootste = bootste; out.bootste_N = N;

if Haufe > 0
    bootmean = mean(Haufeweight, 2, 'omitnan');
    bootste = std(Haufeweight, 0, 2, 'omitnan');
    boot_Z = bootmean./bootste;
    boot_p_z = 2 * (1 - normcdf(abs(boot_Z)));
    
    out.boot_haufe_Z = boot_Z; out.boot_haufe_p_z = boot_p_z; out.bootste_haufe = bootste;
end

end

%% ===================================================================================
function [bootweight,Haufeweight] = boot_parallel(in,s,x,y,log,PO,opt_parameter,out,Haufe,bricks_n)   
    f = in(ceil(max(s)*rand(max(s),1)));   
    if ~isempty(log.param.groupCV) && log.param.samerule == 1 
        bx = []; by = [];
        for i = 1:length(f)
            ff = find(log.param.groupCV==f(i));
            bx = [bx;x(ff,:)]; by = [by;y(ff,:)]; 
        end
    else
        bx = x(f,:); by = y(f,:); 
    end
    if log.param.po > 0 && PO == 1
        [do_parameter,opt_records,param] = get_opt_params(bx,by,log.model,log.param);
    else
        if ~isempty(opt_parameter)
            do_parameter = opt_parameter;
        elseif isfield(out,'opt_parameter') && ~isempty(out.opt_parameter)
            do_parameter = median(out.opt_parameter);
        else
            do_parameter = get_default_params(log.model,log.param);
        end
    end 
    % model training  
    out_train = train_model(bx,by,log.model,do_parameter,log.param);
    %
    bootweight = out_train.feature_weight;
    if Haufe == 1
        w = bootweight;
        Haufeweight(:,1) = cov(bx)*w/cov(w'*bx');
        % pred = bx * w;                     
        % Nn = size(bx,1);
        % 
        % Xc = bsxfun(@minus, bx, mean(bx,1));
        % sc = pred - mean(pred);
        % 
        % haufe_cov = (Xc' * sc) / (Nn - 1);          % Cov(X, s)
        % pred_var  = (sc' * sc) / (Nn - 1);          % Var(s)
        % 
        % Haufeweight(:,1) = haufe_cov / pred_var;    % Haufe pattern        
    elseif Haufe == 2
        w = bootweight(:,1);
        Haufeweight(:,1) = fast_haufe(bx, w, bricks_n);
    else
        Haufeweight = [];
    end
end
