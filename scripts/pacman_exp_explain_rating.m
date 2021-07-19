function pacman_exp_explain_rating(basedir, msg)

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
while true % Button
    DrawFormattedText(theWindow, msg.explain, 'center', 'center', white, [], [], [], 2);
    Screen('Flip', theWindow);

    [x,~,button] = GetMouse(theWindow);
    [~,~,keyCode] = KbCheck;
    if button(1) == 1
        break
    elseif keyCode(KbName('q')) == 1
        abort_experiment('manual');
        break
    end
end


%% Explain one-directional scale with visualization

waitsec_fromstarttime(GetSecs, 0.5);

while true % Space
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    overall_rat_scale = imread(fullfile(basedir, 'scripts', 'gLMS_unidirectional_rating_scale.jpeg'));
    [s1, s2, s3] = size(overall_rat_scale);
    overall_rat_scale_texture = Screen('MakeTexture', theWindow, overall_rat_scale);
    Screen('DrawTexture', theWindow, overall_rat_scale_texture, [0 0 s2 s1],[0 0 W H]);
    Screen('PutImage', theWindow, overall_rat_scale); %show the overall rating scale
    Screen('Flip', theWindow);

    [x,~,button2] = GetMouse(theWindow);
    [~,~,keyCode] = KbCheck;
    if button2(1) == 1
        break
    elseif keyCode(KbName('q')) == 1
        abort_experiment('manual');
        break
    end  
end

Screen(theWindow, 'FillRect', bgcolor, window_rect);
waitsec_fromstarttime(GetSecs, 0.5);

end