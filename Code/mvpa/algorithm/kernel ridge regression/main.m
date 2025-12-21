clear all
close all
[Target,PHI,W,X] = PolynomialExpertToyData();
%Labels  should be from 1,.,K

RegulationTerm=1;

NumberSamples=length(Target);
%Number of Training Samples
NumberTraining=floor(NumberSamples*0.05);
%Number Validation Samples
NumberValidation =floor(NumberSamples*0.05);
%Number of testing Samples
NumberTesting=floor(NumberSamples*0.01);
% partition data into training validation data 
[ Train,Validation,Test] = GetTrainValidateTest(NumberSamples,NumberTraining,NumberValidation,NumberTesting);
 

Paramter=[1 2];
%Create a KernelRidgeRegressio object  
KernelRegression =KernelRidgeRegression(['poly'],X(Train),Paramter,Target(Train),1);

Out=KernelPrediction(KernelRegression ,X(Validation));

 figure 
plot(X(Validation),Out,'LineWidth',4)
hold on



plot(X(Train),Target(Train),'ro','LineWidth', 4)
%hold off
legend('Output of Model Using Validation Data ','Training Samples')
title('Validation Results')
