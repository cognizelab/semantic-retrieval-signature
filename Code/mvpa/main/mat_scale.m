function [xtrain,xtest] = mat_scale(xtrain,xtest)

vmin = min(xtrain); vmax = max(xtrain); v = vmax-vmin;
xtrain = (xtrain - vmin) ./ v;

if nargin > 1 && ~isempty(xtest)
    xtest = (xtest - vmin) ./ v;  
else
    xtest = [];
end