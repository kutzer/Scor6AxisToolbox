%% SCRIPT_Scor6AxisBoxTest
close all
clear all
clc

%% Define BSEPR waypoints
% BSEPR waypoints used to define ScorBot joint trajectory 
BSEPR_all(1,:) = [  0.00000  2.09925 -1.65843 -1.54994  0.00000];
BSEPR_all(2,:) = [ -0.38051  0.67512 -0.29071 -0.38441 -3.14159];
BSEPR_all(3,:) = [  0.38051  0.67512 -0.29071 -0.38441 -1.57080];
BSEPR_all(4,:) = [  0.38051  0.30449 -1.02168  0.71719  0.00000];
BSEPR_all(5,:) = [ -0.38051  0.30449 -1.02168  0.71719  1.57080];
BSEPR_all(6,:) = [ -0.38051  0.67512 -0.29071 -0.38441  3.14159];
BSEPR_all(7,:) = [  0.00000  2.09925 -1.65843 -1.54994  0.00000];

%% Load data
% Load joint data collected from designated BSEPR waypoints
% -> Joint trajectories were captured from an actual ScorBot ER-4u using
%    the Intelitek USB controller.
load('ScorBotBoxData.mat');

%% Plot joint trajectory info
% -> Joint trajectories were captured from an actual ScorBot ER-4u using
%    the Intelitek USB controller.
fig = figure('Name','ScorBotBoxData: Joint Trajectory');
axs = axes('Parent',fig);
xlabel('Time (s)');
ylabel('Joint Angle (rad)');
title('Joint Trajectories');
hold(axs,'on');
colors = 'rgbmk';
t = tBSEPR(:,1);
for j = 2:size(tBSEPR,2)
    theta = tBSEPR(:,j);
    plt(j-1) = plot(axs,t,theta,['-',colors(j-1)]);
end
legend(axs,'Base','Shoulder','Elbow','Pitch','Roll');

%% Initialize and home the robot
Scor6Init('COM3'); % you will need to update the COM port
Scor6Home;

%% Send waypoint commands
for wpnt = 1:size(BSEPR_all,1)
    BSEPR = BSEPR_all(wpnt,:); % get current waypoint
    Scor6SetBSEPR(BSEPR);      % set waypoint
    Scor6WaitForMove;          % send waypoint and wait for movement to finish
end