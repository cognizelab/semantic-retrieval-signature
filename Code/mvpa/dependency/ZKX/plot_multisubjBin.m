function [h,stats] = plot_multisubjBin(X, Y, varargin)
%% Bin plot containing multiple subjects.
%% -------------------------------------------------------------------------------------------------------------------------------
%% Input
%  (1) X: cell array: each cell for each subject contains any x-axis values
%  (2) Y: cell array: each cell for each subject contains any y-axis values
%  (4) optional inputs:
%                   >>> 'nbins', number of bins (default, 4)
%                   >>> 'ylim', y 
%                   >>> 'colors', dot color (default, [0.8353, 0.2431, 0.3098]) 
%                   >>> 'colors_refline', line color (default, [0.9569, 0.4275, 0.2627]) 
%                   >>> 'reflinestyle', reference line stype (default, '--')
%                   >>> 'reflinewidth', reference line width (default, 1)
%                   >>> 'resid', if the residuals of the X and Y are taken
%                   >>> 'covs', covariates
%                   >>> 'stats', should mixed-effects models be conducted
%% Dependency
% https://github.com/canlab/CanlabCore
%% Example
% for i = 1:10, X{i} = rand(20,1); Y{i} = rand(20,1); end
% h = plot_multisubjBin(X, Y);
%---------------------------------------------------------------------------------------------------------------------------------------------------%
% - Z.K.X. 2023/10/03
%---------------------------------------------------------------------------------------------------------------------------------------------------%

%% default setting 
nbins = 4; colors = [0.8353, 0.2431, 0.3098]; colors_ref = [0.9569, 0.4275, 0.2627]; reflinest = '--';

doman_ylim = 0; dorefline = 1; reflinew = 1;

do_resid = 0; do_stat = 0;

subjn = numel(X); X_cov = cell(subjn,1); covariates= cell(subjn,1);

for i = 1:subjn, covariates{i} = []; end

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            case {'ylim'}
                doman_ylim = 1;
                ylim = varargin{i+1};
            case {'colors', 'color'}
                colors = varargin{i+1};
            case {'colors_refline', 'colors_ref'}
                colors_ref = varargin{i+1};
            case {'refline'}
                dorefline = 1;
            case {'reflinestyle'}
                reflinest = varargin{i+1};
            case {'reflinewidth'}
                reflinew = varargin{i+1};
            case {'covs'}
                covariates = varargin{i+1};
            case {'resid'}
                do_resid = 1;
            case {'stats', 'stat'}
                do_stat = 1;
            case {'nbins'}
                nbins = varargin{i+1};
        end
    end
end

%% regress out covariates 
for i = 1:subjn
    X_cov{i} = [X{i} covariates{i}]; 
    if do_resid
        X{i} = resid(covariates{i}, X{i});
    end
end

if do_stat
    stats = glmfit_multilevel(Y, X_cov, [], 'verbose', 'weighted', 'boot', 'nresample', 10000);
else
    stats = [];
end

if do_resid
    for i = 1:subjn
        Y{i} = resid(covariates{i}, Y{i});
    end
end

%% get bin index
for i = 1:subjn
    [~, sort_idx] = sort(X{i});
    binidx = zeros(numel(X{i}),1);
    if numel(unique(X{i})) == nbins
        u = unique(X{i});
        for j = 1:numel(u)
            binidx(X{i} == u(j)) = j;
        end        
        for j = 1:nbins
            Xbins(i,j) = mean(X{i}(binidx==j));
            Ybins(i,j) = mean(Y{i}(binidx==j));
        end        
    else
        algo = {'ceil', 'floor'};
        for j = 1:(nbins-1)
            algon = double(rand>.5)+1;
            eval(['tri_n = ' algo{algon} '(numel(X{i})./nbins);']);
            binidx(find(binidx==0, 1, 'first'):(find(binidx==0, 1, 'first')+tri_n-1)) = ...
                repmat(j, tri_n, 1);
        end
        binidx(binidx==0) = nbins;
        for j = 1:nbins
            Xbins(i,j) = mean(X{i}(sort_idx(binidx==j)));
            Ybins(i,j) = mean(Y{i}(sort_idx(binidx==j)));
        end
    end    
end

x = nanmean(Xbins); xe = ste(Xbins);
y = nanmean(Ybins); ye = ste(Ybins);

xmin = min(x-xe) - range(x)*.05;
xmax = max(x+xe) + range(x)*.05;
% ymin = min(y-ye) - range(y)*.05;
% ymax = max(y+ye) + range(y)*.05;

xmin2 = min(x-xe) - range(x)*.1;
xmax2 = max(x+xe) + range(x)*.1;
ymin2 = min(y-ye) - range(y)*.1;
ymax2 = max(y+ye) + range(y)*.1;

%% plot
h{1} = scatter(x,y, 100, colors, 'filled');

if dorefline
    h{2} = refline;
    set(h{2}, 'Color', colors_ref, 'linewidth', reflinew, 'linestyle', reflinest);
end

hold on

for i = 1:numel(x)
    h{3}{i} = ploterr(x(i),y(i),xe(i),ye(i));
    set(h{3}{i}(1), 'marker', '.', 'color', colors, 'markersize', 1);
    set(h{3}{i}(2), 'color', colors, 'linewidth', 2);
    set(h{3}{i}(3), 'color', colors, 'linewidth', 2);
    xdata = get(h{3}{i}(2), 'xData');
    xdata(4:5) = xdata(1:2); xdata(7:8) = xdata(1:2);
    set(h{3}{i}(2), 'xdata', xdata);
    ydata = get(h{3}{i}(3), 'yData');
    ydata(4:5) = ydata(1:2); ydata(7:8) = ydata(1:2);
    set(h{3}{i}(3), 'ydata', ydata);
    hold on;
end

if dorefline
    xdata = get(h{2}, 'xdata');
    ydata = get(h{2}, 'ydata');
    slope = (ydata(2)-ydata(1))./(xdata(2) - xdata(1));
    intercept = ydata(2) - xdata(2).*slope;
    set(h{2}, 'xdata', [xmin xmax], 'ydata', [xmin*slope+intercept xmax*slope+intercept])
end

if doman_ylim
    set(gca, 'xlim', [xmin2 xmax2], 'ylim', ylim, 'linewidth', 1.2, 'fontsize', 18);
else
    set(gca, 'xlim', [xmin2 xmax2], 'ylim', [ymin2 ymax2], 'linewidth', 1.2, 'fontsize', 18);
end
 