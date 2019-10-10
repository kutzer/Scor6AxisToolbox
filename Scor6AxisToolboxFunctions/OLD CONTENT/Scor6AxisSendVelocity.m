function confirm = Scor6AxisSendVelocity(s,varargin)
% SCOR6AXISSENDVELOCITY
%   SCOR6AXISSENDVELOCITY(s,dt,BSEPRGvelocity)
%
%
%   D. Saiontz and M. Kutzer, 31Aug2016, USNA/SEAP

%% Set output
confirm = false;

%% Check inputs
% TODO - check and parse inputs
dt = varargin{1};
BSEPRGvelocity = varargin{2}; 

%% Create message
% Message format
% !VelCMDdt%f\n
% %d,%f,%f,%f,%f,%f,%f\n
% %d,%f,%f,%f,%f,%f,%f\n
% %d,%f,%f,%f,%f,%f,%f\n
% %d,%f,%f,%f,%f,%f,%f\n
% %d,%f,%f,%f,%f,%f,%f\n
% ...
% %d,%f,%f,%f,%f,%f,%f\n
% **\n

% Preamble
msg{1} = sprintf('!VelCMDdt%.2f\n', dt);
% Waypoints
for i = 1:size(BSEPRGvelocity,1)
    msg{i+1} = sprintf('%d,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f\n',[i,BSEPRGvelocity(i,:)]);
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