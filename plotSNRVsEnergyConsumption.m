clear all;
close all;

disp("What do you want to plot?");
disp("1 - Virtual Queues");
disp("2 - SNR vs Energy Consumption");

type = input("Choose: ");

color_array =  ["#0072BD","#D95319","#EDB120"];
linstyle_array = ["-","--"];


load_folder = "./PathLoss100/";
gavg_array = [80,85,88];
snr_array = ["Neg5","Neg4","Neg3","Neg2","0"];
snr_axis = [-5,-4,-3,-2,0];
v_array = [1e8,1e8,1e8,1e8,1e8,1e8];
trans_end_array = [9000,9000,9000,9000,9000,9000];

energy_array = zeros(1,numel(snr_array));
tx_energy_array = zeros(1,numel(snr_array));
computation_energy_array = zeros(1,numel(snr_array));

if type==1
   for g=1:numel(gavg_array)
        gavg = gavg_array(g);
        for i=1:numel(snr_array)
            path = strcat(load_folder,"SNR",num2str(snr_array(i)),"/","Acc",num2str(gavg),"/");
            virtualQueuesPlotting(path,v_array(i));
        end
    end
else
    figure
    for g=1:numel(gavg_array)
        gavg = gavg_array(g);
        for i=1:numel(snr_array)
            path = strcat(load_folder,"SNR",num2str(snr_array(i)),"/","Acc",num2str(gavg),"/");
            load(strcat(path,"simulation",num2str(v_array(i)),".mat"));
            computation_energy_array(i) = mean(simulation.computationalEnergyArray(9000:end));
            tx_energy_array(i) = mean(simulation.transmissionEnergyArray(9000:end));
            energy_array(i) = computation_energy_array(i)+tx_energy_array(i);
        end
        plot(snr_axis,energy_array,'LineWidth',2,'Marker','o','DisplayName',strcat('$G_{avg}\geq',num2str(gavg_array(g)),"\%$"),'Color',color_array(g))
        path = strcat(load_folder,"OptimizeSNR","/","Acc",num2str(gavg),"/");
        %load(strcat(path,"simulation",num2str(v_array(i)),".mat"));
        etot = simulation.transmissionEnergyArray+simulation.computationalEnergyArray;
        emean = mean(etot(9000:end));
        snr = mean(simulation.SNRdBArray(9000:end));
        hold on;
        %plot(snr,emean,'LineWidth',2,'Marker','H','Color',color_array(g),'HandleVisibility','off');
        xlabel('SNR constraint [dB]','FontSize',14)
        ylabel('Energy [J]','FontSize',14)
        l = legend('Position',[0.3 0.7 0.1 0.2]);
        set(l,'Interpreter','latex');
        set(l,'Fontsize',10);
    end

end





