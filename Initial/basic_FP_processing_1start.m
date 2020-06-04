%%trim the raw data and batch calculate df/f0, starting at the first DIO 1
%%pulse

clc
clear all;
close all;


%% Change this directory to the folder containing your raw doric files!
directory = 'C:\Users\alexa\Google Drive\Grad School\Piciotto Lab\Projects\Sensor FP ReAnalyze\Data\TST NE\To Run';
files = dir(directory);

for file = files'
  
  filename = strcat(file.name);
  %only process .csv files, don't process "PROCESSED" files, and don't
  %process any that already have a 'PROCESSED' version in the folder
  if isempty(strfind(filename, '.csv'))==true || isempty(strfind(filename, 'PROCESSED_'))==false || sum(strcmp(strcat('PROCESSED_',filename),{files.name}))>0
    continue
  end
  
  allData = csvread([directory,'\' filename],2,0); % 1: skip first two lines (header); might need to skip more depeding how the file is formatted but basically the goal is to scrap the headers.
  trash = find(allData(:,1) > 0.1, 1);
  data = allData(trash:end, :); %first 100ms are noise from starting up LEDs
  firstLine = find(allData(:,5) > 0, 1);
  data = data(firstLine:end, :); %trim to first 1 in DIO (beginning of trial)
  
  DF_F0 = calculateDF_F0(data);
  DIO = data(:,5);
  correctedSignal = subtractReferenceAndSave(DF_F0, directory, filename, DIO);
  
end