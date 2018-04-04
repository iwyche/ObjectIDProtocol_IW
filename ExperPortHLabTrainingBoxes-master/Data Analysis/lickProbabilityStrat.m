%% lickProbabilityStrat
%Set various named variables to create calculation of the mouse's
%probability of licking in various situations
%Created 2015-04-28 by J. Sy

%% Set variable list

%P(Engagement)
pEngaged = 0.8;
pNotEngaged = 0.2;

%P(Touch|Engagement)
pTouchEngagedGo = 0.75;
pNoTouchEngagedGo = 0.25;
pTouchEngagedNoGo = 0.5; 
pNoTouchEngagedNoGo = 0.5;
%P(Touch|No Engagement)
pTouchNotEngagedGo = 0.2;
pNoTouchNotEngagedGo = 0.8;
pTouchNotEngagedNoGo = 0;
pNoTouchNotEngagedNoGo = 1;

%P(Lick)
%P(Lick|Engagement & Touch)
pLickTouchEngagedGo = 1;
pLickNoTouchEngagedGo = 0.2;
pLickTouchEngagedNoGo = 0.5;
pLickNoTouchEngagedNoGo = 0.2;
%P(Lick|No Engagement & Touch)
pLickTouchNotEngagedGo = 0.4; 
pLickNoTouchNotEngagedGo = 0.4;
pLickTouchNotEngagedNoGo = 0.4;
pLickNoTouchNotEngagedNoGo = 0.4;

%% Calculator: (calculates total lick Prob with formulas)

%P(Lick|Touch, Go Trial)
pLickTouchGo = ((pEngaged*pTouchEngagedGo*pLickTouchEngagedGo)+(pNotEngaged*pTouchNotEngagedGo*pLickTouchNotEngagedGo))...
    /((pEngaged*pTouchEngagedGo)+(pNotEngaged*pTouchNotEngagedGo)) 
%P(Lick|Touch, No-Go Trial)
pLickTouchNogo = ((pEngaged*pTouchEngagedNoGo*pLickTouchEngagedNoGo)+(pNotEngaged*pTouchNotEngagedNoGo*pLickTouchNotEngagedNoGo))...
    /((pEngaged*pTouchEngagedNoGo)+(pNotEngaged*pTouchNotEngagedNoGo))
%P(Lick|NoTouch, Go Trial)
pLickNoTouchGo = ((pEngaged*pNoTouchEngagedGo*pLickNoTouchEngagedGo)+(pNotEngaged*pNoTouchNotEngagedGo*pLickNoTouchNotEngagedGo))...
    /((pEngaged*pNoTouchEngagedGo)+(pNotEngaged*pNoTouchNotEngagedGo))
%P(Lick|NoTouch, No-go Trial)
pLickNoTouchNoGo = ((pEngaged*pNoTouchEngagedNoGo*pLickNoTouchEngagedNoGo)+(pNotEngaged*pNoTouchNotEngagedNoGo*pLickNoTouchNotEngagedNoGo))...
    /((pEngaged*pNoTouchEngagedNoGo)+(pNotEngaged*pNoTouchNotEngagedNoGo))