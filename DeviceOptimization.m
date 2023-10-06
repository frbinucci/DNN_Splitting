classdef DeviceOptimization
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Wmax
        W_array
        E_array
        SP_array
        N0
        SNR_array
        V
        J_array
        mu
        ni
        lambda
        Dpeak
        pmax
        beta
        fmax
        fmin
        kappa
        roll_off
        G

        server
    end

    methods
        function obj = DeviceOptimization(data_folder,Wmax,roll_off,beta,fmax,fmin,kappa,N0,server,pmax,mu,ni,lambda,V)
            load(strcat(data_folder,"cumulative_energy_vs_SP.mat"))
            load(strcat(data_folder,"num_features_vs_SP.mat"))
            load(strcat(data_folder,"num_FLOPS_vs_SP.mat"))
            load(strcat(data_folder,"snr_array.mat"))
            load(strcat(data_folder,"accuracy_lut.mat"))
            load(strcat(data_folder,"splitting_points.mat"))
            
            obj.SP_array = splitting_points;
            obj.E_array = energy_split;
            obj.W_array = num_features;
            obj.J_array = cumsum(FLOPS_DATA);
            obj.SNR_array = 10.^(snr_array/10);
            obj.G = accuracy_lut;

            obj.roll_off = roll_off;

            obj.Wmax = Wmax;
            obj.N0 = N0;

            obj.mu = mu;
            obj.ni = ni;
            obj.lambda = lambda;
            obj.V = V;
            
            %Don't care at the moment!
            obj.Dpeak = 1;

            obj.pmax = pmax;
            obj.beta = beta;
            obj.fmax = fmax;
            obj.fmin = fmin;
            obj.kappa = kappa;
            obj.server = server;
        end

        function [Wstar,kStar,gammaStar,fStar] = optimizeDevice(obj,server,Z,M,Y,A,h)
            best_cost = inf;
            Wstar = 0;
            fStar = 0;
            kStar = 1;
            gammaStar = 1;
            for k=1:numel(obj.SP_array)
                for g=1:numel(obj.SNR_array)
                    if k>1
                        fbest = nthroot((obj.mu*Z+obj.ni*M/obj.Dpeak)/(2*obj.kappa*obj.V),3);
                        fbest = max(fbest,obj.fmin);
                        fbest = min(fbest,obj.fmax);
                        Dlcomp = obj.computeComputingDelay(A,k,fbest);
                    else
                        fbest = 0;
                        Dlcomp = 0;
                    end
                    if k<20
                        Wbest = min((obj.pmax*h^2)/(obj.SNR_array(g)*obj.N0),obj.Wmax);
                        Dtx = obj.computeTransmissionDelay(A,k,Wbest);
                    else
                        Wbest=0;
                        Dtx=0;
                    end
                    Dser = server.computeServerDelay(A,k);
                    transmissionEnergy = obj.computeTransmissionEnergy(Wbest,g,Dtx,h);
                    computationalEnergy = obj.computeComputationalEnergy(fbest,Dlcomp);
                    cost = obj.computeDeviceCost(Z,M,Y,Dlcomp,Dtx,Dser,g,k,transmissionEnergy,computationalEnergy);
                    if cost < best_cost
                        best_cost = cost;
                        Wstar = Wbest;
                        fStar = fbest;
                        gammaStar = g;
                        kStar = k;
                    end
                end
            end
        end
        function [computingDelay] = computeComputingDelay(obj,A,k,frequency)
            computingDelay = 0;
            if frequency>0
                computingDelay = (A*obj.J_array(k))/(obj.beta*frequency);
            end
        end
        function [transmissionDelay] = computeTransmissionDelay(obj,A,k,W)
            transmissionDelay = 0;
            if W>0
                transmissionDelay = (A*obj.W_array(k)*(1+obj.roll_off))/(2*W);
            end
        end
        function [transmissionEnergy] = computeTransmissionEnergy(obj,Wbest,g,Dtx,h)
            transmissionEnergy = ((obj.SNR_array(g)*obj.N0*Wbest)/(h^2))*Dtx;
        end
        function [computationalEnergy] = computeComputationalEnergy(obj,fbest,Dlcomp)
            computationalEnergy = obj.kappa*fbest^3*Dlcomp;
        end
        function [accuracy] = computeAccuracy(obj,k,g)
            accuracy = obj.G(g,k);
        end
        function [cost] = computeDeviceCost(obj,Z,M,Y,Dlcomp,Dtx,Dser,g,k,transmissionEnergy,computationalEnergy)
            cost = (obj.mu*Z+(obj.ni*M)/(obj.Dpeak))*(Dlcomp+Dtx+Dser)-obj.lambda*Y*obj.G(g,k)+obj.V*(transmissionEnergy+computationalEnergy);
        end

        function [obj] = selectSingleSNR(obj,snr_index)
            fprintf("You selected SNR = %d dB",10*log10(obj.SNR_array(snr_index)))
            obj.G = obj.G(snr_index,:);
        end
    end
end