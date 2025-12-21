function [Target,PHI,W,X] = PolynomialExpertToyData()
%This Function generates some polynomial toy data 
%INPUT


%Output
% PHI: N x M array representing N data points of M dimensions that consist of some nonlinear
%transformation of the array X is this case a second order polinomal  
%X:N x D array representing N datapoints of D dimensions 
%W:array Representing the number of parameters, each column represents the parameters for a 
%different expert, analogues to the parameters in linear regression   
%Target: target data
z=[-5:0.01:5-0.01]
NumberSamples=length(z);
%Generate uniform data for form -5 to 5

X=z';

% number of samples
M=length(X(:,1));
N=length(X(1,:));
%Parameters to make data linearly separable

%Generate lables  sample data
Lables=ones(M,1);

PHI=-ones(M,3);
PHI(:,2)=-3*X(:,1);
PHI(:,3)=X(:,1).^2;
 
    %make some data with nice parmeters
    W=zeros(3,1)
    W(:,1)=[1 2 3];

    % Generate some target data
    %noise standard deviation
    Nsd=0.01;
    Target=PHI*W+Nsd*randn(NumberSamples,1);


end

