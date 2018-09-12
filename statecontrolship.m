function [sys,x0,str,ts,simStateCompliance] = statecontrolship(t,x,u,flag)
switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes;

  %%%%%%%%%%%%%%%
  % Derivatives %
  %%%%%%%%%%%%%%%
  case 1,
    sys=mdlDerivatives(t,x,u);

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2,
    sys=mdlUpdate(t,x,u);

  %%%%%%%%%%%
  % Outputs %
  %%%%%%%%%%%
  case 3,
    sys=mdlOutputs(t,x,u);

  %%%%%%%%%%%%%%%%%%%%%%%
  % GetTimeOfNextVarHit %
  %%%%%%%%%%%%%%%%%%%%%%%
  case 4,
    sys=mdlGetTimeOfNextVarHit(t,x,u);

  %%%%%%%%%%%%%
  % Terminate %
  %%%%%%%%%%%%%
  case 9,
    sys=mdlTerminate(t,x,u);

  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
    DAStudio.error('Simulink:blocks:unhandledFlag', num2str(flag));

end


function [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes

%
% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array.
%
% Note that in this example, the values are hard coded.  This is not a
% recommended practice as the characteristics of the block are typically
% defined by the S-function parameters.
%
sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 2;
sizes.NumInputs      = 3;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);

%
% initialize the initial conditions
%
x0  = [];

%
% str is always an empty matrix
%
str = [];

%
% initialize the array of sample times
%
ts  = [-1 0];

% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'DisallowSimState' < Error out when saving or restoring the model sim state
simStateCompliance = 'UnknownSimState';

% end mdlInitializeSizes

%
%=============================================================================
% mdlDerivatives
% Return the derivatives for the continuous states.
%=============================================================================
%
function sys=mdlDerivatives(t,x,u)

sys = [];

% end mdlDerivatives

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,x,u)

sys = [];

% end mdlUpdate

%
%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
%
function sys=mdlOutputs(t,x,u)
%constants initialization
Psc_char1=5000;
Psc_char2=1000;
SOC_min=65; SOC_max=90; SOC_nom1=85;SOC_nom2=70;Pbat_min=1000;Pbat_max=80000; Pbat_opt=42000;

if(u(2)>SOC_max) 
    state=1;
end
if(u(2)>=SOC_nom2 && u(2)<=SOC_nom1) 
    state=2;
end
if(u(2)>SOC_nom1 && u(2)<=SOC_max) 
    state=u(3);
end
if(u(2)<SOC_min) 
    state=3;
end
if(u(2)>=SOC_min && u(2)<SOC_nom2) 
    state=u(3);
end

%state 1
if(state==1 && u(1)<Pbat_min)
            Pbat=0;

end
  



if(state==1 && u(1)>=Pbat_min && u(1)<=Pbat_max)
            Pbat=u(1);

end



if(state==1 && u(1)>=Pbat_max)
            Pbat=Pbat_max;

end

%state 2
if(state==2 && u(1)<Pbat_min)
            Pbat=Pbat_min+Psc_char2;

end


if(state==2 && u(1)>=Pbat_min && u(1)<Pbat_opt)
            Pbat=Pbat_opt;
end



if(state==2 && u(1)>=Pbat_opt && u(1)<Pbat_max)
            Pbat=u(1);

end



if(state==2 && u(1)>=Pbat_max)
            Pbat=Pbat_max;

end

%state 3
if(state==3 && u(1)<Pbat_min)
            Pbat=u(1)+Psc_char1;

end

if(state==3 &&  u(1)>=Pbat_min && u(1)<Pbat_opt)
            Pbat=max(u(1)+Psc_char1,Pbat_opt);

end



if(state==3 && u(1)>=Pbat_opt && u(1)<Pbat_max)
            Pbat=min(u(1)+Psc_char1,Pbat_max);
           
        
end



if(state==3 && u(1)>=Pbat_max)
            Pbat=Pbat_max;

end


sys = [Pbat state];

% end mdlOutputs

%
%=============================================================================
% mdlGetTimeOfNextVarHit
% Return the time of the next hit for this block.  Note that the result is
% absolute time.  Note that this function is only used when you specify a
% variable discrete-time sample time [-2 0] in the sample time array in
% mdlInitializeSizes.
%=============================================================================
%
function sys=mdlGetTimeOfNextVarHit(t,x,u)

sampleTime = 1;    %  Example, set the next hit to be one second later.
sys = t + sampleTime;

% end mdlGetTimeOfNextVarHit

%
%=============================================================================
% mdlTerminate
% Perform any end of simulation tasks.
%=============================================================================
%
function sys=mdlTerminate(t,x,u)

sys = [];

% end mdlTerminate
