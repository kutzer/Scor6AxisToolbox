function Scor6SetDeltaBSEPR(varargin)
% SCOR6SETDELTABSEPR sets a relative joint movement for the ScorBot.
%   SCOR6SETDELTABSEPR(DeltaBSEPR) specifies the relative joints movement
%   using a 1x5 array. 
%
%   M. Kutzer, 16Nov2018, USNA

global Scor6obj

%% Check inputs
narginchk(1,3);

DeltaBSEPR = varargin{1};
if nargin > 1
    warning('The "MoveType" is not currently implemented.');
end

%% Set parameters

BSEPR = Scor6obj.BSEPR + DeltaBSEPR;

Scor6SetBSEPR(BSEPR);