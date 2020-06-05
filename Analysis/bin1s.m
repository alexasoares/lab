%% 1s Bin
%average the z-scored df/f0 signal over 1s bins and plot it; calculate and
%plot the slope of the binned signal; calculate the average slope during
%each behavioral phase and save to excel

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

%set y-axis height
yax = 5;

%make a folder for the plots of binned data
bindir = [path, '\Figures\1s Binned Plots'];
mkdir(bindir);

%make a folder for the slope plots
mdir = [path, '\Figures\Slope Plots'];
mkdir(mdir);


data = [];

%% SET the index to match the number of files in the folder
for index = 1:5
    
%setup variables
trialname = [exp, '_', num2str(index)];
filenameD = [path, '\To Run\Processed\PROCESSED_', trialname, '.csv'];
D = xlsread(filenameD);

%add a column of zeros to D
zerocol = zeros(size(D,1),1);
D = [D zerocol];

%change the zerocol to a number indicating the second it corresponds to
for i = 1:355
    firstzero = find(D(:,7) == 0, 1); %find the first zero
    onesec = firstzero + 122; %find the last row in this second
    D(firstzero:onesec,7) = i; %convert all the zeros in this second to a number indicating the second
end

%find the average at each second
output = [];
for ii = 1:355
    second = find(D(:,7) == ii); %find the rows corresponding to this second
    secondavg = mean(D(second,6)); %find the average z-scored signal across this second
    secondmove = median(D(second,5)); %find whether the mouse is mobile or immobile for the majority of this second
    output = [output; ii secondavg secondmove]; %put the data in a table
end

%plot the averaged z-score signal with a colored background where DIO = 1
figure()
AA = find(D(:,5) == 1);
Atime = D(AA,1);
Atime = Atime - Atime(1); %set t(0)
for iii = Atime(:,1)
     line([iii iii], [-yax yax],'Color', Abg); %add the colored background
end
hold on

time = output(:,1);
signal = output(:,2);
plot(time,signal,'k')

%format graph
yticks([-yax:1:yax])
ylim([-yax,yax])
set(gca, 'Layer', 'top')
xlim([0,time(end)])
set(gca, 'Layer', 'top')
xlabel('Time (sec)')
ylabel('\DeltaF/F_0 z-score')
title([plotname, num2str(index)])
set(gca,'fontsize',12)


%save it in the 1s Binned Plots folder
saveas(gcf, [bindir, '\1sBin_', trialname,'.png']);
close

%calculate the first derivative and put it in a table
slope = diff(signal); %calculate the first derivative
slopetime = time; %grab the time column created earlier
slopetime(end,:) = [];
slopepulse = (output(:,3)); %grab the DIO column created earlier
slopepulse(end,:) = [];
slopetable = [slopetime slope slopepulse]; %put it all in a table

%calculate the average slope during each phase
binnedA = find(slopetable(:,3) == 1); %find when DIO = 1
Aslope = slopetable(binnedA,2);
Aslopeavg = mean(Aslope);
Aslopemed = median(Aslope);

binnedB = find(slopetable(:,3) == 0); %find when the DIO = 0
Bslope = slopetable(binnedB,2);
Bslopeavg = mean(Bslope);
Bslopemed = median(Bslope);

data = [data; index Aslopeavg Bslopeavg Aslopemed Bslopemed];

%plot the first derivative with a colored background where DIO = 1
figure()

for iii = Atime(:,1)
     line([iii iii], [-yax yax],'Color', Abg); %add the colored background
end
hold on

plot(slopetime,slope, 'k')

%format graph
yticks([-yax:1:yax])
ylim([-yax,yax])
set(gca, 'Layer', 'top')
xlim([0,time(end)])
set(gca, 'Layer', 'top')
xlabel('Time (sec)')
ylabel('\DeltaF/F_0 z-score slope')
title([plotname, num2str(index)])
set(gca,'fontsize',12)

%save it in the Slope Plots folder
saveas(gcf, [mdir, '\Slope_', trialname,'.png']);
close

end

%create a table with all the data
colnames = {'Mouse' [A, '_Slope_Avg'] [B, '_Slope_Avg'] [A, '_Slope_Med'] [B, '_Slope_Med']};
datatable = array2table(data,'VariableNames',colnames);

%save output as excel file
writetable(datatable,[path, '\Figures\', exp, '_slopedata.xlsx'])