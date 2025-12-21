function [opt_parameter,opt_records,param] = get_opt_params_tpls(x,y,param)
%%
if ~isfield(param,'compvec') || isempty(param.compvec)
    param.compvec = 1:25; 
end
if ~isfield(param,'threshvec') || isempty(param.threshvec)
    param.threshvec = 0.05:0.05:1; 
end
 
curr_param = param; curr_param.groupCV = curr_param.groupCVinner;

if param.samerule == 1
    if ~isempty(param.groupCVinner) && size(param.groupCVinner,1) ~= size(x,1)        
        curr_param.groupCV(param.ftest,:) = [];
    end
    if ~isempty(param.stratifyCV) && size(param.stratifyCV,1) ~= size(x,1)
        curr_param.stratifyCV(param.ftest,:) = [];
    end
    if ~isempty(param.indexCV) && size(param.indexCV,1) ~= size(x,1)
        curr_param.indexCV(param.ftest,:) = [];
    end
else
    curr_param.groupCV = []; curr_param.stratifyCV = []; curr_param.indexCV = []; curr_param.keepOrder = 0;
end

index = mat_sample(x,y,[],param.icv,curr_param);

%%
if isfield(param,'po_tpls') && ~isempty(param.po_tpls) && param.po_tpls == 1
    CVfold = [];
    for i = 1:size(index,2)
        curr = zeros(size(index,1),param.icv(1));
        for j = 1:param.icv(1)
           curr(index(:,i)==j,j) = 1; 
        end
        CVfold = [CVfold,curr];
    end     
    cvmdl = TPLS_cv(x,y,CVfold,max(param.compvec));
    if numel(unique(y)) == 2
        if isfield(param,'opt_type') && strcmp(param.opt_type,'negMSE')
            cvstats = evalTuningParam(cvmdl,'negMSE',x,y,param.compvec,param.threshvec);            
        elseif isfield(param,'opt_type') && strcmp(param.opt_type,'combine')
            cvstats1 = evalTuningParam(cvmdl,'AUC',x,y,param.compvec,param.threshvec);
            cvstats2 = evalTuningParam(cvmdl,'negMSE',x,y,param.compvec,param.threshvec);
            A = mean(cvstats1.perfmat,3); B = mean(cvstats2.perfmat,3);
            [d,d_opt,f1,f2] = get_combine_opt(A,B,0);
            cvstats.type = 'combine';
            cvstats.compval = param.compvec;
            cvstats.threshaval = param.threshvec;
            cvstats.perf_best = d_opt;
            cvstats.perfmat = d;
            cvstats.compval_best = param.compvec(f1);
            cvstats.threshval_best = param.threshvec(f2);
        else
            cvstats = evalTuningParam(cvmdl,'AUC',x,y,param.compvec,param.threshvec);            
        end
    else
        if isfield(param,'opt_type') && strcmp(param.opt_type,'negMSE')
            cvstats = evalTuningParam(cvmdl,'negMSE',x,y,param.compvec,param.threshvec);
        elseif isfield(param,'opt_type') && strcmp(param.opt_type,'combine')
            cvstats1 = evalTuningParam(cvmdl,param.corrtype,x,y,param.compvec,param.threshvec);
            cvstats2 = evalTuningParam(cvmdl,'negMSE',x,y,param.compvec,param.threshvec);
            A = mean(cvstats1.perfmat,3); B = mean(cvstats2.perfmat,3);
            [d,d_opt,f1,f2] = get_combine_opt(A,B,0);
            cvstats.type = 'combine';
            cvstats.compval = param.compvec;
            cvstats.threshaval = param.threshvec;
            cvstats.perf_best = d_opt;
            cvstats.perfmat = d;
            cvstats.compval_best = param.compvec(f1);
            cvstats.threshval_best = param.threshvec(f2);            
        else
            cvstats = evalTuningParam(cvmdl,param.corrtype,x,y,param.compvec,param.threshvec);            
        end
    end
    opt_parameter = [cvstats.compval_best,cvstats.threshval_best,max(param.compvec)];
    if param.savelarge ~= 1; cvmdl = []; end
    opt_records = {cvmdl,cvstats};  
    if param.text == 1
        disp('-----------------------------------------------------------------------');
        if numel(unique(y)) == 2
            if isfield(param,'opt_type') && strcmp(param.opt_type,'negMSE')
                disp(['Parameter optimization based on negMSE (default version): negMSE = ',num2str(cvstats.perf_best)]); 
            elseif isfield(param,'opt_type') && strcmp(param.opt_type,'combine')
                disp(['Parameter optimization based on combined strategy (default version): distance to (0,0) = ',num2str(cvstats.perf_best)]);
            else
                disp(['Parameter optimization based on AUC (default version): AUC = ',num2str(cvstats.perf_best)]); 
            end
        else
            if isfield(param,'opt_type') && strcmp(param.opt_type,'negMSE')
                disp(['Parameter optimization based on negMSE (default version): negMSE = ',num2str(cvstats.perf_best)]);                
            elseif isfield(param,'opt_type') && strcmp(param.opt_type,'combine')
                disp(['Parameter optimization based on combined strategy (default version): distance to (0,0) = ',num2str(cvstats.perf_best)]);
            else
                disp(['Parameter optimization based on correlation (default version): correlation = ',num2str(cvstats.perf_best)]);
            end
        end
        f1 = find(param.compvec==cvstats.compval_best); f2 = find(param.threshvec==cvstats.threshval_best);  
        disp(['Optimal component number = ',num2str(cvstats.compval_best),' (number = ',num2str(f1),')']);
        disp(['Optimal pattern threshold = ',num2str(cvstats.threshval_best),' (number = ',num2str(f2),')']);
        disp('-----------------------------------------------------------------------');    
    end
    return
