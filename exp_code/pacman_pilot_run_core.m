function pacman_pilot_run_core(basedir, subject_dir, sid, session_no, low_level_order, varargin)

%% DEFAULT

global USE_EYELINK USE_BIOPAC

testmode = false;
USE_EYELINK = false;
USE_BIOPAC = false;
scan_adjust = false;

%datdir = fullfile(basedir, 'data');
%subject_dir = fullfile(datdir, sid);

%% PARSING VARARGIN

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'test', 'testmode'}
                testmode = true;
            case {'eyelink', 'eye', 'eyetrack'}
                USE_EYELINK = true;
            case {'biopac'}
                USE_BIOPAC = true;
                channel_n = 1;
                biopac_channel = 0;
                ljHandle = BIOPAC_setup(channel_n); % BIOPAC SETUP
            case {'scan_adjust', 'hs/dc'}
                scan_adjust = true;
        end
    end
end
%% GET RUN NUMBER

run_no = input('PaCMan Pilot run number? (n = 1, 2, 3, 4, 5, 6): ');

%% GENERATE TRIAL SEQUENCE

[stimuli_info, im_path] = pacman_pilot_gen_trial_sequence(basedir, session_no, run_no, low_level_order);

%% CREATE AND SAVE DATA

[~, sid] = fileparts(subject_dir);

nowtime = clock;
subjdate = sprintf('%.2d%.2d%.2d', nowtime(1), nowtime(2), nowtime(3));

data.subject = sid;
data.datafile = fullfile(subject_dir, [subjdate, '_', sid, '_session_', sprintf('%.2d', session_no),'_run', sprintf('%.2d', run_no), '.mat']);
data.version = 'PaCMan_pilot_2021_Cocoanlab';
data.starttime = datestr(clock, 0);
data.starttime_getsecs = GetSecs;
data.run_number = run_no;
data.session_number = session_no;
data.stimuli_info = stimuli_info;
data.stimuli_info_desc = [{'High level category'} {'Low level category'} {'Image name' 'Jitter [s]'} {'Cross colour change?'} {'Cross colour change timing from trial start'}];

if exist(data.datafile, 'file')
    fprintf('\n ** EXISTING FILE: %s %s **', [subjdate, '_', sid, sprintf('%.2d', run_no), '.mat']);
    cont_or_not = input(['\nA file with the requested run number already exists.', ...
        '\nWould you like to proceed with the requested run number?', ...
        '\n1: Yes, continue with typed run number.  ,   2: No, it`s a mistake. I`ll break.\n:  ']);
    if cont_or_not == 2
        error('Break.')
    elseif cont_or_not == 1
        save(data.datafile, 'data');
    end
else
    save(data.datafile, 'data');
end

%% 

global theWindow W H; % window property
global white red orange blue bgcolor ; % color
global fontsize window_rect text_color % lb tb recsize barsize rec; % rating scale

% Screen setting
bgcolor = 50;

if testmode == true
    %window_ratio = 2;
    window_ratio = 1.6;
else
    window_ratio = 1;
end

%window_ratio = 1.6;
text_color = 255;
fontsize = [28, 32, 41, 54];


screens = Screen('Screens');
window_num = screens(end);
Screen('Preference', 'SkipSyncTests', 1);
window_info = Screen('Resolution', window_num);
window_rect = [0 0 window_info.width/window_ratio window_info.height/window_ratio]; %for mac, [0 0 2560 1600];

W = window_rect(3); %width of screen
H = window_rect(4); %height of screen
textH = H/2.3;

white = 255;
red = [189 0 38];
blue = [0 85 169];
orange = [255 164 0];

%% KOREAN INSTRUCTIONS

msg.hs_dc = double('스캐너 조정 작업중입니다.\n 소음이 발생할 수 있습니다. 화면 중앙의 십자표시를\n 편안한 마음으로 바라봐주세요.'); % head scout and distortion correction
msg.inst1 = double('You will view a series of images. \n In between the images, you will see a white cross +. \n When the cross turns red, press the button.\n\n Practice time...') ;
msg.inst2 = double('Well done. We will start the run now.');

msg.s_key = double('참가자가 준비되었으면, \n 이미징을 시작합니다 (s).');
msg.s_key2 = double('You will view a series of images. \n In between the images, you will see a white cross +. \n When the cross turns red, press the button.\n\n 참가자가 준비되었으면 이미징을 시작합니다. (s)') ;

