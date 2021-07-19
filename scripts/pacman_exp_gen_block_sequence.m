function block_info = pacman_exp_gen_block_sequence(basedir, run_no, low_level_order, dummy_cat_order)

% ------------ Real vs. dummy block ------------ %

block_info.dummy_block = [repelem(false, 30) repelem(true,6)];
perm_dummy = randperm(length(block_info.dummy_block));
block_info.dummy_block(perm_dummy) = block_info.dummy_block;
block_info.dummy_block = block_info.dummy_block';

% ------------ Stimulation type ------------ %
% 0 - no stimulation; 1 - warmth (46 deg.); 2 - heat (48 deg.)

block_info.stim_type = zeros(36,1);
real_stim = repelem([0 1 2], 10);
real_stim_perm = randperm(length(real_stim));
real_stim(real_stim_perm) = real_stim;

dummy_stim = repelem([0 1 2], 2);
dummy_stim_perm = randperm(length(dummy_stim));
dummy_stim(dummy_stim_perm) = dummy_stim;

block_info.stim_type(block_info.dummy_block==1) = dummy_stim;
block_info.stim_type(block_info.dummy_block~=1) = real_stim;

block_info.stim_type_descr = ['0 - no stimulation; 1 - warmth; 2 - heat'];
block_info.pathway_use = zeros(36,1);
block_info.pathway_use(block_info.stim_type~=0) = 1;

% ------------ Pathway parameters ------------ %

block_info.heat_intensity = zeros(36,1);
block_info.heat_intensity(block_info.stim_type==1) = 46;
block_info.heat_intensity(block_info.stim_type==2) = 48;

block_info.heat_program = zeros(36,1);

PathPrg = load_PathProgram('MPC');
PathPrg_pacman = PathPrg(contains(PathPrg(:,3), 'PaCMan'),:);
    
for mm = 1:length(block_info.heat_intensity)
    
    if block_info.heat_intensity(mm) ~=0
        
        %index = find([PathPrg{:,1}] == block_info.heat_intensity(mm) & contains(PathPrg(:,3), 'PaCMan'));
        block_info.heat_program(mm) = PathPrg_pacman{[PathPrg_pacman{:,1}]== block_info.heat_intensity(mm), 4};
        
    end
    
end

% ------------ Jitter - ISI ------------ %

jitter_isi = repelem([5 7 9], 12);
jitter_isi_perm = randperm(length(jitter_isi));
jitter_isi(jitter_isi_perm) = jitter_isi;
block_info.jitter_isi = jitter_isi;


% ------------ Create image sequences ------------ %
% ------------------------------------------------ %

block_info.im_path = cell(36,1);
block_info.im_info = cell(36,1);
block_info.dummy_wh_repeat = zeros(36,1);

block_info.im_jitter = zeros(2,36);
im_isi = [2 3];
for i = 1:36
    
    perm = randperm(2);
    temp_jitter = im_isi(perm);
    block_info.im_jitter(:,i) = temp_jitter;
    
end

% ------------ Create dummy image blocks ------------ %
% dummy_cat_order: rows - runs; columns - categories

dummydir = fullfile(basedir, 'data', 'exp_stimuli', 'dummy_stimuli');

all_folders_dummy = dir(dummydir);
high_level_dummy  = all_folders_dummy([all_folders_dummy.isdir]);
high_level_dummy = {high_level_dummy.name};
high_level_dummy(contains(high_level_dummy, '.')) = [];

dummy_cat_run_id = find(dummy_cat_order(run_no,:));

low_level_dummy = [];
for i = 1:length(dummy_cat_run_id)
    low_level_dummy{i} = [high_level_dummy{dummy_cat_run_id(i)} int2str(dummy_cat_order(run_no,dummy_cat_run_id(i)))];  
end

dummy_im_path = [];
for i = 1:length(dummy_cat_run_id)
    
    files = dir(fullfile(dummydir,high_level_dummy{dummy_cat_run_id(i)}, '*.jpg'));
    fnames = {files.name};
    im_names_temp = fnames(contains(fnames, low_level_dummy{i}))';
    im_names_temp_perm = randperm(length(im_names_temp));
    im_names_temp(im_names_temp_perm) = im_names_temp;
    
    im_path = [];
    for j = 1:6
        im_path = [im_path; fullfile(dummydir, high_level_dummy{dummy_cat_run_id(i)}, im_names_temp{j})];
    end
    im_path = string(im_path);
    
    stim_id = [0 1 2];
    c = 1;
    for k = 1:3
        wh_repeat = randperm(2);
        im_temp = im_path(c:c+1);
        c = c+2;
        im_temp = repelem(im_temp, wh_repeat);
        save_id = find(block_info.dummy_block == 1 & block_info.stim_type==stim_id(k));
        save_id = save_id(i);
        block_info.im_path{save_id} = im_temp;
        block_info.dummy_wh_repeat(save_id) = find(wh_repeat==2);
        
        im_info_temp = cell(3,3);
        for kk =1:3
            
            split_path = strsplit(im_temp(kk),'/');
            im_info_temp{1,kk} = high_level_dummy{dummy_cat_run_id(i)};
            im_info_temp{2,kk} = low_level_dummy{i};
            im_info_temp{3,kk} = split_path(end);
            
        end
        block_info.im_info{save_id} = im_info_temp;
    end
    
end


% ------------ Create real image blocks ------------ %

stimdir = fullfile(basedir, 'data', 'exp_stimuli', 'real_stimuli');

all_folders = dir(stimdir);
high_level  = all_folders([all_folders.isdir]);
high_level = {high_level.name};
high_level(contains(high_level, '.')) = [];

low_level = [];
for i = 1:10
    low_level{i} = [high_level{i} int2str(low_level_order(run_no,i))];  
end

no_stim_id = find(block_info.dummy_block == 0 & block_info.stim_type==0);
warmth_id = find(block_info.dummy_block == 0 & block_info.stim_type==1);
heat_id = find(block_info.dummy_block == 0 & block_info.stim_type==2);

stim_id_perm = zeros(3,10);
stim_id_perm(1,:) = no_stim_id(randperm(length(no_stim_id)));
stim_id_perm(2,:) = warmth_id(randperm(length(warmth_id)));
stim_id_perm(3,:) = heat_id(randperm(length(heat_id)));

for i = 1:length(high_level)
    
    files = dir(fullfile(stimdir,high_level{i}, '*.jpg'));
    fnames = {files.name};
    im_names_temp = fnames(contains(fnames, low_level{i}))';
    im_names_temp_perm = randperm(length(im_names_temp));
    im_names_temp(im_names_temp_perm) = im_names_temp;
    
    im_path = [];
    for j = 1:length(im_names_temp)
        im_path = [im_path; fullfile(stimdir, high_level{i}, im_names_temp{j})];
    end
    im_path = string(im_path);
    
    stim_id = [0 1 2];
    c = 1;
    for k = 1:3
        
        im_temp = im_path(c:c+2);
        c = c+3;
        
        save_id = stim_id_perm(k, i);
        block_info.im_path{save_id} = im_temp;
        
        im_info_temp = cell(3,3);
        for kk =1:3
            
            split_path = strsplit(im_temp(kk),'/');
            im_info_temp{1,kk} = high_level{i};
            im_info_temp{2,kk} = low_level{i};
            im_info_temp{3,kk} = split_path(end);
            
        end
        block_info.im_info{save_id} = im_info_temp;
    end
    
end


end