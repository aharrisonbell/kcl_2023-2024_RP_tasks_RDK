%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% kcl_rdk_daria_compileData.m %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% started by AHB, Feb 2024
% v1.0 - first draft


%% Load data (Daria - you will need to update these folders OR make sure you run this program from within the same directory as the dat files are located
if ispc % if this program is run on a windows PC
    rootdir='C:\Users\K...\OneDrive - King''s College London\MATLAB';
else % if this program is run on a macbook
    rootdir='~/OneDrive - King''s College London/MATLAB/currentProjects/proj_kcl_RDK_task';
end

%% find datafiles
datafiles = dir('kcl_rdk_daria_ppt_*.mat'); % find all datafiles that are NOT intermediate

summaryData = nan(1,1); % initialise empty matrix

for dd = 1:numel(datafiles)
    

end