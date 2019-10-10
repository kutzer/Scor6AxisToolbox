function confirm = Scor6AxisSend(s,msg)
% SCOR6AXISSEND sends a specified message to the ScorBot 6-Axis controller.
%   SCOR6AXISSEND(s,msg) sends the message contained in msg to the serial
%   object s.
%
%   M. Kutzer, 14Nov2018, USNA

%% Set output
confirm = false;

%% Check inputs
% check serial object
% check message

%% Send message
if numel(msg) == 1
    fprintf('SEND: %s !END\n',msg);
    fprintf(s,'%s',msg,'async');
else
    fprintf('SEND: %s"CR" !END\n',msg);
    fprintf(s,'%s\r',msg,'async');
end

%% Wait for write to complete
% This eliminates async errors
while true
    switch lower(s.TransferStatus)
        case 'idle'
            break
    end
end

%% Set output
confirm = true;