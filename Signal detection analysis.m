%Signal detection analysis - calculates d prime and c values


clear all
clc
dbstop if error

dataRoot = uigetdir('','Pick a Directory containing only interoception results files'); %Directory where all .txt files are saved
cd(dataRoot)

outputRoot = uigetdir('','Pick a Directory to save the output');

results_summary = {'name','d_prime','C'};

files = dir;                                  %Creates a list called txtList with all the fle names from the directory
txtList = {};
for x = 1:length(files)
    file = strcat(dataRoot,files(x).name);
    [filepath,name,ext] = fileparts(file);
    if strcmp(ext,'.txt')
        txtList = [txtList;files(x).name];
    end
end

for x = 1:length(txtList)                                    %Searches each file for the values needed to calculate d and c
    file = fileread(char(txtList(x)));
    buffer = file;
    Hits = str2double(regexpi(buffer, '(?<=Total true positives\s*)\d*', 'match')) + 0.5; %True positive   all uses the log-linear correction +0.5 (Snodgrass and Corwin 1988)
    correctRejects = str2double(regexpi(buffer, '(?<=Total true negatives\s*)\d*', 'match')) + 0.5; %True Negative
    falseAlarms =  str2double(regexpi(buffer, '(?<=Total false positives\s*)\d*', 'match')) +0.5; %False posities
    Misses =  str2double(regexpi(buffer, '(?<=Total false negatives\s*)\d*', 'match')) +0.5; %False Negative
    
    HR = Hits / (Hits + Misses); % compute hits as all the responses to trials in which signal was present 
    % in which the response was present (i.e. == 1). Divide by number of present trials.
    FAR = falseAlarms / (falseAlarms + correctRejects); % misses are the same except when the responses are 0 (absent even though signal was present)

    Z_HR = norminv(HR);
    Z_FAR = norminv(FAR);
    d = Z_HR - Z_FAR;
    c = -(Z_HR + Z_FAR)/2;

    results_summary = [results_summary;{char(txtList(x)),d,c}];
end

cd (outputRoot);  %Directory where you want the ouput file to save

f_name = strcat('signal_detection_analysis_output',date,'.xls');
xlswrite(f_name,results_summary,'Sheet1')                                       %Saves all to excel file










