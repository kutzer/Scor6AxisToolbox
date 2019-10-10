function Scor6SetDeltaXYZPR(varargin)
% SCOR6SETDELTAXYZPR sets a relative task movement for the ScorBot.
%   SCOR6SETDELTAXYZPR(DeltaXYZPR) specifies the relative task movement
%   using a 1x5 array. 
%
%   M. Kutzer, 16Nov2018, USNA

global Scor6obj

%% Check inputs
narginchk(1,3);

DeltaXYZPR = varargin{1};
if nargin > 1
    warning('The "MoveType" is not currently implemented.');
end

%% Set parameters

XYZPR = Scor6obj.XYZPR + DeltaXYZPR;

Scor6SetXYZPR(XYZPR);