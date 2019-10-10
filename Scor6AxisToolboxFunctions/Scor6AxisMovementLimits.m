function mLimits = Scor6AxisMovementLimits
% SCOR6AXISMOVEMENTLIMITS provides the movement limits for each axis of the
% ScorBot ER-4u manipulator to be used for the ScorBot 6-Axis controller.
%   mLimits = SCOR6AXISMOVEMENTLIMITS returns a structured array containing
%   the estimated position (radians), velocity (rad/sec), acceleration 
%   (rad/sec^2), and jerk (rad/sec^3) limits of each axis of the ScorBot 
%   ER-4u manipulator. "Joint 6" represents the gripper with units
%   specified in millimeters. 
%   
%   NOTE: These estimated values were initially generated using the 
%         Intelitek controller.
%
%   M. Kutzer, 15Nov2018, USNA

%% Joint 1
mLimits(1).Name         = 'Base';
mLimits(1).Position     = [-2.33466,3.068393];  % radians
mLimits(1).Velocity     = [ -0.60, 0.60];       % radians/second
mLimits(1).Acceleration = [ -0.40, 0.40];       % radians/second^2
mLimits(1).Jerk         = [ -2.00, 2.00];       % radians/second^3

%% Joint 2
mLimits(2).Name         = 'Shoulder';
mLimits(2).Position     = [-0.49356,2.204281];  % radians
mLimits(2).Velocity     = [ -0.70, 0.70];       % radians/second
mLimits(2).Acceleration = [ -1.00, 1.00];       % radians/second^2
mLimits(2).Jerk         = [ -2.00, 2.00];       % radians/second^3

%% Joint 3
% NOTE: Upper position limit was estimated using the simulation toolbox
mLimits(3).Name         = 'Elbow';
mLimits(3).Position     = [-2.45751,1.890000];  % radians
mLimits(3).Velocity     = [ -0.70, 0.70];       % radians/second
mLimits(3).Acceleration = [ -1.00, 1.00];       % radians/second^2
mLimits(3).Jerk         = [ -2.00, 2.00];       % radians/second^3

%% Joint 4
mLimits(4).Name         = 'Wrist Pitch';
mLimits(4).Position     = [-1.91367,2.340940];  % radians
mLimits(4).Velocity     = [ -2.50, 2.50];       % radians/second
mLimits(4).Acceleration = [ -4.00, 4.00];       % radians/second^2
mLimits(4).Jerk         = [-10.00,10.00];       % radians/second^3

%% Joint 5
mLimits(5).Name         = 'Wrist Roll';
mLimits(5).Position     = [-6.28319,6.283185];  % radians
mLimits(5).Velocity     = [ -2.50, 2.50];       % radians/second
mLimits(5).Acceleration = [ -4.00, 4.00];       % radians/second^2
mLimits(5).Jerk         = [-10.00,10.00];       % radians/second^3

%% Joint 6
% These values need to be estimated!
%{
mLimits(6).Name         = 'Gripper';
mLimits(6).Position     = [ 0,70];
mLimits(6).Velocity     = [a,b];
mLimits(6).Acceleration = [a,b];
mLimits(6).Jerk         = [a,b];
%}