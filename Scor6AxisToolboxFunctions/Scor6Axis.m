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
    %   dt              - Default time step between waypoints (seconds)
    %   BSEPR           - Joint positions
    %   BSEPRposition   - Joint positions
    %   BSEPRvelocity   - Joint velocities
    %   XYZPR           - End-effector position and orientation
    %   XYZPRposition   - End-effector position and orientation
    %   XYZPRvelocity   - End-effector position and orientation velocity
    %   Gripper         - Gripper position (millimeters)
    %   GripperPosition - Gripper position (millimeters)
    %   GripperVelocity - Gripper velocity (millimeters per second)
    %   BSEPRG          - Joint positions (including gripper "joint")
    %   BSEPRGposition  - Joint positions (including gripper "joint")
    %   BSEPRGvelocity  - Joint velocities (including gripper "joint")
    %
    %   D. Saiontz and M. Kutzer, 31Aug2016, USNA/SEAP

    % --------------------------------------------------------------------
    % General properties
    % --------------------------------------------------------------------
    properties (GetAccess='public', SetAccess='private')
        Serial        % Serial port object associated with the controller
        Status        % Controller and joint status
    end % end public/private properties
    
    properties (GetAccess='public', SetAccess='public')
        % --- Time ---
        dt              % Default time step between waypoints (seconds)
    end
    
    properties (Dependent, GetAccess='public', SetAccess='public')
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
            else
                % TODO - check for available COM ports
                % TODO - prompt the user for the COM port
                error('Scor6Axis:NoPort','COM port must be specified.');
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
            set(obj.Serial,'Parity','even');
            set(obj.Serial,'StopBits',1);
            set(obj.Serial,'Terminator','LF');
            set(obj.Serial,'BytesAvailableFcnMode','Terminator');
            set(obj.Serial,'BytesAvailableFcn',@Scor6AxisBytesAvailableFcn);
            % Open serial port
            fopen(obj.Serial);
            
            % Set default value(s)
            obj.dt = 0.05;
        end
        
        function delete(obj)
            % Move ScorBot to home position
            obj.GoHome;
            % Wait for movement
            obj.WaitForMove;
            % Close and delete serial object
            fclose(obj.Serial);
            delete(obj.Serial);
            delete(obj);
        end
    end % end Constructor/Destructor
    
    % --------------------------------------------------------------------
    % General methods
    % --------------------------------------------------------------------
    methods
        function Home(obj)
            % Home the ScorBot 6-Axis Controller
            % Run homing sequence
            % TODO - define command set for homing sequence
            warning('---> METHOD NOT COMPLETE');
        end
        
        function GoHome(obj)
            % Send ScorBot 6-Axis Controller to home position
            obj.BSEPR = obj.BSEPRhome;
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
            dt = obj.dt;
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
            XYZPR = obj.XYZPRG(1:5);
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
            % GripAngle = obj.BSEPRG(6);
            % TODO - Convert gripper angle into linear grip
            Gripper = 'METHOD NOT COMPLETE';       
        end
        
        function GripperPosition = get.GripperPosition(obj)
            % Get gripper position (millimeters)
            GripperPosition = obj.Gripper;
        end
        
        function GripperVelocity = get.GripperVelocity(obj)
            % Get gripper velocity (millimeters per second)
            % GripAngVel = obj.BSEPRvelocity(6);
            % TODO - convert gripper angle velocity into linear velocity
            GripperVelocity = 'METHOD NOT COMPLETE';
        end
        
        function BSEPRG = get.BSEPRG(obj)
            % Get joint positions (including gripper "joint")
            
            % TODO - there must be a better method than using globals
            % Set global for callback function data sharing
            global Scor6AxisData
            
            % Initialize global variable if it does not already exist
            if isempty(Scor6AxisData)
                Scor6AxisData.T = [];
                Scor6AxisData.P = [];
                Scor6AxisData.V = [];
                Scor6AxisData.S = [];
            end
            
            % Parse Data
            if ~isempty(Scor6AxisData.P)
                BSEPRG = Scor6AxisData.P(end,:);
            else
                % TODO - handle this situation better
                warning('Scor6Axis:NoData',...
                    'No joint position data has been received from the ScorBot 6-Axis Controller.');
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
                Scor6AxisData.T = [];
                Scor6AxisData.P = [];
                Scor6AxisData.V = [];
                Scor6AxisData.S = [];
            end
            
            % Parse Data
            if ~isempty(Scor6AxisData.V)
                BSEPRGvelocity = Scor6AxisData.V(end,:);
            else
                % TODO - handle this situation better
                warning('Scor6Axis:NoData',...
                    'No joint velocity data has been received from the ScorBot 6-Axis Controller.');
                BSEPRGvelocity = zeros(1,6);
            end
        end
        
        function XYZPRG = get.XYZPRG(obj)
            % Get end-effector position and orientation (including gripper "joint")
            BSEPRG = obj.BSEPRG;
            XYZPR = ScorBSEPR2XYZPR(BSEPRG(1:5));
            XYZPRG = [XYZPR, BSEPRG(:,6)];     
        end
        
        function XYZPRGposition = get.XYZPRGposition(obj)
            % Get end-effector position and orientation (including gripper "joint")
            XYZPRGposition = obj.XYZPRG;
        end
        
        function XYZPRGvelocity = get.XYZPRGvelocity(obj)
            % Get end-effector position and orientation velocity (including gripper "joint")
            % TODO - this method requires the ScorBotJacobian
            BSEPRGvelocity = obj.BSEPRGvelocity;
            J = ScorXYZPRJacobian(obj.BSEPR);
            XYZPRGvelocity(:,1:5) = transpose( J*transpose(BSEPRGvelocity(:,1:5)));
            XYZPRGvelocity(:,6) = BSEPRGvelocity(:,6);
        end
        
        % ----------------------------------------------------------------
        % Setters
        % ----------------------------------------------------------------
        % TODO - check inputs
        function obj = set.dt(obj,dt)
            % Set time step between waypoints (seconds)
            obj.dt = dt;
        end
        
        function obj = set.BSEPR(obj,BSEPR)
            % Set joint positions
            BSEPRG = BSEPR;                % include joint angles 
            BSEPRG(:,6) = obj.BSEPRG(:,6); % include current gripper state
            obj.BSEPRG = BSEPRG;           % set value
        end
        
        function obj = set.BSEPRposition(obj,BSEPRposition)
            % Set joint positions
            obj.BSEPR = BSEPRposition;
        end
        
        function obj = set.BSEPRvelocity(obj,BSEPRvelocity)
            % Set joint velocities
            BSEPRGvelocity = BSEPRvelocity;      % include joint velocities
            BSEPRGvelocity(:,6) = 0;             % assume zero gripper velocity
            obj.BSEPRGvelocity = BSEPRGvelocity; % set value
        end
        
        function obj = set.XYZPR(obj,XYZPR)
            % Set end-effector position and orientation
            % TODO - Update ScorXYZPR2BSEPR to convert multiple waypoints
            obj.BSEPR = ScorXYZPR2BSEPR(XYZPR);
        end
        
        function obj = set.XYZPRposition(obj,XYZPRposition)
            % Set end-effector position and orientation
            obj.XYZPR = XYZPRposition;
        end
        
        function obj = set.XYZPRvelocity(obj,XYZPRvelocity)
            % Set end-effector position and orientation velocity
            % TODO - error check for good BSEPR value
            J = ScorXYZPRJacobian(obj.BSEPR);
            % TODO - check Jacobian for singularities
            obj.BSEPRvelocity = transpose( minv(J)*transpose(XYZPRvelocity) )';
        end
        
        function obj = set.Gripper(obj,Gripper)
            % Set gripper position (millimeters)
            % GripAngle = obj.BSEPRG(:,6);
            % TODO - Convert gripper angle into linear grip
            warning('---> METHOD NOT COMPLETE');       
        end
        
        function obj = set.GripperPosition(obj,GripperPosition)
            % Set gripper position (millimeters)
            obj.Gripper = GripperPosition;
        end
        
        function obj = set.GripperVelocity(obj,GripperVelocity)
            % Set gripper velocity (millimeters per second)
            % GripAngVel = obj.BSEPRvelocity(6);
            % TODO - convert gripper angle velocity into linear velocity
            warning('---> METHOD NOT COMPLETE');
        end
        
        function obj = set.BSEPRG(obj,BSEPRG)
            % Set joint positions (including gripper "joint")
            if size(BSEPRG,1) > 1
                Scor6AxisSendPosition(obj.Serial, obj.dt, BSEPRG);
            else
                % TODO - Consider linear interpolation from current joint
                %        position to final joint position
                Scor6AxisSendPosition(obj.Serial, 0, BSEPRG);
            end
        end
        
        function obj = set.BSEPRGposition(obj,BSEPRGposition)
            % Set joint positions (including gripper "joint")
            obj.BSEPRG = BSEPRGposition;
        end
        
        function obj = set.BSEPRGvelocity(obj,BSEPRGvelocity)
            % Set joint velocities (including gripper "joint")
            if size(BSEPRGvelocity,1) > 1
                Scor6AxisSendVelocity(obj.Serial, obj.dt, BSEPRGvelocity);
            else
                Scor6AxisSendVelocity(obj.Serial, 0, BSEPRGvelocity);
            end
        end
        
        function obj = set.XYZPRG(obj,XYZPRG)
            % Set end-effector position and orientation (including gripper "joint")
            % TODO - Consider linear interpolation from XYZPR position to  
            %        final XYZPR position and converting to BSEPR
            XYZPR = XYZPRG(:,1:5);
            BSEPR = ScorXYZPR2BSEPR(XYZPR);
            obj.BSEPRG = [BSEPR,XYZPRG(:,6)];
        end
        
        function obj = set.XYZPRGposition(obj,XYZPRGposition)
            % Set end-effector position and orientation (including gripper "joint")
            obj.XYZPRG = XYZPRGposition;
        end
        
        function obj = set.XYZPRGvelocity(obj,XYZPRGvelocity)
            % Set end-effector position and orientation velocity (including gripper "joint")
            % TODO - error check for good BSEPR value
            J = ScorXYZPRJacobian(obj.BSEPR);
            % TODO - check Jacobian for singularities
            BSEPRvelocity = transpose( minv(J)*transpose(XYZPRGvelocity(:,1:5) ));
            obj.BSEPRGvelocity = [BSEPRvelocity,XYZPRGvelocity(:,6)];
        end
    end
end