end
   
%%
p1 = numel(param.compvec);
p2 = numel(param.threshvec);
betamap_folds = cell(p1,p2);

for n = 1:param.icv(2)
    idx = index(:,n); PV = cell(p1,p2); TV = PV;  PW = PV;
    for k = 1:param.icv(1)
        % splitting data sets
        ftest = find(idx==k); ftrain = find(idx~=k);
        xtest = x(ftest,:); ytest = y(ftest,:); 
        xtrain = x(ftrain,:); ytrain = y(ftrain,:); 
        % feature scaling 
        if param.iscale == 1 
            vmin = min(xtrain); vmax = max(xtrain); v = vmax-vmin;
            xtrain = (xtrain - vmin) ./ v;
            xtest = (xtest - vmin) ./ v;    
        end
        % model training
        mdl = TPLS(xtrain,ytrain,max(param.compvec),ones(numel(ytrain),1),0);
        % model generalization
        for i = 1:p1
            for j = 1:p2
                [betamap,bias] = makePredictor(mdl,param.compvec(i),param.threshvec(j));
                score = bias + xtest*betamap;  
                betamap_folds{i,j} = [betamap_folds{i,j},betamap]; 
                PW{i,j} = [PW{i,j};score]; TV{i,j} = [TV{i,j};ytest]; 
                if numel(unique(y)) == 2
                    PV{i,j} = PW{i,j} > 0.5;   
                else
                    PV{i,j} = PW{i,j};
                end
             end
        end
    end
    for i = 1:p1
        for j = 1:p2
            if numel(unique(y)) == 2
                W = mat_assess_classification(logical(TV{i,j}),PW{i,j},1,param);
                AUC(i,j,n) = W.AUC; accuracy(i,j,n) = W.accuracy;
            else
                curr = mat_assess_correlation(PV{i,j},TV{i,j},param);
                accuracy(i,j,n) = curr.accuracy;
                MAE(i,j,n) = curr.MAE;
            end
        end
    end  
end

for i = 1:p1
    for j = 1:p2
        [pattern_correlation(i,j), mean_O(i,j), std_O, mean_OC(i,j)] = mat_assess_stability(betamap_folds{i,j});
    end
end

opt_records.pattern_correlation = pattern_correlation;
opt_records.overlap = mean_O;
opt_records.corrected_overlap = mean_OC;

opt_records.accuracy = accuracy;
A = mean(accuracy,3);

if exist('AUC', 'var') 
    opt_records.AUC = AUC;
    B = mean(AUC,3);
else
    opt_records.MAE = MAE;
    B = mean(MAE,3)*-1;
    curr = mean(opt_records.MAE,3);
end

if param.po == 1
    [f1,f2] = find(A==max(A(:)));
elseif param.po == 2
    [f1,f2] = find(B==max(B(:)));
