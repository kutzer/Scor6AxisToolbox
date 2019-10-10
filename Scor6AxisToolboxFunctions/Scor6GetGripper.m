function grip = Scor6GetGripper
% SCOR6GETGRIPPER gets the current gripper value for the ScorBot.
%   grip = SCOR6GETGRIPPER returns a scalar value representing the gripper
%   state in millimeters where 0 represents a fully closed gripper, and 70
%   represents a fully open gripper.
%
%   M. Kutzer, 19Nov2018, USNA

global Scor6obj

BSEPRG = Scor6obj.BSEPRG;
grip = BSEPRG(6);