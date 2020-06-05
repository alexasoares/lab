%% Zplot - Shaded
%for a folder of trials: plot the raw signal against the reference signal
%with a colored background to indicate when D I/O = 1, then calculate the
%Z-scored signal, add it to the PROCESSED file, and plot with colored
%sections; calculate summary statistics for each phase and export to excel

clc
clear all;
close all;

%% SETUP EXPERIMENT - change these parameters to fit this dataset
path = 'C:\Users\alexa\Google Drive\Grad School\Piciotto Lab\Projects\Sensor FP ReAnalyze\Data\LDT NE'; %CHANGE this to whatever folder holds all the data for this experiment
exp = '103019-LD-NE'; %CHANGE this to whatever the prefix is for all your files
plotname = 'LDT NE '; %CHANGE this to an appropriate title for all the graphs; make sure it ends in a space
A = 'Light'; %What behavioral phase is signified by a 1 in DIO?
B = 'Dark'; %What behavioral phase is signified by a 0 in DIO?
Abg = 'yellow'; %Set the background color for the A phase (i.e. 'green' for TST, 'yellow' for LDT)

%set y-axis heights
yax = 12; %change this to set the height for the y-axis on the RawSig plots
zyax = 5; %change this to set the height for the y-axis on the ZSig plots

%make a folder for the raw plots
rawdir = [path, '\Figures\RawSig Plots'];
mkdir(rawdir);

%make a folder for the z-scored plots
zdir = [path, '\Figures\ZSig Plots'];
mkdir(zdir);

output = [];

%% SET the index to match the number of files in the folder
for index = 1:5 

%setup variables
trialname = [exp, '_', num2str(index)];
filenameD = [path, '\To Run\Processed\PROCESSED_', trialname, '.csv'];
D = xlsread(filenameD);
time = D(:,1);
time = time - time(1); %align to t(0) - since the data was trimmed previously
rowtime = 0.0082; %each row in the data file represents .0082s
rawsig = D(:,3); %this is the raw signal
ref = D(:,2); %this is the reference channel

%make a graph for the raw signal
figure()

%put a colored background to indicate when DIO = 1
AA = find(D(:,5) == 1); 
Atime = D(AA,1);
Atime = Atime - Atime(1);
    for i = Atime(:,1)
     line([i i], [-yax yax],'Color',Abg);
    end
hold on

%plot the raw signal and the reference channel
sigplot = plot(time,rawsig,'k','LineWidth', 0.5);
refplot = plot (time,ref, 'k', 'LineWidth', 0.5);
refplot.Color(4) = 0.2;
    
%format graph
yticks([-yax:2:yax])
ylim([-yax,yax])
set(gca, 'Layer', 'top')
xlim([0,time(end)])
set(gca, 'Layer', 'top')
xlabel('Time (sec)')
ylabel('\DeltaF/F_0')
title([plotname, num2str(index)])
set(gca,'fontsize',12)

%save it in the RawSig Plots folder
saveas(gcf, [rawdir, '\RawPlot_', trialname,'.png']);
close

%find zscore and add it to the excel file
zsig = zscore(rawsig);
xlswrite(filenameD,'Z',1,'F1:F1')
xlswrite(filenameD,zsig,1,'F2')
D = xlsread(filenameD);

%make a graph for the z-scored signal
figure()

%put a colored background to indicate when the mouse is moving
    for i = Atime(:,1)
     line([i i], [-zyax zyax],'Color',Abg);
    end
hold on

%plot the z-scored signal
sigplot = plot(time,zsig,'k','LineWidth', 0.5);

%format graph
yticks([-zyax:1:zyax])
ylim([-zyax,zyax])
set(gca, 'Layer', 'top')
xlim([0,time(end)])
set(gca, 'Layer', 'top')
xlabel('Time (sec)')
ylabel('Z-Scored \DeltaF/F_0')
title([plotname, num2str(index)])
set(gca,'fontsize',12)

%save it in the ZSig Plots folder
saveas(gcf, [zdir, '\ZPlot_', trialname, '.png']);
close

%calculate summary statistics (mean, sem, median, duration, peak) for each phase
%DIO = 1
Azsignal = D(AA,6);
Azavg = mean(Azsignal);
Azsem = std(Azsignal) / sqrt(length(Azsignal));
Azmed = median(Azsignal);
Adur = length(AA)*rowtime;
Apeak = max(Azsignal);

%DIO = 0
BB = find(D(:,5) == 0);
Bzsignal = D(BB,6);
Bzavg = mean(Bzsignal);
Bzsem = std(Bzsignal) / sqrt(length(Bzsignal));
Bzmed = median(Bzsignal);
Bdur = length(BB)*rowtime;
Bpeak = max(Bzsignal);

percentA = Adur / (Adur + Bdur);
percentB = 1 - percentA;

%add the data to output
output = [output; index Azavg Bzavg Azsem Bzsem Azmed Bzmed Adur Bdur percentA percentB Apeak Bpeak];

end

%create a table with all the output data
colnames = {'Mouse' ['Avg_',A] ['Avg_', B] ['SEM_', A] ['SEM_', B] ['Med_', A] ['Med_', B] ['Dur_', A, '_sec'] ['Dur_', B, '_sec'] ['Percent_', A] ['Percent_', B] ['Peak_', A] ['Peak_', B]};
outputtable = array2table(output,'VariableNames',colnames);

%save output as excel file
writetable(outputtable,[path, '\Figures\', exp, '_zdata.xlsx'])
