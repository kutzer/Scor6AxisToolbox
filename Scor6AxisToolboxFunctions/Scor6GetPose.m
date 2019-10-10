function H = Scor6GetPose
% SCOR6GETPOSE gets the current end-effector pose of ScorBot.
%   H = SCOR6GETPOSE returns a 4x4 rigid body transformation representing
%   the position and orientation of ScorBot's end-effector relative to the
%   robot's base frame.
%
%   M. Kutzer, 25Mar2019, USNA

global Scor6obj

BSEPR = Scor6obj.BSEPR;

H = ScorBSEPR2Pose(BSEPR);