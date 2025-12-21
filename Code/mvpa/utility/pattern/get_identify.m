function [predictAbs,predictRatio,predictCat,matrix] = get_identify(x,y,id,method)
%% Identification for Test-retest Dataset
%---------------------------------------------------------------------------------------------------------------------------------------------%
% - Z.K.X. 2019/05/23
%---------------------------------------------------------------------------------------------------------------------------------------------%
%% Input
%  (1) x: patterns * features double matrix in time point 1
%  (2) y: patterns * features double matrix in time point 2
%  (3) id: pattern ids
%  (4) method: method for calculating similarity
%              - 'Pearson'
%              - 'Spearman'
%              - 'Kendall')"
%              - 'Cosine')"
%              - 'Euclidean')"
%---------------------------------------------------------------------------------------------------------------------------------------------%
%% Output
%  (1) predictAbs: absolute identification value (Finn et al. 2015, Nature neuroscience)
%  (2) predictRatio: relative identification rate 
%  (3) predictCat: absolute identification value based on categories 
%  (4) matrix: similarity matrix
%---------------------------------------------------------------------------------------------------------------------------------------------%

if nargin < 3 || isempty(id)
    id = [1:size(x,1)]';
end

if nargin < 4 || isempty(method)
    method = 'Pearson';
end

if strcmp(method,'Pearson')
    clc = "corr(X,Y, 'Type', 'Pearson')";
elseif strcmp(method,'Spearman')
    clc = "corr(X,Y, 'Type', 'Spearman')";
elseif strcmp(method,'Kendall')
    clc = "corr(X,Y, 'Type', 'Kendall')";
elseif strcmp(method,'Cosine')
    clc = "dot(X,Y)/(norm(X)*norm(Y))";
elseif strcmp(method,'Euclidean')
    clc = "1/(1+sqrt(sum((X - Y).^2)))";
end

for i = 1:size(x,1)
    X = x(i,:)';

    for j = 1:size(x,1)
        Y = y(j,:)';
        matrix(i,j) = eval(clc);
    end

    if find(matrix(i,:)==max(matrix(i,:))) == i
        predictAbs(i,1) = 1;
    else
        predictAbs(i,1) = 0;
    end
    
    [a,b] = sort(matrix(i,:));
    f = find(b==i);
    predictRatio(i,1) = f/length(b);

    f = find(matrix(i,:) == max(matrix(i,:)));
    if id(i) == id(f)
        predictCat(i,1) = 1;
    else
        predictCat(i,1) = 0;
    end
    disp(['Pattern recognition process: ',num2str(i)]);
end

matrix = matrix;