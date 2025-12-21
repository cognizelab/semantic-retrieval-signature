classdef KernelRidgeRegression
    %KernelRidgeRegression: This function used to create a  the function Kernel Ridge Regression involves inverting
    %a large matrix, therefore in this code after inputting the kernel, kernel parameters and training data in object is created
    
    properties
        %Type of kennel
        Kernel;
        %parameters of kernel
        Parameters;
        %training samples
        TrainingSamples;
        % vector corresponding to (K+labda*I)^-1 ( Target)
        Train;
           %this is dummy varable For parameters 
        Dummy;
        
 
    end
    
    methods
        %Constructer
        function KernelRegression =KernelRidgeRegression(ker,X,parameters,Target,RegulationTerm);
            %       ker: 'lin','poly','rbf','sam'
            %       X: data matrix with training samples in rows and features in columns
            
            %parameters:
                  %If RBF kernel or sam kernel must be one value 
                  %sigma: width of the RBF kernel
                  
                 % for polynomial kernel 'poly' the paramters are in the
                 % form  parameters=[b a]
                 %       b:     bias in the linear and polinomial kernel
                 %       d:     degree in the polynomial kernel
           
                 %Linear kernels 'lin' parameters=b;
                 %       b:     bias in the linear and polinomial kernel
            
            
            %Target:row vector of continuous values to be predicted
          
            % %K:Gram matrix, each element corresponds to the kernel of two feature vectors
            
            
            if (strcmp(ker,'rbf')||strcmp(ker,'sam'))
            
            if  length(parameters)~=1
               error('Error: RBF kernel and Sam kennel only needs one parameter') 
            end
                
            b=1;
            d=1;
           sigma=parameters;
            K = kernelmatrix(ker,X',X',sigma,b,d);
            
            end
             
            if strcmp(ker,'poly')
            if  length(parameters)~=2
               error('Error: polynomial kernels need two parameters') 
            end
                
            sigma=1;
           b=parameters(1);
           d=parameters(2);
            K = kernelmatrix(ker,X',X',sigma,b,d);
            
            end
            if strcmp(ker,'lin')
            if  length(parameters)~=2
               error('Error: Linear kernels only need one parameter') 
            end
                
            sigma=1;
             d=1;     
           b=parameters(1);
           
            K = kernelmatrix(ker,X',X',sigma,b,d);
            
            
            end
            
            
            
            %Regulation matrix
            RegularizationMatrix=eye(length(K(:,1)));
         
            %Name of kernel
            KernelRegression.Kernel=ker;
            %store Parameters
            KernelRegression.Parameters=parameters;
            %Store training parameters
            KernelRegression.TrainingSamples=X';
            %This is the vector of  parameters (K+labda I)^-1 Targets
            KernelRegression.Train=((K+RegulationTerm*RegularizationMatrix)^-1)*Target;
            
            KernelRegression.Dummy=[sigma,b,d];
            
            
            
        end
        
        function [Prediction,Kt] = KernelPrediction(KernelRegression,X)
            %This is a matrix where each index corresponds the Kernel between the training samples and the samples you world like a preddication for
            %each rowe  eorresponds to a training sample and each column corresponds to a sample that you would like a prediction for
            Kt = kernelmatrix(KernelRegression.Kernel,KernelRegression.TrainingSamples,X',KernelRegression.Dummy(1),KernelRegression.Dummy(2),KernelRegression.Dummy(3));
            Prediction =Kt'*KernelRegression.Train;
        end
      
    end
    
    
    
end

function K = kernelmatrix(ker,X,X2,sigma,b,d)
            % With Fast Computation of the RBF kernel matrix
            % To speed up the computation, we exploit a decomposition of the Euclidean distance (norm)
            %
            % Inputs:
            %       ker:    'lin','poly','rbf','sam'
            %       X:      data matrix with training samples in rows and features in columns
            %       X2:     data matrix with test samples in rows and features in columns
            %       sigma: width of the RBF kernel
            %       b:     bias in the linear and polinomial kernel
            %       d:     degree in the polynomial kernel
            %
            % Output:
            %       K: kernel matrix
            %
            % Gustavo Camps-Valls
            % 2006(c)
            % Jordi (jordi@uv.es), 2007
            % 2007-11: if/then -> switch, and fixed RBF kernel
            switch ker
                case 'lin'
                    if exist('X2','var')
                        K = X' * X2;
                    else
                        K = X' * X;
                    end
                    
                case 'poly'
                    if exist('X2','var')
                        K = (X' * X2 + b).^d;
                    else
                        K = (X' * X + b).^d;
                    end
                    
                case 'rbf'
                    
                    n1sq = sum(X.^2,1);
                    n1 = size(X,2);
                    
                    if isempty(X2);
                        D = (ones(n1,1)*n1sq)' + ones(n1,1)*n1sq -2*X'*X;
                    else
                        n2sq = sum(X2.^2,1);
                        n2 = size(X2,2);
                        D = (ones(n2,1)*n1sq)' + ones(n1,1)*n2sq -2*X'*X2;
                    end;
                    K = exp(-D/(2*sigma^2));
                    
                case 'sam'
                    if exist('X2','var');
                        D = X'*X2;
                    else
                        D = X'*X;
                    end
                    K = exp(-acos(D).^2/(2*sigma^2));
                    
                otherwise
                    error(['Unsupported kernel ' ker])
            end
   
            
        end

