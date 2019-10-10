function Scor6SetCurrents
% SCOR6SETCURRENTS updates the stall current values used by the controller
% to detect faults. This will trigger several small, jerky movements.
%
%   M. Kutzer, 29Mar2019, USNA

global Scor6obj

Scor6obj.UpdateStallCurrents;
