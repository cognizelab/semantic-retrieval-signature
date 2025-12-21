function [index,cv] = mat_sample(x,y,c,cv,param)
%% Assign Subjects to Different Datasets.
%% -------------------------------------------------------------------------------------------------------------------------------
%% Input
%  (1) x: subjects * features of interest (double) 
%  (2) y: subjects * target variable 
%  (3) c: subjects * covariates to be controled
%                 <regress covariates (e.g. head motion) from y (target variable)>
%  (4) param: corresponding parameters
%             -- param.groupCV, numerical label for group-based cross-validation
%             -- param.stratifyCV, numerical label for stratified cross-validation 
%             -- param.keepOrder, if the data for each fold is determined based on the order of y
%                                   >>> 1 = YES 
%                                   >>> 0 = NO (default) 
%             -- param.indexCV, enter a given CV folds (if not, folds will be randomly assigned)
%                                   >>> [] = NO (default)  
%% Output
%  (1) cv: cross-validation number (n folds & k times) 
%  (2) index: the numbering of subjects in each cross-validation, examining how subjects are allocated
%% -------------------------------------------------------------------------------------------------------------------------------
% - Z.K.X. 2021/10/01 (MATLAB R2018a)
%% -------------------------------------------------------------------------------------------------------------------------------

if isfield(param,'indexCV') && ~isempty(param.indexCV)
    index = param.indexCV; 
    cv(1) = numel(unique(index(:,1)));
    cv(2) = size(index,2);
    return
end

if ~isfield(param,'groupCV') || isempty(param.groupCV)
    K = [1:size(x,1)]';
else
    K = param.groupCV;
end

k = unique(K);

if ~isfield(param,'keepOrder') || param.keepOrder ~= 1
    if ~isfield(param,'stratifyCV') || isempty(param.stratifyCV)
        for i = 1:cv(2)
            indexc(:,i) = crossvalind('Kfold',length(k),cv(1)); 
        end
    else
        [~,~,indexc] = group_sample(param.stratifyCV,cv(1),cv(2));
    end
    if length(k) == length(K)
        index = indexc;
    else
        for i = 1:cv(2)
            for j = 1:numel(k)
                f = find(K==k(j));
                index(f,i) = indexc(j,i);
            end
        end 
    end
else
    [a,b] = sort(y,'descend');
    for i = 1:cv(1)
        p = i:cv(1):numel(y);
        index(b(p),1) = i;
    end
end

if cv(1) == 1
    index = index - 1;
end

end
 
%% Group Data by Certain Criteria
function [G,m,index] = group_sample(data,skn,rn) 
%------------------------------------------------------------------------------------------------%
%  Z.K.X. 2018/08/30
%------------------------------------------------------------------------------------------------%
%% Input 
% (1) data: row - subjects; column - digital label criteria 
%      (e.g., apply 0 and 1 to label different gender in the first column, 
%      and apply 0, 1 and 2 to label different projects in second column )
% (2) skn: stratified K-folds - number of k 
% (3) rn: repeated number of k
%% Output
%  G: grouping information
%  m: the subject number of smallest group
%  index:ID of stratified K-folds 
%------------------------------------------------------------------------------------------------%
for i = 1:size(data,2)
    X{i} = unique(data(:,i));
end

S = []; m = length(X);    
lt = ones(1,m); n = 1;

for k = 1:m
    lt(k) = length(X{k});
    n = n * lt(k); 
end

for k = m:-1:1 
    r = [];
    l = lt(k);
    j = 1;
    for p = (k+1):m
        j=j*lt(p);
    end 
    tm=n/(j*l); 
    for p = 1:tm 
        for h = 1:l 
            for g = 1:j 
                r = [r;X{k}(h)];
            end
        end
    end
    S = [r S];
end 

for i = 1:n
    tt1 = ['N{',num2str(i),'}=find('];
    tt2 = [];
    for j = 1:size(S,2)
        tt2 = [tt2,'data(:,',num2str(j),')==S(',num2str(i),',',num2str(j),')&'];
    end
    tt = [tt1,tt2]; tt(end) = []; tt = [tt,');'];
    eval(tt);
end

for i = 1:size(S,1)
    G(i).Group_type = S(i,:);
    G(i).Subjects = N{i};
    G(i).Number = length(N{i});
    n(i) = length(N{i});
end

n = min(n);

for i = 1:size(S,1)
     G(i).Sample = randsample(G(i).Subjects,n);
     m(i) = length(G(i).Sample);
end

m = min(m);

for n = 1:rn
    for i = 1:length(G) 
        curr = crossvalind('Kfold',G(i).Number,skn);
        index(G(i).Subjects,n) = curr;
    end
end

end