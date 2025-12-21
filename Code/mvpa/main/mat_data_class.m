function [cgroup] = data_class(value,class,v)
%% Data Classification
%% -------------------------------------------------------------------------------------------------------------------------------
%% Input
%  (1) value: classification basis (double array data for categorical or continuous variables)
%  (2) class: classification method ('cat'\'bin','window')
%  (3) v: for "class = bin", v should be the number bins;
%         for "class = window", v(1) is the length and v(2) is the step width of windows
%% Output
%  (1) cgroup: Data Classification ID 
%% Example
%  cgroup = data_class([1:100],'window',[10 2]);
%% -------------------------------------------------------------------------------------------------------------------------------
% - Z.K.X. 2021/06/04 (MATLAB R2018a)
%% -------------------------------------------------------------------------------------------------------------------------------
cgroup = [];
if strcmp(class,'cat')
   g = unique(value);
   for i = 1:length(g)
       f = find(value==g(i));
       cgroup = [cgroup;f];
   end
elseif strcmp(class,'bin') 
    edges = linspace(min(value), max(value), v+1);
    cgroup = discretize(value, edges);
elseif strcmp(class,'window') 
   g = unique(value);
   g = sort(g);
   P = sliding_window(g,v(1),v(2));
   for i = 1:size(P,1)
       f = P(i,:);
       cgroup = [cgroup;f];
   end  
end

end

function P = sliding_window(A,L,W)
%%
% A: vector of data
% L: length of windows 
% W: step width 

if mod(length(A) - L,W) > 0
    N = fix((length(A) - L)/W) + 1;
else
    N = (length(A) - L)/W;
end
     
clear P; P(1,:) = A(1:L);
ep = L;

for i = 1:N   
    if ep+W <= length(A)
        c = P(i,:); c(1:W) = []; 
        c = [c,A([ep+1:ep+W])];
    else
        c = A([length(A)-L+1:length(A)]);
    end
    P(i+1,:) = c;
    ep = ep + W;
end    
end