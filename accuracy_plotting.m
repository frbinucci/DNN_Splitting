clear all;
close all;

load('./Data/accuracy_lut.mat');
accuracy_lut =accuracy_lut*100;
x_axis = linspace(0,19,20);
legend_labels = ["\boldmath$\overline{\gamma}$ = -5 dB", "\boldmath$\overline{\gamma}$ = -3 dB", "\boldmath$\overline{\gamma}$ = 0 dB", "\boldmath$\overline{\gamma}$ = 5 dB", "\boldmath$\overline{\gamma}$ = 10 dB","\boldmath$\overline{\gamma}$ = 20 dB"];
marker_array = ["o","diamond","Hexagram","Pentagram","*","square"];


figure;
for i=1:size(accuracy_lut,1)
    plot(x_axis,accuracy_lut(i,:),'Marker',marker_array(i),'DisplayName',legend_labels(i),'LineWidth',1.5);
    xticks(x_axis)
    hold on;
end

l = legend('Position',[0.7 0.3 0.1 0.2]);
set(l,'Interpreter','latex');
set(l','FontSize',10);
grid on;
xlabel('Splitting Point','FontSize',14);
ylabel('Accuracy [%]','FontSize',14);
annotation('textarrow',[0.25,0.13],[0.16,0.14],'String','Full Offloading (raw data)');
annotation('textarrow',[0.75,0.87],[0.20,0.15],'String','Full Local Computation');