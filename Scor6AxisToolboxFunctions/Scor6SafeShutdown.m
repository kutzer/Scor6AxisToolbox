function Scor6SafeShutdown
% SCOR6SAFESHUTDOWN returns the ScorBot to the home position and closes the
% connection with the robot controller.
%
%   M. Kutzer, 26Mar2019, USNA

global Scor6obj

Scor6obj.delete;

Scor6obj = [];

clear Scor6obj