msg.start_buffer = double('시작합니다...');

msg.fixation = double('+');

msg.run_end = double('Well done. The run is over.');


%% FULL SCREEN

try
    
    [theWindow, ~] = Screen('OpenWindow',0, bgcolor, window_rect);%[0 0 2560/2 1440/2]
    Screen('Preference','TextEncodingLocale','ko_KR.UTF-8');
    Screen('TextSize', theWindow, fontsize(3));
    %if ~testmode, HideCursor; end
    HideCursor;
    %% SETUP: Eyelink
    % need to be revised when the eyelink is here.
    if USE_EYELINK
        edf_filename = ['E' sid(5:7), '_F' sprintf('%.1d', run_no)]; % name should be equal or less than 8
        % E_F for Free_thinking
        edfFile = sprintf('%s.EDF', edf_filename);
        eyelink_main(edfFile, 'Init');
        
        status = Eyelink('Initialize');
        if status
            error('Eyelink is not communicating with PC. Its okay baby.');
        end
        Eyelink('Command', 'set_idle_mode');
        waitsec_fromstarttime(GetSecs, .5);
    end
    
    %% HEAD SCOUT AND DISTORTION CORRECTION
    if scan_adjust == true % the first run
        while (1)
            
            [~,~,keyCode] = KbCheck;
            
            if keyCode(KbName('a'))==1
                break
            elseif keyCode(KbName('q'))==1
                abort_experiment('manual');
            end
            
            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            DrawFormattedText(theWindow, msg.hs_dc,'center', 'center', white, [], [], [], 1.5); %'center', 'textH'
            Screen('Flip', theWindow);
            
        end
        
        WaitSecs(0.5);
        
        while (1)
            
            [~,~,keyCode] = KbCheck;
            
            if keyCode(KbName('b'))==1
                break
            elseif keyCode(KbName('q'))==1
                abort_experiment('manual');
            end
            
            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            DrawFormattedText(theWindow, msg.fixation,'center', 'center', white); %'center', 'textH'
            Screen('Flip', theWindow);
            
        end
    end
    
    %% Practice before Run 1
    
    if run_no == 1
        
        WaitSecs(0.5);
        while (1)
            
            [~,~,keyCode] = KbCheck;
            
            if keyCode(KbName('space'))==1
                break
            elseif keyCode(KbName('q'))==1
                abort_experiment('manual');
            end
            
            DrawFormattedText(theWindow, msg.inst1, 'center', 'center', text_color, [], [], [], 1.5);
            Screen('Flip', theWindow);
            
        end
        
        WaitSecs(0.5);
        
        image_practice(basedir)
        
        WaitSecs(0.5);
        while (1)
            
            [~,~,keyCode] = KbCheck;
            
            if keyCode(KbName('space'))==1
                break
            elseif keyCode(KbName('q'))==1
                abort_experiment('manual');
            end
            
            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            DrawFormattedText(theWindow, msg.inst2,'center', 'center', white); %'center', 'textH'
            Screen('Flip', theWindow);
            
        end
        
        WaitSecs(0.5);
    end
    
    %% Start image viewing
    
    % INPUT (s key) FROM THE SCANNER
    
    while (1)
        
        [~,~,keyCode] = KbCheck;
        
        if keyCode(KbName('s'))==1
            break
        elseif keyCode(KbName('q'))==1
            abort_experiment('manual');
        end
        
        if run_no == 1
            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            DrawFormattedText(theWindow, msg.s_key,'center', 'center', white, [], [], [], 1.5); %'center', 'textH'
            Screen('Flip', theWindow);
            
        else
            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            DrawFormattedText(theWindow, msg.s_key2, 'center', 'center', text_color, [], [], [], 1.3);
            Screen('Flip', theWindow);
            
        end
    end
    %% Time stamp for run start
    
    data.runscan_starttime = GetSecs;
    
    
    %% EYELINK AND BIOPAC START
    
    if USE_EYELINK
        Eyelink('StartRecording');
        data.eyetracker_starttime = GetSecs; % eyelink timestamp
        Eyelink('Message','FT Run start');
    end
    
    if USE_BIOPAC
        data.biopac_starttime = GetSecs; % biopac timestamp
        BIOPAC_trigger(ljHandle, biopac_channel, 'on');
        waitsec_fromstarttime(data.biopac_starttime, 1); % biopac start trigger: 1
        BIOPAC_trigger(ljHandle, biopac_channel, 'off');
    end
    %% START IMAGE VIEWING
   

    [screenXpixels, screenYpixels] = Screen('WindowSize', theWindow);
    ifi = Screen('GetFlipInterval', theWindow);
    [xCenter, yCenter] = RectCenter(window_rect);
    Screen('BlendFunction', theWindow, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    
    data = viewImages(im_path, stimuli_info, msg, data);
    
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    Screen('TextSize', theWindow, fontsize(3));
    DrawFormattedText(theWindow, msg.run_end, 'center', textH, white);
    Screen('Flip', theWindow);
    
    if USE_EYELINK
        Eyelink('Message','Story Run END');
        eyelink_main(edfFile, 'Shutdown');
    end
    if USE_BIOPAC
        data.biopac_endtime = GetSecs; % biopac timestamp
        BIOPAC_trigger(ljHandle, biopac_channel, 'on');
        ending_trigger =  0.1 * run_num; % biopac run ending trigger: 0.1 * run_number
        waitsec_fromstarttime(data.biopac_endtime, ending_trigger); 
        BIOPAC_trigger(ljHandle, biopac_channel, 'off');
    end
    
    data.runscan_endtime{i} = GetSecs;
    save(data.datafile, 'data', '-append');
    
    while (1)
        [~,~,keyCode] = KbCheck;
        if keyCode(KbName('space'))==1
            break
        end
    end
    
    ShowCursor();
    Screen('Clear');
    Screen('CloseAll');
    
catch err
    
    % ERROR
    disp(err);
    for i = 1:numel(err.stack)
        disp(err.stack(i));
    end
    %     fclose(t);
    %     fclose(r);  % Q??
    abort_experiment('error');
end
    
%% Additional functions

function image_practice(basedir)

    practice_dir = fullfile(basedir, 'data', 'pilot_practice');
    practice_im = dir(fullfile(practice_dir, '*.jpg'));
    practice_im = {practice_im.name};



    [screenXpixels, screenYpixels] = Screen('WindowSize', theWindow);

    ifi = Screen('GetFlipInterval', theWindow);

    [xCenter, yCenter] = RectCenter(window_rect);

    Screen('BlendFunction', theWindow, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    for j = 1:3
        theImageLocation = fullfile(practice_dir, practice_im{j});
        theImage = imread(theImageLocation);
        [s1, s2, s3] = size(theImage);
        aspectRatio = s2 / s1;
        heightScalers = 0.75;
        imageHeights = screenYpixels .* heightScalers;
        imageWidths = imageHeights .* aspectRatio;

        theRect = [0 0 imageWidths imageHeights];
        dstRects = CenterRectOnPointd(theRect, screenXpixels / 2,...
                screenYpixels / 2);

        imageTexture = Screen('MakeTexture', theWindow, theImage);

        if j==3 

            % Draw fixation cross + change colour for 100 ms
            DrawFormattedText(theWindow, msg.fixation, 'center', 'center', text_color, [], [], [], 1.5);
            Screen('Flip', theWindow);
            WaitSecs(3-1.1);

            DrawFormattedText(theWindow, msg.fixation, 'center', 'center', red, [], [], [], 1.5);
            Screen('Flip', theWindow);
            WaitSecs(0.1);

            DrawFormattedText(theWindow, msg.fixation, 'center', 'center', text_color, [], [], [], 1.5);
            Screen('Flip', theWindow);
            WaitSecs(1);
        else
            % Draw fixation cross + no change
            DrawFormattedText(theWindow, msg.fixation, 'center', 'center', text_color, [], [], [], 1.5);
            Screen('Flip', theWindow);
            % WaitSecs(2); ORIGINAL -- 2 s stimulus duration
            WaitSecs(3); % revised -- 1.5 s stimulus dur.

        end

        % Draw the image
        Screen('DrawTexture', theWindow, imageTexture, [], dstRects);
        Screen('Flip', theWindow);
        WaitSecs(1.5);  % Show image for 1.5 s
    end


end



function data = viewImages(im_path, stimuli_info, msg, data)

[screenXpixels, screenYpixels] = Screen('WindowSize', theWindow);
ifi = Screen('GetFlipInterval', theWindow);
[xCenter, yCenter] = RectCenter(window_rect);
Screen('BlendFunction', theWindow, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');


imageView_sTime = GetSecs;

for i = 1:length(im_path)
    theImageLocation = im_path{i};
    theImage = imread(theImageLocation);

    imageTexture = Screen('MakeTexture', theWindow, theImage);

    % Get the size of the image and change size
    [s1, s2, s3] = size(theImage);
    aspectRatio = s2 / s1;
    heightScalers = 0.75;
    imageHeights = screenYpixels .* heightScalers;
    imageWidths = imageHeights .* aspectRatio;

    theRect = [0 0 imageWidths imageHeights];
    dstRects = CenterRectOnPointd(theRect, screenXpixels / 2,...
            screenYpixels / 2);

    % Here we check if the image is too big to fit on the screen and abort if
    % it is. See ImageRescaleDemo to see how to rescale an image.
    % if s1 > screenYpixels || s2 > screenYpixels
    %     disp('ERROR! Image is too big to fit on the screen');
    %     sca;
    %     return;
    % end
    trial_start = GetSecs;
    %if i == 1, data.run_starttime = trial_start; end
    
    if stimuli_info{i,5}==1

        % Draw fixation cross + change colour for 100 ms
        DrawFormattedText(theWindow, msg.fixation, 'center', 'center', text_color, [], [], [], 1.5);
        Screen('Flip', theWindow);
        %WaitSecs(stimuli_info{i,4}-1.1);
        %waitsec_fromstarttime(trial_start, stimuli_info{i,4}-1.1);
        waitsec_fromstarttime(trial_start, stimuli_info{i,6});
        
        data.cross_change_time{i} = GetSecs;
        DrawFormattedText(theWindow, msg.fixation, 'center', 'center', red, [], [], [], 1.5);
        Screen('Flip', theWindow);
        WaitSecs(0.1);
        
        cross_remain_start = GetSecs;
        while GetSecs - cross_remain_start <= stimuli_info{i,4}-stimuli_info{i,6}-0.1+1
            
            DrawFormattedText(theWindow, msg.fixation, 'center', 'center', text_color, [], [], [], 1.5);
            Screen('Flip', theWindow);
            
            [~,~,button] = GetMouse(theWindow);
            if button(1) == 1
                   data.button_press_time{i} = GetSecs;
            end
            
%             [~,~,keyCode] = KbCheck;
%             if keyCode(KbName('m'))==1
%                 
%                     data.button_press_time{i} = GetSecs;
%             
%             end
            
            
        end
        %WaitSecs(1);
        %waitsec_fromstarttime(GetSecs, stimuli_info{i,4}-stimuli_info{i,6}-0.1+1);
        
    else
        % Draw fixation cross + no change
        DrawFormattedText(theWindow, msg.fixation, 'center', 'center', text_color, [], [], [], 1.5);
        Screen('Flip', theWindow);
        %WaitSecs(stimuli_info{i,4});
        waitsec_fromstarttime(trial_start, stimuli_info{i,4})

    end

    % Draw the image
    stim_starttime = GetSecs;
    data.stim_starttime{i} = stim_starttime;
    Screen('DrawTexture', theWindow, imageTexture, [], dstRects);
    Screen('Flip', theWindow);
    %WaitSecs(2);  % Show image for 2 s
    %waitsec_fromstarttime(stim_starttime, 2) % --> original (2 s stim. dur.)
    %waitsec_fromstarttime(stim_starttime, 1) % --> revised (1 s stim. dur.)
    waitsec_fromstarttime(stim_starttime, 1.5) % --> revised (1.5 s stim. dur.)
    
    data.stim_endtime{i} = GetSecs;
    
    if i == 30 ||  i == 60 || i == 90
        save(data.datafile, 'data', '-append');
    end

end

DrawFormattedText(theWindow, '', 'center', 'center', text_color, [], [], [], 1.5);
Screen('Flip', theWindow);
WaitSecs(1);

%sca;
%data.runscan_endtime{i} = GetSecs;
save(data.datafile, 'data', '-append');

end

function abort_experiment(varargin)

% ABORT the experiment
%
% abort_experiment(varargin)

str = 'Experiment aborted.';

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'error'}
                str = 'Experiment aborted by error.';
            case {'manual'}
                str = 'Experiment aborted by the experimenter.';
        end
    end
end

ShowCursor; %unhide mouse
Screen('CloseAll'); %relinquish screen control
disp(str); %present this text in command window

end


    
end