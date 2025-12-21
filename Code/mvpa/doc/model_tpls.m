%% Thresholded Partial Least Squares (TPLS)
% Train the TPLS model for binary classification or regression tasks.
% The parameters of components and thresholds can be fine-tuned through 'param.compvec' and 'param.threshvec'.
%% Input
%       >>> param.compvec: number of components to be retained
%       >>> param.threshvec: what percentage of the most important features should be retained?
%       >>> param.po_tpls: 1 = execute the default parameter optimization strategy of the toolkit  
%       >>> param.opt_type: parameter optimization
%                           'negMSE': use the 'negMSE' method for parameter optimization instead of other methods
%                           'combine': combine the 'negMSE' and accuracy based methods for parameter optimization
%                           []: use accuracy based methods for parameter optimization
%% Reference
% Citation: Lee, S., Bradlow, E. T., & Kable, J. W. (2022). Fast Construction of Interpretable Whole-brain Decoders. Cell Reports Methods.