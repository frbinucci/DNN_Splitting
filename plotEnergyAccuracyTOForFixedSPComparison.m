clear all;
close all;


disp("Energy vs Accuracy Plotting");
disp("1 - Plot Virtual Queues for Fixed SP strategy");
disp("2 - Plot Virtual Queues for Dynamic SP Strategy");
disp("3 - Plot Energy vs Accuracy")
disp("4 - Plot Energy Loss for best SP and Full Local");
disp("5 - Plot Energy gain for Full Local")
disp("6 - Plot Energy vs FLOPS");
disp("7 - Plot Average Splitting Point vs Accuracy");
disp("8 - Plot Average Splitting Point Bar Diagram");

type = input("Choose: ");

pl_array = [115,120,125,130,135];
    %,5,6,7,8,9,10,11,12,13,14,15,16,17,18,20
sp_array = {[20];
    [4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20];
    [8,9,10,11,12,13,14,15,16,17,18,20]};
color_array = ["#0072BD","#D95319","#EDB120","#77AC30",	"#7E2F8E"]
%label_array = sp_array-1;
g_avg_array = [70,75,80,85];
v_array = 1e8*ones(1,numel(g_avg_array));
trans_end = 5000;
color_matrix = [[0 0.4470 0.7410];
    [0.8500 0.3250 0.0980];
    [0.9290 0.6940 0.1250]];

root = './SplittingPointComparisonFixed';
dynamic_root ='./SplittingPointComparison';


