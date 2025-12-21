function h = mat_plot_correlation(out,opt)

%% Default setting
if nargin < 2; opt = struct; end
if ~isfield(opt,'colors') || isempty(opt.colors)
    colors = [0.5529 0.6275 0.7961];
end
if size(colors,1) == 1
    colors = repmat(colors,6,1);
end
if ~isfield(opt,'bins') || isempty(opt.bins)
    bins = 4;
else
    bins = opt.bins;
end

%% Figure 1: whole group scatter plot
subplot(2,8,[1 2]);
h{1,1} = scatter(out.TV(:,1),out.PV(:,1),50,colors(1,:),'filled','MarkerFaceAlpha',0.8); 
h{2,1} = refline; set(h{2}, 'Color', [.3 .3 .3], 'linewidth', 2);
set(gca,'linewidth', 1.5, 'fontsize', 18, 'tickdir', 'out');
ax = gca; ax.TickLength = [0.03 0.03];
xlabel('Ture Value', 'FontSize', 20);
ylabel('Predicted Value', 'FontSize', 20);

%% Figure 2: permutation results
if isfield(out,'p_model_permutation') && ~isempty(out.p_model_permutation)
    subplot(2,8,[3]);
    [han, mu, sigma, q, notch] = al_goodplot(out.accuracy_null, [], [], colors(2,:));
    h{1,2} = han{1}; box off
    set(gca,'linewidth', 1.5, 'fontsize', 18, 'tickdir', 'out');
    ylabel('Accuracy', 'FontSize', 20);
    xticklabels([]); grid off;
    scatter(1,out.accuracy_true,100,'^','filled','MarkerEdgeColor',[.5 .5 .5],'MarkerFaceColor',[1 1 .3]);
    ax = gca; ax.TickLength = [0.03 0.03];
    text(1.5, out.accuracy_true, 'Ture Value', 'HorizontalAlignment', 'left', 'FontSize', 14);
    text(1.5, median(out.accuracy_null), 'Null Distribution', 'HorizontalAlignment', 'left', 'FontSize', 14);    
end

%% Figure 3: multiple scatter plots
subplot(2,8,[5 6]);
if size(out.TV,2) > 1 & size(out.TV,2) <= 20
    for i  = 1:size(out.TV,2)
        X{i} = out.TV(:,i); Y{i} = out.PV(:,i);
    end
    [han, X, Y, slope_stats] = line_plot_multisubject(X, Y,'group_avg_ref_line','center');
    % [han, X, Y, slope_stats] = line_plot_multisubject(X, Y,'group_avg_ref_line','center', 'colors', custom_colors(colors(3,:), [1 1 0.7], length(X)));
    set(gca,'linewidth', 1.5, 'fontsize', 18, 'tickdir', 'out');
    ax =gca; ax.TickLength = [0.03 0.03];
    h{1,3} = han.line_handles;    
    h{2,3} = han.point_handles
    xlabel('Ture Value (each implementation)', 'FontSize', 20);
    ylabel('Predicted Value (each implementation)', 'FontSize', 20);    
else
    currv = out.outcomes_each_fold(:,1);
    for i  = 1:length(currv)
        X{i} = currv{i}.tv; Y{i} = currv{i}.pv; 
    end    
    [han, X, Y, slope_stats] = line_plot_multisubject(X, Y,'group_avg_ref_line','center');
    set(gca,'linewidth', 1.5, 'fontsize', 18, 'tickdir', 'out');
    ax =gca; ax.TickLength = [0.03 0.03];
    h{1,3} = han.line_handles;    
    h{2,3} = han.point_handles;
    xlabel('Ture Value (each fold)', 'FontSize', 20);
    ylabel('Predicted Value (each fold)', 'FontSize', 20);
end

%% Figure 4: distribution of accuracy in across folds
currv = out.assessment_each_fold(:); clear v;
for i = 1:length(currv)
    v(i,1) = currv{i}.accuracy;
end

subplot(2,8,[7]);
[han, mu, sigma, q, notch] = al_goodplot(v, [], [], colors(4,:));
h{1,4} = han{1}; box off; grid off; 
set(gca,'linewidth', 1.5, 'fontsize', 18, 'tickdir', 'out');
ax =gca; ax.TickLength = [0.03 0.03];
ylabel('Accuracy across Folds', 'FontSize', 20);
xticklabels([]);

%% 
subplot(2,8,[8]);
al_goodplot([],0.5,[],colors(4,:));
axis off

%% Figure 5: bin plots
subplot(2,8,[9 10]);
h{1,5} = plot_multisubjBin(X, Y, 'colors', colors(5,:), 'colors_refline', [0.6 0.6 0.6],'nbins',bins,'reflinewidth',2);
set(gca,'linewidth', 1.5, 'fontsize', 18, 'tickdir', 'out');
ax =gca; ax.TickLength = [0.03 0.03];
xlabel('Ture Value (each fold)', 'FontSize', 20);
ylabel('Predicted Value (each fold)', 'FontSize', 20);

%% Figure 6: bootstrap
try
if isfield(out,'boot_Z') && ~isempty(out.boot_Z)
    subplot(2,8,[12 15]); clear v;
    v = out.boot_Z; [a,b] = sort(v,'descend');
    h{1,6} = scatter([1:numel(a)]',a,50,'MarkerEdgeColor',[.5 .5 .5],'MarkerFaceColor',colors(6,:),'LineWidth',1);
    line([1 numel(a)],[0 0],'LineStyle','--','Color','k','LineWidth',1);
    xlim([0 numel(a)+1]);
    pz = makeFDR(out.boot_p_z,0.05); pr = makeFDR(out.boot_p_ratio,0.05);  
    % z 
    if ~isempty(pz)
        mark_pz = zeros(1,numel(a)); mark_pz(out.boot_p_z<=pz) = 1; mark_pz = mark_pz(b);
        fp = find(a'>0 & mark_pz==1); kp = (a(max(fp)) + a(max(fp)+1))/2;
        fn = find(a'<0 & mark_pz==1); kn = (a(min(fn)) + a(min(fn)-1))/2;
        line([1 numel(a)],[kp kp],'LineStyle','--','Color','r','LineWidth',1);
        line([1 numel(a)],[kn kn],'LineStyle','--','Color','b','LineWidth',1);
        text(numel(a)+1, kp, 'FDR, p-z < 0.05', 'HorizontalAlignment', 'left');
        text(numel(a)+1, kn, 'FDR, p-z < 0.05', 'HorizontalAlignment', 'left');
    end
    % ratio
    if ~isempty(pr)
        mark_pr = zeros(1,numel(a)); mark_pr(out.boot_p_ratio<=pr) = 1; mark_pr = mark_pr(b);
        fp = find(a'>0 & mark_pr==1); kp = (a(max(fp)) + a(max(fp)+1))/2;
        fn = find(a'<0 & mark_pr==1); kn = (a(min(fn)) + a(min(fn)-1))/2;
        line([1 numel(a)],[kp kp],'LineStyle',':','Color','r','LineWidth',1);
        line([1 numel(a)],[kn kn],'LineStyle',':','Color','b','LineWidth',1);
        text(numel(a)+1, kp, 'FDR, p-ratio < 0.05', 'HorizontalAlignment', 'left');
        text(numel(a)+1, kn, 'FDR, p-ratio < 0.05', 'HorizontalAlignment', 'left');
    end
    set(gca,'linewidth', 1.5, 'fontsize', 18, 'tickdir', 'out');
    ax =gca; ax.TickLength = [0.03 0.03];
    ylabel('Z', 'FontSize', 20);
    xlabel('Features', 'FontSize', 20);
end
end