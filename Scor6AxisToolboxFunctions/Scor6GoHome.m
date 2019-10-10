function Scor6GoHome
% SCOR6GOHOME returns the ScorBot to the home configuration.
%
%   M. Kutzer, 14Nov2018, USNA

global Scor6obj

Scor6obj.GoHome;
Scor6WaitForOK;