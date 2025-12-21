function [ytrain,ytest] = mat_regress_xy(ctrain,ctest,ytrain,ytest)

ctrain = bsxfun(@minus, ctrain, mean(ctrain));
ctrain = [ones(size(ytrain,1),1) ctrain];
beta = (ctrain'*ctrain)\(ctrain'*ytrain);
ytrain = ytrain - ctrain*beta;

if nargin == 4 & ~isempty(ytest)
    ctest = bsxfun(@minus, ctest, mean(ctest));
    ctest = [ones(size(ytest,1),1) ctest];
    ytest = ytest - ctest*beta;
else
    ytest = [];
end

