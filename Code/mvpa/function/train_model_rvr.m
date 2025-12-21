function out_train = train_model_rvr(xtrain,ytrain)

[w,out_train.model] = W_Calculate_RVR(xtrain,ytrain',[],'None');
out_train.feature_weight = w';
out_train.parameter = []; out_train.parameter_label = [];
