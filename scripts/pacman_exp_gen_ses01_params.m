function param_info = pacman_exp_gen_ses01_params()

% ------------ Pathway parameters ------------ %

intensity_level = repelem([46 47 48], 4);
intensity_level_perm(randperm(length(intensity_level))) = intensity_level;


param_info.heat_intensity = intensity_level_perm;
param_info.heat_program = zeros(length(intensity_level),1);

PathPrg = load_PathProgram('MPC');
PathPrg_pacman = PathPrg(contains(PathPrg(:,3), 'PaCMan'),:);
    
for mm = 1:length(param_info.heat_intensity)

    param_info.heat_program(mm) = PathPrg_pacman{[PathPrg_pacman{:,1}]== param_info.heat_intensity(mm), 4};

end
% ------------ Jitter ------------ %

jitter_pairs = [8 4; 7 5; 6 6];
jitter_all = repmat(jitter_pairs,4,1);

jitter_all_perm(randperm(length(jitter_all(:,1))),:) = jitter_all;

param_info.jitter = jitter_all_perm;

end