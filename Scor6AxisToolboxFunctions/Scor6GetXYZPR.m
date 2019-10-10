function XYZPR = Scor6GetXYZPR
% SCOR6GETXYZPR gets the current task configuration of ScorBot.
%   XYZPR = SCOR6GETXYZPR returns a 1x5 element array containing the task
%   configuration of the ScorBot (XYZ in millimeters, PR in radians).
%
%   M. Kutzer, 16Nov2018, USNA

global Scor6obj

XYZPR = Scor6obj.XYZPR;