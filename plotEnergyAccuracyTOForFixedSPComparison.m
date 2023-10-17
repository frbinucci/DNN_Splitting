clear all;
close all;

disp("Energy vs Accuracy Plotting");
disp("1 - Plot Virtual Queues for Fixed SP strategy");
disp("2 - Plot Virtual Queues for Dynamic SP Strategy");
disp("3 - Plot Energy vs Accuracy");

type = input("Choose: ");

pl_array = [90];
sp_array = ["6","7","8","11"]%,"20"];%,"6","9"];
g_avg_array = [70,75,80,85];
v_array = 1e8*ones(1,numel(g_avg_array));
trans_end = [8000,8000,8000];

root = "./SplittingPointComparisonFixed";
dynamic_root ="./SplittingPointComparison";

switch type
    case 1
        for p=1:numel(pl_array)
            for s=1:numel(sp_array)
                for g=1:numel(g_avg_array)
                    path = strcat(root,"/PathLoss",num2str(pl_array(p)),"/","SP",num2str(sp_array(s)),"/Acc",num2str(g_avg_array(g)),"/");
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
                for s=1:numel(sp_array)
                    for g=1:numel(g_avg_array)
                        path = strcat(root,"/PathLoss",num2str(pl_array(p)),"/","SP",sp_array(s),"/Acc",num2str(g_avg_array(g)),"/");
                        load(strcat(path,'simulation',num2str(v_array(g)),".mat"),'simulation');
                        computation_energy = mean(simulation.computationalEnergyArray(trans_end(1):end));
                        tx_energy = mean(simulation.transmissionEnergyArray(trans_end(1):end));
                        energy_axis(g) = tx_energy+computation_energy;
                        accuracy_axis(g) = mean(simulation.accuracyArray(trans_end(1):end));
                    end
                    semilogy(accuracy_axis*100,energy_axis,'LineWidth',1.5,'marker','o','DisplayName',strcat("$k = $",sp_array(s)),'LineStyle','--');
                    hold on;
                end
            end
        catch
            disp(strcat(root," not found..."));
        end
        try
            for p=1:numel(pl_array)
                for g=1:numel(g_avg_array)
                    path = strcat(dynamic_root,"/PathLoss",num2str(pl_array(p)),"/Acc",num2str(g_avg_array(g)),"/");
                    load(strcat(path,'simulation',num2str(v_array(g)),".mat"),'simulation');
                    computation_energy = mean(simulation.computationalEnergyArray(trans_end(1):end));
                    tx_energy = mean(simulation.transmissionEnergyArray(trans_end(1):end));
                    energy_axis(g) = tx_energy+computation_energy;
                    accuracy_axis(g) = mean(simulation.accuracyArray(trans_end(1):end));
                end
                semilogy(accuracy_axis*100,energy_axis,'LineWidth',1.5,'marker','hexagram','DisplayName','$k$ Opt.');
                hold on;
            end
        catch
            disp(strcat(root," not found..."));
        end
        hold on;
        grid on;
        l = legend('Location','best','Fontsize',12);
        set(l,'Interpreter','latex');
        xlabel('Accuracy [%]','FontSize',14);
        ylabel('Energy [J]','FontSize',14);
end

