function [stimuli_info, im_path] = pacman_pilot_gen_trial_sequence(basedir, session_no, run_no, low_level_order)


if session_no == 1 % natural images
    stimdir = fullfile(basedir, 'data', 'pilot_stimuli', 'natural');
    
    all_folders = dir(stimdir);
    high_level  = all_folders([all_folders.isdir]);
    high_level = {high_level.name};
    high_level(contains(high_level, '.')) = [];

    low_level = [];
    for i = 1:12
        low_level{i} = [high_level{i} int2str(low_level_order(run_no,i))];  
    end

    im_names = [];
    im_path = {};
    high_level_all = {};
    low_level_all = {};
    for i = 1:12

        files = dir(fullfile(stimdir,high_level{i}, '*.jpg'));
        fnames = {files.name};
        im_names_temp = fnames(contains(fnames, low_level{i}))';
        im_names = [im_names; im_names_temp];
        high_level_all = [high_level_all; repmat({high_level{i}}, 10,1)];
        low_level_all = [low_level_all; repmat({low_level{i}}, 10,1)];

        for j = 1:10
            im_path = [im_path; fullfile(stimdir, high_level{i}, im_names_temp{j})];
        end

    end

    stimuli_info = cell(120, 6);
    stimuli_info(:,1) = high_level_all; 
    stimuli_info(:,2) = low_level_all;
    stimuli_info(:,3) = im_names;
    rng('shuffle');
    im_order = randperm(length(im_names));

    stimuli_info = stimuli_info(im_order,:);
    im_path = im_path(im_order);

    % Jitter

    jitter = repmat([2; 3; 4], 40, 1);

    rng('shuffle');
    jitter = jitter(randperm(length(jitter)));

    stimuli_info(:,4) = num2cell(jitter); 


    % Change fixation cross colour

    cross_change = false(120,1);
    %cross_change(1:40) = 1;
    cross_change(1:18) = 1; % 15% of trials with colour change
    cross_change = cross_change(randperm(length(cross_change)));

    stimuli_info(:,5) = num2cell(cross_change);
    
    % Cross colour change - timing
    
    cross_change_id = find(cross_change);
    col_change_time = zeros(120,1);
    for c = 1:length(find(cross_change))
        
        id_temp = cross_change_id(c);
        col_change_time(id_temp) = randi([1, (jitter(id_temp)-1)*10]) / 10;
        
    end
    stimuli_info(:,6) = num2cell(col_change_time); 
    stimuli_info(:,7) = num2cell(zeros(120,1)); 
    
