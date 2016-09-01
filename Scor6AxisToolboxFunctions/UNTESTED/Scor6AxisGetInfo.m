function obj = Scor6AxisGetInfo(s)
%% OBJ = SCOR6AXISGETINFO(s) returns the most recent Time, Velocities,
%  Positions, and States from a Scor6AxisSim object
%
%  D. Saiontz, M. Kutzer, 15July2016, USNA/SEAP

global recentV;
global recentT;
global recentP;
global recentS;
obj.Time = recentT;
obj.Position = recentP;
obj.Velocity = recentV;
obj.State = recentS;

end

