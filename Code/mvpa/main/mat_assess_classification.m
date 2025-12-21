function model_quality = mat_assess_classification(TV,PV,w,param)
%%
%--------------------------------------------------------------------------
%                                 Predicted Category    Total                                 
%                                    1         -1
%
%                         1          TP        FN         P                   
%       True Category 
%                        -1          FP        TN         N
%
%                       Total        P'        N'        P+N
%--------------------------------------------------------------------------
%  [A]  Accuracy = ( TP + TN )/( P + N )
%  [E]  Error Rate = ( FP + FN )/( P + N ) = 1 - Accuracy
%  [S1] Sensitive = TP/P
%  [S2] Specificity = TN/N
%  [P]  Precision = TP/P'
%  [R]  Recall = TP/P = Sensive 
%--------------------------------------------------------------------------

%%
if nargin < 3; w = 0; end
if nargin < 4; param = struct(); end

if w ~= 1
    C = confusionmat(TV, PV);
    TP = C(2,2);
    FN = C(2,1);
    FP = C(1,2);
    TN = C(1,1);
    
    TPR = TP / (TP + FN);  % Sensitive/Recall
    FNR = FN / (TP + FN);
    FPR = FP / (FP + TN);
    TNR = TN / (FP + TN);  % Specificity
    
    accuracy = (TP + TN) / (TP + FN + FP + TN);
    error_rate = 1 - accuracy;
    precision = TP/(TP + FP);
    
    % [~,~,~,AUC] = perfcurve(TV,PV,1);   
     
    model_quality.accuracy = accuracy;
    model_quality.error_rate = error_rate;
    model_quality.precision = precision;
    model_quality.specificity = TNR;
    model_quality.sensitivity = TPR;
    
    model_quality.TPR = TPR;
    model_quality.FNR = FNR;
    model_quality.FPR = FPR;
    model_quality.TNR = TNR;
else
    if isfield(param,'twochoice') && param.twochoice == 1
        ROC = roc_plot_2020(PV,logical(TV),'noplot','nooutput','twochoice');
    else
        ROC = roc_plot_2020(PV,logical(TV),'noplot','nooutput');
    end
    % d = cohens_d_2sample(PV,logical(TV));
    model_quality.AUC = ROC.AUC;
    model_quality.specificity = ROC.sensitivity;
    model_quality.sensitivity = ROC.specificity;
    model_quality.accuracy = ROC.accuracy;
    model_quality.accuracy_p = ROC.accuracy_p;
    model_quality.accuracy_se = ROC.accuracy_se;
    model_quality.Cohen_d = ROC.Gaussian_model.d_a;
end