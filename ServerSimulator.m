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
        freq
    end

    methods
        function obj = ServerSimulator(data_folder,fmax,alfa,betaSer,kSer)
            load(strcat(data_folder,"num_FLOPS_vs_SP.mat"));

            obj.J_ser = cumsum(FLOPS_DATA);
            obj.fmax = fmax;
            obj.alfa = alfa;
            obj.betaSer = betaSer;
            obj.kSer = kSer;
            obj.freq = obj.fmax*unifrnd(1e-3,obj.alfa);

        end
        function [obj] = updateFrequency(obj)
            obj.freq = obj.fmax*unifrnd(1e-3,obj.alfa);
        end
        function [serverDelay,serverEnergy] = simulateServer(obj,A,k)
            serverDelay = obj.computeServerDelay(A,k);
            serverEnergy = obj.computeServerEnergy(serverDelay);
        end

        function [Drcomp] = computeServerDelay(obj,A,k)
            residualNumberFlops = obj.J_ser(end)-obj.J_ser(k);
            Drcomp = (A*residualNumberFlops)/(obj.betaSer*obj.freq);
        end

        function [serverEnergy] = computeServerEnergy(obj,Drcomp)
            serverEnergy = obj.kSer*obj.freq^3*Drcomp;
        end
    end
end