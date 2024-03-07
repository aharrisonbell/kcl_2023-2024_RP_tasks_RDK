%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% kcl_rdk_shuyi_compileData.m %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% started by AHB, Mar 2024
% v1.0 - first draft
% v1.1 - added descriptives and figure


%% Load data (Shuyi - you will need to update these to the same directory as the data files are located on your machine
clearvars 
responseCutoff = 1; % change all trials with RTs > 1 second to TIMED OUT

if ispc % if this program is run on a windows PC
    rootdir='C:\Users\K...\OneDrive - King''s College London\MATLAB';
else % if this program is run on a macbook
    rootdir='~/OneDrive - King''s College London/MATLAB/currentProjects/proj_kcl_RDK_task/shuyi_data/';
end

%% find datafiles (*.mat)
datafiles = dir([rootdir, filesep, 'kcl_rdk_shuyi_ppt_*.txt']); % find all datafiles that are NOT intermediate
disp(['Found ',num2str(numel(datafiles)), ' datafiles'])



% SummaryData Structure
% 1)  Participant Number
% 2)  Current Block
% 3)  Total experiment trial number
% 4)  Block trial number
% 5)  Condition Number
% 6)  Direction number
% 7)  Direction in degrees
% 8)  Coherence number
% 9)  Coherence value
% 10) Colour number
% 11) Required response
% 12) Actual response
% 13) Outcome category
% 14) Response time
% 15) Intertrial interval
% 16) Task_version

%% Create large summaryData matrix with all GOOD data
rawData = []; %#ok<*NASGU> % initialise empty matrix
for dd = 1:size(datafiles)
    clear respMat temp_*
    % load([rootdir, filesep, datafiles(dd).name])
    respMat = dlmread(datafiles(dd).name); %#ok<DLMRD>
    if size(respMat, 2) == 15
        respMat = [respMat nan(size(respMat,1) ,1)]; % if less than 16 columns, add a blank one
    end    

    
    %% Correct Participant Number
    temp_participantNumber = str2num(datafiles(dd).name(19:20));
    if respMat(1,1) ~= temp_participantNumber
        disp([datafiles(dd).name,' - Participant numbers don''t match. Switching to number in FILENAME'])
        respMat(:,1) = temp_participantNumber;
    end
  
    rawData = [rawData; respMat]; %#ok<*AGROW>
end

%% Clear out NANs by row
rawData(any(isnan(rawData),2),:) = [];

%% Correct Reaction Time and trial outcome
rawData(rawData(:,14) > responseCutoff, 13) = 3; % correct trials where the reaction time is greater than 'responseCutoff' to 3

%% Save Raw Data
writematrix(rawData, [rootdir, filesep, 'kcl_shuyi_SummaryData_', date, '_', num2str(size(datafiles, 1)), 'files.csv']) %#ok<*DATE>
writecell({datafiles.name}', [rootdir, filesep, 'kcl_shuyi_SummaryData_', date, '_list_of_files.csv'])

%% Scroll through each participant to generate summary statistics
% Structure of summaryData
% 1)  Participant Number
% 2)  GROUP NUMBER (Daria - you will need to sort this out)
% 3)  Block Number
% 4)  num of Correct Trials
% 5)  num of Incorrect Trials
% 6)  num of Timed Out/No Response Trials
% 7)  % Correct/Block (including timed out trials) ALL DIFFICULTIES
% 8)  % Correct/Block (not including timed out trials) ALL DIFFICULTIES
% 9)  % Correct/Block (including timed out trials) COHERENCE 1
% 10) % Correct/Block (not including timed out trials) COHERENCE 1
% 11) % Correct/Block (including timed out trials) COHERENCE 2
% 12) % Correct/Block (not including timed out trials) COHERENCE 2
% 13) % Correct/Block (including timed out trials) COHERENCE 3
% 14) % Correct/Block (not including timed out trials) COHERENCE 3
% 15) % Correct/Block (including timed out trials) COHERENCE 4
% 16) % Correct/Block (not including timed out trials) COHERENCE 4
% 17) % Correct/Block (including timed out trials) COHERENCE 5
% 18) % Correct/Block (not including timed out trials) COHERENCE 5
% 19) % Correct/Block (including timed out trials) COHERENCE 6
% 20) % Correct/Block (not including timed out trials) COHERENCE 6

