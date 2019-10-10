function [pp,tf] = Scor6AxisJointScurve(q0,qf,pSpeed)
% SCOR6AXISJOINTSCURVE generates an S-curve trajectory between two joint
% configurations, moving each joint linearly relative to one-another in 
% joint space.
%   [pp,tf] = SCOR6AXISJOINTSCURVE(q0,qf,pSpeed) generates an S-curve 
%   between q0 and qf given a percent of the maximum allowable speed (100
%   is maximum speed). This function returns a piecewise polynomial, and
%   the time duration of the movement (in seconds).
%
%   M. Kutzer, 15Nov2018, USNA

%% Check inputs
narginchk(2,3);

if nargin < 3
    pSpeed = 100;
end

%% Make sure waypoints are defined as column vectors
q0 = reshape(q0,[],1);
qf = reshape(qf,[],1); 

%% Get movement limits
mLimits = Scor6AxisMovementLimits;

%% Generate fastest trajectory for each individual joint
for i = 1:5
    x0 = q0(i); % Initial position
    xf = qf(i); % Final poosition
    
    vLim = min( abs(mLimits(i).Velocity) ) * pSpeed/100;
    aLim = min( abs(mLimits(i).Acceleration) );
    jLim = min( abs(mLimits(i).Jerk) );
    
    % "Jerk time"
    tj = aLim/jLim;

    % Genereate trajectory
    [Y,t]=GenTraj(aLim,vLim,abs(xf-x0),tj);
    t_max(i) = max(t);
    % Define x
    x{i} = sign(xf-x0)*Y(3,:) + repmat(x0,size(Y(3,:)));
end

% Define time index to stretch trajectories
tf = max(t_max);
t = linspace(0,tf,numel(t));

% Calculate intermittent fits
for i = 1:numel(x)
    t_tmp = linspace(0,tf,numel(x{i}));
    x_all(i,:) = spline(t_tmp,x{i},t);
end

% Fit final spline
pp = spline(t,x_all);

%% WORK IN PROGRESS
return
%{
%% Fit straight line path between waypoints
% q = A*[s; 1]
% s \in [0,1]
s0 = 0;
sf = 1;
A = [q0,qf] * [s0,sf; 1,1]^(-1);

%% Generate fastest trajectory for each individual joint
for i = 1:5
    x0 = q0(i); % Initial position
    xf = qf(i); % Final poosition
    
    vLim = mLimits(i).Velocity;
    aLim = mLimits(i).Acceleration;
    jLim = mLimits(i).Jerk;
    
    % Calculate time to get to peak acceleration/deceleration
    tj_pos = aLim(2)/jLim(2);
    tj_neg = aLim(1)/jLim(1);
    
    % Calculate time to get to maximum and minimum velocity
    %ta_pos = 
    %ta_neg = 
    
    % Apply maximum velocity, acceleration, and jerk values
    switch sign( A(i,1) )
        case -1
            % Joint moving in the negative direction
            
            % -> Jerk
            b_pos(1) = jLim(1)/(6*A(i,1));
            tj_pos = aLim(1)/(6*A(i,1)*b_pos(1));
            b_lin(1) = 0;
            b_neg(1) = jLim(2)/(6*A(i,1));

            % -> Acceleration
            b_pos(2) = 0;   % Initial acceleration is 0
            t_pos(1) = (aLim(1) - 2*A(i,1)*b_pos(2))/(6*A(i,1)*b_pos(1));
            b_lin(2) = 0;
            b_neg(2) = 0;   % Initial deceleration is 0
        case 1
            % Joint moving in the positive direction
            % -> Jerk
            b_pos(1) = jLim(2)/(6*A(i,1));
            b_lin(1) = 0;
            b_neg(1) = jLim(1)/(6*A(i,1));
            % -> Acceleration
            b_pos(2) = 0;   % Initial acceleration is 0
            b_lin(2) = 0;
            b_neg(2) = 0;   % Initial deceleration is 0
        otherwise
            % Joint is not moving
            % -> Jerk
            b_pos(1) = 0;
            b_lin(1) = 0;
            b_neg(1) = 0;
            % -> Acceleration
            b_pos(2) = 0;   % Initial acceleration is 0
            b_lin(2) = 0;
            b_neg(2) = 0;   % Initial deceleration is 0
    end
end

 %}