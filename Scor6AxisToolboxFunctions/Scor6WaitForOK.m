function varargout = Scor6WaitForOK
% SCORWAITFOROK waits for the "OK" message from the ScorBot 6-axis
% controller.
%
%   M. Kutzer, 16Nov2018, USNA

global Scor6AxisIsOK

if nargout == 0
    errorFlag = true;
else
    errorFlag = false;
end

%% Initialize return values
confirm = true;
msg = [];

t0 = tic;
Scor6AxisIsOK = 0;
while Scor6AxisIsOK == 0
    % Wait for response
    t = toc(t0);
    if t > 45
        if errorFlag
            warning('Wait timeout reached.');
        else
            fprintf(2,'Scor6WaitForOK: Wait timeout reached.\n');
            confirm = false;
            msg = 'Timeout';
            if nargout > 0
                varargout{1} = confirm;
            end
            if nargout > 1
                varargout{2} = msg;
            end
        end
        break
    end
end

if Scor6AxisIsOK == -1
    if errorFlag
        error('Controller Restart!!! \n -> Re-home robot!\n');
    else
        fprintf(2,'Scor6WaitForOK: Controller Restart!!! \n -> Re-home robot!\n');
        confirm = false;
        msg = 'Restart';
    end
end

if Scor6AxisIsOK == -2
    if errorFlag
        error('NAK Error!!! \n -> Re-home robot!\n');
    else
        fprintf(2,'Scor6WaitForOK: NAK Error!!! \n -> Re-home robot!\n');
        confirm = false;
        msg = 'NAK';
    end
end


if nargout > 0
    varargout{1} = confirm;
end
if nargout > 1
    varargout{2} = msg;
end