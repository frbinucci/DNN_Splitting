clear all;
close all;

disp("Energy vs Accuracy Plotting");
disp("1 - Plot Virtual Queues for Fixed SP strategy");
disp("2 - Plot Virtual Queues for Dynamic SP Strategy");
disp("3 - Plot Energy vs Accuracy");
disp("4 - Plot Energy vs FLOPS");

type = input("Choose: ");

pl_array = [90];
sp_array_num = [4,5,6,7,8,9,10,11,12,13,14,20];
sp_array = ["4","5","6","7","8","9","10","11","12","13","14"]%,"10","20"]%,"11","12","13","14"]%,"5","7","9","11","20"]%,"9","11","20"]%,"7","8","11"]%,"20"];%,"6","9"];
label_array = ["3","4","5","6","7","8","9","10","11","12","13","19"];
best_sp = ["6","6","6","9"];
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
        energy_axis_full = zeros(1,numel(g_avg_array));
        accuracy_axis = zeros(1,numel(g_avg_array));
%         try
%             for p=1:numel(pl_array)
%                 for s=1:numel(sp_array)
%                     for g=1:numel(g_avg_array)
%                         path = strcat(root,"/PathLoss",num2str(pl_array(p)),"/","SP",sp_array(s),"/Acc",num2str(g_avg_array(g)),"/");
%                         load(strcat(path,'simulation',num2str(v_array(g)),".mat"),'simulation');
%                         computation_energy = mean(simulation.computationalEnergyArray(trans_end(1):end));
%                         tx_energy = mean(simulation.transmissionEnergyArray(trans_end(1):end));
%                         energy_axis(g) = (tx_energy+computation_energy);
%                         accuracy_axis(g) = mean(simulation.accuracyArray(trans_end(1):end));
%                     end
%                     semilogy(accuracy_axis*100,energy_axis,'LineWidth',1.5,'marker','o','DisplayName',strcat("$k = $",label_array(s)),'LineStyle','--');
%                     hold on;
%                 end
%             end
%         catch
%            disp(strcat(root," not found..."));
%         end
        try
            for p=1:numel(pl_array)
                for g=1:numel(g_avg_array)

                    %Computing the energy consumption for the best fixed P
                    path = strcat(root,"/PathLoss",num2str(pl_array(p)),"/","SP",best_sp(g),"/Acc",num2str(g_avg_array(g)),"/");
                    load(strcat(path,'simulation',num2str(v_array(1)),".mat"),'simulation');
                    computation_energy = mean(simulation.computationalEnergyArray(trans_end(1):end));
                    tx_energy = mean(simulation.transmissionEnergyArray(trans_end(1):end));
                    Estar = tx_energy+computation_energy;
                    
                    %Computing the energy consumption for the full
                    %offloading

                    path = strcat(root,"/PathLoss",num2str(pl_array(p)),"/","SP","20","/Acc",num2str(g_avg_array(g)),"/");
                    load(strcat(path,'simulation',num2str(v_array(1)),".mat"),'simulation');
                    computation_energy = mean(simulation.computationalEnergyArray(trans_end(1):end));
                    tx_energy = mean(simulation.transmissionEnergyArray(trans_end(1):end));
                    Efull = tx_energy+computation_energy;


                    path = strcat(dynamic_root,"/PathLoss",num2str(pl_array(p)),"/Acc",num2str(g_avg_array(g)),"/");
                    load(strcat(path,'simulation',num2str(v_array(g)),".mat"),'simulation');
                    computation_energy = mean(simulation.computationalEnergyArray(trans_end(1):end));
                    tx_energy = mean(simulation.transmissionEnergyArray(trans_end(1):end));
                    etot = tx_energy+computation_energy;
                    energy_axis(g) = (Estar-(etot))/etot;
                    energy_axis_full(g) = (Efull-(etot))/etot;
                    accuracy_axis(g) = mean(simulation.accuracyArray(trans_end(1):end));
                end
                semilogy(accuracy_axis*100,energy_axis*100,'LineWidth',1.5,'marker','hexagram','DisplayName','Best k');
                hold on;
                semilogy(accuracy_axis*100,energy_axis_full*100,'LineWidth',1.5,'marker','hexagram','DisplayName','Full Offloading');
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
        ylabel('Energy Loss [%]','FontSize',14);
    case 4
        load('./Data/num_flops_vs_SP.mat','FLOPS_DATA');
        complete_flops_axis = cumsum(FLOPS_DATA);

        max_flops = complete_flops_axis(20);
        complete_flops_axis = (complete_flops_axis/max_flops);
        flops_axis = complete_flops_axis(str2double(sp_array));

        path = strcat(root,"/PathLoss",num2str(pl_array(1)),"/","SP20","/Acc",num2str(g_avg_array(1)),"/");
        load(strcat(path,'simulation',num2str(v_array(1)),".mat"),'simulation');
        computation_energy = mean(simulation.computationalEnergyArray(trans_end(1):end));
        tx_energy = mean(simulation.transmissionEnergyArray(trans_end(1):end));
        Emax = tx_energy+computation_energy;
        optimal_energy = zeros(1,numel(g_avg_array));
        optimal_flops = zeros(1,numel(g_avg_array));
        for p=1:numel(pl_array)
            for g=1:numel(g_avg_array)
                path = strcat(dynamic_root,"/PathLoss",num2str(pl_array(p)),"/Acc",num2str(g_avg_array(g)),"/");
                load(strcat(path,'simulation',num2str(v_array(g)),".mat"),'simulation');
                computation_energy = mean(simulation.computationalEnergyArray(trans_end(1):end));
                tx_energy = mean(simulation.transmissionEnergyArray(trans_end(1):end));
                optimal_energy(g) = (Emax-(tx_energy+computation_energy))/Emax;
                complete_flops_axis(floor(mean(simulation.kArray(trans_end(1):end))));
                floor(mean(simulation.kArray(trans_end(1):end)))
                optimal_flops(g) = mean(complete_flops_axis(simulation.kArray(trans_end(1):end)));
                plot(optimal_flops(g),optimal_energy(g),'LineWidth',2,'Marker','x','HandleVisibility','off');
                hold on;
            end
        end
        set(gca,'ColorOrderIndex',1)
        for p=1:numel(pl_array)
            energy_axis = zeros(1,numel(sp_array));
            for g=1:numel(g_avg_array)
                for s=1:(numel(sp_array))
                    path = strcat(root,"/PathLoss",num2str(pl_array(p)),"/","SP",sp_array(s),"/Acc",num2str(g_avg_array(g)),"/");
                    load(strcat(path,'simulation',num2str(v_array(g)),".mat"),'simulation');
                    computation_energy = mean(simulation.computationalEnergyArray(trans_end(1):end));
                    tx_energy = mean(simulation.transmissionEnergyArray(trans_end(1):end));
                    tot_energy = tx_energy+computation_energy;
                    energy_axis(s) = (Emax-tot_energy)/Emax;
                end
                plot(flops_axis,energy_axis,'Marker','o','LineWidth',2,'DisplayName',strcat('$G_{avg}$=',num2str(g_avg_array(g))));
                hold on;
            end
        end
        grid on;
        l = legend(Location="best");
        set(l,'interpreter','latex');
        xlabel("[%] of FLOPS",'FontSize',14);
        ylabel("Energy Reduction [%]",'FontSize',14);



end

