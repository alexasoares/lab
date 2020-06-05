%% Pre/Post Transition Analysis
%calculate summary statistics to compare pre vs post transition data for
%transitions between DIO = 1 and DIO = 0

clc
clear all
close all

%% SETUP EXPERIMENT - change these parameters to fit this dataset
path = 'C:\Users\alexa\Google Drive\Grad School\Piciotto Lab\Projects\Sensor FP ReAnalyze\Data\LDT NE'; %CHANGE this to whatever folder holds all the data for this experiment
exp = '103019-LD-NE'; %CHANGE this to whatever the prefix is for all your files
A = 'Light'; %What behavioral phase is signified by a 1 in DIO?
B = 'Dark'; %What behavioral phase is signified by a 0 in DIO?

stopoutput = [];
startoutput = [];

%% SET the index to match the number of files in the folder
for index = 1:5

%setup variables
trialname = [exp, '_', num2str(index)];
filenameT = [path, '\To Run\Transition_2s\2sTrans_', trialname, '.xlsx'];
stopdata = xlsread(filenameT, 1); %the first sheet contains the transitions from A to B
startdata = xlsread(filenameT, 2); %the second sheet contains the transitions from B to A

%separate the data into chunks before and after each transition (t(0) will not be included in analysis)
trans = find(stopdata(:,1) == 0); %find t(0)
prestoptemp = stopdata(1:(trans - 1), 2:end); %all the data from the beginning of the window to the transition
prestop = prestoptemp(:); %convert to 1D
poststoptemp = stopdata((trans + 1):end, 2:end); %all the data from the transition to the end of the window
poststop = poststoptemp(:); %convert to 1D
prestarttemp = startdata(1:(trans - 1), 2:end); %all the data from the beginning of the window to the transition
prestart = prestarttemp(:); %convert to 1D
poststarttemp = startdata((trans + 1):end, 2:end); %all the data from the transition to the end of the window
poststart = poststarttemp(:); %convert to 1D

%find summary statistics (mean, sem, median, peak) for each chunk
%StopA - before transition
prestopavg = mean(prestop);
prestopsem = std(prestop) / sqrt(length(prestop));
prestopmed = median(prestop);
prestoppeak = max(prestop);

%StopA - after transition
poststopavg = mean(poststop);
poststopsem = std(poststop) / sqrt(length(poststop));
poststopmed = median(poststop);
poststoppeak = max(poststop);

%StartA - before transition
prestartavg = mean(prestart);
prestartsem = std(prestart) / sqrt(length(prestart));
prestartmed = median(prestart);
prestartpeak = max(prestart);

%StartA - after transition
poststartavg = mean(poststart);
poststartsem = std(poststart) / sqrt(length(poststart));
poststartmed = median(poststart);
poststartpeak = max(poststart);

%add the data to output
stopoutput = [stopoutput; index prestopavg poststopavg prestopsem poststopsem prestopmed poststopmed prestoppeak poststoppeak];
startoutput = [startoutput; index prestartavg poststartavg prestartsem poststartsem prestartmed poststartmed prestartpeak poststartpeak];

end

%create tables with all the output data
colnames = {'Mouse' 'Pre_Avg' 'Post_Avg' 'Pre_SEM' 'Post_SEM' 'Pre_Median' 'Post_Median' 'Pre_Peak' 'Post_Peak'};
stoptab = array2table(stopoutput, 'VariableNames', colnames);
starttab = array2table(startoutput, 'VariableNames', colnames);

%export to excel
dataname = [path, '\Figures\', exp, '_transdata.xlsx'];
writetable(stoptab, dataname, 'Sheet', 1);
writetable(starttab, dataname, 'Sheet', 2);

%set the sheetnames
e = actxserver('Excel.Application'); %open ActiveX server
ewb = e.Workbooks.Open(dataname); %open file
ewb.Worksheets.Item(1).Name = ['To', B]; %rename 1st sheet
ewb.Worksheets.Item(2).Name = ['To', A]; %rename 2nd sheet
ewb.Save
ewb.Close(false)
e.Quit