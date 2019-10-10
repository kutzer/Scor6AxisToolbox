function [Y,T]=GenTraj(A,V,P,Tj,Ts)
%GenTraj Trajectory generation for point to point motion with velocity,
% acceleration, jerk and snap (second time derivative of acceleration)
% constraints
% Example:[Y,T]=GenTraj(A,V,P,Tj,Ts) returns the position, velocity
% and acceleration profiles for a snap controlled law from the specified
% constraints on maximum velocity V, maximum acceleration A, desired
% travelling distance P, Jerk time Tj and Snap time Ts.
% Y is a 3 row matrix containing the position, velocity and acceleration
% profile associated to the time vector T.
%
% If Tj and Ts are not given, Tj=Ts=0 is assumed. The resulting mouvement is
% acceleration limited. If Ts is not given, Ts=0 and P contains the points
% of the corresponding jerk limited law
%
% R. Béarée, ENSAM CER Lille, France
%
% 2007-06-14

%--------------------------------------------------------------------------

if nargin<3
    error('At Least Three Input Arguments are Required.')
end
if nargin==3
    type=0;
    Tj=0;
    Ts=0;
elseif nargin==4
    type=1;
    Ts=0;
elseif nargin==5
    type=2;
end

%Te=1e-4; % interpolation time
Te = 1e-2;

% Verification of the acceleration and velocity constraints
Ta=V/A; % Acceleration time
Tv=(P-A*Ta^2)/(V); % Constant velocity time
if P<=Ta*V % Triangular velocity profile
    Tv=0;Ta=sqrt(P/A);
end
Tf=2*Ta+Tv+Tj+Ts; % Mouvement time

% Elaboration of the limited acceleration profile
T=0:Te:Tf;
t(1)=0;t(2)=Ta;t(3)=Ta+Tv;t(4)=2*Ta+Tv;
s(1)=1;s(2)=-1;s(3)=-1;s(4)=1;
P=zeros(3,length(T));
% Ech=zeros(4);
for k=1:3
    u=zeros(1,k+1);u(1,1)=1;
    for i=1:4
        Ech = tf(1, u,'inputdelay',t(i));
        law(i,:)=impulse(s(i)*A*(Ech),T);
    end
    Y(k,:)=sum(law);
end

if (type==1 || type==2)
    % Average Filter for Jerk limitation
    a = 1;      % Filter coefficients
    b = (1/(Tj/Te))*ones(1,(Tj/Te)); % Filter duration equal to jerk time
    Y(3,:)= filter(b,a,Y(3,:));
    Y(2,1:length(T)-1)=diff(Y(3,:),1)/Te;
    Y(1,1:length(T)-1)=diff(Y(2,:),1)/Te;
    if type==2
        % Average Filter for snap limitation
        a = 1;      % Filter coefficients
        b = (1/(Ts/Te))*ones(1,(Ts/Te)); % Filter duration equal to snap time
        Y(3,:)= filter(b,a,Y(3,:));
        Y(2,1:length(T)-1)=diff(Y(3,:),1)/Te;
        Y(1,1:length(T)-1)=diff(Y(2,:),1)/Te;
    end
end

%%%%%%%%%%%%%%%

%{
figure;
sp(1)=subplot(3,1,1);plot(T,Y(3,:))
sp(2)=subplot(3,1,2);plot(T,Y(2,:))
sp(3)=subplot(3,1,3);plot(T,Y(1,:))
linkaxes(sp,'x');
ylabel(sp(1),'Position [m]');ylabel(sp(2),'Velocity [m/s]');ylabel(sp(3),'Acceleration [m/s^2]');xlabel(sp(3),'Time [s]')
%}
