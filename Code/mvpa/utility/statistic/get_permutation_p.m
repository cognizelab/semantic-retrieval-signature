function p = get_permutation_p(tvalue,rvalue,direction)

if nargin < 3 || isempty(direction)
    direction = 'two';
end

v = [tvalue;rvalue(:)];

if strcmp(direction,'left') || (strcmp(direction,'two') & tvalue <= mean(rvalue))  
    [a,b] = sort(v); f = find(b==1);
    p = f/numel(v);
elseif strcmp(direction,'right') || (strcmp(direction,'two') & tvalue > mean(rvalue))  
    [a,b] = sort(v,'descend'); f = find(b==1);
    p = f/numel(v); 
end

if strcmp(direction,'two')
    p = p*2;
end

end