function Scor6Home
% SCOR6HOME homes the ScorBot 6-axis controller.
%
%   M. Kutzer, 15Nov2018, USNA

global Scor6obj

if isempty(Scor6obj)
    error('You need to run Scor6Init.');
end

Scor6obj.Home;
%Scor6WaitForOK;