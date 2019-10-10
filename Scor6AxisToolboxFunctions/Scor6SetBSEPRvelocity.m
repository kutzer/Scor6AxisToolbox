function Scor6SetBSEPRvelocity(varargin)
% SCOR6SETBSEPRVELOCITY sets the BSEPR velocity for the ScorBot.
%   SCOR6SETBSEPRVELOCITY(dBSEPRdt) sets the BSEPR velocity
%   (radians/second) with a default 1 second velocity timeout value.
%
%   SCOR6SETBSEPRVELOCITY(dBSEPRdt,velTimeout) sets the BSEPR velocity
%   (radians/second)with a designated velocity timeout in seconds.
%
%   M. Kutzer, 25Mar2019, USNA

global Scor6obj

%% Check and parse inputs
narginchk(1,2);
velTimeout = 1.0; % Default velocity timeout
if nargin >= 1
    dBSEPRdt = varargin{1};
end

if nargin >= 2
    velTimeout = varargin{2};
end

%% Set velocity
% Update velocity timeout
velTimeoutOLD = Scor6obj.VelocityTimeout;
Scor6obj.VelocityTimeout = velTimeout;
% Execute movement
Scor6obj.BSEPRGvelocity = [reshape(dBSEPRdt,1,5),0];
% Reset velocity timeout
Scor6obj.VelocityTimeout = velTimeoutOLD;