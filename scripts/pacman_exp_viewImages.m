function data = pacman_exp_viewImages(block_info, msg, data)

global ip port
global theWindow W H window_num; % window property
global white red orange blue bgcolor ; % color
global fontsize font window_rect text_color

[screenXpixels, screenYpixels] = Screen('WindowSize', theWindow);
ifi = Screen('GetFlipInterval', theWindow);
[xCenter, yCenter] = RectCenter(window_rect);
Screen('BlendFunction', theWindow, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

for i = 1:length(block_info.im_path) 
    
    block_start = GetSecs;
    data.blocks{i}.block_start = block_start;
    
    DrawFormattedText(theWindow, msg.fixation, 'center', 'center', text_color, [], [], [], 1.5);
    Screen('Flip', theWindow);
    block_fixation_start = GetSecs;
    data.blocks{i}.block_fixation_start = block_fixation_start;
    
    %% -------------Setting Pathway------------------
    if block_info.pathway_use(i) == 1
        main(ip,port,1, block_info.heat_program(i));     % select the program
    end
    

    %% -------------Ready for Pathway------------------
    if block_info.pathway_use(i) == 1
        main(ip,port,2); %ready to pre-start
    end
    
    waitsec_fromstarttime(block_fixation_start, block_info.jitter_isi(i)) % fixation jitter
    
    %% -------------Trigger Pathway------------------
    if block_info.pathway_use(i) == 1
        
        main(ip,port,2);
        data.blocks{i}.heat_stim_trigger_start = GetSecs;
    end    
    
    theImageLocation_block = block_info.im_path{i};
   
   if block_info.dummy_block(i) == 1
       
       wh_repeat = block_info.dummy_wh_repeat(i);
       wh_repeat = wh_repeat+1;
       
        for im = 1:3

            DrawFormattedText(theWindow, msg.fixation, 'center', 'center', text_color, [], [], [], 1.5);
            Screen('Flip', theWindow);

            theImageLocation = theImageLocation_block{im};

            tic
            theImage = imread(theImageLocation);
            toc
            
            if im == 1
                waitsec_fromstarttime(block_fixation_start, block_info.jitter_isi(i)+2.5)
                block_fixation_end = GetSecs;
                data.blocks{i}.block_fixation_end = block_fixation_end;
            else
                fix_start = GetSecs;
                data.blocks{i}.images_fixation{im}.fix_start = fix_start;
                waitsec_fromstarttime(img_end, block_info.im_jitter(im-1,i));
                data.blocks{i}.images_fixation{im}.fix_end = GetSecs;
            end

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


            % Draw the image
            if im == wh_repeat 
                
                Screen('DrawTexture', theWindow, imageTexture, [], dstRects);
                Screen('Flip', theWindow);
                stim_starttime = GetSecs;
                data.blocks{i}.images{im}.im_start = stim_starttime;

                %waitsec_fromstarttime(stim_starttime, 1.5) % --> revised (1.5 s stim. dur.
                
                while GetSecs - stim_starttime <= 1.5    
                    
                    if ~testmode
                        [~,~,button] = GetMouse(theWindow);
                        if button(1) == 1
                             data.blocks{i}.button_press_time = GetSecs;
                        end
                    else
                        [~,~,keyCode] = KbCheck;
                        if keyCode(KbName('m'))==1

                               data.blocks{i}.button_press_time = GetSecs;

                        end
                    end
            
            
                end
                
                img_end = GetSecs;
                data.blocks{i}.images{im}.im_end = img_end;
                
            else
                
                Screen('DrawTexture', theWindow, imageTexture, [], dstRects);
                Screen('Flip', theWindow);
                stim_starttime = GetSecs;
                data.blocks{i}.images{im}.im_start = stim_starttime;

                waitsec_fromstarttime(stim_starttime, 1.5) % --> revised (1.5 s stim. dur.)

                img_end = GetSecs;
                data.blocks{i}.images{im}.im_end = img_end;
            end

            

           
        end
       
       
   else
           for im = 1:3

            DrawFormattedText(theWindow, msg.fixation, 'center', 'center', text_color, [], [], [], 1.5);
            Screen('Flip', theWindow);

            theImageLocation = theImageLocation_block{im};

            tic
            theImage = imread(theImageLocation);
            toc
            
            if im == 1
                waitsec_fromstarttime(block_fixation_start, block_info.jitter_isi(i)+2.5)
            else
                fix_start = GetSecs;
                data.blocks{i}.images_fixation{im}.fix_start = fix_start;
                waitsec_fromstarttime(img_end, block_info.im_jitter(im-1,i));
                data.blocks{i}.images_fixation{im}.fix_end = GetSecs;
            end

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


            % Draw the image
            
            Screen('DrawTexture', theWindow, imageTexture, [], dstRects);
            Screen('Flip', theWindow);
            stim_starttime = GetSecs;
            data.blocks{i}.images{im}.im_start = stim_starttime;

            waitsec_fromstarttime(stim_starttime, 1.5) % --> revised (1.5 s stim. dur.)

            img_end = GetSecs;
            data.blocks{i}.images{im}.im_end = img_end;

          
           end
           
   end
   
   DrawFormattedText(theWindow, msg.fixation, 'center', 'center', text_color, [], [], [], 1.5);
   Screen('Flip', theWindow);
   fix_start = GetSecs;
   data.blocks{i}.images_fixation{im}.fix_start = fix_start;
   waitsec_fromstarttime(img_end, 2.5);
   data.blocks{i}.images_fixation{im}.fix_end = GetSecs;

   if i == 12 ||  i == 24 || i == 36
       save(data.datafile, 'data', '-append');
       data.blocks{i}.save_end = GetSecs;
   end
    
   data.blocks{i}.block_end = GetSecs;
    

end

DrawFormattedText(theWindow, msg.fixation, 'center', 'center', text_color, [], [], [], 1.5);
Screen('Flip', theWindow);
WaitSecs(4);

%sca;
%data.runscan_endtime{i} = GetSecs;
save(data.datafile, 'data', '-append');

end

