function Scor6SetXYZPR(varargin)
% SCOR6SETXYZPR sets a new XYZPR waypoint for the ScorBot.
%   SCOR6SETXYZPR(XYZPR) sets the new waypoint to the 5-element array
%   contained in XYZPR.
%
%   M. Kutzer 15Nov2018, USNA

global BSEPR_GO XYZPR_GO G_GO MoveType

%% Check inputs
narginchk(1,3);

XYZPR = varargin{1};
if nargin > 1
    warning('The "MoveType" is not currently implemented.');
end

%% Set parameters
MoveType = 'LinearJoint';
XYZPR_GO = XYZPR;
BSEPR_GO = [];
G_GO = [];
