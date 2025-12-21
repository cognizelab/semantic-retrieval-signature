function stat = nifti_statistic_image(weight,pvalue,template,mask)

if ischar(template)
    if nargin > 3 && ischar(mask)
        data = fmri_data(template); 
    else
        data = fmri_data(template,mask); 
    end
else
    data = template;
end

if size(weight,2) > 1
    weight = weight';
end
if size(pvalue,2) > 1
    pvalue = pvalue';
end    

stat = statistic_image();
stat.type = 'generic';
stat.p = pvalue;
stat.p_type = [];
stat.ste = [];
stat.threshold = [];
stat.thr_type = [];
stat.sig = logical(ones(numel(pvalue),1));
stat.N = [];
stat.dfe = [];
stat.image_labels = {};
stat.dat = weight;
stat.dat_descrip = [];
stat.volInfo = data.volInfo;
stat.removed_voxels = data.removed_voxels;
stat.removed_images = data.removed_images;
stat.image_names = [];
stat.fullpath = '';
stat.files_exist = 0;
stat.history = { };
 