%% kcl_rdkBlockTask_Daria.m
% based on MainTask.m provided by Paul Muhle-Karbe <p.muhle-karbe@bham.ac.uk>
% edited by AHB, Jan 2024
% v.1.3 Feb 6, 2024
% Uses Psychtoolbox V3
% This task includes 144 trials in each of four blocks
% Each trial begins with a central fixation point followed by a RDK (with
% variable characteristics). The direction of motion is alternated between
% 4 directions (randomly). The participant must indicate with a button push
% which direction they believe is the dominant direction of motion. The
% trials are presented in 4 blocks.
% Block 1 - the colour of the dots and the correct direction of motion are
% unrelated.
% Blocks 2-4 - the colour of the dots is linked (with 100% reliability) to
% the correct direction of motion. With each progressive block, the
% participants are given increasing clues as to the correct relationship
% between the dot colour and the direction of motion.

%% Trial/Task Description
% 144 Trials per block; total trials = 144 * 4
% Block 1: 4 directions (UL, LL, UR, LR) * 6 coherence levels (5%-50%) * 2
% colours

%% Clear dots workspace and screen 
%clear dots
sca;
close all;
clearvars;

%screenResX = 2560; % 3840;
%screenResY = 1440; % 2160;
%SetResolution(0, screenResX, screenResY, 60); % screen num, X, Y, refresh

%% HardCoded Task Parameters (translation matrix for text file)
% Coherence Levels (1-6)
coherenceLevels = [1 0.05; 2 0.10; 3 0.20; 4 0.30; 5 0.40; 6 0.50]; % this converts the digit in the input textfile to a % coherence level (0.05 = 5%)
% colours
red    = [255 0   0  ]; 
blue   = [100 175 255]; % light blue
green  = [0   255 0  ];
magenta= [255 0   255];
cyan   = [0   255 255];
yellow = [255 255 0  ];
orange = [255 128 0  ];

% Color for each trial (1 = red, 2 = orange, 3 = blue, 4 = green)

% direction
% Motion direction for each trial (1 = left-up, 2 = right-up, 3 = right-down, 4 = left-down)

% required response
% 1 = LEFTWARD RESPONSE ("z") in response to colours 1, 2
% 2 = RIGHTWARD RESPONSE ("m") in response to colours 3, 4

% DOT PARAMETERS for the dots clouds
dots.nDots = 200; % number of dots
dots.speed = 8; % speed of dots (degrees/sec)
dots.direction = 80; % direction from 0 - 360; will be overwritten later in the script
dots.lifetime = 14; % number of frames until dot will be replaced (to avoid that ppts are tracking individual dots)
dots.apertureSize = [10,10]; % [x,y] size of elliptical aperture (degrees)
dots.center = [0,0]; % [x,y] Center of the aperture (degrees)
dots.color = [255,255,255]; % RGB color of the dots, will be overwritten later in the script
dots.size = 14; % size of individual dots in pixels
dots.coherence_reg = .25; % motion coherence (0 - 1)
dots.col.coherence = 1; % color coherence (0 - 1)
duration = 1.6; % duration of the dot stimulus in seconds
directions = [315; 45; 135; 225]; % values for motion directions: 90 = right, 270 = left
dots.distr1.color = [0 0 0];
dots.distr2.color = [0 0 0];

%% Setup PTB with some default values
PsychDefaultSetup(2);
KbName('UnifyKeyNames');
KbCheck;

%Set the screen number to the external secondary monitor if connected
screenNumber = max(Screen('Screens'));

%% Set display parameters (THESE MAY NEED TO CHANGE DEPENDING ON SETUP)
display.dist = 50;  % cm
display.width = 30; % cm
display.skipChecks = 1; % avoid Screen's timing checks and verbosity

%Some variables for trial loops
% RCat = 0; % Response category, will be updated later

%% TASK PARAMETERS
total_trials_block = 144;
total_number_of_blocks = 4;
ITIs = [ones(total_trials_block/4,1)*.5;ones(total_trials_block/4,1)*.75;ones(total_trials_block/4,1)*1;ones(total_trials_block/4,1)*1.25];% create vector for ITIs
ITI = Shuffle(ITIs);% shuffle ITIs

global RT %#ok<*GVMIS>
global response
% global run
global tarresp
global feedback
feedback = 0;
ntrialsBetweenBreaks = 50; % number of trials between short breaks
breaktime = 3; % countdown variable at the start of the block
response = 0;
colours  = [red; orange; blue; green];


%% Prompt screen to enter ppt info to be written in logfile name
question = {'Participant Number:'; 'Block Number'};
title = 'Experiment Setup';
NumOfLines = [1 50; 1 50];
prompt= inputdlg(question,title,NumOfLines);
participantNumber  = str2double(prompt(1));
startingBlock = str2double(prompt(2));
if isempty(startingBlock)||isnan(startingBlock)
    startingBlock = 1;
end

