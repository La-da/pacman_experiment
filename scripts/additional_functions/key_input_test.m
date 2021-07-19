addpath(genpath(pwd));

devices = PsychHID('Devices');

device(1).product = 'Apple Internal Keyboard / Trackpad';
device(1).vendorID= 1452;

% device(2).product = 'KeyWarrior8 Flex';
% device(2).vendorID= 1984;

apple = IDkeyboards(device(1));
% sync_box = IDkeyboards(device(2));

% while true
% %     [~,~,keyCode] = KbCheck(sync_box);
%     [~,~,keyCode] = KbCheck;
%
%     if keyCode(KbName('s'))==1
%         break
%     elseif keyCode(KbName('q'))==1
%         break
%     end
%
% end
while true
    [~,~,keyCode] = KbCheck;
    
    if keyCode(KbName('a'))==1
        break
    elseif keyCode(KbName('q'))==1
        abort_experiment('manual');
    end
end