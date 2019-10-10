function Scor6SetBSEPR(varargin)
% SCOR6SETBSEPR sets a new BSEPR waypoint for the ScorBot.
%   SCOR6SETBSEPR(BSEPR) sets the new waypoint to the 5-element array
%   contained in BSEPR.
%
%   M. Kutzer 15Nov2018, USNA

global BSEPR_GO XYZPR_GO G_GO MoveType

%% Check inputs
narginchk(1,3);

BSEPR = varargin{1};
if nargin > 1
    warning('The "MoveType" is not currently implemented.');
end

%% Set parameters
MoveType = 'LinearJoint';
XYZPR_GO = [];
BSEPR_GO = BSEPR;
G_GO = [];
