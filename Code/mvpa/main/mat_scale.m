function [xtrain,xtest] = mat_scale(xtrain,xtest)

vmin = min(xtrain); vmax = max(xtrain); v = vmax-vmin;
v(~isfinite(v) | v == 0) = 1;
xtrain = (xtrain - vmin) ./ v;

if nargin > 1 && ~isempty(xtest)
    xtest = (xtest - vmin) ./ v;  
else
    xtest = [];
end
