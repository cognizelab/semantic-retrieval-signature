function out_train = train_model_lm(xtrain,ytrain)

out_train.model = regress(ytrain,xtrain);
out_train.parameter = []; out_train.parameter_label = [];
out_train.feature_weight = out_train.model;
 