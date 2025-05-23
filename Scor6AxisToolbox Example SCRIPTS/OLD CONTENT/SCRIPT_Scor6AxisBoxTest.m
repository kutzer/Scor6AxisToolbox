%% SCRIPT_Scor6AxisBoxTest
close all
clear all
clc

%% Load data
load('ScorBotBoxData.mat');

%% Create object
obj = Scor6Axis('COM3'); % you will need to update the COM port

%% Send 5-second move (50 data points) 
% NOTE: This assumes the robot starts from a "home" position
obj.dt = 0.10;
obj.BSEPR = BSEPR_10Hz(1:50,:);

%% Execute full move (~35 seconds, ~350 data points)
% NOTE: This assumes the robot starts from a "home" position
obj.dt = 0.10;
obj.BSEPR = BSEPR_10Hz;