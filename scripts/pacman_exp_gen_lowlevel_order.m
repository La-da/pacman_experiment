function [low_level_order, dummy_cat_order] = pacman_exp_gen_lowlevel_order()

low_level_order = zeros(6,10); % row = run

    for i = 1:10

        low_level_order(:,i) = randperm(6);

    end

dummy_cat_order_id = zeros(6,2);

check_same = true;
while check_same == true
    
    dummy_cat_order_id(:,1) = randperm(6);
    dummy_cat_order_id(:,2) = randperm(6);
    
    if isempty(find(dummy_cat_order_id(:,1)==dummy_cat_order_id(:,2)))
        check_same = false;
    end
        
end


dummy_cat_order = zeros(6,6); % rows - runs; columns - higher level categories;

for i = 1:6
    
    dummy_cat_order(dummy_cat_order_id(i,1),i) = 1;
    dummy_cat_order(dummy_cat_order_id(i,2),i) = 2;
end



end