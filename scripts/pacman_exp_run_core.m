function pacman_exp_run_core(basedir, subject_dir, sid, session_no, varargin)

%% DEFAULT

global USE_EYELINK USE_BIOPAC
global ip port
ip = '192.168.0.2'; 
port = 20121;

testmode = false;
USE_EYELINK = false;
USE_BIOPAC = false;
scan_adjust = false;
do_practice = false;
low_level_order = [];
dummy_cat_order = [];

rng('shuffle')

%% PARSING VARARGIN

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'order'}
                low_level_order = varargin{i+1};
                dummy_cat_order = varargin{i+2};
                varargin{i+1} =[];
                varargin{i+2} =[];
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
            case {'practice'}
                do_practice = true;
        end
    end
end
%% GET RUN NUMBER

run_no = input('PaCMan Pilot run number? (n = 1, 2, 3, 4, 5, 6): ');

if session_no == 1 && run_no > 3
    error('Wrong run number!')
end

%% GENERATE TRIAL SEQUENCE
if session_no == 1
    
    param_info = pacman_exp_gen_ses01_params();
    
elseif session_no == 2
    
    if isempty(low_level_order) && isempty(dummy_cat_order)
        error('You did not input category order!')
    end
    
    block_info = pacman_exp_gen_block_sequence(basedir, run_no, low_level_order, dummy_cat_order);

else
    error('Wrong session number!')
end 



%% CREATE AND SAVE DATA

[~, sid] = fileparts(subject_dir);

nowtime = clock;
subjdate = sprintf('%.2d%.2d%.2d', nowtime(1), nowtime(2), nowtime(3));

data.subject = sid;
data.datafile = fullfile(subject_dir, [subjdate, '_', sid, '_session_', sprintf('%.2d', session_no),'_run', sprintf('%.2d', run_no), '.mat']);
data.version = 'PaCMan_exp_2021_Cocoanlab';
data.starttime = datestr(clock, 0);
data.starttime_getsecs = GetSecs;
data.run_number = run_no;
data.session_number = session_no;

if session_no == 1
    data.pathway_params = param_info;
elseif session_no == 2
    data.low_level_order = low_level_order;
    data.dummy_cat_order = dummy_cat_order;
    data.block_info = block_info;
end


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

global theWindow W H window_num; % window property
global white red orange blue bgcolor ; % color
global fontsize font window_rect text_color % lb tb recsize barsize rec; % rating scale

% Screen setting
bgcolor = 50;

if testmode == true
    %window_ratio = 2;
    window_ratio = 2.5;
else
    window_ratio = 1;
end

%window_ratio = 1.6;
text_color = 255;
fontsize = [28, 32, 32, 54];


screens = Screen('Screens');
window_num = screens(end);
Screen('Preference', 'SkipSyncTests', 1);
window_info = Screen('Resolution', window_num);
window_rect = [0 0 window_info.width/window_ratio window_info.height/window_ratio]; %for mac, [0 0 2560 1600];

W = window_rect(3); %width of screen
H = window_rect(4); %height of screen
textH = H/2.3;
font = 'NanumBarunGothic';

white = 255;
red = [189 0 38];
blue = [0 85 169];
orange = [255 164 0];

%% KOREAN INSTRUCTIONS
% Beginning of the session - before first run
msg.hs_dc = double('스캐너 조정 작업중입니다.\n 소음이 발생할 수 있습니다. 화면 중앙의 십자표시를\n 편안한 마음으로 바라봐주세요.'); % head scout and distortion correction

msg.inst2 = double('잘하셨습니다. 세션을 시작하겠습니다.');

msg.explain = double('지금부터 실험이 시작됩니다.\n\n먼저, 실험을 진행하기에 앞서 평가 척도에 대한 설명을 진행하겠습니다.\n\n참가자는 모든 준비가 완료되면 마우스를 눌러주시기 바랍니다.\n\n Click mouse');
msg.practice = double('참가자는 충분히 평가 방법을 연습한 후 \n\n 연습이 끝나면 버튼을 눌러주시기 바랍니다.');
msg.s_key_ses01 = double('You will experience a series of painful stimuli. \n\n Rate intensity of each. \n\n 참가자가 준비되었으면 이미징을 시작합니다 (s).');
msg.s_key2_ses01 = double('You will experience a series of painful stimuli. \n\n Rate intensity of each. \n\n 참가자가 준비되었으면 이미징을 시작합니다. (s)') ;


msg.s_key_ses02 = double('이미지 속 물체를 집중해서 봐주세요. \n When you see an image twice, \n 버튼을 눌러주세요. \n\n 참가자가 준비되었으면 이미징을 시작합니다 (s).');
msg.s_key2_ses02 = double('이미지 속 물체를 집중해서 봐주세요. \n When you see an image twice, \n 버튼을 눌러주세요. \n\n 참가자가 준비되었으면 이미징을 시작합니다. (s)') ;

msg.start_buffer = double('시작합니다...');

msg.fixation = double('+');

msg.run_end = double('이번 세션이 끝났습니다. \n\n 잘하셨습니다. 잠시 대기해 주세요.');


