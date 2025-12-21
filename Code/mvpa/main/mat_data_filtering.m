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

% Initialize a counter for deleted rows
r = 0;

% Loop over each feature
for i = 1:m
    % If a feature has only one unique value, or the proportion of missing values is more than 10%, then mark it as a bad feature
    if numel(unique(x(:,i))) == 1 || sum(isnan(x(:,i)) | isinf(x(:,i))) > n * thr % perfentage of cut off
        fgood(i) = false;
    elseif k == 1  % If k is 1, perform interpolation
        x(:,i) = fillmissing(x(:,i), 'linear');  % You can replace 'linear' with other methods if you want
    elseif k == 2  % Otherwise, delete all rows with missing values
        rowsToDelete = isnan(x(:,i)) | isinf(x(:,i));
        r = r + sum(rowsToDelete);  % Update the counter
        x(rowsToDelete, :) = [];
    end
end

if r == 0
    r = [];
end

% Remove bad features
x(:, ~fgood) = [];