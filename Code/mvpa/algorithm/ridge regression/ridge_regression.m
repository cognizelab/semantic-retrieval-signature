function w = ridge_regression(x,y,lambda)
%% Ridge Regression
%------------------------------------------------------------------------------------------------%
% - Z.K.X. 2019/01/09
%------------------------------------------------------------------------------------------------%
R = x' * x;
R_inv = R^-1;
d = size(x, 2);
w_ls = R_inv * x' * y;
w = (eye(d) + lambda * R_inv)^-1 * w_ls;

% xTx = x'*x;
% [m,n] = size(xTx);
% temp = xTx + eye(m,n)*lambda;
% if det(temp) == 0
% disp('This matrix is singular, cannot do inverse');
% end
% w = temp^(-1)*x'*y;