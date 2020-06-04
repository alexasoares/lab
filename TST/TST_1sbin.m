%%average the z-scored df/f0 signal over 1s bins and plot it; calculate and
%%plot the first derivative of the binned signal; calculate the average
%%slope during immobile and mobile phases and save it in an excel file

clc
clear all;
close all;

%%SETUP EXPERIMENT
path = 'C:\Users\alexa\Google Drive\Grad School\Piciotto Lab\Projects\Sensor FP ReAnalyze\Data\TST NE'; %CHANGE this to whatever folder holds all the data for this experiment
exp = '103119-TST-NE'; %CHANGE this to whatever the prefix is for all your files
plotname = 'TST NE '; %CHANGE this to an appropriate title for all the graphs; make sure it ends in a space


%%set y-axis height
yax = 3;

%%make a folder for the plots of binned data
bindir = [path, '\Figures\1s Binned Plots'];
mkdir(bindir);

%%make a folder for the slope plots
mdir = [path, '\Figures\Slope Plots'];
mkdir(mdir);


data = [];
for index = 1:5 %CHANGE the second number to match the number of files in the folder
%%setup variables
trialname = [exp, '_', num2str(index)];
filenameD = [path, '\To Run\Processed\PROCESSED_', trialname, '.csv'];
D = xlsread(filenameD);

%%add a column of zeros to D
zerocol = zeros(size(D,1),1);
D = [D zerocol];

%%change the zerocol to a number indicating the second it corresponds to
for i = 1:355
    firstzero = find(D(:,7) == 0, 1); %find the first zero
    onesec = firstzero + 122; %find the last row in this second
    D(firstzero:onesec,7) = i; %convert all the zeros in this second to a number indicating the second
end

%%find the average at each second
output = [];
for ii = 1:355
    second = find(D(:,7) == ii); %find the rows corresponding to this second
    secondavg = mean(D(second,6)); %find the average z-scored signal across this second
    secondmove = median(D(second,5)); %find whether the mouse is mobile or immobile for the majority of this second
    output = [output; ii secondavg secondmove]; %put the data in a table
end

%%plot the averaged z-score signal with a green background where the mouse
%%is moving
figure()
move = find(D(:,5) == 1); %find when the mouse is moving
movetime = D(move,1);
movetime = movetime - movetime(1); %set t(0)
for iii = movetime(:,1)
     line([iii iii], [-yax yax],'Color','green'); %add the green background for the mobile phases
end
hold on

time = output(:,1);
signal = output(:,2);
plot(time,signal,'k')

%%format graph
yticks([-yax:1:yax])
ylim([-yax,yax])
set(gca, 'Layer', 'top')
xlim([0,time(end)])
set(gca, 'Layer', 'top')
xlabel('Time (sec)')
ylabel('\DeltaF/F_0 z-score')
title([plotname, num2str(index)])
set(gca,'fontsize',12)


%%save it in the 1s Binned Plots folder
saveas(gcf, [bindir, '\1sBin_', trialname,'.png']);
close

%%calculate the first derivative and put it in a table
slope = diff(signal); %calculate the first derivative
slopetime = time; %grab the time column created earlier
slopetime(end,:) = [];
slopepulse = (output(:,3)); %grab the DIO column created earlier
slopepulse(end,:) = [];
slopetable = [slopetime slope slopepulse]; %put it all in a table

%%calculate the average slope during mobile vs immobile phases
binnedmove = find(slopetable(:,3) == 1); %find when the mouse is moving
moveslope = slopetable(binnedmove,2);
moveslopeavg = mean(moveslope);
moveslopemed = median(moveslope);

binnedstill = find(slopetable(:,3) == 0); %find when the mouse is immobile
stillslope = slopetable(binnedstill,2);
stillslopeavg = mean(stillslope);
stillslopemed = median(stillslope);

data = [data; index moveslopeavg stillslopeavg moveslopemed stillslopemed];

%%plot the first derivative with a green background where the mouse is
%%moving
figure()

for iii = movetime(:,1)
     line([iii iii], [-yax yax],'Color','green'); %add the green background for mobile phases
end
hold on

plot(slopetime,slope, 'k')

%%format graph
yticks([-yax:1:yax])
ylim([-yax,yax])
set(gca, 'Layer', 'top')
xlim([0,time(end)])
set(gca, 'Layer', 'top')
xlabel('Time (sec)')
ylabel('\DeltaF/F_0 z-score slope')
title([plotname, num2str(index)])
set(gca,'fontsize',12)

%%save it in the Slope Plots folder
saveas(gcf, [mdir, '\Slope_', trialname,'.png']);
close

end

%%create a table with all the data
colnames = {'Mouse' 'Mobile_Slope_Avg' 'Immobile_Slope_Avg' 'Mobile_Slope_Med' 'Immobile_Slope_Med'};
datatable = array2table(data,'VariableNames',colnames);

%%save output as excel file
writetable(datatable,[path, '\Figures\', exp, '_slopedata.xlsx'])