%% PaCMan experiment - main script

%% 1. get basedir/set path + create subject folder + input subject ID + input session no.
% 'lk_mac' -- DB mac, 'lk_git_mac -- git mac', 'lap01' - laptop 01 for
% experiment

[basedir, session_no, sid, subject_dir] = pacman_directory_sub_info('lap01');

%% 2. generate low level category order for the whole session - input: session no.


low_level_order = pacman_pilot_gen_lowlevel_order(session_no);

%% 3. Core function for each run - inputs: basedir + subject ID + output of 2. + others
 
pacman_pilot_run_core(basedir, subject_dir, sid, session_no, low_level_order, 'scan_adjust', 'testmode')
