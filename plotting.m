%To be deleted...

clear all;
close all;
dir_vect =["./VariableAccuracyConstraints/PathLoss90/Acc60/","./VariableAccuracyConstraints/PathLoss90/Acc88/"]%,"./VariableAccuracyConstraints/PathLoss90Old/Acc88/"]%,"./VariableAccuracyConstraints/PathLoss90/Acc88/"]%,"./VariableAccuracyConstraints/PathLoss90/Acc88/"]%,"./VariableAccuracyConstraints/PathLoss90/Acc88/"]%,"./VariableAccuracyConstraints/PathLoss90/Acc88/"]%,"./VariableAccuracyConstraints/PathLoss90/Acc88/"]%,"./VariableAccuracyConstraints/PathLoss90/Acc88/"]%,"./VariableAccuracyConstraints/PathLoss90/Acc88/"]%,"./VariableAccuracyConstraints/PathLoss90/Acc88/"]%,"./VariableAccuracyConstraints/PathLoss90/Acc88/"]%,"./VariableAccuracyConstraints/PathLoss90/Acc86/"]%,"./VariableAccuracyConstraints/PathLoss90/Acc86/"]%,"./VariableAccuracyConstraints/PathLoss90/Acc86/"]%,"./VariableAccuracyConstraints/PathLoss90/Acc86/"]%,"./VariableAccuracyConstraints/PathLoss90/Acc86/"]%,"./VariableAccuracyConstraints/PathLoss90/Acc89/"]%,"./VariableAccuracyConstraints/PathLoss90/Acc89/"]%,"./VariableAccuracyConstraints/PathLoss90/Acc89/"]%,"./VariableAccuracyConstraints/PathLoss90/Acc70/"]%,"./VariableAccuracyConstraints/PathLoss90/Acc88/"]%,"./VariableAccuracyConstraints/Acc88/"]%,"./VariableAccuracyConstraints/Acc88/"]%,"./VariableAccuracyConstraints/Acc70/"]%,"./VariableAccuracyConstraints/Acc88/"]%,"./VariableAccuracyConstraints/Acc70/","./VariableAccuracyConstraints/Acc86/"]%,"./VariableAccuracyConstraints/Acc70/","./VariableAccuracyConstraints/Acc86/"];%,"./VariableAccuracyConstraints/Acc70/"]%,"./VariableAccuracyConstraints/Acc80/","./VariableAccuracyConstraints/Acc86/"]%,"./VariableAccuracyConstraints/Acc80/","./VariableAccuracyConstraints/Acc86/"]%,"./VariableAccuracyConstraints/Acc80/"]%,"./PreliminarySimulations/medChannel/","./PreliminarySimulations/badChannel/"]%,"./NewSimulationData/medChannel/","./NewSimulationData/badChannel/"]%,"./SimulationData/goodChannel/","./SimulationData/medChannel/"]%,"./SimulationData/badChannel/"];
index = 1;
label_array = ["Accuracy = 60%","Accuracy = 88%","PL = 110dB"];
marker_array = ["-v","-diamond","-o","-v","-diamond","-o","-v","-diamond","-o"];
color_array = ["#0072BD","#D95319","#0FEA11","#0072BD","#D95319","#0FEA11","#0072BD","#D95319","#0FEA11"];
linestyle_array = ["--","--","--",":",":",":","-","-","-"];

v_array =  {[1e1,1e2,1e3,1e4,1e5];
    [1e1,1e2,1e3,1e4,1e5];
    [1e2,2e2,5e2,1e3,2e3,5e3,1e4,2e4,5e4,1e5,2e5,5e5,1e6]};

tau = 0.05;
aavg_array = [2,2,2,2,2,2,2,2,2];
colors = ["#0072BD","#008000","#A2142F"];

disp("What do you want to plot?");
disp("1 - E/L trade-off");
disp("2 - Transmission Energy/Latency trade-off")
disp("3 - Computational Energy/Latency trade-off")
disp("4 - Virtual Queues");
disp("5 - Splitting Point Histograms")

type = input("Choose: ");
sim_duration = 1e4;

trans_end_array = 9000*[1,1,1,1,1,1,1,1,1,1,1,1,1];
switch type
    case {1,2,3}
        for d=1:numel(dir_vect)
            dir = dir_vect(d);
            q_array = zeros(numel(v_array{d}),1);
            etot_array = zeros(numel(v_array{d}),1);
            for index=1:numel(v_array{d})

                load(strcat(dir,'simulation',num2str(v_array{d}(index)),'.mat'));
                dtot = simulation.localCalculationLatencyArray+simulation.transmissionLatencyArray+simulation.serverLatencyArray;
                qtot = mean(dtot(trans_end_array(index):sim_duration));
                if type==1
                    etot = simulation.transmissionEnergyArray+simulation.computationalEnergyArray;%+simulation.serverEnergyArray;
                else
                    if type==2
                        etot = simulation.transmissionEnergyArray;
                    else
                        etot = simulation.computationalEnergyArray;
                    end
                end
                etot = mean(etot(trans_end_array(index):sim_duration));
                q_array(index) = qtot;
                etot_array(index) = etot;
            end
            if label_array(d) ~= ""
                plot(etot_array,q_array,marker_array(d),'DisplayName',label_array(d),'Color',color_array(d),'LineStyle',linestyle_array(d),'LineWidth',1.25)
            else
                plot(etot_array,q_array,marker_array(d),'Color',color_array(d),'LineStyle',linestyle_array(d),'HandleVisibility','off','LineWidth',1.25)
            end
            xlabel('TX Energy energy consumption [Joule]','FontSize',14)
            ylabel('Latency [s]','FontSize',14)
            grid on
            hold on
        end
        yline(20e-3,'-.','Color',"#EDB120",'DisplayName','{$D_{avg}$}','LineWidth',2,'Interpreter','latex');
        legend('location','best','Interpreter','latex');
        set(gca, 'XScale', 'log');
        %axis([1e-2 1.5e-1,0.12,0.21]);
    case 4
        dir = input("Please, select the directory of which you want to plot the virtual queues: ",'s');
        for i=1:numel(v_array{index})
            load(strcat(dir,'simulation',num2str(v_array{index}(i)),'.mat'))
            figure
            subplot(2,1,1);
            plot(simulation.YArray)
            grid on
            ylabel('Accuracy virtual queue')
            subplot(2,1,2);
            plot(simulation.ZArray)
            grid on
            ylabel('Latency Virtual Queue')
            xlabel('Time-slot index')
        end
    case 5
        for d=1:numel(dir_vect)
            figure;
            dir = dir_vect(d);
            load(strcat(dir,'simulation',num2str(v_array{d}(end)),'.mat'));
            strcat(dir,'simulation',num2str(v_array{d}(end)),'.mat')
            data_hist = simulation.kArray()-1;
            histHandle = histogram(data_hist(5000:end));
            %histHandle.BinEdges = histHandle.BinEdges + histHandle.BinWidth/2;
            legend(label_array(d));
            xticks(linspace(0,19,20))
            xlim([-1, 20]);
            grid on;
        end
end
