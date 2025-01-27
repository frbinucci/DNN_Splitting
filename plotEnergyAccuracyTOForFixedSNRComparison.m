clear all;
close all;

disp("Energy vs Accuracy Plotting");
disp("1 - Plot Virtual Queues for Fixed SNR strategy");
disp("2 - Plot Virtual Queues for Dynamic SNR Strategy");
disp("3 - Plot Energy vs Accuracy");
disp("4 - Plot Energy Loss for best SNR and Full Local");
disp("5 - Plot comparison Fixed SNR/Fixed SP");

type = input("Choose: ");

pl_array = [115,120,125];
snr_array = {["SNRNeg5","SNRNeg4","SNRNeg3","SNRNeg2","SNR0","SNR5","SNR10","SNR20"];
    ["SNRNeg5","SNRNeg4","SNRNeg3","SNRNeg2","SNR0","SNR5","SNR10","SNR20"];
    ["SNRNeg5","SNRNeg4","SNRNeg3","SNRNeg2","SNR0","SNR5","SNR10","SNR20"]};
%snr_array = ["SNRNeg5","SNRNeg4","SNRNeg3","SNRNeg2","SNR0","SNR5","SNR10","SNR20"]
snr_num = ["-5","-4","-3","-2","0","5","10","20"];
best_snr = ["SNRNeg2","SNRNeg2","SNRNeg2","SNR0"]
g_avg_array = [70,75,80,85];
v_array = 1e8*ones(1,numel(g_avg_array));
trans_end = [8000,8000,8000];

sp_array = {[4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,20];
    [7,8,9,10,11,12,13,14,15,16,17,18,20];
    [7,8,9,10,11,12,13,14,15,16,17,18,20]};

root = "./SNRComparisonFixed";
dynamic_root ="./SplittingPointComparison";
fixed_sp_dir = "./SplittingPointComparisonFixed";
%no_opt_acc_root = "./NoOptAcc";

color_array = ["#0072BD","#D95319","#EDB120"]