switch type
    case 1
        for p=1:numel(pl_array)
            for s=1:numel(sp_array{p})
                for g=1:numel(g_avg_array)
                    path = strcat(root,"/PathLoss",num2str(pl_array(p)),"/","SP",num2str(sp_array{p}(s)),"/Acc",num2str(g_avg_array(g)),"/");
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
                        path = strcat(root,"/PathLoss",num2str(pl_array(p)),"/","SP",num2str(sp_array(s)),"/Acc",num2str(g_avg_array(g)),"/");
                        load(strcat(path,'simulation',num2str(v_array(g)),".mat"),'simulation');
                        computation_energy = mean(simulation.computationalEnergyArray(trans_end:end));
                        tx_energy = mean(simulation.transmissionEnergyArray(trans_end:end));
                        energy_axis(g) = (tx_energy+computation_energy);
                        accuracy_axis(g) = mean(simulation.accuracyArray(trans_end:end));
                    end
                    semilogy(accuracy_axis*100,energy_axis,'LineWidth',1.5,'marker','o','DisplayName',strcat("$k = $",num2str(label_array(s))),'LineStyle','--');
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
                    computation_energy = mean(simulation.computationalEnergyArray(trans_end:end));
                    tx_energy = mean(simulation.transmissionEnergyArray(trans_end:end));
                    etot = tx_energy+computation_energy;
                    energy_axis(g) = etot;
                    accuracy_axis(g) = mean(simulation.accuracyArray(trans_end:end));
                end
                semilogy(accuracy_axis*100,energy_axis,'LineWidth',1.5,'marker','hexagram','DisplayName','Best k');
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
        ylabel('Energy Consumption[J]','FontSize',14);

    case 4
        energy_axis = zeros(1,numel(g_avg_array));
        energy_axis_full = zeros(1,numel(g_avg_array));
        accuracy_axis = zeros(1,numel(g_avg_array));
        try
            for p=1:numel(pl_array)
                for g=1:numel(g_avg_array)
                    Ebest=inf;
                    for s=1:numel(sp_array{p})
                        %Computing the energy consumption for the best fixed P
                        path = strcat(root,"/PathLoss",num2str(pl_array(p)),"/","SP",num2str(sp_array{p}(s)),"/Acc",num2str(g_avg_array(g)),"/");
                        load(strcat(path,'simulation',num2str(v_array(1)),".mat"),'simulation');
                        computation_energy = mean(simulation.computationalEnergyArray(trans_end:end));
                        tx_energy = mean(simulation.transmissionEnergyArray(trans_end:end));
                        Estar = tx_energy+computation_energy;
                        if Estar<Ebest
                            Ebest=Estar;
                        end
                    end

                    %Computing the energy consumption for the full
                    %offloading

                    path = strcat(root,"/PathLoss",num2str(pl_array(p)),"/","SP","20","/Acc",num2str(g_avg_array(g)),"/");
                    load(strcat(path,'simulation',num2str(v_array(1)),".mat"),'simulation');
                    computation_energy = mean(simulation.computationalEnergyArray(trans_end:end));
                    tx_energy = mean(simulation.transmissionEnergyArray(trans_end:end));
                    Efull = tx_energy+computation_energy;


                    path = strcat(dynamic_root,"/PathLoss",num2str(pl_array(p)),"/Acc",num2str(g_avg_array(g)),"/");
                    load(strcat(path,'simulation',num2str(v_array(g)),".mat"),'simulation');
                    computation_energy = mean(simulation.computationalEnergyArray(trans_end:end));
                    tx_energy = mean(simulation.transmissionEnergyArray(trans_end:end));
                    etot = tx_energy+computation_energy;
                    energy_axis(g) = (Ebest-(etot))/Ebest;
                    energy_axis_full(g) = (Efull-(etot))/Efull;
                    accuracy_axis(g) = mean(simulation.accuracyArray(trans_end:end));
                end
                plot(accuracy_axis*100,energy_axis*100,'LineWidth',2,'marker','o','DisplayName',strcat('PL=',num2str(pl_array(p)),' dB'),'Color',color_array(p),'LineStyle','-');
                hold on;
                plot(accuracy_axis*100,energy_axis_full*100,'LineWidth',2,'marker','o','DisplayName',strcat("$k_{20}$ PL=",num2str(pl_array(p))),'Color',color_array(p),'LineStyle','--','HandleVisibility','off');
                hold on;
            end
        catch exception
            disp(exception.message);
        end
        hold on;
        grid on;
        l = legend('Location','best','Fontsize',12);
        set(l,'Interpreter','latex');
        xlabel('Accuracy [%]','FontSize',14);
        ylabel('Energy Expenditure Reduction [%]','FontSize',14);
    case 5
        energy_axis = zeros(1,numel(g_avg_array));
        energy_axis_full = zeros(1,numel(g_avg_array));
        accuracy_axis = zeros(1,numel(g_avg_array));
        try
            for p=1:numel(pl_array)
                for g=1:numel(g_avg_array)
                    %Computing the energy consumption for the full
                    %offloading

                    path = strcat(root,"/PathLoss",num2str(pl_array(p)),"/","SP","20","/Acc",num2str(g_avg_array(g)),"/");
                    load(strcat(path,'simulation',num2str(v_array(1)),".mat"),'simulation');
                    computation_energy = mean(simulation.computationalEnergyArray(trans_end:end));
                    tx_energy = mean(simulation.transmissionEnergyArray(trans_end:end));
                    Efull = tx_energy+computation_energy;


                    path = strcat(dynamic_root,"/PathLoss",num2str(pl_array(p)),"/Acc",num2str(g_avg_array(g)),"/");
                    load(strcat(path,'simulation',num2str(v_array(g)),".mat"),'simulation');
                    computation_energy = mean(simulation.computationalEnergyArray(trans_end:end));
                    tx_energy = mean(simulation.transmissionEnergyArray(trans_end:end));
                    etot = tx_energy+computation_energy;
                    energy_axis(g) = (Ebest-(etot))/Ebest;
                    energy_axis_full(g) = (Efull-(etot))/Efull;
                    accuracy_axis(g) = mean(simulation.accuracyArray(trans_end:end));
                end
                plot(accuracy_axis*100,energy_axis_full*100,'LineWidth',2,'marker','o','DisplayName',strcat("$k_{20}$ PL=",num2str(pl_array(p))),'Color',color_array(p),'LineStyle','--','HandleVisibility','off');
                hold on;
            end
        catch exception
            disp(exception.message);
        end
        hold on;
        grid on;
        l = legend('Location','best','Fontsize',12);
        set(l,'Interpreter','latex');
        xlabel('Accuracy [%]','FontSize',14);
        ylabel('Energy Expenditure Reduction [%]','FontSize',14);        
    case 6
        load('./Data/num_flops_vs_SP.mat','FLOPS_DATA');
        complete_flops_axis = cumsum(FLOPS_DATA);

        max_flops = complete_flops_axis(20);
        complete_flops_axis = (complete_flops_axis/max_flops);
        flops_axis = complete_flops_axis(str2double(sp_array));

        path = strcat(root,"/PathLoss",num2str(pl_array(1)),"/","SP20","/Acc",num2str(g_avg_array(1)),"/");
        load(strcat(path,'simulation',num2str(v_array(1)),".mat"),'simulation');
        computation_energy = mean(simulation.computationalEnergyArray(trans_end:end));
        tx_energy = mean(simulation.transmissionEnergyArray(trans_end:end));
        Emax = tx_energy+computation_energy;
        optimal_energy = zeros(1,numel(g_avg_array));
        optimal_flops = zeros(1,numel(g_avg_array));
        for p=1:numel(pl_array)
            for g=1:numel(g_avg_array)
                path = strcat(dynamic_root,"/PathLoss",num2str(pl_array(p)),"/Acc",num2str(g_avg_array(g)),"/");
                load(strcat(path,'simulation',num2str(v_array(g)),".mat"),'simulation');
                computation_energy = mean(simulation.computationalEnergyArray(trans_end:end));
                tx_energy = mean(simulation.transmissionEnergyArray(trans_end:end));
                optimal_energy(g) = (Emax-(tx_energy+computation_energy))/Emax;
                complete_flops_axis(floor(mean(simulation.kArray(trans_end:end))));
                floor(mean(simulation.kArray(trans_end:end)))
                optimal_flops(g) = mean(complete_flops_axis(simulation.kArray(trans_end:end)));
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
                    computation_energy = mean(simulation.computationalEnergyArray(trans_end:end));
                    tx_energy = mean(simulation.transmissionEnergyArray(trans_end:end));
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
    case 7
        set(0,'defaultTextInterpreter','latex');
        figure
        k_array = zeros(numel(pl_array),numel(g_avg_array));
        accuracy_array = zeros(numel(g_avg_array),1);
        std_dev_array =  zeros(numel(g_avg_array),1);
        for p=1:numel(pl_array)
            k_array = zeros(numel(g_avg_array),1);
            accuracy_array = zeros(numel(g_avg_array),1);
            for g=1:numel(g_avg_array)
                 path = strcat(dynamic_root,"/PathLoss",num2str(pl_array(p)),"/Acc",num2str(g_avg_array(g)),"/");
                 load(strcat(path,'simulation',num2str(v_array(1)),".mat"),'simulation');
                 k_array(g) = mean(simulation.kArray(trans_end:end));
                 accuracy_array(g) = mean(simulation.accuracyArray(trans_end:end));
                 std_dev_array(g) = std(simulation.kArray(trans_end:end));
            end
            plot(accuracy_array*100,k_array,'Marker','o','LineWidth',2,'DisplayName',strcat("PL = ",num2str(pl_array(p))," dB"),'Color',color_array(p));
            hold on;
            grid on;
            xlabel("Accuracy [\%]");
            ylabel("Average SP");
            l=legend(Location='best');
            set(l,'interpreter','latex');
            set(l,'FontSize',28);
            set(l,'FontWeight','bold');
            ax = gca;
            ax.FontSize=30;
            ax.FontWeight = 'bold';
            set(gcf, 'Position',  [100, 10, 1212, 775.2])
            ax.TickLabelInterpreter='latex';  
        end
    case 8
        k_array = zeros(numel(pl_array),numel(g_avg_array));
        std_dev_array = zeros(numel(pl_array),numel(g_avg_array));
        for p=1:numel(pl_array)
            for g=1:numel(g_avg_array)
                path = strcat(dynamic_root,"/PathLoss",num2str(pl_array(p)),"/Acc",num2str(g_avg_array(g)),"/");
                load(strcat(path,'simulation',num2str(v_array(1)),".mat"),'simulation');
                k_array(p,g) = mean(simulation.kArray(trans_end:end));
                std_dev_array(p,g) = std(simulation.kArray(trans_end:end));
            end
        end
        bar([1,2,3,4],k_array');
        hold on;
        nbars = 3;
        ngroups = 4;
        groupwidth = min(0.8, nbars/(nbars + 1.5));
        for i = 1:numel(pl_array)
            % Calculate center of each bar
            x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
            errorbar(x,k_array(i,:)',std_dev_array(i,:)','linestyle','none','LineWidth',1.5,'Color','black')
        end
        xticklabels({'70','75','80','85'})    
        %errorbar(x, model_series(:,i), model_error(:,i), 'k', 'linestyle', 'none');
end


