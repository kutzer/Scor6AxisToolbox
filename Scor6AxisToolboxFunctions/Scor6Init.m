function Scor6Init(varargin)
% SCOR6INIT initializes the ScorBot 6-axis controller.
%   SCOR6INIT prompts the user to select the appropriate COM port for the
%   6-axis controller.
%
%   SCOR6INIT(com) uses the COM port specified in "com" (e.g. 'COM4').
%
%   M. Kutzer, 16Nov2018, USNA

global Scor6obj

if nargin < 1
    Scor6obj = Scor6Axis;
else
    Scor6obj = Scor6Axis(varargin{1});
end