elseif param.po == 3
    [f1,f2] = find(pattern_correlation==max(pattern_correlation(:)));
elseif param.po == 4
    [f1,f2] = find(mean_OC==max(mean_OC(:)));
elseif param.po == 5
    a = rescale(A); b = rescale(pattern_correlation);
    for i = 1:p1
        for j = 1:p2
            d(i,j) = pdist2([a(i,j),b(i,j)],[1 1]);
        end
    end
    [f1,f2] = find(d==min(d(:)));
elseif param.po == 6
    a = rescale(A); b = rescale(mean_OC);
    for i = 1:p1
        for j = 1:p2
            d(i,j) = pdist2([a(i,j),b(i,j)],[1 1]);
        end
    end
    [f1,f2] = find(d==min(d(:))); 
elseif param.po == 7
    a = rescale(B); b = rescale(pattern_correlation);
    for i = 1:p1
        for j = 1:p2
            d(i,j) = pdist2([a(i,j),b(i,j)],[1 1]);
        end
    end
    [f1,f2] = find(d==min(d(:)));    
elseif param.po == 8
    a = rescale(B); b = rescale(mean_OC);
    for i = 1:p1
        for j = 1:p2
            d(i,j) = pdist2([a(i,j),b(i,j)],[1 1]);
        end
    end
    [f1,f2] = find(d==min(d(:)));    
end

if exist('d','var'); opt_records.d = d; end
f1 = f1(end); f2 = f2(end);
opt_parameter = [param.compvec(f1(end)),param.threshvec(f2(end))];
opt_parameter(3) = max(param.compvec);

if param.text == 1
    disp('-----------------------------------------------------------------------');
    if param.po == 1
        disp(['Parameter optimization based on accuracy: accuracy = ',num2str(opt_records.accuracy(f1,f2))]);
    elseif param.po == 2
        if numel(unique(y)) == 2
            disp(['Parameter optimization based on AUC: AUC = ',num2str(opt_records.AUC(f1,f2))]);
        else
            disp(['Parameter optimization based on MAE: MAE = ',num2str(curr(f1,f2))]);
        end
    elseif param.po == 3
        disp(['Parameter optimization based on pattern similarity: similarity = ',num2str(opt_records.pattern_correlation(f1,f2))]);
    elseif param.po == 4
        disp(['Parameter optimization based on pattern overlap: overlap = ',num2str(opt_records.corrected_overlap(f1,f2))]);
    elseif param.po == 5
        disp('Parameter optimization based on accuracy and pattern similarity:');     
        disp(['accuracy = ',num2str(opt_records.accuracy(f1,f2)),'; similarity = ',num2str(opt_records.pattern_correlation(f1,f2))]);
    elseif param.po == 6
        disp('Parameter optimization based on accuracy and pattern overlap:'); 
        disp(['accuracy = ',num2str(opt_records.AUC(f1,f2)),'; similarity = ',num2str(opt_records.corrected_overlap(f1,f2))]);    
    elseif param.po == 7
        if numel(unique(y)) == 2
            disp('Parameter optimization based on AUC and pattern similarity:');  
            disp(['accuracy = ',num2str(opt_records.accuracy(f1,f2)),'; similarity = ',num2str(opt_records.pattern_correlation(f1,f2))]);
        else
            disp('Parameter optimization based on MAE and pattern similarity:');  
            disp(['accuracy = ',num2str(curr(f1,f2)),'; similarity = ',num2str(opt_records.pattern_correlation(f1,f2))]);        
        end
    elseif param.po == 8
        if numel(unique(y)) == 2
            disp('Parameter optimization based on AUC and pattern overlap:'); 
            disp(['accuracy = ',num2str(opt_records.AUC(f1,f2)),'; similarity = ',num2str(opt_records.corrected_overlap(f1,f2))]);        
        else
            disp('Parameter optimization based on MAE and pattern overlap:'); 
            disp(['accuracy = ',num2str(curr(f1,f2)),'; similarity = ',num2str(opt_records.corrected_overlap(f1,f2))]);                
        end
    end    
    disp(['Optimal component number = ',num2str(param.compvec(f1)),' (number = ',num2str(f1),')']);
    disp(['Optimal pattern threshold = ',num2str(param.threshvec(f2)),' (number = ',num2str(f2),')']);
    disp('-----------------------------------------------------------------------');
end