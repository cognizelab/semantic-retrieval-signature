function [pattern_correlation, mean_O, std_O, mean_OC, std_OC, mean_OE, std_OE] = mat_assess_stability(feature_weight)

if isempty(feature_weight) || size(feature_weight,2) < 2
    pattern_correlation = NaN;
    mean_O = NaN; std_O = NaN;
    mean_OC = NaN; std_OC = NaN;
    mean_OE = NaN; std_OE = NaN;
    return
end

r = corr(feature_weight,'Rows','pairwise'); 
pattern_correlation = local_nanmean(tri_oneD(r)); 

for i = 1:size(feature_weight, 2)
    % fFind the row indices of non-zero elements in column i
    support{i} = find(isfinite(feature_weight(:, i)) & feature_weight(:, i) ~= 0);  
end

n = size(feature_weight,1);

% support is a cell array containing the support sets of each subject
% n is the total number of voxels

% Number of subjects
ns = numel(support);
% Uncorrected overlap
O = zeros(ns,ns);
% Corrected overlap
OC = zeros(ns,ns);
% Relative overlap
OE = zeros(ns,ns);

for ks1 = 1:ns
   O(ks1,ks1) = 1;
   for ks2 = ks1+1:ns
      % Use the max(.,0) to avoid NaN from dividing by zero
      % O = |I_1 \cap I_2|/max(s1,s2)
      max_support = max(numel(support{ks1}),numel(support{ks2}));
      if max_support == 0
          O(ks1,ks2) = NaN;
      else
          O(ks1,ks2) = max(numel(intersect(support{ks1},support{ks2}))/max_support,0);
      end
      O(ks2,ks1) = O(ks1,ks2);
      E = numel(support{ks1})*numel(support{ks2})/n;
      if max_support == 0
          OC(ks1,ks2) = NaN;
      else
          OC(ks1,ks2) = O(ks1,ks2) - max(E/max_support,0);
      end
      OC(ks2,ks1) = OC(ks1,ks2);
      % OE = |I_1 \cap I_2|/E
      if E == 0
          OE(ks1,ks2) = NaN;
      else
          OE(ks1,ks2) = numel(intersect(support{ks1},support{ks2}))/E/n;
      end
      OE(ks2,ks1) = OE(ks1,ks2);
   end
end

dummy = squeeze(O(:,:));
dummy(1:ns+1:end) = [];
mean_O = local_nanmean(dummy(:));
std_O = local_nanstd(dummy(:));
dummy = squeeze(OC(:,:));
dummy(1:ns+1:end) = [];
mean_OC = local_nanmean(dummy(:));
std_OC = local_nanstd(dummy(:));
dummy = squeeze(OE(:,:));
dummy(1:ns+1:end) = [];
mean_OE = local_nanmean(dummy(:));
std_OE = local_nanstd(dummy(:));

end

%%
function C2 = tri_oneD(C,M,D)

if (nargin < 2)
	M = 1; D = 1;
end

if (nargin < 3);
	D = 1;
end

if isa(C,'cell') == 1
    C2 = {};
    z_oneD = {};
else
    C2 = [];
    z_oneD = [];
end

if M == 1
    o = 2;
elseif M ==2
    o = 1;
end
   
for c = 1:length(C)
    if D == 2
       z1 = C(:,c);
       z1 = z1(o:length(C));     
       o = o+1;
       z_oneD = [z_oneD;z1];
    elseif D == 1
           z1 = C(c,:);
           z1 = z1(o:length(C));     
           o = o+1;
           z_oneD = [z_oneD,z1];
    end
end

C2 = cat(2,C2,z_oneD);
end

function m = local_nanmean(x)

x = x(isfinite(x));
if isempty(x)
    m = NaN;
else
    m = mean(x);
end

end

function s = local_nanstd(x)

x = x(isfinite(x));
if numel(x) < 2
    s = NaN;
else
    s = std(x);
end

end
