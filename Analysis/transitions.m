%% Transitions
%cut out all the 4s (2s before and after) windows around transitions (D I/O
%switching from 1 to 0 or vv), excluding any that are too small (i.e.
%overlap other windows)
%start with z-scored data
%end result: a folder with 1 excel file for each trial/mouse in which the
%first sheet has all the transitions from DIO = 1 to DIO = 0 and the second
%sheet has all the transitions from DIO = 0 to DIO = 1

%% NOTE: this assumes that DIO = 1 in the first timepoint

clc
clear all;
close all;

%% SETUP EXPERIMENT - change these parameters to fit this dataset
path = 'C:\Users\alexa\Google Drive\Grad School\Piciotto Lab\Projects\Sensor FP ReAnalyze\Data\LDT NE'; %CHOOSE folder where the data is stored
exp = '103019-LD-NE'; %CHANGE this to whatever the prefix is for all your files
A = 'Light'; %What behavioral phase is signified by a 1 in DIO?
B = 'Dark'; %What behavioral phase is signified by a 0 in DIO?
chunk = 244; %244 rows represents ~2s (really, 243.9024 rows represents 2s)- change this if you want a different time window

%make a folder to store the output files
tdir = [path, '\To Run\Transition_2s'];
mkdir(tdir);

%% SET the index to match the number of files in the folder
for index = 1:5
    
%setup variables
trialname = [exp, '_', num2str(index)];
filenameD = [path, '\To Run\Processed\PROCESSED_', trialname, '.csv'];
D = xlsread(filenameD);
time = D(:,1);
zsig = D(:,6);
rowtime = 0.0082; %each row in the data file represents .0082s
pulse = D(:,5);

%find transition points
temptrans = diff(pulse);
alltrans = find(temptrans ~= 0); %all transitions
stopA = find(temptrans < 0); %from A phase to B phase
startA = find(temptrans > 0); %from B phase to A phase

stopdata = [];
startdata = [];
n = size(alltrans, 1) - 1; %leave out the last transition for now, will get to that later

%analyze all transitions except the last
for i = 1:n
    if i == 1
        start1 = alltrans(1) - chunk; %find the index of the beginning of the time window
        stop1 = alltrans(1) + chunk; %find the index of the end of the time window
        if (start1 > 0) && (stop1 < (alltrans(2) - chunk)) %if the window for the first transition is between the start of the trial and the beginning of the window for the second transition
            zwindow1 = zsig(start1:stop1); %find the z-scored signal data for this time window
            stopdata = [zwindow1]; %this is a transition from A to B
        end
    
    else
        start2 = alltrans(i) - chunk; %find the index of the beginning of the time window
        stop2 = alltrans(i) + chunk; %find the index of the end of the time window
        if (start2 > (alltrans(i - 1) + chunk)) && (stop2 < (alltrans(i + 1) - chunk)) %if the window for this transition is between the end of the last window and the beginning of the next window
            zwindow2 = zsig(start2:stop2); %find the z-scored signal data for this time window
            if ismember(alltrans(i), stopA) == 1
                stopdata = [stopdata zwindow2]; %this is a transition from A to B
            else
                startdata = [startdata zwindow2]; %this is a transition from B to A
            end   
        end
    end
end

%analyze the last transition
start3 = alltrans(end) - chunk;
stop3 = alltrans(end) + chunk;
if (start3 > (alltrans(end - 1) + chunk)) && (stop3 < length(zsig)) %if the window for the last transition is between the end of the previous window and the end of the trial
    zwindow3 = zsig(start3:stop3);
    if ismember(alltrans(end), stopA) == 1
        stopdata = [stopdata zwindow3]; %this is a transition from A to B
    else
        startdata = [startdata zwindow3]; %this is a transition from B to A
    end
end

%get the timestamps
doublechunk = chunk * 2;
fullchunk = doublechunk + 1; %to capture all the rows in the full 4s window, you will need t(0) plus 2s before and after
chunktime = time(1:fullchunk); %grab an appropriate chunk of the time column
zero = chunktime(chunk + 1); %set the midpoint as 0
chunktime = chunktime - zero; %realign all the timestamps around 0
stopdata = [chunktime stopdata];
startdata = [chunktime startdata]; %add the timestamp column

%export to excel
stopdatatable = array2table(stopdata);
startdatatable = array2table(startdata);
dataname = [tdir, '\2sTrans_', trialname, '.xlsx'];
writetable(stopdatatable, dataname, 'Sheet', 1);
writetable(startdatatable, dataname, 'Sheet', 2);

%set the sheetnames
e = actxserver('Excel.Application'); %open ActiveX server
ewb = e.Workbooks.Open(dataname); %open file
ewb.Worksheets.Item(1).Name = ['To', B]; %rename 1st sheet
ewb.Worksheets.Item(2).Name = ['To', A]; %rename 2nd sheet
ewb.Save
ewb.Close(false)
e.Quit

end
