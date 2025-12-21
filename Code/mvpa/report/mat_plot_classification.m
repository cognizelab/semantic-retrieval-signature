function h = mat_plot_classification(out,opt) 

%% Default setting
if nargin < 2; opt = struct; end
if ~isfield(opt,'colors') || isempty(opt.colors)
    colors = [0.5529 0.6275 0.7961; 0.9882 0.5529 0.3843; 0.8353 0.3647 0.4980];
end
if size(colors,1) == 1
    colors = repmat(colors,6,1);
end

%% AUC across repetations
subplot(2,8,[1 2]); hold on

clear labels scores
for i = 1:size(out.TV,2)
    labels{i,1} = out.TV(:,i);
    scores{i,1} = out.PW(:,i);
end

% https://www.mathworks.com/help/stats/rocmetrics.html

if length(labels) > 1
    rocObj = rocmetrics(labels,scores,1);
else
    rocObj = rocmetrics(labels{1},scores{1},1);
end
h{1} = plot(rocObj,ShowConfidenceIntervals=true);

set(gca,'linewidth', 1.5, 'fontsize', 18, 'tickdir', 'out');
ax =gca; ax.TickLength = [0.03 0.03];

title(''); legend('off');
xlabel('False Positive Rate', 'FontSize', 20);
ylabel('True Positive Rate', 'FontSize', 20);

h{1}.Color = colors(1,:);
h{1}.LineWidth = 1;

meanValue = max(out.model_quality.AUC); % best model
diffs = abs(out.model_quality.AUC-meanValue);
[~,idx] = min(diffs);

target = out.TV(:,idx)'; dvs = out.PW(:,idx)'; target(target==0) = -1;
[TPR_bin,FPR_bin,PPV_bin] = prc_stats_binormal(target,dvs,false);
plot(FPR_bin, TPR_bin, '-', 'color', colors(1,:), 'linewidth', 3);

%% Distribution of decision values
subplot(2,8,[4 5]); hold on

muN = -1; sigmaN = std(dvs(target==-1));     
muP = 1; sigmaP = std(dvs(target==1));     

binWidth = 0.5;
pdfRange = [muN-3*sigmaN:0.01:muP+3*sigmaP];
h{2,1} = prc_conthist(dvs(target==-1), binWidth, colors(2,:), 3);
h{2,2} = prc_conthist(dvs(target==+1), binWidth, colors(3,:), 3);

h{2,3} = plot(pdfRange, normpdf(pdfRange, muN, sigmaN)*binWidth*sum(target==-1), 'linewidth', 3, 'color', colors(2,:));
h{2,4} = plot(pdfRange, normpdf(pdfRange, muP, sigmaP)*binWidth*sum(target==+1), 'linewidth', 3, 'color', colors(3,:));

set(gca,'linewidth', 1.5, 'fontsize', 18, 'tickdir', 'out');
ax =gca; ax.TickLength = [0.03 0.03];

xlabel('Decision Value', 'FontSize', 20);
ylabel('Density/ Frequency', 'FontSize', 20);

%% Two group comparison
if isfield(out,'value_twochoice') && ~isempty(out.value_twochoice)
    subplot(2,8,[7 8]);  
    plot_specificity_box_2020(out.value_twochoice(:,1),out.value_twochoice(:,2),'colors',colors([3 2],:),'linecolors',colors([3 2],:));
    xticklabels({'Group A','Group B'});
    set(gca,'linewidth', 1.5, 'fontsize', 18, 'tickdir', 'out');
    ax =gca; ax.TickLength = [0.03 0.03];
    ylabel('Pattern Expression', 'FontSize', 20);
end

%% AUC across folds
subplot(2,8,[9 10]); hold on

data = out.outcomes_each_fold(:);
data_assessment = out.assessment_each_fold(:);

clear labels scores
for i = 1:length(data)
    labels{i,1} = data{i}.tv;
    scores{i,1} = data{i}.dp;
    AUC(i) = data_assessment{i}.W.AUC;
end

rocObj = rocmetrics(labels,scores,1);
h{1} = plot(rocObj,ShowConfidenceIntervals=true);
set(gca,'linewidth', 1.5, 'fontsize', 18, 'tickdir', 'out');
ax =gca; ax.TickLength = [0.03 0.03];

title(''); legend('off');
xlabel('False Positive Rate (each fold)', 'FontSize', 20);
ylabel('True Positive Rate (each fold)', 'FontSize', 20);

h{1}.Color = colors(1,:);
h{1}.LineWidth = 1;

meanValue = mean(AUC);
diffs = abs(AUC-meanValue);
[~,idx] = min(diffs);

target = labels{idx}'; dvs = scores{idx}'; target(target==0) = -1;
[TPR_bin,FPR_bin,PPV_bin] = prc_stats_binormal(target,dvs,false);
plot(FPR_bin, TPR_bin, '-', 'color', colors(1,:), 'linewidth', 3);

%% Bootstrap
if isfield(out,'boot_Z') && ~isempty(out.boot_Z)
    subplot(2,8,[12 15]); clear v;
    v = out.boot_Z; [a,b] = sort(v,'descend');
    h{1,6} = scatter([1:numel(a)]',a,50,'MarkerEdgeColor',[.5 .5 .5],'MarkerFaceColor',colors(3,:),'LineWidth',1);
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
    ylabel('Z', 'FontSize', 20);
    xlabel('Features', 'FontSize', 20);
end