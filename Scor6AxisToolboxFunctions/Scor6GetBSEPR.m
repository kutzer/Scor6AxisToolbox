function BSEPR = Scor6GetBSEPR
% SCOR6GETBSEPR gets the current joint configuration of ScorBot.
%   BSEPR = SCOR6GETBSEPR returns a 1x5 element array containing the joint
%   position of ScorBot in radians.
%
%   M. Kutzer, 16Nov2018, USNA

global Scor6obj

BSEPR = Scor6obj.BSEPR;