function pacman_exp_practice_rating(msg)

global theWindow W H window_num; % window property
global white red orange blue bgcolor ; % color
global fontsize font window_rect text_color

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
%%

Screen(theWindow, 'FillRect', bgcolor, window_rect);

% one-directional
x = W*(1/4);
y = H*(1/2);
SetMouse(x,y)  

while true % To finish practice, push button
    
    DrawFormattedText(theWindow, msg.practice, 'center', H*(1/4), white, [], [], [], 2);
    Screen('DrawLine', theWindow, white, lb2, H*(1/2), rb2, H*(1/2), 4); %rating scale
    % penWidth: 0.125~7.000
    Screen('DrawLine', theWindow, white, lb2, H*(1/2)-scale_H/3, lb2, H*(1/2)+scale_H/3, 6);
    Screen('DrawLine', theWindow, white, rb2, H*(1/2)-scale_H/3, rb2, H*(1/2)+scale_H/3, 6);
    Screen('DrawLine', theWindow, orange, x, H*(1/2)-scale_H/3, x, H*(1/2)+scale_H/3, 6); %rating bar
    Screen('Flip', theWindow);

    [x,~,button] = GetMouse(theWindow);
    if x < lb2; x = lb2; elseif x > rb2; x = rb2; end
    [~,~,keyCode] = KbCheck;
    if button(1) == 1
        break
    elseif keyCode(KbName('q')) == 1
        abort_experiment('manual');
        break
    end

end

Screen(theWindow, 'FillRect', bgcolor, window_rect);

end