function [] = virtualQueuesPlotting(path,v_array)
for i=1:numel(v_array)
    load(strcat(path,"simulation",num2str(v_array(i)),".mat"),'simulation');
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
end

