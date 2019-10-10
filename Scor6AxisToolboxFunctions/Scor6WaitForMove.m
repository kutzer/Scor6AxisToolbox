function Scor6WaitForMove(varargin)
% SCOR6WAITFORMOVE executes a movement from the current configuration to a
% designated waypoint.
%   SCOR6WAITFORMOVE executes a move using a calculated fixed velocity for
%   each joint over a desired time interval.
%
%   SCOR6WAITFORMOVE('Fixed Velocity') executes a move using a calculated
%   fixed velocity for each joint over a desired time interval.
%
%   SCOR6WAITFORMOVE('S-Curve') executes a movement using an S-curve
%   profile.
%
%   SCOR6WAITFORMOVE('S-Curve Velocity') executes a movement using an
%   S-curve profile with velocity commands.
%
%   SCOR6WAITFORMOVE('Trapezoidal') executes a movement using an S-curve
%   profile.
%
%
%   NOTE: Linear movements in task space are not currently supported!
%
%   M. Kutzer, 15Nov2018, USNA

global Scor6obj BSEPR_GO XYZPR_GO G_GO pSpeed %MoveType

%% Set debug plots flag
plotsOn = false;

%% Set default values
if isempty(pSpeed)
    pSpeed = 100;
end

if nargin < 1
    mProfile = 'Fixed Velocity';
else
    switch lower(varargin{1})
        case 's-curve'
            % OK
            mProfile = varargin{1};
        case 'trapezoidal'
            % OK
            mProfile = varargin{1};
        case 's-curve velocity'
            % OK
            mProfile = varargin{1};
        case 'fixed velocity'
            % OK
            mProfile = varargin{1};
        otherwise
            error('Specified profile is not recognized.');
    end
end

%% Check if movement is specified
if isempty(BSEPR_GO) && isempty(XYZPR_GO) && isempty(G_GO)
    error('You need to specify a waypoint using Scor6Set* prior to running this function.');
end

%% Get current position
BSEPRG_NOW  = Scor6obj.BSEPRG;
BSEPR_NOW = BSEPRG_NOW(1:5);
G_NOW = BSEPRG_NOW(6);

%% Execute gripper movement (if applicable)
if ~isempty(G_GO)
    switch lower(mProfile)
        case 'fixed velocity'
            % Define BSEPRG value
            BSEPRG_GO = [reshape(BSEPR_NOW,1,[]),G_GO];
            % Define movement time
            tf = abs(G_NOW-G_GO)/12;
            % Define movement speed
            dGdt = (G_GO - G_NOW)/tf;
            % Update velocity timeout
            velTimeout = Scor6obj.VelocityTimeout;
            Scor6obj.VelocityTimeout = tf;
            % Execute movement
            Scor6obj.BSEPRGvelocity = [0,0,0,0,0,dGdt];
            
            % Check for stop condition
            t_tic = tic;
            pause(tf/10);
            stopFlag = 0;
            while true
                % Check if the gripper stopped moving
                BSEPRGvelocity = Scor6obj.BSEPRGvelocity;
                %disp(abs(BSEPRGvelocity(6)));
                if abs(BSEPRGvelocity(6)) < 0.01
                    stopFlag = stopFlag+1;
                end
                % Check number of stop instances and stop gripper
                if stopFlag == 3
                    Scor6obj.BSEPRGvelocity = zeros(1,6);
                    break
                end
                % Stop gripper if the movement is complete
                if toc(t_tic) >= tf
                    Scor6obj.BSEPRGvelocity = zeros(1,6);
                    break
                end
            end
            
            % Reset velocity timeout
            Scor6obj.VelocityTimeout = velTimeout;
            % Reset value
            G_GO = [];
        otherwise
            % Define BSEPRG value
            BSEPRG_GO = [reshape(BSEPR_NOW,1,[]),G_GO];
            % Define movement time
            tf = abs(G_NOW-G_GO)/70;
            % Execute movement
            Scor6obj.dtBSEPRG = [tf,BSEPRG_GO];
            Scor6WaitForOK;
            % Reset value
            G_GO = [];
    end
    return
