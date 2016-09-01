function Scor6AxisBytesAvailableFcn(s,event)
% SCOR6AXISBYTESAVAILABLEFCN
%
%
% D. Saiontz, M. Kutzer, 31Aug2016, USNA/SEAP

global Scor6AxisData

%% Initialize global variable if it does not already exist
if isempty(Scor6AxisData)
    Scor6AxisData.T = [];
    Scor6AxisData.P = [];
    Scor6AxisData.V = [];
    Scor6AxisData.S = [];
end

%% Set data collection limit
dataLimit = 5000; % data history limit

%% Read serial port
try
    switch event.Type
        case 'BytesAvailable'
            if ser.BytesAvailable > 9
                % Read data from serial buffer
                data = fscanf(s,...
                    [...
                    '$T%f',...                % Time stamp
                    'P%f,%f,%f,%f,%f,%f',...  % Joint position
                    'V%f,%f,%f,%f,%f,%f',...  % Joint velocity
                    'S%d,%d,%d,%d,%d,%d' ...  % Joint state
                    ],...
                    [1,19]); % Data size
                % Parse Data
                T = data(1);     % Time stamp
                P = data(2:7);   % Axis positions
                V = data(8:13);  % Axis velocities
                S = data(14:19); % Axis states
                % Package Data
                % TODO - check lengths of all fields
                if size(Scor6AxisData.T,1) >= dataLimit
                    % Migrate old data
                    Scor6AxisData.T(1:(dataLimit-1), :) = Scor6AxisData.T(2:dataLimit, :);
                    Scor6AxisData.P(1:(dataLimit-1), :) = Scor6AxisData.P(2:dataLimit, :);
                    Scor6AxisData.V(1:(dataLimit-1), :) = Scor6AxisData.V(2:dataLimit, :);
                    Scor6AxisData.S(1:(dataLimit-1), :) = Scor6AxisData.S(2:dataLimit, :);
                    % Add new data
                    Scor6AxisData.T(dataLimit, :) = T;
                    Scor6AxisData.P(dataLimit, :) = P;
                    Scor6AxisData.V(dataLimit, :) = V;
                    Scor6AxisData.S(dataLimit, :) = S;
                else
                    % Append new data
                    Scor6AxisData.T(end+1, :) = T;
                    Scor6AxisData.P(end+1, :) = P;
                    Scor6AxisData.V(end+1, :) = V;
                    Scor6AxisData.S(end+1, :) = S;
                end
                % Display data in command window
                %fprintf('Time: %.2f\n',T)
                %fprintf('Position: %.4f, %.4f, %.4f, %.4f, %.4f, %.4f\n', P);
                %fprintf('Velocity: %.4f, %.4f, %.4f, %.4f, %.4f, %.4f\n', V);
                %fprintf('State:    %d, %d, %d, %d, %d, %d\n', S);
            end
        otherwise
            error('Unexpected event.')
    end
catch
    % Flush buffer is a read error occurs
    flushinput(s);
end