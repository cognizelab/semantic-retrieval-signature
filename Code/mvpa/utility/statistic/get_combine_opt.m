function [d,d_opt,f1,f2] = get_combine_opt(A,B,k)

if k == 0
    k = [0 0];
else
    k = [1 1];
end

a = rescale(A); b = rescale(B);

for i = 1:size(A,1)
    for j = 1:size(A,2)
        d(i,j) = pdist2([a(i,j),b(i,j)],k);
    end
end

if k(1) == 1
    [f1,f2] = find(d==min(d(:)));
else
    [f1,f2] = find(d==max(d(:)));
end

d_opt = d(f1,f2);