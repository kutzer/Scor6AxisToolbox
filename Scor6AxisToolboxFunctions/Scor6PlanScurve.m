function [pp,tf] = Scor6PlanScurve(q0,q1,moveFlag)
% SCOR6PLANSCURVE plans an S-curve between values of two arrays. This
% assumes the movements start and stop from rest.
%   [pp,tf] = Scor6PlanScurve(q0,q1,moveFlag)
%
%       q0 - 1x5 element array defining start position (BSEPR or XYZPR)
%       q1 - 1x5 element array defining final position (BSEPR or XYZPR)
% moveFlag - String argument [{'BSEPR'}, 'XYZPR']
%
%   M. Kutzer, 14Nov2018, USNA

error('This function is incomplete.');

%% Set defaults
if nargin < 3
    moveType = 'BSEPR';
end

%% Define Jerk for movement type
switch lower(moveType)
    case bsepr
        jerk 
end