function [out,bootweight,Haufeweight] = mat_bootstrap(x,y,c,log,out,varargin)
%---------------------------------------------------------------------------------------------------------------------------------------------------%
% - Z.K.X. 2023/10/03
%---------------------------------------------------------------------------------------------------------------------------------------------------%
%% default setting 
N = 10000; PO = 0; opt_parameter = []; doparallel = 0; text = 0; nparpool = 12; Haufe = 0; 

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

% covariates regression  
if log.param.covariates > 0 && ~isempty(c) 
   if log.param.covariates == 1 
      y = mat_regress_xy(c,[],y);
   elseif log.param.covariates == 2 
      x = mat_regress_xy(c,[],x);
   end
end    

% feature scaling 
if log.param.scale == 1 
    x = mat_scale(x); 
end

%% Bootstrap Test
if ~isempty(log.param.groupCV) && log.param.samerule == 1
    in = unique(log.param.groupCV); s = size(in);  
else
    in = [1:size(x,1)]'; s = size(in);  
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
            [do_parameter,opt_records,param] = get_opt_params(by,by,log.model,log.param);
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
            [bootweight{n},Haufeweight{n}] = boot_parallel(in,s,x,y,log,PO,opt_parameter,out,Haufe); 
            parfor_progress; 
        end
        parfor_progress(0);  
    else
        parfor n = 1:N
            [bootweight{n},Haufeweight{n}] = boot_parallel(in,s,x,y,log,PO,opt_parameter,out,Haufe); 
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
bootmean = nanmean(bootweight');
bootste = nanstd(bootweight');
boot_Z = bootmean./bootste;
boot_p_z = 2 * (1 - normcdf(abs(boot_Z)));

out.boot_Z = boot_Z'; out.boot_p_z = boot_p_z'; out.bootste = bootste'; out.bootste_N = N;

if Haufe > 0
    bootmean = nanmean(Haufeweight');
    bootste = nanstd(Haufeweight');
    boot_Z = bootmean./bootste;
    boot_p_z = 2 * (1 - normcdf(abs(boot_Z)));
    
    out.boot_haufe_Z = boot_Z'; out.boot_haufe_p_z = boot_p_z'; out.bootste_haufe = bootste'; 
end

end

%% ===================================================================================
function [bootweight,Haufeweight] = boot_parallel(in,s,x,y,log,PO,opt_parameter,out,Haufe)   
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
        [do_parameter,opt_records,param] = get_opt_params(by,by,log.model,log.param);
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
    elseif Haufe == 2
        w = bootweight(:,1);
        Haufeweight(:,1) = fast_haufe(bx, w, bricks_n);
    else
        Haufeweight = [];
    end
end