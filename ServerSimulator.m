classdef ServerSimulator
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        fmax
        betaSer
        alfa
        kSer

        J_ser
        E_ser
    end

    methods
        function obj = ServerSimulator(data_folder,fmax,alfa,betaSer,kSer)
            load(strcat(data_folder,"num_FLOPS_vs_SP.mat"));

            obj.J_ser = cumsum(FLOPS_DATA);
            obj.fmax = fmax;
            obj.alfa = alfa;
            obj.betaSer = betaSer;
            obj.kSer = 1.097e-27;

        end
        function [serverDelay,serverEnergy] = simulateServer(obj,A,k)
            freq = obj.fmax*unifrnd(1e-3,obj.alfa);
            serverDelay = obj.computeServerDelay(A,k,freq);
            serverEnergy = obj.computeServerEnergy(freq,serverDelay);
        end

        function [Drcomp] = computeServerDelay(obj,A,k,freq)
            residualNumberFlops = obj.J_ser(end)-obj.J_ser(k);
            Drcomp = (A*residualNumberFlops)/(obj.betaSer*freq);
        end

        function [serverEnergy] = computeServerEnergy(obj,freq,Drcomp)
            serverEnergy = obj.kSer*freq^3*Drcomp;
        end
    end
end