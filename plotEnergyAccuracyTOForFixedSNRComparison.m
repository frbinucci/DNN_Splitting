clear all;
close all;

disp("Energy vs Accuracy Plotting");
disp("1 - Plot Virtual Queues for Fixed SNR strategy");
disp("2 - Plot Virtual Queues for Dynamic SNR Strategy");
disp("3 - Plot Energy vs Accuracy");

type = input("Choose: ");

pl_array = [90];
snr_array = ["SNRNeg5","SNRNeg4","SNRNeg3","SNRNeg2","SNR0"];
snr_num = ["-5","-4","-3","-2","0","5"];
g_avg_array = [70,75,80,85];
v_array = 1e8*ones(1,numel(g_avg_array));
trans_end = [8000,8000,8000];

root = "./NewAccuracyTrendFixed120msec";
dynamic_root ="./NewAccuracyTrend120msec";

switch type
    case 1
        for p=1:numel(pl_array)
            for s=1:numel(snr_array)
                for g=1:numel(g_avg_array)
                    path = strcat(root,"/PathLoss",num2str(pl_array(p)),"/",num2str(snr_array(s)),"/Acc",num2str(g_avg_array(g)),"/");
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
        energy_axis = zeros(1,numel(g_avg_array));
        accuracy_axis = zeros(1,numel(g_avg_array));
        try
            for p=1:numel(pl_array)
                for s=1:numel(snr_array)
                    for g=1:numel(g_avg_array)
                        path = strcat(root,"/PathLoss",num2str(pl_array(p)),"/",num2str(snr_array(s)),"/Acc",num2str(g_avg_array(g)),"/");
                        load(strcat(path,'simulation',num2str(v_array(g)),".mat"),'simulation');
                        computation_energy = mean(simulation.computationalEnergyArray(trans_end(1):end));
                        tx_energy = mean(simulation.transmissionEnergyArray(trans_end(1):end));
                        energy_axis(g) = tx_energy+computation_energy;
                        accuracy_axis(g) = mean(simulation.accuracyArray(trans_end(1):end));
                    end
                    semilogy(accuracy_axis*100,energy_axis,'LineWidth',1.5,'marker','o','DisplayName',strcat('$\overline{\gamma}$ = ',snr_num(s)),'LineStyle','--');
                    hold on;
                end
            end
        catch
            disp(strcat(root," not found..."));
        end
        for p=1:numel(pl_array)
            for g=1:numel(g_avg_array)
                path = strcat(dynamic_root,"/PathLoss",num2str(pl_array(p)),"/Acc",num2str(g_avg_array(g)),"/");
                load(strcat(path,'simulation',num2str(v_array(g)),".mat"),'simulation');
                computation_energy = mean(simulation.computationalEnergyArray(trans_end(1):end));
                tx_energy = mean(simulation.transmissionEnergyArray(trans_end(1):end));
                energy_axis(g) = tx_energy+computation_energy;
                accuracy_axis(g) = mean(simulation.accuracyArray(trans_end(1):end));
            end

            semilogy(accuracy_axis*100,energy_axis,'LineWidth',1.5,'marker','hexagram','DisplayName','$\gamma$ Opt.');
            hold on;
        end
        hold on;
        grid on;
        l = legend('Location','best','Fontsize',12);
        set(l,'Interpreter','latex');
        xlabel('Accuracy [%]','FontSize',14);
        ylabel('Energy [J]','FontSize',14);
end