switch type
    case 1
        for p=1:numel(pl_array)
            for s=1:numel(snr_array{p})
                for g=1:numel(g_avg_array)
                    path = strcat(root,"/PathLoss",num2str(pl_array(p)),"/",num2str(snr_array{p}(s)),"/Acc",num2str(g_avg_array(g)),"/");
                    virtualQueuesPlotting(path,v_array(g));
                end
            end
        end
    case 2
        for p=1:numel(pl_array)
            for g=1:numel(g_avg_array)
                path = strcat(dynamic_root,"/PathLoss",num2str(pl_array(p)),"/Acc",num2str(g_avg_array(g)),"/");
                virtualQueuesPlotting(path,v_array(g));
            end
        end
    case 3
        energy_opt_axis = zeros(1,numel(g_avg_array));
        accuracy_axis = zeros(1,numel(g_avg_array));
        accuracy_opt_axis = zeros(1,numel(g_avg_array));
        try
            for p=1:numel(pl_array)
                for g=1:numel(g_avg_array)
                    path = strcat(dynamic_root,"/PathLoss",num2str(pl_array(p)),"/Acc",num2str(g_avg_array(g)),"/");
                    load(strcat(path,'simulation',num2str(v_array(g)),".mat"),'simulation');
                    computation_energy = mean(simulation.computationalEnergyArray(trans_end(1):end));
                    tx_energy = mean(simulation.transmissionEnergyArray(trans_end(1):end));
                    etot = tx_energy+computation_energy;
                    energy_opt_axis(g) = etot;
                    accuracy_opt_axis(g) = mean(simulation.accuracyArray(trans_end(1):end));
                end
                %semilogy(accuracy_axis*100,energy_axis,'LineWidth',1.5,'marker','hexagram','DisplayName','Best SNR');
                hold on;
            end
        catch
            disp(strcat(root," not found..."));
        end
        energy_axis = zeros(1,numel(g_avg_array));

        for p=1:numel(pl_array)
            for s=1:numel(snr_array{p})
                for g=1:numel(g_avg_array)
                    %Computing the energy consumption for the best fixed P
                    path = strcat(root,"/PathLoss",num2str(pl_array(p)),"/",num2str(snr_array{p}(s)),"/Acc",num2str(g_avg_array(g)),"/");
                    load(strcat(path,'simulation',num2str(v_array(1)),".mat"),'simulation');
                    computation_energy = mean(simulation.computationalEnergyArray(trans_end(1):end));
                    tx_energy = mean(simulation.transmissionEnergyArray(trans_end(1):end));
                    Estar = tx_energy+computation_energy;
                    energy_axis(g) = (Estar-energy_opt_axis(g))/Estar;
                    accuracy_axis(g) = mean(simulation.accuracyArray(trans_end(1):end));
                end
                plot(accuracy_opt_axis*100,energy_axis,'LineWidth',1.5,'marker','hexagram','DisplayName',strcat(snr_num(s), " dB"),'LineStyle','--');
                hold on;
            end
        end
        grid on;
        l = legend('Location','best','Fontsize',12);
        set(l,'Interpreter','latex');
        xlabel('Accuracy [%]','FontSize',14);
        ylabel('Energy [J]','FontSize',14);
    case 4
        energy_axis = zeros(numel(g_avg_array),numel(pl_array));
        full_energy_axis = zeros(1,numel(g_avg_array));
        accuracy_axis = zeros(1,numel(g_avg_array));
        for p=1:numel(pl_array)
            for g=1:numel(g_avg_array)
                Ebest=inf;
                Etot = zeros(1,numel(pl_array));
                best = 1;
                for s=1:numel(snr_array{p})
                    %Computing the energy consumption for the best fixed P
                    path = strcat(root,"/PathLoss",num2str(pl_array(p)),"/",num2str(snr_array{p}(s)),"/Acc",num2str(g_avg_array(g)),"/");
                    load(strcat(path,'simulation',num2str(v_array(1)),".mat"),'simulation');
                    computation_energy = mean(simulation.computationalEnergyArray(trans_end(1):end));
                    tx_energy = mean(simulation.transmissionEnergyArray(trans_end(1):end));
                    Estar = tx_energy+computation_energy;
                    if Estar<Ebest
                       Ebest=Estar;
                       best = snr_array{p}(s);
                    end
                end
                path = strcat(dynamic_root,"/PathLoss",num2str(pl_array(p)),"/Acc",num2str(g_avg_array(g)),"/");
                load(strcat(path,'simulation',num2str(v_array(g)),".mat"),'simulation');
                
                computation_energy = mean(simulation.computationalEnergyArray(trans_end(1):end));
                tx_energy = mean(simulation.transmissionEnergyArray(trans_end(1):end));
                etot = tx_energy+computation_energy;
                energy_axis(g,p) = (Ebest-etot)/Ebest;
                accuracy_axis(g) = mean(simulation.accuracyArray(trans_end(1):end));
            end
        end
        for p=1:numel(pl_array)
            for g=1:numel(g_avg_array)
                Ebest=inf;
                Etot = zeros(1,numel(pl_array));
                best = 1;

                %Computing the energy consumption for the best fixed P
                path = strcat(root,"/PathLoss",num2str(pl_array(p)),"/SP20","/Acc",num2str(g_avg_array(g)),"/");
                load(strcat(path,'simulation',num2str(v_array(1)),".mat"),'simulation');
                computation_energy = mean(simulation.computationalEnergyArray(trans_end(1):end));
                tx_energy = mean(simulation.transmissionEnergyArray(trans_end(1):end));
                Efull = tx_energy+computation_energy;
            
                path = strcat(dynamic_root,"/PathLoss",num2str(pl_array(p)),"/Acc",num2str(g_avg_array(g)),"/");
                load(strcat(path,'simulation',num2str(v_array(g)),".mat"),'simulation');

                computation_energy = mean(simulation.computationalEnergyArray(trans_end(1):end));
                tx_energy = mean(simulation.transmissionEnergyArray(trans_end(1):end));
                etot = tx_energy+computation_energy;
            
                full_energy_axis(g,p) = (Efull-etot)/Efull;
                accuracy_axis(g) = mean(simulation.accuracyArray(trans_end(1):end));
            end
        end 
        bar([70,75,80,85],[energy_axis]*100);
        legend(["PL = 90 dB","PL = 95 dB","PL = 100 dB"])
        hold on;
        grid on;
        l = legend('Location','best','Fontsize',10);
        set(l,'Interpreter','latex');
        xlabel('Accuracy [%]','FontSize',14);

        ylabel('Energy Expenditure Reduction [%]','FontSize',14);
    case 5
        energy_axis = zeros(1,numel(g_avg_array));
        energy_axis_full = zeros(1,numel(g_avg_array));
        accuracy_axis = zeros(1,numel(g_avg_array));
        accuracy_axis_full_local = zeros(1,numel(g_avg_array));
        try
            for p=1:numel(pl_array)
                for g=1:numel(g_avg_array)
                    Ebest=inf;
                    for s=1:numel(sp_array{p})
                        %Computing the energy consumption for the best fixed P
                        path = strcat(fixed_sp_dir,"/PathLoss",num2str(pl_array(p)),"/","SP",num2str(sp_array{p}(s)),"/Acc",num2str(g_avg_array(g)),"/");
                        load(strcat(path,'simulation',num2str(v_array(1)),".mat"),'simulation');
                        computation_energy = mean(simulation.computationalEnergyArray(trans_end(1):end));
                        tx_energy = mean(simulation.transmissionEnergyArray(trans_end(1):end));
                        Estar = tx_energy+computation_energy;
                        if Estar<Ebest
                            Ebest=Estar;
                        end
                    end

                    %Computing the energy consumption for the full
                    %offloading

                    path = strcat(fixed_sp_dir,"/PathLoss",num2str(pl_array(p)),"/","SP","20","/Acc",num2str(g_avg_array(g)),"/");
                    load(strcat(path,'simulation',num2str(v_array(1)),".mat"),'simulation');
                    computation_energy = mean(simulation.computationalEnergyArray(trans_end(1):end));
                    tx_energy = mean(simulation.transmissionEnergyArray(trans_end(1):end));
                    Efull = tx_energy+computation_energy;
                    accuracy_axis_full_local(g)= mean(simulation.accuracyArray(trans_end(1):end));


                    path = strcat(dynamic_root,"/PathLoss",num2str(pl_array(p)),"/Acc",num2str(g_avg_array(g)),"/");
                    load(strcat(path,'simulation',num2str(v_array(g)),".mat"),'simulation');
                    computation_energy = mean(simulation.computationalEnergyArray(trans_end(1):end));
                    tx_energy = mean(simulation.transmissionEnergyArray(trans_end(1):end));
                    etot = tx_energy+computation_energy;
                    energy_axis(g) = (Ebest-(etot))/Ebest;
                    energy_axis_full(g) = (Efull-(etot))/Efull;
                    accuracy_axis(g) = mean(simulation.accuracyArray(trans_end(1):end));
                end
                plot(accuracy_axis*100,energy_axis*100,'LineWidth',1.5,'marker','o','DisplayName',strcat('PL=',num2str(pl_array(p)),' dB'),'Color',color_array(p),'LineStyle','--');
                hold on;
                plot(accuracy_axis*100,energy_axis_full*100,'LineWidth',1.5,'marker','o','DisplayName',strcat("$k_{20}$ PL=",num2str(pl_array(p))),'Color',color_array(p),'LineStyle','-','HandleVisibility','off');
                hold on;
            end
        catch exception
            disp(exception.message);
        end
        energy_axis = zeros(1,numel(g_avg_array));
        full_energy_axis = zeros(1,numel(g_avg_array));
        accuracy_axis = zeros(1,numel(g_avg_array));
        energy_axis_no_accuracy = zeros(1,numel(g_avg_array));
        accuracy_axis_no_accuracy = zeros(1,numel(g_avg_array));
        for p=1:numel(pl_array)
            for g=1:numel(g_avg_array)
                Ebest=inf;
                Etot = zeros(1,numel(pl_array));
                best = 1;
                for s=1:numel(snr_array{p})
                    %Computing the energy consumption for the best fixed P
                    path = strcat(root,"/PathLoss",num2str(pl_array(p)),"/",num2str(snr_array{p}(s)),"/Acc",num2str(g_avg_array(g)),"/");
                    load(strcat(path,'simulation',num2str(v_array(1)),".mat"),'simulation');
                    computation_energy = mean(simulation.computationalEnergyArray(trans_end(1):end));
                    tx_energy = mean(simulation.transmissionEnergyArray(trans_end(1):end));
                    Estar = tx_energy+computation_energy;
                    if Estar<Ebest
                       Ebest=Estar;
                       best = snr_array{p}(s);
                    end
                end
                path = strcat(dynamic_root,"/PathLoss",num2str(pl_array(p)),"/Acc",num2str(g_avg_array(g)),"/");
                load(strcat(path,'simulation',num2str(v_array(g)),".mat"),'simulation');
                
                computation_energy = mean(simulation.computationalEnergyArray(trans_end(1):end));
                tx_energy = mean(simulation.transmissionEnergyArray(trans_end(1):end));
                etot = tx_energy+computation_energy;
                energy_axis(g) = (Ebest-(etot))/Ebest;
                accuracy_axis(g) = mean(simulation.accuracyArray(trans_end(1):end));                
            end
            plot(accuracy_axis*100,energy_axis*100,'LineWidth',1.5,'marker','o','HandleVisibility','off','Color',color_array(p),'LineStyle',':')
            hold on;
        end
        hold on;
        grid on;
        l = legend('Location','best','Fontsize',12);
        set(l,'Interpreter','latex');
        xlabel('Accuracy Loss [%]','FontSize',14);
        ylabel('Energy Expenditure Reduction [%]','FontSize',14);

end