%% FULL SCREEN

try
    
    Screen('Preference','TextEncodingLocale','ko_KR.UTF-8');
    [theWindow, ~] = Screen('OpenWindow',0, bgcolor, window_rect);%[0 0 2560/2 1440/2]
    Screen('TextFont', theWindow, font);
    Screen('TextSize', theWindow, fontsize(3)); %screens = Screen('Screens');
%     
%% Explanation & practice
    if session_no == 1
        pacman_exp_explain_rating(basedir, msg)
        pacman_exp_practice_rating(msg)
    end

%%
    
    if ~testmode, HideCursor; end
    %HideCursor;
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
    %PsychHID('Devices')
    if ~testmode
        device(1).product = 'Apple Keyboard';
        device(1).vendorID= 1452;

        device(2).product = 'KeyWarrior8 Flex';
        device(2).vendorID= 1984;

        apple = IDKeyboards(device(1));
        sync_box = IDKeyboards(device(2));
    end
    
    if scan_adjust == true && run_no == 1 % the first run
        while (1)
            if ~testmode
                [~,~,keyCode] = KbCheck(apple);
            else 
                [~,~,keyCode] = KbCheck;
            end
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
            
            if ~testmode
                [~,~,keyCode] = KbCheck(apple);
            else 
                [~,~,keyCode] = KbCheck;
            end
            
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
    

    %% Start image viewing
    
    % INPUT (s key) FROM THE SCANNER
  
    while (1)
        if ~testmode
            [~,~,keyCode] = KbCheck(sync_box);
        else
            [~,~,keyCode] = KbCheck;
        end 
       
        if keyCode(KbName('s'))==1
            break
        elseif keyCode(KbName('q'))==1
            abort_experiment('manual');
        end
        
        if run_no == 1
            if session_no == 1
                Screen(theWindow, 'FillRect', bgcolor, window_rect);
                DrawFormattedText(theWindow, msg.s_key_ses01,'center', 'center', white, [], [], [], 1.5); %'center', 'textH'
                Screen('Flip', theWindow);
            elseif session_no == 2
                Screen(theWindow, 'FillRect', bgcolor, window_rect);
                DrawFormattedText(theWindow, msg.s_key_ses02,'center', 'center', white, [], [], [], 1.5); %'center', 'textH'
                Screen('Flip', theWindow);
            end

        else
            if session_no == 1
                Screen(theWindow, 'FillRect', bgcolor, window_rect);
                DrawFormattedText(theWindow, msg.s_key2_ses01, 'center', 'center', text_color, [], [], [], 1.3);
                Screen('Flip', theWindow);
            elseif session_no == 2
                Screen(theWindow, 'FillRect', bgcolor, window_rect);
                DrawFormattedText(theWindow, msg.s_key2_ses02, 'center', 'center', text_color, [], [], [], 1.3);
                Screen('Flip', theWindow);
            end
            
        end
    end
    %% Time stamp for run start
    
    data.runscan_starttime = GetSecs; % run start timestamp
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    DrawFormattedText(theWindow, msg.start_buffer, 'center', 'center', white, [], [], [], 1.2);
    Screen('Flip', theWindow);
    
    waitsec_fromstarttime(data.runscan_starttime, 4);
    Screen(theWindow,'FillRect',bgcolor, window_rect);
    Screen('Flip', theWindow);
    
    waitsec_fromstarttime(data.runscan_starttime, 8);
    
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
    
    Screen(theWindow,'FillRect',bgcolor, window_rect);
    Screen('Flip', theWindow);
    
    waitsec_fromstarttime(data.runscan_starttime, 16);
    %% START IMAGE VIEWING
   

    [screenXpixels, screenYpixels] = Screen('WindowSize', theWindow);
    ifi = Screen('GetFlipInterval', theWindow);
    [xCenter, yCenter] = RectCenter(window_rect);
    Screen('BlendFunction', theWindow, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    if session_no == 1
        data = pacman_exp_painLocaliser(param_info, msg, data);
    elseif session_no == 2
        data = pacman_exp_viewImages(block_info, msg, data);
    else
        error('Wrong session number!')
    end
    
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    Screen('TextSize', theWindow, fontsize(3));
    DrawFormattedText(theWindow, msg.run_end, 'center', textH, white);
    Screen('Flip', theWindow);
    
    if USE_EYELINK
        Eyelink('Message','Run END');
        eyelink_main(edfFile, 'Shutdown');
    end
    if USE_BIOPAC
        data.biopac_endtime = GetSecs; % biopac timestamp
        BIOPAC_trigger(ljHandle, biopac_channel, 'on');
        ending_trigger =  0.1 * run_num; % biopac run ending trigger: 0.1 * run_number
        waitsec_fromstarttime(data.biopac_endtime, ending_trigger); 
        BIOPAC_trigger(ljHandle, biopac_channel, 'off');
    end
    
    data.runscan_endtime = GetSecs;
    save(data.datafile, 'data', '-append');
    
    while (1)
        if ~testmode
            [~,~,keyCode] = KbCheck(apple);
        else 
            [~,~,keyCode] = KbCheck;
        end
        
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