function confirm = Scor6AxisSendPosition(s,varargin)
% SCOR6AXISSENDPOSITION
%   SCOR6AXISSENDPOSITION(s,dt,BSEPRG)
%
%
%   D. Saiontz and M. Kutzer, 31Aug2016, USNA/SEAP

%% Set output
confirm = false;

%% Check inputs
% TODO - check and parse inputs
dt = varargin{1};
BSEPRG = varargin{2}; 

%% Create message
% Message format
% !PosCMDdt%f\n
% %d,%f,%f,%f,%f,%f,%f\n
% %d,%f,%f,%f,%f,%f,%f\n
% %d,%f,%f,%f,%f,%f,%f\n
% %d,%f,%f,%f,%f,%f,%f\n
% %d,%f,%f,%f,%f,%f,%f\n
% ...
% %d,%f,%f,%f,%f,%f,%f\n
% **\n

% Preamble
msg{1} = sprintf('!PosCMDdt%.2f\n', dt);
% Waypoints
for i = 1:size(BSEPRG,1)
    msg{i+1} = sprintf('%d,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f\n',[i,BSEPRG(i,:)]);
end
% Epilogue
msg{end+1} = sprintf('**\n');

%% Send message
for i = 1:numel(msg)
    % Display message to command window
    fprintf('%s',msg{i});
    % Send command to ScorBot 6-Axis Controller
    fprintf(s,'%s',msg{i},'async');
    % Check transfer status and wait for idle
    while true
        switch lower(s.TransferStatus)
            case 'idle'
                break
        end
    end
end

%% Set output
confirm = true;