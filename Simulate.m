clear vars
close all
snr_names = ["SNRNeg5","SNRNeg4","SNRNeg3","SNRNeg2","SNR0","SNR5","SNR10","SNR20"];

rng(46);
snr_index = 1:8;
sp_index = [11];

path_loss_db = 90;
fixed_snr = true;
opt_acc = true;
accuracy_const = 85;
realizations = 1;
comparison_type = "SP";
basename = './SplittingPointComparison'

if strcmp("SNR", comparison_type)
    if numel(snr_index)==1
        output_dir = strcat(basename,"Fixed","/PathLoss",num2str(path_loss_db),"/",snr_names(snr_index),"/Acc",num2str(accuracy_const),"/");
    else
        output_dir = strcat(basename,"/PathLoss",num2str(path_loss_db),"/Acc",num2str(accuracy_const),"/");
    end
end

if strcmp("SP", comparison_type)
    if numel(sp_index)==1
        output_dir = strcat(basename,"Fixed","/PathLoss",num2str(path_loss_db),"/","SP",num2str(sp_index),"/Acc",num2str(accuracy_const),"/");
    else
        output_dir = strcat(basename,"/PathLoss",num2str(path_loss_db),"/Acc",num2str(accuracy_const),"/");
    end
end
mkdir(output_dir);

%Definition of the simulation parameters
t_sim = 10000;
N0 = 3.98e-18;
pmax = 0.3; 
fmin = 0;
fmax = 1.4e9;
roll_off = 0.25;
betaDev = 50;
betaSer = 2000;
kappa = 1.097e-27;
Wmax = 10e6;

%Tx and computational weights
tx_weight = 1;
comp_weight = 1;

%Average arrivals
Aavg = 5;

%Don't care.
Dpeak = 0;
outage = 0;

%Latency Constraint
Davg = 120e-3;
%Accuracy Constraint
Gavg = accuracy_const/100;

%Server Parameters
fSer = 4.5e9;
alfaSer = 1;

%Lyapunov Parameters
v_vector = [1e8];
ni_vector = 0*ones(1,numel(v_vector));
mu_vector = 4e2*ones(1,numel(v_vector));
lambda_vector =2e2*opt_acc*ones(1,numel(v_vector));

%Generating Channel 
%PL 90 dB exponentLoss=2, dmax = 100
%PL 100 dB exponentLoss=2, dmax = 500
%PL 110 dB exponentLoss=20, dmax = 1500
exponentLoss = 1;
dmax = 1500;
fc = 5e9;
pl = 10*exponentLoss*log10(dmax)+10*exponentLoss*log10(fc)-147.55;
%pl_linear = 10^(-pl/10);
pl_linear = 10^(-path_loss_db/10);

sigma = 1/sqrt(2);
h = sigma*abs(randn(1,t_sim)+1i*randn(1,t_sim));
h = sqrt(pl_linear)*h;

%Simulation tracker

for r=1:realizations
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
        SNRTracker = zeros(1,t_sim);
        SNRdBTracker = zeros(1,t_sim);
        accuracyTracker = zeros(1,t_sim);
        server = ServerSimulator("./Data/",fSer,alfaSer,betaSer,kappa);
        device = DeviceOptimization("./Data/",Wmax,roll_off,betaDev,fmax,fmin,kappa,N0,server,pmax,mu_vector(v),ni_vector(v),lambda_vector(v),v_vector(v));
            
        device = device.setSPSubSet(sp_index);
        device = device.setSNRSubSet(snr_index);
        device = device.setTxWeight(tx_weight);
        device = device.setCompWeight(comp_weight);
        for ts=1:t_sim
            A = poissrnd(Aavg);
            server = server.updateFrequency();
            [WStar,kStar,gammaStar,fStar,snrStar] = device.optimizeDevice(server,Z,M,Y,A,h(ts));
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
            SNRTracker(ts) = gammaStar;
            SNRdBTracker(ts) = snrStar;
            accuracyTracker(ts) = accuracy;
            
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
        simulation.SNRArray = SNRTracker;
        simulation.kArray = splittingPointTracker;
        simulation.SNRdBArray = SNRdBTracker;
        simulation.accuracyArray = accuracyTracker;
        if realizations==1
            save(strcat(output_dir,'/simulation',num2str(v_vector(v)),'.mat'),'simulation');
        else
            save(strcat(output_dir,'/simulation_',num2str(r),'.mat'),'simulation');
        end
    end
end



