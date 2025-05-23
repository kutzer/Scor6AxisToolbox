%% SCRIPT_Scor6AxisBoxTest_DataExport
close all
clear all
clc

%% Define BSEPR waypoints
% BSEPR waypoints used to define ScorBot joint trajectory 
BSEPR_all(1,:) = [  0.00000  2.09925 -1.65843 -1.54994  0.00000];
BSEPR_all(2,:) = [ -0.38051  0.67512 -0.29071 -0.38441 -3.14159];
BSEPR_all(3,:) = [  0.38051  0.67512 -0.29071 -0.38441 -1.57080];
BSEPR_all(4,:) = [  0.38051  0.30449 -1.02168  0.71719  0.00000];
BSEPR_all(5,:) = [ -0.38051  0.30449 -1.02168  0.71719  1.57080];
BSEPR_all(6,:) = [ -0.38051  0.67512 -0.29071 -0.38441  3.14159];
BSEPR_all(7,:) = [  0.00000  2.09925 -1.65843 -1.54994  0.00000];

%% Define "perfect" joint space data set
colors = 'rgbmk';
for i = 2:size(BSEPR_all,1)
    q0 = BSEPR_all(i-1,:); % Initial waypoint
    qf = BSEPR_all(  i,:); % Final waypoint
    
    % Define s-curve movement between waypoints
    [pp{i-1},tf(i-1)] = Scor6AxisJointScurve(q0,qf,50); % assume 50% speed
    
    % Plot joints
    fig = figure;
    axs = axes('Parent',fig);
    hold(axs,'on');
    title(axs,sprintf('Waypoint %d to %d',i-1,i));
    t = linspace(0,tf(i-1),1000);
    Q = ppval(pp{i-1},t);
    for j = 1:5
        plt(i-1,j) = plot(axs,t,Q(j,:),colors(j));
    end
end

%% Combine polynomials with a fixed offset
ppALL = pp{1};
breakOffset = 1;
for i = 2:numel(pp)
    pp1 = ppALL;
    pp2 = pp{i};
    ppALL = appendpp(pp1,pp2,breakOffset);
end
t0 = ppALL.breaks(1);
tf =ppALL.breaks(end);

%% Plot combine result
% Plot joint position
fig = figure;
axs = axes('Parent',fig);
hold(axs,'on');
title(axs,'Combine Waypoints');
xlabel('Time (s)');
ylabel('Joint Position (rad)');
t = linspace(t0,tf,2000);
Q = ppval(ppALL,t);
for j = 1:5
    pltALL(j) = plot(axs,t,Q(j,:),colors(j));
end

% Plot joint velocity
dppALL = diffpp(ppALL);
fig = figure;
axs = axes('Parent',fig);
hold(axs,'on');
title(axs,'Combine Waypoints');
xlabel('Time (s)');
ylabel('Joint Velocity (rad/s)');
dQ = ppval(dppALL,t);
for j = 1:5
    pltALL(j) = plot(axs,t,dQ(j,:),colors(j));
end

%% Visualize
makeVideo = true;

if makeVideo
    vid = VideoWriter('ScorBotBoxData_sCurve.mp4','MPEG-4');
    open(vid)
end

% Initialize visualization
sim = ScorSimInit;
ScorSimPatch(sim);
set(sim.Figure,'Color',[1 1 1]);
title(sim.Axes,sprintf('Time = %6.3fs',0));

% Plot Waypoints
pltWPT = plot(sim.Axes,0,0,'*b');
pltBOX = plot(sim.Axes,0,0,':k');
for i = 1:size(BSEPR_all,1)
    XYZPR_all(i,:) = ScorBSEPR2XYZPR(BSEPR_all(i,:));
    set(pltWPT,'xData',XYZPR_all(:,1),'yData',XYZPR_all(:,2),'zData',XYZPR_all(:,3));
    set(pltBOX,'xData',XYZPR_all(:,1),'yData',XYZPR_all(:,2),'zData',XYZPR_all(:,3));
end

