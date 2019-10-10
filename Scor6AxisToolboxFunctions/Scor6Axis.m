classdef Scor6Axis < matlab.mixin.SetGet
    % SCOR6AXIS Construct handle class for communicating with the ScorBot
    % 6-Axis Controller.
    %
    %   obj = SCOR6AXIS('PORT') constructs a Scor6Axis object associated
    %   with port, PORT. If PORT does not exist, is in use, or is not
    %   properly connected to a ScorBot 6-Axis Controller, you will not be
    %   able to communicate with the 6-Axis Controller.
    %
    % Scor6Axis Methods
    %   Home        - Home the ScorBot 6-Axis Controller
    %   GoHome      - Move to the home position
    %   WaitForMove - Wait for movement to complete
    %   get         - Query properties of the Scor6Axis object
    %   set         - Update properties of the Scor6Axis object
    %   delete      - Uninitialize and remove the Scor6Axis object
    %
    % Scor6Axis Properties
    %   Serial          - Serial port object associated with the controller
    %   Status          - Controller and joint status
    %   dt              - Streaming time (from controller)
    %   VelocityTimeout - Timeout time for velocity movements (seconds)
    %   BSEPR           - Joint positions
    %   BSEPRposition   - Joint positions
    %  ~BSEPRvelocity   - Joint velocities
    %   XYZPR           - End-effector position and orientation
    %   XYZPRposition   - End-effector position and orientation
    %  ~XYZPRvelocity   - End-effector position and orientation velocity
    %   Gripper         - Gripper position (millimeters)
    %   GripperPosition - Gripper position (millimeters)
    %  ~GripperVelocity - Gripper velocity (millimeters per second)
    %   BSEPRG          - Joint positions (including gripper "joint")
    %   BSEPRGposition  - Joint positions (including gripper "joint")
    %  ~BSEPRGvelocity  - Joint velocities (including gripper "joint")
    %   dtBSEPRG        - Joint/gripper waypoint, trapezoidal move
    %
    %   D. Saiontz & M. Kutzer, 31Aug2016, USNA/SEAP
    
    % --------------------------------------------------------------------
    % General properties
    % --------------------------------------------------------------------
    properties (GetAccess='public', SetAccess='private')
        Serial        % Serial port object associated with the controller
        Status        % Controller and joint status
    end % end public/private properties
    
    properties (GetAccess='public', SetAccess='public')
        % --- Time ---
        VelocityTimeout % Timeout time for velocity movements (seconds)
    end
    
    properties (Dependent, GetAccess='public', SetAccess='public')
        % --- Time ---
        dt              % Default time step between waypoints (seconds)
        % --- Joint Space ---
        BSEPR           % Joint positions
        BSEPRposition   % Joint positions
        BSEPRvelocity   % Joint velocities
        % --- Task Space ---
        XYZPR           % End-effector position and orientation
        XYZPRposition   % End-effector position and orientation
        XYZPRvelocity   % End-effector position and orientation velocity
        % --- Gripper ---
        Gripper         % Gripper position (millimeters)
        GripperPosition % Gripper position (millimeters)
        GripperVelocity % Gripper velocity (millimeters per second)
        % --- Joint Space with Gripper ---
        BSEPRG          % Joint positions (including gripper "joint")
        BSEPRGposition  % Joint positions (including gripper "joint")
        BSEPRGvelocity  % Joint velocities (including gripper "joint")
        % --- Task Space with Gripper ---
        XYZPRG          % End-effector position and orientation (including gripper "joint")
        XYZPRGposition  % End-effector position and orientation (including gripper "joint")
        XYZPRGvelocity  % End-effector position and orientation velocity (including gripper "joint")
    end % end public/public properties
    
    properties (Dependent, GetAccess='private', SetAccess='public')
        % --- Trapezoidal move ---
        dtBSEPRG        % Joint/gripper waypoint, trapezoidal move
    end
    
    properties (Hidden)
        dtWorkAround
    end
    
    properties (Constant, Hidden)
        BSEPRhome = [0.00000,2.09925,-1.65843,-1.54994,0.00000];
    end % end constant properties
    
    % --------------------------------------------------------------------
    % Constructor/Destructor
    % --------------------------------------------------------------------
    methods (Access = 'public')
        % Constructor
        function obj = Scor6Axis(COM)
            % Check input arguments
            narginchk(0,1);
            if nargin > 0
                % TODO - check for correct COM port syntax
                % NOTE: This differs based on different operating systems
            else
                % Get serial ports
                inst = instrhwinfo('serial');
                % Display list dialog to user
                [idx,OK] = listdlg('PromptString','Select a file:',...
                    'SelectionMode','single',...
                    'ListString',inst.SerialPorts,...
                    'InitialValue',numel(inst.SerialPorts));
                % Get selection
                if OK
                    COM = inst.SerialPorts{idx};
                else
                    error('Scor6Axis:Constructor','No serial port selected.');
                end
            end
            
            % Check if port is already declared or in use
            s = instrfindall('Port',COM);
            if ~isempty(s)
                switch lower(s.Status)
                    case 'open'
                        warning('Scor6Axis:Constructor',...
                            'Port "%s" is already declared and open. Deleting existing object.',...
                            s.Port);
                        delete(s);
                    case 'closed'
                        warning('Scor6Axis:Constructor',....
                            'Port "%s" is already declared. Deleting existing object.',...
                            s.Port);
                        delete(s);
                    otherwise
                        error('Unexpected Serial Object status.');
                end
            end
            
            % Declare serial port
            obj.Serial = serial(COM);
            % Adjst serial port parameters
            set(obj.Serial,'BaudRate',115200);
            set(obj.Serial,'DataBits',8);
            set(obj.Serial,'Parity','none');
            set(obj.Serial,'StopBits',1);
            set(obj.Serial,'Terminator','CR/LF');
            set(obj.Serial,'InputBufferSize',2048);
            set(obj.Serial,'BytesAvailableFcnMode','Terminator');
            set(obj.Serial,'BytesAvailableFcn',@Scor6AxisBytesAvailableFcn);
            % Open serial port
            fopen(obj.Serial);
            
            % Set default value(s)
            obj.VelocityTimeout = 1.0; % Velocity timeout (seconds)
            obj.dt = 0.05;             % Stream rate (seconds)
            
            % Start telemetry data streaming
            obj.StartStreaming;
            
            % Call object?
            obj;
        end
        % Destructor
        function delete(obj)
            % Display status to the user
            fprintf('Deleting Scor6Axis Object...\n');
            % Move ScorBot to home position
            fprintf(' -> Moving to home position...\n');
            try
                obj.GoHome;
                Scor6WaitForOK;
                fprintf(' -> ..........................[COMPLETE]\n');
            catch
                fprintf('[FAIL]\n');
                fprintf(2,'An error occured during the shutdown process.\n');
            end
            
            % Close serial object
            fprintf(' -> Closing serial object...');
            try
                fclose(obj.Serial);
                fprintf('[COMPLETE]\n');
            catch
                fprintf('[ERROR]\n');
                % TODO - add error reporting
            end
            
            % Delete serial object
            fprintf(' -> Deleting serial object...');
            try
                delete(obj.Serial);
                fprintf('[COMPLETE]\n');
            catch
                fprintf('[ERROR]\n');
                % TODO - add error reporting
            end
            
            % Delete Scor6Axis object
            fprintf(' -> Deleting Scor6Axis object...');
            try
                delete(obj);
                fprintf('[COMPLETE]\n');
            catch
                fprintf('[ERROR]\n');
                % TODO - add error reporting
            end
            
        end
    end % end Constructor/Destructor
    
    % --------------------------------------------------------------------
    % General methods
    % --------------------------------------------------------------------
    methods
        function Home(obj)
            % Home the ScorBot 6-Axis Controller
            % Run homing sequence
            msg = 'Ha';
            confirm = Scor6AxisSend(obj.Serial,msg);
            [confirm,msg] = Scor6WaitForOK;
            if ~confirm
                fprintf(2,'Homing Failed. Attempting to recover.\n');
                switch lower(msg)
                    case 'timeout'
                        obj.RestartController;
                        obj.RecoverController;
                    case 'restart'
                        obj.RecoverController;
                    case 'nak'
                        fprintf(2,'\t -> Restarting Telemetry Stream...\n');
                        obj.StartStreaming;
                        pause(1);
                end
                fprintf(2,'\t -> Rehoming Robot...\n');
                msg = 'Ha';
                confirm = Scor6AxisSend(obj.Serial,msg);
                [confirm,msg] = Scor6WaitForOK;
            end
        end
        
        function GoHome(obj)
            % Send ScorBot 6-Axis Controller to home position
            msg = 'G';
            confirm = Scor6AxisSend(obj.Serial,msg);
        end
        
        function StartStreaming(obj)
            % Start telemetry data streaming
            msg = '<1';
            confirm = Scor6AxisSend(obj.Serial,msg);
            msg = '^1';
            confirm = Scor6AxisSend(obj.Serial,msg);
        end
        
        function ClearStallCurrents(obj)
            % Clear stall currents
            msg = 'Cc';
            confirm = Scor6AxisSend(obj.Serial,msg);
            pause(1);
        end
        
        function UpdateStallCurrents(obj)
            % Update stall currents
            msg = '|';
            confirm = Scor6AxisSend(obj.Serial,msg);
            pause(1);
        end
        
        function RestartController(obj)
            % Restart controller
            msg = char(27); % ESC
            confirm = Scor6AxisSend(obj.Serial,msg);
        end
        
        function RecoverController(obj)
            % Run through recovery steps (clear/update currents etc)
            fprintf(2,'\t -> Clearing stall currents...\n');
            obj.ClearStallCurrents;
            fprintf(2,'\t -> Updating stall currents...\n');
            obj.UpdateStallCurrents;
            obj.UpdateStallCurrents;
            obj.UpdateStallCurrents;
            fprintf(2,'\t -> Restarting telemetry stream...\n');
            obj.StartStreaming;
            pause(1);
        end
        
        function CheckStreaming(obj)
            % Check streaming status and restart if streaming stopped
            global Scor6AxisTiming
            dt = obj.dt;
            Scor6AxisTiming.dt = dt;
            
            t_now = now * 24 * 60 * 60; 
            t_last = Scor6AxisTiming.t_LastBSEPR;
            if (t_now - t_last) > 2*dt
                fprintf(2,'\t -> Telemetry streaming may have stopped.\n');
                fprintf(2,'\t -> Restarting telemetry stream...\n');
                obj.StartStreaming;
                pause(1);
            end
        end
        
        function WaitForMove(obj)
            % Wait for movement to complete
            % TODO - define joint idle state
            warning('---> METHOD NOT COMPLETE');
        end
    end
    
    % --------------------------------------------------------------------
    % Getters/Setters
    % --------------------------------------------------------------------
    methods
        % ----------------------------------------------------------------
        % Getters
        % ----------------------------------------------------------------
        function Serial = get.Serial(obj)
            % Get serial port object associated with the controller
            Serial = obj.Serial;
        end
        
        function Status = get.Status(obj)
            % Get controller and joint status
            % TODO - parse incoming message
            Status = 'METHOD NOT COMPLETE';
        end
        
        function dt = get.dt(obj)
            % Get time step between waypoints (seconds)
            dt = obj.dtWorkAround;
        end
        
        function VelocityTimeout = get.VelocityTimeout(obj)
            % Get velocity timeout (seconds)
            VelocityTimeout = obj.VelocityTimeout;
        end
        
        function BSEPR = get.BSEPR(obj)
            % Get joint positions
            BSEPR = obj.BSEPRG(1:5);
        end
        
        function BSEPRposition = get.BSEPRposition(obj)
            % Get joint positions
            BSEPRposition = obj.BSEPR;
        end
        
        function BSEPRvelocity = get.BSEPRvelocity(obj)
            % Get joint velocities
            BSEPRvelocity = obj.BSEPRGvelocity(1:5);
        end
        
        function XYZPR = get.XYZPR(obj)
            % Get end-effector position and orientation
            BSEPR = obj.BSEPR;
            XYZPR = ScorBSEPR2XYZPR(BSEPR);
        end
        
        function XYZPRposition = get.XYZPRposition(obj)
            % Get end-effector position and orientation
            XYZPRposition = obj.XYZPR;
        end
        
        function XYZPRvelocity = get.XYZPRvelocity(obj)
            % Get end-effector position and orientation velocity
            J = ScorXYZPRJacobian(obj.BSEPR);
            XYZPRvelocity = transpose( J*transpose(obj.BSEPRvelocity) );
        end
        
        function Gripper = get.Gripper(obj)
            % Get gripper position (millimeters)
            Gripper = obj.BSEPRG(6);
        end
        
        function GripperPosition = get.GripperPosition(obj)
            % Get gripper position (millimeters)
            GripperPosition = obj.Gripper;
        end
        
        function GripperVelocity = get.GripperVelocity(obj)
            % Get gripper velocity (millimeters per second)
            GripperVelocity = obj.BSEPRGvelocity(6);
        end
        
        function BSEPRG = get.BSEPRG(obj)
            % Get joint positions (including gripper "joint")
            
            % TODO - there must be a better method than using globals
            % Set global for callback function data sharing
            global Scor6AxisData
            
            % Initialize global variable if it does not already exist
            if isempty(Scor6AxisData)
                Scor6AxisData.Time = [];            % Run time in seconds
                Scor6AxisData.Mode = [];            % Position mode [Degrees, Radians, Counts]
                Scor6AxisData.BSEPRGposition = [];  % Joint configuration and gripper state
                Scor6AxisData.BSEPRGvelocity = [];  % Joint configuration and gripper state velocty
                Scor6AxisData.Status = [];          % Axis Status
                Scor6AxisData.Movement = [];        % Axis Movement
            end
            
            % Check streaming
            obj.CheckStreaming;
            
            % Parse Data
            if ~isempty(Scor6AxisData.BSEPRGposition)
                BSEPRG = Scor6AxisData.BSEPRGposition(end,:);
                % Adjust for negative base value on controller
                BSEPRG(1) = -BSEPRG(1);
                BSEPRG(5) = -BSEPRG(5);
            else
                % TODO - handle this situation better
                warning('Scor6Axis:NoData',...
                    'No joint position data has been received from the ScorBot 6-Axis Controller.');
                % Enable stream flag
                warning('Scor6Axis:NoData',...
                    'Enabling Stream Flag.');
                % Start telemetry data streaming
                obj.StartStreaming;
                BSEPRG = zeros(1,6);
            end
        end
        
        function BSEPRGposition = get.BSEPRGposition(obj)
            % Get joint positions (including gripper "joint")
            BSEPRGposition = obj.BSEPRG;
        end
        
        function BSEPRGvelocity = get.BSEPRGvelocity(obj)
            % Get joint velocities (including gripper "joint")
            
            % TODO - there must be a better method than using globals
            % Set global for callback function data sharing
            global Scor6AxisData
            
            % Initialize global variable if it does not already exist
            if isempty(Scor6AxisData)
                Scor6AxisData.Time = [];            % Run time in seconds
                Scor6AxisData.Mode = [];            % Position mode [Degrees, Radians, Counts]
                Scor6AxisData.BSEPRGposition = [];  % Joint configuration and gripper state
                Scor6AxisData.BSEPRGvelocity = [];  % Joint configuration and gripper state velocty
                Scor6AxisData.Status = [];          % Axis Status
                Scor6AxisData.Movement = [];        % Axis Movement
            end
                        
            % Check streaming
            obj.CheckStreaming;
            
            % Parse Data
            if ~isempty(Scor6AxisData.BSEPRGposition)
                BSEPRGvelocity = Scor6AxisData.BSEPRGvelocity(end,:);
                % Adjust for negative base value on controller
                BSEPRGvelocity(1) = -BSEPRGvelocity(1);
                BSEPRGvelocity(5) = -BSEPRGvelocity(5);
            else
                % TODO - handle this situation better
                warning('Scor6Axis:NoData',...
                    'No joint velocity data has been received from the ScorBot 6-Axis Controller.');
                % Enable stream flag
                warning('Scor6Axis:NoData',...
                    'Enabling Stream Flag.');
                % Start telemetry data streaming
                obj.StartStreaming;
                BSEPRGvelocity = zeros(1,6);
            end
        end
        
        % ----------------------------------------------------------------
        % Setters
        % ----------------------------------------------------------------
        % TODO - check inputs
        function set.dt(obj,dt)
            % Set time step between waypoints (seconds)
            % Adjust streaming rate
            msg = sprintf('>%.4f',dt);
            confirm = Scor6AxisSend(obj.Serial,msg);
            obj.dtWorkAround = dt;
        end
        
        function set.dtWorkAround(obj,dt)
            % Set the dt "workaround" and update global for callback
            % function
            global Scor6AxisTiming
            obj.dtWorkAround = dt;
            Scor6AxisTiming.dt = dt;
        end
        
        function set.VelocityTimeout(obj,VelocityTimeout)
            % Set velocity timeout (seconds) to be used with velocity
            % waypoints.
            obj.VelocityTimeout = VelocityTimeout;
        end
        
        function set.BSEPR(obj,BSEPR)
            % Adjust for negative base value on controller
            BSEPR(1) = -BSEPR(1);
            BSEPR(5) = -BSEPR(5);
            % Set joint positions
            msg = sprintf('{%.4f,%.4f,%.4f,%.4f,%.4f',BSEPR);
            confirm = Scor6AxisSend(obj.Serial,msg);
        end
        
        function set.BSEPRposition(obj,BSEPRposition)
            % Set joint positions
            obj.BSEPR = BSEPRposition;
        end
        
        function set.BSEPRvelocity(obj,BSEPRvelocity)
            % Set joint velocities
            BSEPRGvelocity = zeros(1,6);
            BSEPRGvelocity(1:5) = BSEPRvelocity;
            obj.BSEPRGvelocity = BSEPRGvelocity;
        end
        
        function set.XYZPR(obj,XYZPR)
            % Set end-effector position and orientation
            % TODO - Update ScorXYZPR2BSEPR to convert multiple waypoints
            obj.BSEPR = ScorXYZPR2BSEPR(XYZPR);
        end
        
        function set.XYZPRposition(obj,XYZPRposition)
            % Set end-effector position and orientation
            obj.XYZPR = XYZPRposition;
        end
        
        function set.XYZPRvelocity(obj,XYZPRvelocity)
            % Set end-effector position and orientation velocity
            XYZPRGvelocity = zeros(1,6);
            XYZPRGvelocity(1:5) = XYZPRvelocity;
            obj.XYZPRGvelocity = XYZPRGvelocity;
        end
        
        function set.Gripper(obj,Gripper)
            % Set gripper position (millimeters)
            % GripAngle = obj.BSEPRG(:,6);
            % TODO - Convert gripper angle into linear grip
            BSEPR = obj.BSEPR;
            BSEPRG = [BSEPR,Gripper];
            obj.BSEPRG = BSEPRG;
        end
        
        function set.GripperPosition(obj,GripperPosition)
            % Set gripper position (millimeters)
            obj.Gripper = GripperPosition;
        end
        
        function set.GripperVelocity(obj,GripperVelocity)
            % Set gripper velocity (millimeters per second)
            % GripAngVel = obj.BSEPRvelocity(6);
            % TODO - convert gripper angle velocity into linear velocity
            BSEPRGvelocity = zeros(1,6);
            BSEPRGvelocity(end) = GripperVelocity;
            obj.BSEPRGvelocity = BSEPRGvelocity;
        end
        
        function set.BSEPRG(obj,BSEPRG)
            % Adjust for negative base value on controller
            BSEPRG(1) = -BSEPRG(1);
            BSEPRG(5) = -BSEPRG(5);
            % Set joint positions (including gripper "joint")
            msg = sprintf('}%.4f,%.4f,%.4f,%.4f,%.4f,%.4f',BSEPRG);
            confirm = Scor6AxisSend(obj.Serial,msg);
        end
        
        function set.BSEPRGposition(obj,BSEPRGposition)
            % Set joint positions (including gripper "joint")
            obj.BSEPRG = BSEPRGposition;
        end
        
        function set.BSEPRGvelocity(obj,BSEPRGvelocity)
            % Set joint velocities (including gripper "joint")
            global Scor6AxisVelStatus
            
            % Adjust for negative base value on controller
            BSEPRGvelocity(1) = -BSEPRGvelocity(1);
            BSEPRGvelocity(5) = -BSEPRGvelocity(5);
            
            % Send message preamble
            msg = 'V';
            Scor6AxisVelStatus.Response = false;
            Scor6AxisVelStatus.Acknowledge = false;
            Scor6AxisVelStatus.Error = false;
            confirm = Scor6AxisSend(obj.Serial,msg);
            
            % Wait for message preamble response
            tic;
            while ~Scor6AxisVelStatus.Response
                if Scor6AxisVelStatus.Error
                    msg = 'V';
                    Scor6AxisVelStatus.Response = false;
                    Scor6AxisVelStatus.Acknowledge = false;
                    Scor6AxisVelStatus.Error = false;
                    confirm = Scor6AxisSend(obj.Serial,msg);
                end
                drawnow
            end
            toc;
            
            t = obj.VelocityTimeout;
            if numel([t,BSEPRGvelocity]) ~= 7
                error('Oh shit!');
            end
            msg = sprintf('%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f',[t,BSEPRGvelocity]);
            confirm = Scor6AxisSend(obj.Serial,msg);
            
            % Wait for message response
            tic;
            while ~Scor6AxisVelStatus.Acknowledge
                if Scor6AxisVelStatus.Error
                    msg = ' ';
                    Scor6AxisVelStatus.Response = false;
                    Scor6AxisVelStatus.Acknowledge = false;
                    Scor6AxisVelStatus.Error = false;
                    confirm = Scor6AxisSend(obj.Serial,msg);
                    break;
                end
                drawnow
            end
            toc;
            
        end
        
        function set.XYZPRG(obj,XYZPRG)
            % Set end-effector position and orientation (including gripper "joint")
            % TODO - Consider linear interpolation from XYZPR position to
            %        final XYZPR position and converting to BSEPR
            XYZPR = XYZPRG(:,1:5);
            BSEPR = ScorXYZPR2BSEPR(XYZPR);
            obj.BSEPRG = [BSEPR,XYZPRG(:,6)];
        end
        
        function set.XYZPRGposition(obj,XYZPRGposition)
            % Set end-effector position and orientation (including gripper "joint")
            obj.XYZPRG = XYZPRGposition;
        end
        
        function set.XYZPRGvelocity(obj,XYZPRGvelocity)
            % Set end-effector position and orientation velocity (including gripper "joint")
            % -> NOTE: This is only valid for instantaneous movements!
            J = ScorXYZPRJacobian(obj.BSEPR);
            % TODO - check for near-singular values
            BSEPRvelocity = transpose( (J^(-1))*transpose(XYZPRGvelocity(1:5)) );
            BSEPRGvelocity = [BSEPRvelocity,XYZPRGvelocity(6)];
            obj.BSEPRGvelocity = BSEPRGvelocity;
        end
        
        function set.dtBSEPRG(obj,dtBSEPRG)
            % Adjust for negative base value on controller
            dtBSEPRG(2) = -dtBSEPRG(2);
            dtBSEPRG(6) = -dtBSEPRG(6);
            
            % Move in a trapezoidal fashion
            msg = sprintf('!%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f',dtBSEPRG);
            confirm = Scor6AxisSend(obj.Serial,msg);
        end
    end
end