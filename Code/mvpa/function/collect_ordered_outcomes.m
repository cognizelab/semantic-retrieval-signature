function [TV, PV, PW] = collect_ordered_outcomes(out_apply_col, nSubject)
% COLLECT_ORDERED_OUTCOMES  Collect fold predictions in subject-index order.

if nargin < 2
    nSubject = [];
end

out_apply_col = out_apply_col(:);
valid = false(numel(out_apply_col), 1);

for i = 1:numel(out_apply_col)
    valid(i) = isstruct(out_apply_col{i}) && ...
        isfield(out_apply_col{i}, 'tv') && isfield(out_apply_col{i}, 'pv');
end

if ~any(valid)
    TV = [];
    PV = [];
    PW = [];
    return;
end

hasSubjectIndex = true;
for i = find(valid)'
    hasSubjectIndex = hasSubjectIndex && ...
        isfield(out_apply_col{i}, 'subject_index') && ...
        ~isempty(out_apply_col{i}.subject_index);
end

if hasSubjectIndex
    [TV, PV, PW] = collectBySubjectIndex(out_apply_col, valid, nSubject);
else
    [TV, PV, PW] = collectByFoldOrder(out_apply_col, valid);
end
end

function [TV, PV, PW] = collectBySubjectIndex(out_apply_col, valid, nSubject)
firstIdx = find(valid, 1, 'first');
first = out_apply_col{firstIdx};

if isempty(nSubject)
    nSubject = 0;
    for i = find(valid)'
        curr = out_apply_col{i};
        nSubject = max(nSubject, max(curr.subject_index(:)));
        if isfield(curr, 'n_subject') && ~isempty(curr.n_subject)
            nSubject = max(nSubject, curr.n_subject);
        end
    end
end

TV = nan(nSubject, size(first.tv, 2));
PV = nan(nSubject, size(first.pv, 2));

hasPW = isfield(first, 'dp') && ~isempty(first.dp);
if hasPW
    PW = nan(nSubject, size(first.dp, 2));
else
    PW = [];
end

for i = find(valid)'
    curr = out_apply_col{i};
    idx = curr.subject_index(:);
    TV(idx, :) = curr.tv;
    PV(idx, :) = curr.pv;

    if hasPW && isfield(curr, 'dp') && ~isempty(curr.dp)
        PW(idx, :) = curr.dp;
    end
end
end

function [TV, PV, PW] = collectByFoldOrder(out_apply_col, valid)
TV = [];
PV = [];
PW = [];

for i = find(valid)'
    curr = out_apply_col{i};
    TV = [TV; curr.tv];
    PV = [PV; curr.pv];
    if isfield(curr, 'dp') && ~isempty(curr.dp)
        PW = [PW; curr.dp];
    end
end
end
