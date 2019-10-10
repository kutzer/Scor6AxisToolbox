%% SCRIPT_Test_Scor6Toolbox

%%
Scor6Init('COM4');

%%
Scor6Home;

%% 
Scor6GoHome;

%% Test multiple velocity commands
for i = 1:3
    Scor6SetBSEPRvelocity([-0.2,-0.2,-0.2,-0.2,-0.2]);
    pause(0.5);
end
Scor6SetBSEPRvelocity(zeros(1,5));

%%
Scor6SetBSEPR([0,pi/2,-pi/2,0,0]);
%Scor6WaitForMove('s-curve');
%Scor6WaitForMove('s-curve velocity');
Scor6WaitForMove('fixed velocity');

%% 
Scor6SetBSEPR([0,0,0,0,0])
%Scor6WaitForMove;
%Scor6WaitForMove('s-curve velocity');
Scor6WaitForMove('fixed velocity');

%% 
Scor6SetBSEPR([0,0,pi/2,0,0])
%Scor6WaitForMove;
%Scor6WaitForMove('s-curve velocity');
Scor6WaitForMove('fixed velocity');

%% 
Scor6GoHome

%%
Scor6SetGripper('open');
Scor6WaitForMove;