function [basedir, session_no, sid, subject_dir] = pacman_directory_sub_info(where)
%
% Function to set the base directory and create subject folder in the
% appropriate session folder.
%
%%
switch where
    
    case 'lk_mac'
        basedir = '/System/Volumes/Data/Users/ladakohoutova/Dropbox/pacman/projects/';
    case 'lap01'
        basedir = 'C:\Users\Cocoanlab_WL01\Dropbox\pacman\projects\';
        
end

addpath(genpath(basedir));

session_no = input('Session number? \n (1: natural images; 2: geometric images): ', 's');% session_no = 1; --> natural images, session_no = 2; --> geometric images
session_no = str2num(session_no);

if session_no == 1
    datdir = fullfile(basedir, 'data', 'pilot_exp', 'session_1');
elseif session_no ==2
    datdir = fullfile(basedir, 'data', 'pilot_exp', 'session_2');
end

sid = input('Subject ID?: ', 's');
sid(isspace(sid)) = []; % remove every blank

subject_dir = fullfile(datdir, sid);

if exist(subject_dir, 'dir') == 0 % no subject dir
    fprintf(['\n ** no existing directory: ', sid, ' **']);
    cont_or_not = input(['\n Do you want to make new subject directory?', ...
        '\n1: Yes, make directory.  ,   2: No, it`s a mistake. I`ll break.\n:  ']);
    if cont_or_not == 2
        error('Break.')
    elseif cont_or_not == 1
        mkdir(subject_dir);
    end
end


end
