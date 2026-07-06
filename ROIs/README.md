# ROIs

This directory contains ROI resources used to characterize the semantic distance
signature across cortical parcels and functional systems.

## Files

- `Glasser_2016.32k.L.label.gii` and `Glasser_2016.32k.R.label.gii`: left and
  right hemisphere labels from the Multi-Modal Parcellation (MMP) atlas.
- `ROI_labels.mat`: MATLAB file containing `roi_id`, the significant MMP parcel
  indices in the semantic distance signature.
- `ROI_id_surface.mat`: MATLAB file containing `system_id`, the functional
  system assignment for each ROI, and `roilabel`, the corresponding MMP label.
- `Signature_ROI.dlabel.nii`: CIFTI label file for the signature ROIs.
- `ROI-masks-volume.rar`: compressed NIFTI version of the ROI masks.

These files support the manuscript parcel-level, network-level, functional
system, RSA, and representational connectivity analyses.