dt = 1/30;
t = t0:dt:tf;
Q = ppval(ppALL,t);
pltTRJ = plot(sim.Axes,0,0,'m','LineWidth',2);
for i = 1:size(Q,2)
    title(sim.Axes,sprintf('Time = %6.3fs',t(i)));
    ScorSimSetBSEPR(sim,Q(:,i).');
    
    XYZPR = ScorBSEPR2XYZPR(Q(:,i).');
    switch i
        case 1
            set(pltTRJ,'XData',XYZPR(1),'YData',XYZPR(2),'ZData',XYZPR(3));
        otherwise
            x = [get(pltTRJ,'XData'), XYZPR(1)];
            y = [get(pltTRJ,'YData'), XYZPR(2)];
            z = [get(pltTRJ,'ZData'), XYZPR(3)];
            set(pltTRJ,'XData',x,'YData',y,'ZData',z);
    end

    drawnow;
    if makeVideo
        frm = getframe(sim.Figure);
        writeVideo(vid,frm);
    end
end
if makeVideo
    close(vid);
    delete(vid);
end

%% Export .csv files
hzALL = 10:10:100;
for hz = hzALL
    % Create files
    fname = fullfile('ScorBotBoxData_sCurve',sprintf('BSEPR_Position_%dHz.csv',hz));
    fid_pos = fopen(fname,'w+');
    fname = fullfile('ScorBotBoxData_sCurve',sprintf('BSEPR_Velocity_%dHz.csv',hz));
    fid_vel = fopen(fname,'w+');
    % Write header information
    fprintf(fid_pos,'Time_(s), Base_Joint_Position_(rad), Shoulder_Joint_Position_(rad), Elbow_Joint_Position_(rad), Wrist_Pitch_Joint_Position_(rad), Wrist_Roll_Joint_Position_(rad)\r\n');
    fprintf(fid_vel,'Time_(s), Base_Joint_Velocity_(rad/s), Shoulder_Joint_Velocity_(rad/s), Elbow_Joint_Velocity_(rad/s), Wrist_Pitch_Joint_Velocity_(rad/s), Wrist_Roll_Joint_Velocity_(rad/s)\r\n');
    % Write file data
    t = t0:(1/hz):tf;           % Time data
    Q = ppval(ppALL,t);     % Joint position data
    dQ = ppval(dppALL,t);   % Joint velocity data
    for i = 1:numel(t)
        fprintf(fid_pos,'%.3f, %.5f, %.5f, %.5f, %.5f, %.5f\r\n',t(i),Q(:,i));
        fprintf(fid_vel,'%.3f, %.5f, %.5f, %.5f, %.5f, %.5f\r\n',t(i),dQ(:,i));
    end
    % Close and delete file IDs
    fclose(fid_pos);
    fclose(fid_vel);
end

return
    
%% Load data
% Load joint data collected from designated BSEPR waypoints
% -> Joint trajectories were captured from an actual ScorBot ER-4u using
%    the Intelitek USB controller.
load('ScorBotBoxData.mat');

%% Fit spline to data set
for i = 1:5
    ppJoint{i} = spline(tBSEPR(:,1),tBSEPR(:,i+1));
    dppJoint{i} = diffpp(ppJoint{i});
end

%% Resample data at fixed sample rate
dataRate = 10:10:100;
for j = 1:numel(dataRate)
    dt = 1/dataRate(j);
    t = 0:dt:max(tBSEPR(:,1));
    FixedSampleRateData.(sprintf('Time_%dHz',dataRate(j))) = t.';
    for i = 1:5
        FixedSampleRateData.(sprintf('JointPosition_%dHz',dataRate(j)))(:,i) = ppval(ppJoint{i},t);
        %FixedSampleRateData.(sprintf('JointVelocity_%dHz',dataRate(j)))(:,i) = ppval(dppJoint{i},t);
        FixedSampleRateData.(sprintf('JointVelocity_%dHz',dataRate(j)))(2:numel(t),i) = diff(FixedSampleRateData.(sprintf('JointPosition_%dHz',dataRate(j)))(:,i))./dt;
    end
end