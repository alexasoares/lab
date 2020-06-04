%%for a folder of TST trials: plot the raw signal against the reference signal with green background to indicate
%%mobile phases, then calculate the Z-scored signal, add it to the PROCESSED file, and plot with green
%%sections; calculate summary statistics for each phase and export to excel

clc
clear all;
close all;

%%SETUP EXPERIMENT
path = 'C:\Users\alexa\Google Drive\Grad School\Piciotto Lab\Projects\Sensor FP ReAnalyze\Data\TST NE'; %CHANGE this to whatever folder holds all the data for this experiment
exp = '103119-TST-NE'; %CHANGE this to whatever the prefix is for all your files
plotname = 'TST NE '; %CHANGE this to an appropriate title for all the graphs; make sure it ends in a space

%%set y-axis heights
yax = 12; %change this to set the height for the y-axis on the RawSig plots
zyax = 5; %change this to set the height for the y-axis on the ZSig plots

%%make a folder for the raw plots
rawdir = [path, '\Figures\RawSig Plots'];
mkdir(rawdir);

%%make a folder for the z-scored plots
zdir = [path, '\Figures\ZSig Plots'];
mkdir(zdir);

output = [];
for index = 1:5 %CHANGE the second number to match the number of files in the folder

%%setup variables
trialname = [exp, '_', num2str(index)];
filenameD = [path, '\To Run\Processed\PROCESSED_', trialname, '.csv'];
D = xlsread(filenameD);
time = D(:,1);
time = time - time(1); %align to t(0) - since the data was trimmed previously
rowtime = 0.0082; %each row in the data file represents .0082s
rawsig = D(:,3); %this is the raw signal
ref = D(:,2); %this is the reference channel

%%make a graph for the raw signal
figure()

%%put a green background to indicate when the mouse is moving
move = find(D(:,5) == 1); %the mouse is moving when the DIO pulse = 1
movetime = D(move,1);
movetime = movetime - movetime(1);
    for i = movetime(:,1)
     line([i i], [-yax yax],'Color','green');
    end
hold on

%%plot the raw signal and the reference channel
sigplot = plot(time,rawsig,'k','LineWidth', 0.5);
refplot = plot (time,ref, 'k', 'LineWidth', 0.5);
refplot.Color(4) = 0.2;
    
%%format graph
yticks([-yax:2:yax])
ylim([-yax,yax])
set(gca, 'Layer', 'top')
xlim([0,time(end)])
set(gca, 'Layer', 'top')
xlabel('Time (sec)')
ylabel('\DeltaF/F_0')
title([plotname, num2str(index)])
set(gca,'fontsize',12)

%%save it in the RawSig Plots folder
saveas(gcf, [rawdir, '\RawPlot_', trialname,'.png']);
close

%%find zscore and add it to the excel file
zsig = zscore(rawsig);
xlswrite(filenameD,'Z',1,'F1:F1')
xlswrite(filenameD,zsig,1,'F2')
D = xlsread(filenameD);

%%make a graph for the z-scored signal
figure()

%%put a green background to indicate when the mouse is moving
    for i = movetime(:,1)
     line([i i], [-zyax zyax],'Color','green');
    end
hold on

%%plot the z-scored signal
sigplot = plot(time,zsig,'k','LineWidth', 0.5);

%%format graph
yticks([-zyax:1:zyax])
ylim([-zyax,zyax])
set(gca, 'Layer', 'top')
xlim([0,time(end)])
set(gca, 'Layer', 'top')
xlabel('Time (sec)')
ylabel('Z-Scored \DeltaF/F_0')
title([plotname, num2str(index)])
set(gca,'fontsize',12)

%%save it in the ZSig Plots folder
saveas(gcf, [zdir, '\ZPlot_', trialname, '.png']);
close

%%calculate summary statistics (mean, sem, median, duration, peak) for each phase
%mobile
movezsignal = D(move,6);
movezavg = mean(movezsignal);
movezsem = std(movezsignal) / sqrt(length(movezsignal));
movezmed = median(movezsignal);
movedur = length(move)*rowtime;
movepeak = max(movezsignal);

%immobile
still = find(D(:,5) == 0); %the mouse is immobile when DIO = 0
stillzsignal = D(still,6);
stillzavg = mean(stillzsignal);
stillzsem = std(stillzsignal) / sqrt(length(stillzsignal));
stillzmed = median(stillzsignal);
stilldur = length(still)*rowtime;
stillpeak = max(stillzsignal);

percentmove = movedur / (movedur + stilldur);
percentstill = 1 - percentmove;

%%add the data to output
output = [output; index movezavg stillzavg movezsem stillzsem movezmed stillzmed movedur stilldur percentmove percentstill movepeak stillpeak];

end

%%create a table with all the output data
colnames = {'Mouse' 'Avg_Mobile' 'Avg_Immobile' 'SEM_Mobile' 'SEM_Immobile' 'Med_Mobile' 'Med_Immobile' 'Dur_Mobile_sec' 'Dur_Immobile_sec' 'Percent_Mobile' 'Percent_Immobile' 'Peak_Mobile' 'Peak_Immobile'};
outputtable = array2table(output,'VariableNames',colnames);

%%save output as excel file
writetable(outputtable,[path, '\Figures\', exp, '_zdata.xlsx'])
