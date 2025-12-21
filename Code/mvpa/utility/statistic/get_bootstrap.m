function [f,o] = bootstrap_zkx(in)
%%
s = size(in);     
if min(s) == 1  
   f = in(ceil(max(s)*rand(max(s),1)));    
else         
   f = in(ceil(s(1)*s(2)*rand(s(1),s(2),1))); 
end
o = setdiff(in,f);
end