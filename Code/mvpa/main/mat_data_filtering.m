function [x, fgood, r] = mat_data_filtering(x, k, thr)
%% Data Filtering
%% Input
%  (1) x: raw data  
%  (2) k: whether to perform interpolation
%  (2) thr: filtering threshold (default, 0.1)
%% Output
%  (1) x: filtered data  
%  (2) fgood: retained feature positions
%  (3) r: removed subjects (row number)
%% -------------------------------------------------------------------------------------------------------------------------------
% - Z.K.X. 2023/09/27 (MATLAB R2022b)
%% -------------------------------------------------------------------------------------------------------------------------------
if nargin < 3; thr = 0.1; end

% Get the size of the data
[n, m] = size(x);

% Initialize a logical array to mark good features
fgood = true(1, m);

% Initialize removed row indices
r = [];

if isempty(x)
    return
end

% Loop over each feature
for i = 1:m
    curr = x(:,i);
    finite_curr = curr(isfinite(curr));
    % If a feature is constant, fully invalid, or has too many invalid values, mark it as bad.
    if isempty(finite_curr) || numel(unique(finite_curr)) == 1 || sum(~isfinite(curr)) > n * thr
        fgood(i) = false;
    elseif k == 1  % If k is 1, perform interpolation
        x(~isfinite(x(:,i)),i) = NaN;
        x(:,i) = fillmissing(x(:,i), 'linear');
        x(:,i) = fillmissing(x(:,i), 'nearest');
        if any(isnan(x(:,i)))
            medv = median(finite_curr);
            x(isnan(x(:,i)),i) = medv;
        end
    end
end

if k == 2
    r = find(any(~isfinite(x(:,fgood)),2));
    x(r,:) = [];
end

% Remove bad features
x(:, ~fgood) = [];
