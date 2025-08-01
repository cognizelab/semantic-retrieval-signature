Surface: The semantic retrieval signature in CIFTI format across all participants for each trial.

*   T-PLS (main predictive model based on Thresholded Partial Least Squares)

    *   **z\_stat\_predictive\_weight\_map\_semantic\_retrieval\_signature.dscalar.nii**: The Z-statistic map based on bootstrapped predictive weights, which represents the semantic retrieval signature in the study (and can be generalized to other samples through methods such as dot product).
    *   z\_stat\_activation\_map\_semantic\_retrieval\_signature.dscalar.nii: The Z-statistic map based on bootstrapped Haufe-transformed activation maps.
    *   mask\_weight\_FDR05.dscalar.nii: The weight map surviving at the significance level of FDR p < 0.05.
    *   mask\_activation\_FDR05.dscalar.nii: The activation map surviving at the significance level of FDR p < 0.05.
    *   **mask\_overlap\_FDR05.dscalar.nii**: The overlap between the weight map and activation map masks defines the primary ROIs of interest in the study.&#x20;
*   SVR (supplementary predictive model based on Support Vector Regression)

    *   z\_stat\_predictive\_weight\_map\_semantic\_retrieval\_signature.dscalar.nii: The Z-statistic map based on bootstrapped predictive weights.
    *   z\_stat\_activation\_map\_semantic\_retrieval\_signature.dscalar.nii: The Z-statistic map based on bootstrapped Haufe-transformed activation maps.
    *   mask\_weight\_FDR05.dscalar.nii: The weight map surviving at the significance level of FDR p < 0.05.
    *   mask\_activation\_FDR05.dscalar.nii: The activation map surviving at the significance level of FDR p < 0.05.

Volume: The semantic retrieval signature in NIFTI format across all participants for each trial.

*   T-PLS (main predictive model based on Thresholded Partial Least Squares)

    *   z\_stat\_predictive\_weight\_map\_semantic\_retrieval\_signature.dscalar.nii: The Z-statistic map based on bootstrapped predictive weights.
    *   mask\_weight\_FDR05.dscalar.nii: The weight map surviving at the significance level of FDR p < 0.05.

***

Note: The two versions of neural signatures were derived by applying the same T-PLS model parameters separately to surface and volumetric spaces, resulting in distinct spatial implementations of the signature. No spatial transformation techniques were employed in this process.