elseif session_no == 2 % geometric images
    
    stimdir = fullfile(basedir, 'data', 'pilot_stimuli', 'geometric');
    
    if run_no <= 3
        
        stimdir_run = fullfile(stimdir, 'familiar');
        low_level_order = low_level_order.familiar;
        
        all_folders = dir(stimdir_run);
        high_level  = all_folders([all_folders.isdir]);
        high_level = {high_level.name};
        high_level(contains(high_level, '.')) = [];
        
        low_level = [];
        k = 1;
        for i = 1:6
            for j = run_no:run_no+1
            low_level{k} = [high_level{i} int2str(low_level_order(j,i))];  
            k = k+1;
            end
        end
        
        % scramble low_level
        rng('shuffle');
        im_order = randperm(length(low_level));
        low_level_trial_order = low_level(im_order);
        high_level_order = repelem(high_level,2);
        high_level_order = high_level_order(im_order);
        
        im_names = [];
        im_path = {};
        high_level_all = {};
        low_level_all = {};
        for i = 1:12

            files = dir(fullfile(stimdir_run,high_level_order{i}, '*.bmp'));
            fnames = {files.name};
            im_names_temp = fnames(contains(fnames, low_level_trial_order{i}))';
            im_names = [im_names; im_names_temp];
            high_level_all = [high_level_all; repmat({high_level_order{i}}, 10,1)];
            low_level_all = [low_level_all; repmat({low_level_trial_order{i}}, 10,1)];

            for j = 1:10
                im_path = [im_path; fullfile(stimdir_run, high_level_order{i}, im_names_temp{j})];
            end

        end

        stimuli_info = cell(120, 6);
        stimuli_info(:,1) = high_level_all; 
        stimuli_info(:,2) = low_level_all;
        stimuli_info(:,3) = im_names;
        
         % Jitter

        jitter = repmat([2; 3; 4], 40, 1);

        rng('shuffle');
        jitter = jitter(randperm(length(jitter)));

        stimuli_info(:,4) = num2cell(jitter); 


        % Change fixation cross colour

        cross_change = false(120,1);
        % cross_change(1:40) = 1;
        cross_change(1:18) = 1; % 15% of trials with colour change
        cross_change = cross_change(randperm(length(cross_change)));

        stimuli_info(:,5) = num2cell(cross_change);
        
        cross_change_id = find(cross_change);
        col_change_time = zeros(120,1);
        for c = 1:length(find(cross_change))

            id_temp = cross_change_id(c);
            col_change_time(id_temp) = randi([1, (jitter(id_temp)-1)*10]) / 10;

        end
        stimuli_info(:,6) = num2cell(col_change_time); 
        stimuli_info(:,7) = num2cell(zeros(120,1)); 
        
        
    else
        
        stimdir_run = fullfile(stimdir, 'unfamiliar');
        low_level_order = low_level_order.unfamiliar;
        
        all_folders = dir(stimdir_run);
        high_level  = all_folders([all_folders.isdir]);
        high_level = {high_level.name};
        high_level(contains(high_level, '.')) = [];
        
        low_level = [];
        k = 1;
        for i = 1:6
            for j = run_no:run_no+1
            low_level{k} = [high_level{i} int2str(low_level_order(j,i))];  
            k = k+1;
            end
        end
        
        % scramble low_level
        rng('shuffle');
        im_order = randperm(length(low_level));
        low_level_trial_order = low_level(im_order);
        high_level_order = repelem(high_level,2);
        high_level_order = high_level_order(im_order);
        
        im_names = [];
        im_path = {};
        high_level_all = {};
        low_level_all = {};
        for i = 1:12

            files = dir(fullfile(stimdir_run,high_level_order{i}, '*.bmp'));
            fnames = {files.name};
            im_names_temp = fnames(contains(fnames, low_level_trial_order{i}))';
            im_names = [im_names; im_names_temp];
            high_level_all = [high_level_all; repmat({high_level_order{i}}, 10,1)];
            low_level_all = [low_level_all; repmat({low_level_trial_order{i}}, 10,1)];

            for j = 1:10
                im_path = [im_path; fullfile(stimdir_run, high_level_order{i}, im_names_temp{j})];
            end

        end

        stimuli_info = cell(120, 6);
        stimuli_info(:,1) = high_level_all; 
        stimuli_info(:,2) = low_level_all;
        stimuli_info(:,3) = im_names;
        
         % Jitter

        jitter = repmat([2; 3; 4], 40, 1);

        rng('shuffle');
        jitter = jitter(randperm(length(jitter)));

        stimuli_info(:,4) = num2cell(jitter); 


        % Change fixation cross colour

        cross_change = false(120,1);
        % cross_change(1:40) = 1;
        cross_change(1:18) = 1; % 15% of trials with colour change
        cross_change = cross_change(randperm(length(cross_change)));

        stimuli_info(:,5) = num2cell(cross_change);
        
        cross_change_id = find(cross_change);
        col_change_time = zeros(120,1);
        
        for c = 1:length(find(cross_change))

            id_temp = cross_change_id(c);
            col_change_time(id_temp) = randi([1, (jitter(id_temp)-1)*10]) / 10;

        end
        stimuli_info(:,6) = num2cell(col_change_time); 
        stimuli_info(:,7) = num2cell(zeros(120,1)); 

    end
    
    
    
    
end




end