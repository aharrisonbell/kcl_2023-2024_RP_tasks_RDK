%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% kcl_rdk_shuyi_compileData.m %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% started by AHB, Mar 2024
% v1.0 - first draft


%% Load data (Shuyi - you will need to update these to the same directory as the data files are located on your machine
if ispc % if this program is run on a windows PC
    rootdir='C:\Users\K...\OneDrive - King''s College London\MATLAB';
else % if this program is run on a macbook
    rootdir='~/OneDrive - King''s College London/MATLAB/currentProjects/proj_kcl_RDK_task/shuyi_data/';
end

%% find datafiles (*.mat)
datafiles = dir([rootdir, filesep, 'kcl_rdk_shuyi_ppt_*.txt']); % find all datafiles that are NOT intermediate
disp(['Found ',num2str(numel(datafiles)), ' datafiles'])

summaryData = []; % initialise empty matrix
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
% 16) Task_version;

summaryData = []; % initialise empty matrix
for dd = 1:size(datafiles)
    clear respMat temp_*
    % load([rootdir, filesep, datafiles(dd).name])
    respMat = dlmread(datafiles(dd).name); %#ok<DLMRD>

    if size(respMat, 2) == 15
        respMat = [respMat nan(size(respMat,1) ,1)]; % if less than 16 columns, add a blank one
    end    
    summaryData = [summaryData; respMat]; %#ok<*AGROW>
end

writematrix(summaryData, [rootdir, filesep, 'kcl_shuyi_SummaryData_', date, '_', num2str(size(datafiles, 1)), 'files.csv'])
writecell({datafiles.name}', [rootdir, filesep, 'kcl_shuyi_SummaryData_', date, '_list_of_files.csv'])