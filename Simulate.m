clear vars
close all

output_dir = "./VariableAccuracyConstraints/Acc70";
mkdir(output_dir);

%Definition of the simulation parameters
t_sim = 10000;
N0 = 3.98e-18;
pmax = 0.1; 
fmin = 1.4e8;
fmax = 1.4e9;
roll_off = 0.25;
betaDev = 500;
betaSer = 2000;
kappa = 1.097e-27;
Wmax = 5e6;

%Average arrivals
Aavg = 5;

%Don't care.
Dpeak = 0;
outage = 0;

%Latency Constraint
Davg = 20e-3;
%Accuracy Constraint
Gavg = 0.7;

%Server Parameters
fSer = 4.5e9;
alfaSer = 1;

%Lyapunov Parameters
v_vector = [1e2,2e2,5e2,1e3,2e3,5e3,1e4,2e4,5e4,1e5,2e5,5e5,1e6];
ni_vector = 0*ones(1,numel(v_vector));
mu_vector = 100*ones(1,numel(v_vector));
lambda_vector = 1*ones(1,numel(v_vector));

%Generating Channel 
%PL 90 dB exponentLoss=2, dmax = 100
%PL 100 dB exponentLoss=2, dmax = 500
%PL 110 dB exponentLoss=20, dmax = 1500
exponentLoss = 1;
dmax = 1500;
fc = 5e9;
pl = 10*exponentLoss*log10(dmax)+10*exponentLoss*log10(fc)-147.55;
%pl_linear = 10^(-pl/10);
pl_linear = 10^(-9);

sigma = sqrt(2/(4-pi));
h = abs(sigma*randn(1,t_sim)+1i*sigma*randn(1,t_sim));
h = sqrt(pl_linear)*h;

%Simulation tracker

Z = 1;
M = 0;
Y = 0;

for v=1:numel(v_vector)
    computationalEnergyTracker = zeros(1,t_sim);
    serverEnergyTracker = zeros(1,t_sim);
    transmissionEnergyTracker = zeros(1,t_sim);
    transmissionLatencyTracker = zeros(1,t_sim);
    localCalculationLatencyTracker = zeros(1,t_sim);
    remoteCalculationLatencyTracker = zeros(1,t_sim);
    splittingPointTracker = zeros(1,t_sim);
    Ztracker = zeros(1,t_sim);
    Ytracker = zeros(1,t_sim);
    Mtracker = zeros(1,t_sim);
    server = ServerSimulator("./Data/",fSer,alfaSer,betaSer,kappa);
    device = DeviceOptimization("./Data/",Wmax,roll_off,betaDev,fmax,fmin,kappa,N0,server,pmax,mu_vector(v),ni_vector(v),lambda_vector(v),v_vector(v));
    %device.selectSingleSNR(2)
    for ts=1:t_sim
        A = poissrnd(Aavg);
        server = server.updateFrequency();
        [WStar,kStar,gammaStar,fStar] = device.optimizeDevice(server,Z,M,Y,A,h(ts));
        [serverDelay,serverEnergy] = server.simulateServer(A,kStar);
        Dl = device.computeComputingDelay(A,kStar,fStar);
        Dtx = device.computeTransmissionDelay(A,kStar,WStar);
        Dr = serverDelay;
        Ecomp = device.computeComputationalEnergy(fStar,Dl);
        Etx = device.computeTransmissionEnergy(WStar,gammaStar,Dtx,h(ts));
        Eser = serverEnergy;

        accuracy = device.computeAccuracy(kStar,gammaStar);

        Dtot = Dl+Dtx+Dr;

        Ztracker(ts) = Z;
        Ytracker(ts) = Y;
        Mtracker(ts) = M;

        %Updating energy trackers
        computationalEnergyTracker(ts) = Ecomp;
        transmissionEnergyTracker(ts) = Etx;
        serverEnergyTracker(ts) = Eser;
        
        %Updating latency trackers
        remoteCalculationLatencyTracker(ts) = Dr;
        localCalculationLatencyTracker(ts) = Dl;
        transmissionLatencyTracker(ts) = Dtx;

        %Updating Splitting Point tracker
        splittingPointTracker(ts) = kStar;

        Z = max(0,Z+mu_vector(v)*(Dtot-Davg));

        Y = max(0,Y+lambda_vector(v)*(Gavg-accuracy));
        M = max(0,M+ni_vector(v)*(heaviside(Dtot-Dpeak)-outage));
    end
    
    simulation.computationalEnergyArray = computationalEnergyTracker;
    simulation.transmissionEnergyArray = transmissionEnergyTracker;
    simulation.localCalculationLatencyArray = localCalculationLatencyTracker;
    simulation.transmissionLatencyArray = transmissionLatencyTracker;
    simulation.serverEnergyArray = serverEnergyTracker;
    simulation.serverLatencyArray = remoteCalculationLatencyTracker;
    simulation.ZArray = Ztracker;
    simulation.YArray = Ytracker;
    simulation.Marray = Mtracker;
    simulation.kArray = splittingPointTracker;
    save(strcat(output_dir,'/simulation',num2str(v_vector(v)),'.mat'),'simulation');
end



