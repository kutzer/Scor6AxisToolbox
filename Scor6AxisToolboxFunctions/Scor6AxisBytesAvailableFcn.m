function Scor6AxisBytesAvailableFcn(s,event)
% SCOR6AXISBYTESAVAILABLEFCN
%
%
% M. Kutzer, 14Nov2018, USNA

global Scor6AxisData Scor6AxisIsOK Scor6AxisVelStatus Scor6AxisTiming Scor6sim

%% Initialize global variable if it does not already exist
if isempty(Scor6AxisData)
    Scor6AxisData.Time = [];     % Run time in seconds
    Scor6AxisData.Mode = [];     % Position mode [Degrees, Radians, Counts]
    Scor6AxisData.BSEPRG = [];   % Joint configuration and gripper state
    Scor6AxisData.Status = [];   % Axis Status
    Scor6AxisData.Movement = []; % Axis Movement
end

if isempty(Scor6AxisTiming)
    Scor6AxisTiming.dt = 0.02; % Default set by Scor6Axis Controller
    Scor6AxisTiming.tStart = now * 24 * 60 * 60; 
end

%% Update timing
Scor6AxisTiming.t_LastCallback = now * 24 * 60 * 60; 

%% Set data collection limit
%dataLimit = 5000; % data history limit

%% Read serial port
%try
switch event.Type
    case 'BytesAvailable'
        if s.BytesAvailable > 3
            % Read data from serial buffer
            msg = fscanf(s,'%s');
            % Print Message (for debugging)
            %fprintf('LINE: %s !END\n',msg);
            % Messages should generally take the form:
            % T#.#P_#,#,#,#,#,#V#,#,#,#,#,#S____M____
            idxT = strfind(msg,'T');
            idxP = strfind(msg,'P');
            idxV = strfind(msg,'V');
            idxS = strfind(msg,'S');
            idxM = strfind(msg,'M');
            % Check for telemetry/status message
            if numel(idxT) == 1 && numel(idxP) == 1 && ...
                    numel(idxS) == 1 && numel(idxM) == 1
                
                % Get time stamp
                time = sscanf( msg( (idxT(1)+1):(idxP(1)-1) ),'%f' );
                % Get BSEPRG position value
                BSEPRGposition = sscanf( msg( (idxP(1)+2):(idxV(1)-1) ), '%f,%f,%f,%f,%f,%f',[1,6]);
                % Get BSEPRG velocity value
                BSEPRGvelocity = sscanf( msg( (idxV(1)+1):(idxS(1)-1) ), '%f,%f,%f,%f,%f,%f',[1,6]);
                % Get Mode
                mode = msg( idxP(1)+1 );
                % Get status and movement information
                status   = msg( (idxS(1)+1):(idxM(1)-1) );
                movement = msg( (idxM(1)+1):(idxM(1)+2) );
                
                % Displace parsed message
                %{
                    fprintf('\t             Time - %.4f\n',time);
                    fprintf('\t  Position BSEPRG - [%.4f,%.4f,%.4f,%.4f,%.4f,%.4f]\n',BSEPRGposition);
                    fprintf('\t  Velocity BSEPRG - [%.4f,%.4f,%.4f,%.4f,%.4f,%.4f]\n',BSEPRGvelocity);
                    fprintf('\t             Mode - %s\n',mode);
                    fprintf('\t           Status - %s\n',status);
                    fprintf('\t         Movement - %s\n',movement);
                %}
                
                Scor6AxisData.Time = time;                      % Run time in seconds
                Scor6AxisData.Mode = mode;                      % Position mode [Degrees, Radians, Counts]
                Scor6AxisData.BSEPRGposition = BSEPRGposition;  % Joint configuration and gripper state position
                Scor6AxisData.BSEPRGvelocity = BSEPRGvelocity;  % Joint configuration and gripper state velocity
                Scor6AxisData.Status = status;                  % Axis Status
                Scor6AxisData.Movement = movement;              % Axis Movement
                
                % Update timing
                Scor6AxisTiming.t_LastBSEPR = now * 24 * 60 * 60;
                
                % Update simulation
                if ~isempty(Scor6sim)
                    if ishandle(Scor6sim.Axes)
                        ScorSimSetBSEPR(Scor6sim,BSEPRGposition(1:5));
                        ScorSimSetGripper(Scor6sim,BSEPRGposition(6));
                    else
                        Scor6sim = [];
                    end
                end
            else
                if isequal(msg,'OK')
                    Scor6AxisIsOK = 1;
                end
                if isequal(msg,'Press?formenu')
                    Scor6AxisIsOK = -1;
                end
                if isequal(msg,'NAK')
                    Scor6AxisIsOK = -2;
                end
                if isequal(msg,'EnterTimeout,velocity:b,s,e,p,rinRad/sec,ginmmSec')
                    Scor6AxisVelStatus.Response = true;
                end
                % T0.200,Vb-0.000,s-0.106,e0.019,p0.316,r0.000,g0.000
                if contains(msg,'T') &&... 
                        contains(msg,',Vb') &&...
                        contains(msg,',s') && ...
                        contains(msg,',e') && ...
                        contains(msg,',p') && ...
                        contains(msg,',r') && ...
                        contains(msg,',g')
                    Scor6AxisVelStatus.Acknowledge = true;
                end
                if isequal(msg,'Incorrectnumberofparametersscanned!!')
                    Scor6AxisVelStatus.Response = false;
                    Scor6AxisVelStatus.Acknowledge = false;
                    Scor6AxisVelStatus.Error = true;
                end
                fprintf('LINE: %s !END\n',msg);
            end
        end
    otherwise
        error('Unexpected event.')
end
%catch
% Flush buffer is a read error occurs
%flushinput(s);
%end