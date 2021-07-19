function data = pacman_exp_painLocaliser(param_info, msg, data)

global ip port
global theWindow W H window_num; % window property
global white red orange blue bgcolor ; % color
global fontsize font window_rect text_color

[screenXpixels, screenYpixels] = Screen('WindowSize', theWindow);
ifi = Screen('GetFlipInterval', theWindow);
[xCenter, yCenter] = RectCenter(window_rect);
Screen('BlendFunction', theWindow, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

 %% -------------Setting Screen Parameters------------------
 % For rating
 
screen_param.window_info = struct('W',W, 'H',H, 'window_num',window_num, 'window_rect',window_rect, 'theWindow',theWindow, 'fontsize',fontsize, 'font',font);
lb1 = W*(1/6); % rating scale left bounds 1/6
rb1 = W*(5/6); % rating scale right bounds 5/6
lb2 = W*(1/4); % rating scale left bounds 1/4
rb2 = W*(3/4); % rating scale right bounds 3/4

scale_W = W*0.1;
scale_H = H*0.1;

anchor_lms = [W/2-0.014*(W/2-lb1) W/2-0.061*(W/2-lb1) W/2-0.172*(W/2-lb1) W/2-0.354*(W/2-lb1) W/2-0.533*(W/2-lb1);
              W/2+0.014*(W/2-lb1) W/2+0.061*(W/2-lb1) W/2+0.172*(W/2-lb1) W/2+0.354*(W/2-lb1) W/2+0.533*(W/2-lb1)];
screen_param.line_parameters = struct('lb1',lb1, 'rb1',rb1, 'lb2',lb2, 'rb2',rb2, 'scale_W',scale_W, 'scale_H',scale_H, 'anchor_lms',anchor_lms);
screen_param.color_values = struct('bgcolor',bgcolor, 'white',white, 'orange',orange, 'red',red);


 %% -------------Loop over trials------------------
 %% -----------------------------------------------
for i = 1:length(param_info.heat_intensity) 
    
    wait_first_jitter = param_info.jitter(i,1);
    wait_finish_stim = wait_first_jitter+14.5;
    wait_pre_rating = wait_finish_stim+param_info.jitter(i,2);
    wait_rating = wait_pre_rating+5;
    
    trial_start = GetSecs;
    data.trials{i}.trial_start = trial_start;
    
    DrawFormattedText(theWindow, msg.fixation, 'center', 'center', text_color, [], [], [], 1.5);
    Screen('Flip', theWindow);
    block_fixation_start = GetSecs;
    data.blocks{i}.block_fixation_start = block_fixation_start;
    
    %% -------------Setting Pathway------------------
  
    main(ip,port,1, param_info.heat_program(i));     % select the program
   
    %% -------------Ready for Pathway------------------
    
    main(ip,port,2); %ready to pre-start
    
    % Initial jitter time
    waitsec_fromstarttime(trial_start, wait_first_jitter) 
    %% -------------Trigger Pathway------------------
        
    main(ip,port,2);
    
    % Get trigger time
    data.trials{i}.heat_stim_trigger_start = GetSecs;
       
    
    % Wait for stimulus to end 
    waitsec_fromstarttime(trial_start, wait_finish_stim)
    
    % Get stimulus end time
    data.trials{i}.heat_stim_end = GetSecs;
    
    % Jitter before rating
    waitsec_fromstarttime(trial_start, wait_pre_rating)
    
    %% -------------Rating------------------
    
    rating_types_pls = call_ratingtypes_pls('temp');

    scale = ('overall_int');
    [lb, rb, start_center] = draw_scale_pls(scale, screen_param.window_info, screen_param.line_parameters, screen_param.color_values);
    Screen(theWindow, 'FillRect', bgcolor, window_rect);

    rating_start = GetSecs;
    data.trials{i}.rating_starttime = rating_start;

    ratetype = strcmp(rating_types_pls.alltypes, scale);

    %% Initial mouse position
    
    if start_center
        SetMouse(W/2,H/2); % set mouse at the center
    else
        SetMouse(lb,H/2); % set mouse at the left
    end

    %% Rating start
    
    while true
        [x,~,button] = GetMouse(theWindow);
        [lb, rb, start_center] = draw_scale_pls(scale, screen_param.window_info, screen_param.line_parameters, screen_param.color_values);
        if x < lb; x = lb; elseif x > rb; x = rb; end

        DrawFormattedText(theWindow, double(rating_types_pls.prompts{ratetype}), 'center', H*(1/4), white, [], [], [], 2);
        Screen('DrawLine', theWindow, orange, x, H*(1/2)-scale_H/3, x, H*(1/2)+scale_H/3, 6); %rating bar
        Screen('Flip', theWindow);

        if button(1)
            while button(1)
                [~,~,button] = GetMouse(theWindow);
            end
            break
        end

        [~,~,keyCode] = KbCheck;
        if keyCode(KbName('q')) == 1
            abort_experiment('manual');
            break
        end
        if GetSecs - rating_start > 5
            break
        end
    end
    
    rating_end = GetSecs;

    data.trials{i}.rating = (x-lb)/(rb-lb);
    data.trials{i}.rating_endtime = rating_end;
    data.trials{i}.rating_duration = rating_end - rating_start;
    
    %% Adjusting total trial time
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    Screen('Flip', theWindow);
    DrawFormattedText(theWindow, msg.fixation, 'center', 'center', text_color, [], [], [], 1.5);
    Screen('Flip', theWindow);
    
    %% rating time adjusting
    waitsec_fromstarttime(trial_start, wait_rating)
    %waitsec_fromstarttime(trial_start, total_trial_time)

    %% saving trial end time
    data.trials{i}.trial_end = GetSecs;
    data.trials{i}.trial_duration = data.trials{i}.trial_end - data.trials{i}.trial_start;

    if i==6
        save(data.datafile, 'data', '-append');
    end

end
DrawFormattedText(theWindow, msg.fixation, 'center', 'center', text_color, [], [], [], 1.5);
Screen('Flip', theWindow);
WaitSecs(4);

%sca;
%data.runscan_endtime{i} = GetSecs;
save(data.datafile, 'data', '-append');
end