% Specifies condition file and load conditions
conditionsFile = textread('kcl_rdk_daria_master.txt'); %#ok<*DTXTRD>

blockNum            = conditionsFile(:,1); % block number (1-4), 1 = uncorrelated, 2 = correlated with no hints, 3 = correlated with hint, 4 = correlated with solution
blockTrialNumber    = conditionsFile(:,2); % trial number within block
continuousTrNum     = conditionsFile(:,3); % trial number within experiment
direction           = conditionsFile(:,4); % Motion direction for each trial (1 = left-up, 2 = right-up, 3 = right-down, 4 = left-down)
coherenceLevel      = conditionsFile(:,5); % 1-6 (see matrix above for conversion from level to %)
dotColour           = conditionsFile(:,6); % 1,2 = linked to leftkey, 3,4 = linked to rightkey (in blocks 2-4)
requiredResponse    = conditionsFile(:,7); % 1 = leftKey, 2 = rightKey

%% Do dummy calls to GetSecs, WaitSecs, KbCheck
KbCheck;
WaitSecs(0.1);
GetSecs;

%Get keyboard information
escapeKey = KbName('Q');
leftKey   = KbName('Z');
rightKey  = KbName('M');

% Initialise response matrix
respMat = nan(length(conditionsFile),15);
HideCursor;
ListenChar(2);

%Start experimental loop%
display = OpenWindow(display);
center  = display.resolution/2;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intro Screen - display once

%% NOTE: this doesn't include a practice set. That will be run in a separate experiment file.

totalTrialExperiment = 0;

