function out = mat_permutation(x,y,c,log,out,varargin)

%%
N = 10000; par = 0;
 
for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            case {'N'}
                N = varargin{i+1};
            case {'parallel'}
                par = 1;
        end
    end
end

pparam = log.param; model = log.model; cv = log.ocv;
pparam.random = 1; pparam.text = 0; pparam.progress = 0;

%%
if par == 1
    disp('Permutation Test (Parallel Computing):');
    % parfor_progress(N);  
    parfor n = 1:N
        currout = mat_cv(x,y,c,model,cv,pparam);
        if isfield(currout.model_quality,'accuracy_correlation')
            accuracy_null(n,1) = mean(currout.model_quality.accuracy_correlation);
        else
            try
                accuracy_null(n,1) = mean(currout.model_quality.accuracy_classification);
            catch
                accuracy_null(n,1) = mean(currout.model_quality.accuracy);
            end
        end
        % parfor_progress; 
    end
    % parfor_progress(0);  
else
    mwb('Permutation Test', 0, 'CancelFcn', @(a,b) disp( ['Cancel ',a] ), 'Color', 'b');
    for n = 1:N
        currout = mat_cv(x,y,c,model,cv,pparam);
        if isfield(currout.model_quality,'accuracy_correlation')
            accuracy_null(n,1) = mean(currout.model_quality.accuracy_correlation);
        else
            try
                accuracy_null(n,1) = mean(currout.model_quality.accuracy_classification);
            catch
                accuracy_null(n,1) = mean(currout.model_quality.accuracy);
            end
        end
        abort = mwb('Permutation Test', n/N);
    end
    mwb('Permutation Test', 'Close');
end

if isfield(out.model_quality,'accuracy_correlation')
    accuracy_true = mean(out.model_quality.accuracy_correlation);
else
    try
        accuracy_true = mean(out.model_quality.accuracy_classification);
    catch
        accuracy_true = mean(out.model_quality.accuracy);
    end
end

out.accuracy_true = accuracy_true;
out.accuracy_null = accuracy_null;
out.p_model_permutation = get_permutation_p(accuracy_true,accuracy_null,'right');
out.N_permutation = N;