individualParticipants = unique(rawData(:,1));
summaryData = []; % initialise matrix
for pp = 1:length(individualParticipants)
    temp_summaryData =nan(4, 20);
    disp(['Analysing participant ',num2str(individualParticipants(pp)),'...'])
    tempData = rawData(rawData(:,1) == individualParticipants(pp),1:15);
    
    temp_summaryData(:,1) = tempData(1,1); % paste participant number
    for bb = 1:length(unique(tempData(:,2))) % scroll through each block
        temp_summaryData(bb, 3) = bb; % block number
        temp_summaryData(bb, 4) = length(find(tempData(:,2) == bb & tempData(:,13)==1)); % correct trials
        temp_summaryData(bb, 5) = length(find(tempData(:,2) == bb & tempData(:,13)==2)); % incorrect trials
        temp_summaryData(bb, 6) = length(find(tempData(:,2) == bb & tempData(:,13)==3)); % timed out trials
        temp_summaryData(bb, 7) = temp_summaryData(bb, 4) / sum(temp_summaryData(bb, 4:5)) * 100;
        temp_summaryData(bb, 8) = temp_summaryData(bb, 4) / sum(temp_summaryData(bb, 4:6)) * 100;

        for cc = 1:length(unique(tempData(:,8))) % scroll through each difficulty (coherence) level
            clear temp_difficulty_vector_data

            temp_difficulty_vector_data(1) = length(find(tempData(:,2) == bb & tempData(:,8) == cc & tempData(:,13)==1)); % correct trials
            temp_difficulty_vector_data(2) = length(find(tempData(:,2) == bb & tempData(:,8) == cc & tempData(:,13)==2)); % incorrect trials
            temp_difficulty_vector_data(3) = length(find(tempData(:,2) == bb & tempData(:,8) == cc & tempData(:,13)==3)); % timed out trials

            temp_summaryData(bb, 7+(cc*2)) = temp_difficulty_vector_data(1) / sum(temp_difficulty_vector_data(1:2)) * 100;
            temp_summaryData(bb, 8+(cc*2)) = temp_difficulty_vector_data(1) / sum(temp_difficulty_vector_data(1:3)) * 100;
        end
    end

    summaryData = [summaryData; temp_summaryData];
    clear temp_summaryData

end
summaryData(1:4,3:end)

%% Plot Data
figure
subplot(1, 2, 1)
hold on
errorbar([0.05, 0.10, 0.20, 0.30, 0.40, 0.50], mean(summaryData(summaryData(:,3)==1, [9, 11, 13, 15, 17, 19])), ...
    sem(summaryData(summaryData(:,3)==1, [9, 11, 13, 15, 17, 19])), 'rs-'); % block 1
errorbar([0.05, 0.10, 0.20, 0.30, 0.40, 0.50], mean(summaryData(summaryData(:,3)==2, [9, 11, 13, 15, 17, 19])), ...
    sem(summaryData(summaryData(:,3)==2, [9, 11, 13, 15, 17, 19])), 'bs-'); % block 2
errorbar([0.05, 0.10, 0.20, 0.30, 0.40, 0.50], mean(summaryData(summaryData(:,3)==3, [9, 11, 13, 15, 17, 19])), ...
    sem(summaryData(summaryData(:,3)==3, [9, 11, 13, 15, 17, 19])), 'gs-'); % block 3
errorbar([0.05, 0.10, 0.20, 0.30, 0.40, 0.50], mean(summaryData(summaryData(:,3)==4, [9, 11, 13, 15, 17, 19])), ...
    sem(summaryData(summaryData(:,3)==4, [9, 11, 13, 15, 17, 19])), 'ms-'); % block 4
title({'Performance as a function of BLOCK and Coherence Level','(mean +/- sem)'}, 'FontSize', 14)
xlabel('Difficulty (% Coherence)', 'FontSize', 12)
ylabel('Performance (% Correct)', 'FontSize', 12)

subplot(1, 2, 2)
hold on
errorbar([0.05, 0.10, 0.20, 0.30, 0.40, 0.50], mean(summaryData(summaryData(:,3)==1, [10, 12, 14, 16, 18, 20])), ...
    sem(summaryData(summaryData(:,3)==1, [10, 12, 14, 16, 18, 20])), 'rs-'); % block 1
errorbar([0.05, 0.10, 0.20, 0.30, 0.40, 0.50], mean(summaryData(summaryData(:,3)==2, [10, 12, 14, 16, 18, 20])), ...
    sem(summaryData(summaryData(:,3)==2, [10, 12, 14, 16, 18, 20])), 'bs-'); % block 2
errorbar([0.05, 0.10, 0.20, 0.30, 0.40, 0.50], mean(summaryData(summaryData(:,3)==3, [10, 12, 14, 16, 18, 20])), ...
    sem(summaryData(summaryData(:,3)==3, [10, 12, 14, 16, 18, 20])), 'gs-'); % block 3
errorbar([0.05, 0.10, 0.20, 0.30, 0.40, 0.50], mean(summaryData(summaryData(:,3)==4, [10, 12, 14, 16, 18, 20])), ...
    sem(summaryData(summaryData(:,3)==4, [10, 12, 14, 16, 18, 20])), 'ms-'); % block 4
title({'Performance as a function of BLOCK and Coherence Level','(mean +/- sem) - Includes TimeOut Trials'}, 'FontSize', 14)
xlabel('Difficulty (% Coherence)', 'FontSize', 12)
ylabel('Performance (% Correct)', 'FontSize', 12)
