function out_train = train_model_krr(xtrain,ytrain,parameter)

out_train.model = KernelRidgeRegression('lin',xtrain,[1 1],ytrain,parameter);
out_train.parameter = parameter; out_train.parameter_label = 'lambda';
feature_model_weight = [];
 