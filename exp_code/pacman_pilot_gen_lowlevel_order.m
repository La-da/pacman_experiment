function low_level_order = pacman_pilot_gen_lowlevel_order(session_no)
% session_no = 1; --> natural images
% session_no = 2; --> geometric images

rng('shuffle');


if session_no == 1
    low_level_order = zeros(6,12); % row = run

    for i = 1:12

        low_level_order(:,i) = randperm(6);

    end
    
elseif session_no == 2
    
    low_level_order.familiar = zeros(6,6);
    low_level_order.unfamiliar = zeros(6,6);
    
    for i = 1:6

        low_level_order.familiar(:,i) = randperm(6);
        low_level_order.unfamiliar(:,i) = randperm(6);

    end
    
else
    error('Incorrect or missing session number!')
end

end