for currBlock = startingBlock:total_number_of_blocks % allows for manually starting at any block
    if currBlock == 1 % display instructions for block 1
        %Screen(display.windowPtr,'DrawText','BLOCK 1' ,center(1),center(2) - 10,[255,255,255]);
        instructionimg = imread('kcl_rdk_Daria_PromptScreens_block1.jpg');
        texI = Screen('MakeTexture', display.windowPtr, instructionimg); 
        % rect = [50 -250 1600 1250];
        Screen('DrawTexture', display.windowPtr, texI) %, rect);
        Screen('Flip',display.windowPtr);
        KbWait();
    elseif currBlock == 2 % display instructions for block 2
        instructionimg = imread('kcl_rdk_Daria_PromptScreens_block2.jpg');
        texI = Screen('MakeTexture', display.windowPtr, instructionimg); 
        % rect = [50 -250 1600 1250];
        Screen('DrawTexture', display.windowPtr, texI) %, rect);
        Screen('Flip',display.windowPtr);
        KbWait();
    elseif currBlock == 3 % display instructions for block 3
        instructionimg = imread('kcl_rdk_Daria_PromptScreens_block3.jpg');
        texI = Screen('MakeTexture', display.windowPtr, instructionimg); 
        % rect = [50 -250 1600 1250];
        Screen('DrawTexture', display.windowPtr, texI) %, rect);
        Screen('Flip',display.windowPtr);
        KbWait();
    else % display instructions for block 4
        instructionimg = imread('kcl_rdk_Daria_PromptScreens_block4.jpg');
        texI = Screen('MakeTexture', display.windowPtr, instructionimg); 
        % rect = [50 -250 1600 1250];
        Screen('DrawTexture', display.windowPtr, texI) %, rect);
        Screen('Flip',display.windowPtr);
        KbWait();
    end

    %% Waiting period until next block starts (defined as "breaktime" in seconds)
    for j = 0:breaktime
        pause(1);
        count = breaktime - j;
        Screen(display.windowPtr,'DrawText',['Next block starts in ', num2str(count)], center(1)-150, center(2),[255,255,255]);
        Screen('Flip',display.windowPtr);
        Screen('CloseScreen');

        %% add button press to advance block
    end

    % initialise display 
    drawFixation(display);
    pause(1); % pause (in s) between FP display and array

    % Create new block-specific conditions setup
    trialOrder = Shuffle(1:total_trials_block);
    blockConditions = conditionsFile(conditionsFile(:,1) == currBlock, :);
    bl_blockNum            = blockConditions(:,1); % block number (1-4), 1 = uncorrelated, 2 = correlated with no hints, 3 = correlated with hint, 4 = correlated with solution
    bl_blockTrialNumber    = blockConditions(:,2); % trial number within block
    bl_continuousTrNum     = blockConditions(:,3); % trial number within experiment
    bl_direction           = blockConditions(:,4); % Motion direction for each trial (1 = left-up, 2 = right-up, 3 = right-down, 4 = left-down)
    bl_coherenceLevel      = blockConditions(:,5); % 1-6 (see matrix above for conversion from level to %)
    bl_dotColour           = blockConditions(:,6); % 1,2 = linked to leftkey, 3,4 = linked to rightkey (in blocks 2-4)
    bl_requiredResponse    = blockConditions(:,7); % 1 = leftKey, 2 = rightKey

    for ttb = 1:total_trials_block % counter for trials per block

        totalTrialExperiment = totalTrialExperiment + 1;

        % break every "ntrialsBetweenBreaks" trials
        if  ttb > 1 && rem(ttb, ntrialsBetweenBreaks) == 1
            Screen(display.windowPtr,'DrawText', 'Time for a break.', center(1)-150,center(2),[255,255,255]);
            Screen(display.windowPtr,'DrawText','Press any key to continue.', center(1)-150, center(2)+100,[255,255,255]);
            Screen('Flip',display.windowPtr);
            KbWait();
        end

        % Cue to determine whether a response has been made
        respToBeMade = true;

        % Create Target screen with moving dots
        dots.direction       = directions(bl_direction(trialOrder(ttb)));
        dots.color           = colours(bl_dotColour(trialOrder(ttb)),:)';
        dots.coherence       = coherenceLevels(bl_coherenceLevel(trialOrder(ttb)),2);

        % Select target button and present dots
        tarresp = bl_requiredResponse(trialOrder(ttb)); % tarresp = correct response?

        %Select target button and present dots
        %tarresp = InpResp(ttb);
        if coherenceLevels(bl_coherenceLevel(trialOrder(ttb)),2) == 0
            tarresp  = 99;
        end

        % Present moving dots and record onset time
        movingDots(display,dots,duration);
        
        % Create final RCat variable
        if tarresp == response
            RCat = 1; % OUTCOME  = trial is correct
        elseif tarresp ~= response && response ~= 0
            RCat = 2; % OUTCOME = trial is incorrect
        else % if response == 0
            RCat = 3; % OUTCOME = response was too slow
            Screen(display.windowPtr,'DrawText','TOO SLOW' ,center(1)-100,center(2),[255,255,255]);
            Screen('Flip',display.windowPtr);
            pause(0.5);
            Screen('CloseScreen');
        end

        drawFixation(display);
        pause(ITI-0.4);
        Screen('CloseScreen');

        % if dots.direction < 3
        %     congr = 1;
        % elseif dots.direction > 2
        %     congr = 0;
        % end

        % Need to correct for problems with empty RT
        if isempty(RT)
            RT = 0;
        end

        % Write output into respMat
        respMat(totalTrialExperiment,1)  = participantNumber; % participant number
        respMat(totalTrialExperiment,2)  = currBlock; % trial
        respMat(totalTrialExperiment,3)  = totalTrialExperiment; % continuous trial number
        respMat(totalTrialExperiment,4)  = ttb; % current trial/block
        respMat(totalTrialExperiment,5)  = bl_continuousTrNum(trialOrder(ttb)); % condition number

        % Stim Parameters
        respMat(totalTrialExperiment,6)  = bl_direction(trialOrder(ttb)); % direction number
        respMat(totalTrialExperiment,7)  = directions(bl_direction(trialOrder(ttb))); % direction in degrees
        respMat(totalTrialExperiment,8)  = bl_coherenceLevel(trialOrder(ttb)); % coherence number
        respMat(totalTrialExperiment,9)  = coherenceLevels(bl_coherenceLevel(trialOrder(ttb)),2); % coherence value

        respMat(totalTrialExperiment,10) = bl_dotColour((trialOrder(ttb)),:); % colour number
        respMat(totalTrialExperiment,11) = tarresp; % required response
        respMat(totalTrialExperiment,12) = response; % actual response
        respMat(totalTrialExperiment,13) = RCat; % outcome category
        respMat(totalTrialExperiment,14) = RT; % response time
        respMat(totalTrialExperiment,15) = ITI(ttb); % intertrial interval
    end % trials/block
end % block
% Save respMat output in logfile (add time and date to avoid overwriting)
dlmwrite(['kcl_rdk_daria_ppt_' , num2str(participantNumber), '_', datestr(now,'mmmm-dd-yyyy_HH-MM-SS AM'), '.txt'],respMat,'delimiter','\t') %#ok<*TNOW1,*DATST,*DLMWT>
save(['kcl_rdk_daria_ppt_' , num2str(participantNumber), '_', datestr(now,'mmmm-dd-yyyy_HH-MM-SS AM'), '.mat'],'respMat')

%% Finish slide at the end of the whole run
debriefimg = imread('kcl_rdk_Daria_PromptScreens_debrief.jpg');
texI = Screen('MakeTexture', display.windowPtr, instructionimg);
rect = [50 -250 1600 1250];
Screen('DrawTexture', display.windowPtr, texI) %, rect);
Screen('Flip',display.windowPtr);
KbWait();
pause(0.1);

Screen('CloseAll');
ListenChar(1);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IF SOMETHING GOES WRONG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To manually save the data, highlight the following text and right-click -> "evaluate current selection in command window"
saveAfterCrash_Daria; %#ok<*UNRCH>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If you can't use the keyboard (it appears "locked"), highlight the following text, right-click -> "evaluate current selection in command window"
ListenChar(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

