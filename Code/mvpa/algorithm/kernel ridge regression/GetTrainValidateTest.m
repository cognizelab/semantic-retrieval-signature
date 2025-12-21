function [ Train,Validation,Test] = GetTrainValidateTest(NumberSamples,NumberTraining,NumberValidation,NumberTesting)
%This function randomly partitions data into training, validation and testing data using Cross Validation.
%partitioning data in this manner is commonly used for determining the performance of algorithms with free parameters.
%Training data is commonly used to train the system, the optimum value for the free parameters are determined using validation data.
%Finally the results of the algorithm determined using testing data.This function is different than Matlab in that you enter the number
%of elements for each set
%Input%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%NumberSamples: number of samples in your data set
%NumberTraining: number of training examples
%NumberValidation: number of validation examples
%NumberTesting: number of test examples
%such that :NumberSamples> NumberTraining> NumberValidation>NumberTesting
%Output%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%Train: Logical index column vectors for training data
%Validation:  Logical index column vectors for validation data
%Test:  Logical index column vectors for testing data

%by: Joseph Santarcangelo 19/11/2014
%Also see: crossvalind

% Initialize ouput variables  
Train=zeros(NumberSamples,1);
Validation=zeros(NumberSamples,1);
Test=zeros(NumberSamples,1);

%Proportion of training data
TrainProportion= (1-NumberTraining/NumberSamples);
%Partition data into training and other, then partition Other into validation and testing data, other is just a dummy variable
%Other={ validation, test}
[Train, Othere] = crossvalind('HoldOut', NumberSamples,TrainProportion);

%index of data points in other
IndexOthere=find(Othere==1);
%Number of data points used for training and testing
SizeOthere=length(IndexOthere);
%Proportion of data in the set other used in validation
ValidationProportion=NumberTesting/NumberValidation;
%Partition into Validation data and testing data
[ValidationDummy ,TestDummy]=crossvalind('HoldOut', SizeOthere,ValidationProportion);

%logical index vectors for validation data
Validation(IndexOthere(ValidationDummy))=1;

% logical index vectors for test data
Test(IndexOthere(TestDummy))=1;
Validation=logical(Validation);
Test=logical(Test);
end
