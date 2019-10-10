function Scor6SetGripper(grip)
% SCOR6SETGRIPPER sets the gripper to a desired value.
%   SCOR6SETGRIPPER(grip) sets the gripper to a designated value in
%   millimeters (0 is fully closed, 70 is fully open).
%
%   SCOR6SETGRIPPER('Open') opens the gripper fully.
%
%   SCOR6SETGRIPPER('Close') closes the gripper fully.
%
%   M. Kutzer, 16Nov2018, USNA

global BSEPR_GO XYZPR_GO G_GO MoveType

switch lower(grip)
    case 'open'
        grip = 70;
    case 'close'
        grip = 0;
    otherwise
        if grip < 0
            warning('Grip value must be between 0 and 70.');
            grip = 0;
        elseif grip > 70
            warning('Grip value must be between 0 and 70.');
            grip = 70;
        end
end

MoveType = 'LinearJoint';
XYZPR_GO = [];
BSEPR_GO = [];
G_GO = grip;