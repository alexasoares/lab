%% Reference Transitions
%cut out all the 4s (2s before and after) windows around transitions(D I/O
%switching from 1 to 0 or vv), excluding any that are too small (i.e.
%overlap other windows) - to compare raw signal and reference channel
%end result: a folder with 1 excel file for each trial/mouse in which the
%first 2 sheets have raw and reference data for transitions from DIO = 1
%to DIO = 0 and the last 2 sheets have raw and reference data for
%transitions from DIO = 0 to DIO = 1

%% NOTE: this assumes DIO = 1 in the first timepoint

clc
clear all;
close all;

%% SETUP EXPERIMENT - change these parameters to fit this dataset
path = 'C:\Users\alexa\Google Drive\Grad School\Piciotto Lab\Projects\Sensor FP ReAnalyze\Data\LDT NE'; %CHANGE this to whatever folder holds all the data for this experiment
exp = '103019-LD-NE'; %CHANGE this to whatever the prefix is for all your files
A = 'Light'; %What behavioral phase is signified by a 1 in DIO?
B = 'Dark'; %What behavioral phase is signified by a 0 in DIO?
chunk = 244; %CHANGE this depending on the window you want; 244 rows represents ~2s (really, 243.9024 rows represents 2s)


%make a folder to store the output files
tdir = [path, '\To Run\Transition_2s_Ref'];
mkdir(tdir);

%% SET the index to match the number of files in the folder
for index = 1:5
    
%setup variables
trialname = [exp, '_', num2str(index)];
filenameD = [path, '\To Run\Processed\PROCESSED_', trialname, '.csv'];
D = xlsread(filenameD);
time = D(:,1);
refsig = D(:,2); %reference channel
rawsig = D(:,3); %raw signal
rowtime = 0.0082; %each row in the data file represents .0082s
pulse = D(:,5);

%find transition points
temptrans = diff(pulse);
alltrans = find(temptrans ~= 0); %all transitions
stopA = find(temptrans < 0); %from A to B
startA = find(temptrans > 0); %from B to A

stopdataref = [];
stopdataraw = [];
startdataref = [];
startdataraw = [];
n = size(alltrans, 1) - 1; %leave out the last transition for now, will get to that later

%analyze all transitions except the last
for i = 1:n
    if i == 1
        start1 = alltrans(1) - chunk; %find the index of the beginning of the time window
        stop1 = alltrans(1) + chunk; %find the index of the end of the time window
        if (start1 > 0) && (stop1 < (alltrans(2) - chunk)) %if the window for the first transition is between the start of the trial and the beginning of the window for the second transition
            refwindow1 = refsig(start1:stop1); %find the refsig data for this time window
            rawwindow1 = rawsig(start1:stop1); %find the rawsig data for this time window
            
            %this is a transition from A to B
            stopdataref = [refwindow1];
            stopdataraw = [rawwindow1];
        end
    
    else
        start2 = alltrans(i) - chunk; %find the index of the beginning of the time window
        stop2 = alltrans(i) + chunk; %find the index of the end of the time window
        if (start2 > (alltrans(i - 1) + chunk)) && (stop2 < (alltrans(i + 1) - chunk)) %if the window for this transition is between the end of the last window and the beginning of the next window
            refwindow2 = refsig(start2:stop2); %find the refsig data for this time window
            rawwindow2 = rawsig(start2:stop2); %find the rawsig data for this time window
            if ismember(alltrans(i), stopA) == 1 %this is a transition from A to B
                stopdataref = [stopdataref refwindow2];
                stopdataraw = [stopdataraw rawwindow2];
            else %this is a transition from B to A
                startdataref = [startdataref refwindow2];
                startdataraw = [startdataraw rawwindow2];
            end   
        end
    end
end

%analyze the last transition
start3 = alltrans(end) - chunk;
stop3 = alltrans(end) + chunk;
if (start3 > (alltrans(end - 1) + chunk)) && (stop3 < length(rawsig)) %if the window for the last transition is between the end of the previous window and the end of the trial
    refwindow3 = refsig(start3:stop3); %find the refsig for this time window
    rawwindow3 = rawsig(start3:stop3); %find the rawsig for this time window
    if ismember(alltrans(end), stopA) == 1 %this is a transition from A to B
        stopdataref = [stopdataref refwindow3];
        stopdataraw = [stopdataraw rawwindow3];
    else %this is a transition from B to A
        startdataref = [startdataref refwindow3];
        startdataraw = [startdataraw rawwindow3];
    end
end

%get the timestamps
doublechunk = chunk * 2;
fullchunk = doublechunk + 1; %to capture all the rows in the full 4s window, you will need t(0) plus 2s before and after
chunktime = time(1:fullchunk); %grab an appropriate chunk of the time column
zero = chunktime(chunk + 1); %set the midpoint as 0
chunktime = chunktime - zero; %realign all the timestamps around 0

%add the timestamp column
stopdataref = [chunktime stopdataref];
stopdataraw = [chunktime stopdataraw];
startdataref = [chunktime startdataref];
startdataraw = [chunktime startdataraw];

%export to excel
stopdatareftab = array2table(stopdataref);
stopdatarawtab = array2table(stopdataraw);
startdatareftab = array2table(startdataref);
startdatarawtab = array2table(startdataraw);
dataname = [tdir, '\2sTransRef_', trialname, '.xlsx'];
writetable(stopdatareftab, dataname, 'Sheet', 1);
writetable(stopdatarawtab, dataname, 'Sheet', 2);
writetable(startdatareftab, dataname, 'Sheet', 3);
writetable(startdatarawtab, dataname, 'Sheet', 4);

%set the sheetnames
e = actxserver('Excel.Application'); %open ActiveX server
ewb = e.Workbooks.Open(dataname); %open file
ewb.Worksheets.Item(1).Name = ['To', B, 'Ref']; %rename 1st sheet
ewb.Worksheets.Item(2).Name = ['To', B, 'Raw']; %rename 2nd sheet
ewb.Worksheets.Item(3).Name = ['To', A, 'Ref']; %rename 3rd sheet
ewb.Worksheets.Item(4).Name = ['To', A, 'Raw']; %rename 4th sheet
ewb.Save
ewb.Close(false)
e.Quit

end