end

%% Execute waypoint movement

% Convert XYZPR to joint angles
if isempty(BSEPR_GO)
    BSEPR_GO = ScorXYZPR2BSEPR(XYZPR_GO);
end

% Set initial and final waypoint
q0 = BSEPR_NOW;
qf = BSEPR_GO;
% Plan s-curve
[pp,tf] = Scor6AxisJointScurve(q0,qf,pSpeed);
dpp = diffpp(pp);

switch lower(mProfile)
    case 'trapezoidal'
        % Use embedded trapezoidal move function
        Scor6obj.dtBSEPRG = [tf,reshape(BSEPR_GO,1,[]),BSEPRG_NOW(6)];
        Scor6WaitForOK;
    case 's-curve'
        % Run movement
        %Scor6obj.dt = 0.08;
        dt = Scor6obj.dt;
        t = [0:dt:tf,tf];
        q = ppval(pp,t);
        
        % Debug
        if plotsOn
            fig = figure;
            axs = axes('Parent',fig);
            set(axs,'NextPlot','add');
            xlabel(axs,'Time (s)');
            ylabel(axs,'Joint Angle (rad)');
            
            colors = 'rgbmk';
            for i = 1:size(q,1)
                plt_posDes(i) = plot(axs,t,q(i,:),[':',colors(i)]);
                plt_posAct(i) = plot(axs,t(1),q0(i),['-',colors(i)]);
            end
        end
        
        % Send messages
        for i = 1:size(q,2)
            % Debug
            if plotsOn
                % Current joint position
                q_now = reshape(Scor6obj.BSEPR,1,5);
                
                for j = 1:numel(plt_posAct)
                    Q = get(plt_posAct(j),'YData');
                    Q(end+1) = q_now(j);
                    set(plt_posAct(j),'XData',t(1:numel(Q)),'YData',Q);
                end
            end
            
            % Use BSEPR
            Scor6obj.BSEPR = q(:,i);
            pause(dt);
            %Scor6WaitForOK;
        end
    case 's-curve velocity'
        % Run movement
        %Scor6obj.dt = 0.05;
        dt = Scor6obj.dt;
        %dt = 0.01;
        t = [0:dt:tf,tf];
        q = ppval(pp,t);
        dqdt = ppval(dpp,t);
        
        % Debug
        if plotsOn
            fig = figure;
            axs(1) = subplot(1,2,1,'Parent',fig);
            axs(2) = subplot(1,2,2,'Parent',fig);
            set(axs,'NextPlot','add');
            xlabel(axs(1),'Time (s)');
            ylabel(axs(1),'Joint Angle (rad)');
            xlabel(axs(2),'Time (s)');
            ylabel(axs(2),'Joint Velocity (rad/s)');
            
            colors = 'rgbmk';
            for i = 1:size(q,1)
                plt_posDes(i) = plot(axs(1),t,q(i,:),[':',colors(i)]);
                plt_posAct(i) = plot(axs(1),t(1),q0(i),['-',colors(i)]);
                
                plt_velDes(i) = plot(axs(2),t,dqdt(i,:),[':',colors(i)]);
                plt_velAct(i) = plot(axs(2),t(1),0,['-',colors(i)]);
            end
        end
        
        % Update velocity timeout
        velTimeout = Scor6obj.VelocityTimeout;
        Scor6obj.VelocityTimeout = 10*dt;
        
        % Send messages
        for i = 1:size(q,2)
            % Position difference "Gain"
            k = 1;
            % Current joint position
            q_now = reshape(Scor6obj.BSEPR,1,5);
            % Desired joint position
            q_des = reshape(q(:,i),1,5);
            % Current joint velocity
            dqdt_now = reshape(Scor6obj.BSEPRvelocity,1,5);
            
            % Debug
            if plotsOn
                for j = 1:numel(plt_posAct)
                    Q = get(plt_posAct(j),'YData');
                    dQ = get(plt_velAct(j),'YData');
                    Q(end+1) = q_now(j);
                    dQ(end+1) = dqdt_now(j);
                    
                    fprintf('\n\n');
                    set(plt_posAct(j),'XData',t(1:numel(Q)),'YData',Q);
                    set(plt_velAct(j),'XData',t(1:numel(dQ)),'YData',dQ);
                end
            end
            
            deltaq = q_des - q_now;
            Scor6obj.BSEPRvelocity = reshape(dqdt(:,i),1,5) + k*deltaq;
            
            pause(dt);
        end
        % Stop the robot
        Scor6obj.BSEPRvelocity = zeros(1,5);
        
        % Reset velocity timeout
        Scor6obj.VelocityTimeout = velTimeout;
        
    case 'fixed velocity'
        fvOption = 2;
        
        switch fvOption
            case 1
                % Define Delta BSEPRG value
                dBSEPR = BSEPR_GO - BSEPR_NOW;
                % Get Movement Limits
                mLimits = Scor6AxisMovementLimits;
                % Find Delta t for each joint
                speedFraction = 0.5;    % Limit max speed
                for i = 1:numel(dBSEPR)
                    dq = dBSEPR(i);
                    if dBSEPR(i) < 1
                        dqdt = speedFraction*mLimits(i).Velocity(1);
                    else
                        dqdt = speedFraction*mLimits(i).Velocity(2);
                    end
                    dt(i) = dq/dqdt;
                end
                % Define movement time
                tf = max(dt);   % Choose the longest movement
                % Apply threshold to refine movement
                if tf < 0.75
                    tf = 0.75;
                end
                
                % Define movement speed
                dBSEPRdt = dBSEPR/tf;
                % Update velocity timeout
                velTimeout = Scor6obj.VelocityTimeout;
                Scor6obj.VelocityTimeout = tf;
                % Execute movement
                Scor6obj.BSEPRvelocity = dBSEPRdt;
                pause(tf);
            case 2
                % Get Initial Delta
                dBSEPR = BSEPR_GO - BSEPR_NOW;
                while max(abs(dBSEPR)) > deg2rad(3)
                    % Update BSEPR
                    BSEPRG_NOW  = Scor6obj.BSEPRG;
                    BSEPR_NOW = BSEPRG_NOW(1:5);
                    % Define Delta BSEPRG value
                    dBSEPR = BSEPR_GO - BSEPR_NOW;
                    % Get Movement Limits
                    mLimits = Scor6AxisMovementLimits;
                    % Find Delta t for each joint
                    speedFraction = 0.5;    % Limit max speed
                    for i = 1:numel(dBSEPR)
                        dq = dBSEPR(i);
                        if dBSEPR(i) < 1
                            dqdt = speedFraction*mLimits(i).Velocity(1);
                        else
                            dqdt = speedFraction*mLimits(i).Velocity(2);
                        end
                        dt(i) = dq/dqdt;
                    end
                    % Define movement time
                    tf = max(dt);   % Choose the longest movement
                    % Apply threshold to refine movement
                    if tf < 0.75
                        tf = 0.75;
                    end
                    
                    % Define movement speed
                    dBSEPRdt = dBSEPR/tf;
                    % Update velocity timeout
                    velTimeout = Scor6obj.VelocityTimeout;
                    Scor6obj.VelocityTimeout = tf;
                    % Execute movement
                    Scor6obj.BSEPRvelocity = dBSEPRdt;
                    pause(tf);
                    % Wait for velocity to be zero
                    while norm(Scor6obj.BSEPRvelocity) > 0
                        pause(0.5);
                    end
                    % Wait for BSEPR to settle
                    %delta_BSEPR_now = ones(1,5);
                    %while norm(delta_BSEPR_now) > deg2rad(1)
                    %    delta_BSEPR_now = Scor6obj.BSEPR;
                    %    pause( 2*Scor6obj.dt );
                    %    delta_BSEPR_now = delta_BSEPR_now - Scor6obj.BSEPR;
                    %end
                    % Pause some random amount of time?
                    %pause(5);
                end
        end
        % Reset velocity timeout
        Scor6obj.VelocityTimeout = velTimeout;
        % Reset value
        G_GO = [];
end

% Reset values
BSEPR_GO = [];
XYZPR_GO = [];