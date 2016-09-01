function varargout = Scor6AxisVer
% SCOR6AXISVER displays the ScorBot 6-Axis Toolbox information.
%   SCOR6AXISVER displays the information to the command prompt.
%
%   A = SCOR6AXISVER returns in A the sorted struct array of version 
%   information for the ScorBot 6-Axis Toolbox.
%     The definition of struct A is:
%             A.Name      : toolbox name
%             A.Version   : toolbox version number
%             A.Release   : toolbox release string
%             A.Date      : toolbox release date
%
%   M. Kutzer 01Sept2016, USNA

% Updates


A.Name = 'ScorBot 6-Axis Toolbox';
A.Version = '1.0.0';
A.Release = '(R2015b)';
A.Date = '01-Sept-2016';
A.URLVer = 1;

msg{1} = sprintf('MATLAB %s Version: %s %s',A.Name, A.Version, A.Release);
msg{2} = sprintf('Release Date: %s',A.Date);

n = 0;
for i = 1:numel(msg)
    n = max( [n,numel(msg{i})] );
end

fprintf('%s\n',repmat('-',1,n));
for i = 1:numel(msg)
    fprintf('%s\n',msg{i});
end
fprintf('%s\n',repmat('-',1,n));

if nargout == 1
    varargout{1} = A;
end