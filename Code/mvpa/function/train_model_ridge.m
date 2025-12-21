function out_train = train_model_ridge(xtrain,ytrain,parameter)

out_train.model = ridge_regression(xtrain,ytrain,parameter);
out_train.parameter = parameter; out_train.parameter_label = 'lambda';
out_train.feature_weight = out_train.model;
 