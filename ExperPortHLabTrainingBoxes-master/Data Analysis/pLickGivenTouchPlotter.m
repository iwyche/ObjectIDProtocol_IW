%% pLickGivenTouchPlotter: calculates probability of a lick given a touch and plots go vs. no-go trials by mouse
%Created 2015-04-27 by J. Sy
%Modified 2015-04-28, added no-touch trials as separate plotted data

%% Section 1: Set variables

ARRAY_NAME = 'L5';
MOUSE_NAMES = {... 
    'ANM17702_';...
    'JF42400_1';...
    'ANM101105';...
    'ANM106213';...
    'ANM134333'}; %Note: use the first 9 characters of the mouse name within the trial array names
                  % regardless of whether those characters are still part
                  % of the name. -J. Sy
PATH = 'D:\L5';
                  
numSessions = numel(eval(ARRAY_NAME)); 
numMice = numel(MOUSE_NAMES);

%% Section 2: Loop through each session, check what mouse it is for, and generate probabilities for go or no-go per mouse

mouseLickPb = zeros(3, numMice); 
mouseLickPbNT = zeros(3, numMice);

mouseList{numSessions} = {[]}; 
for i = 1:numSessions %Creates cell containing the name of the mouse in each session
    s{1} = ARRAY_NAME;
    s{2} = '{';
    s{3} = num2str(i);
    s{4} = '}';
    arrayName = eval(strcat(s{1},s{2},s{3},s{4}));
    mouseName = arrayName.meta.trialArrayName(13:21);
    mouseList{i} = {mouseName};
end

for j = 1:numMice
    currentMouse = MOUSE_NAMES{j}; %Cycle through each mouse name
    cMouseIdx = find(strcmp([mouseList{:}], currentMouse)); %Find indices of sessions for selected mouse
    cIdxSize = numel(cMouseIdx);
    
    GoArray{cIdxSize} = [];
    NoGoArray{cIdxSize} = [];
    for k = 1:cIdxSize
        desiredSession = cMouseIdx(k);
        desiredSession = num2str(desiredSession);
        dS{1} = ARRAY_NAME;
        dS{2} = '{';
        dS{3} = desiredSession;
        dS{4} = '}';
        arrayName = eval(strcat(dS{1},dS{2},dS{3},dS{4}));
        GoMat = lickProbWTouch_v2(arrayName, 1); %Calls lickProbWTouch_v2, separate m file
        GoArray{k} = GoMat;
        NoGoMat = lickProbWTouch_v2(arrayName, 0);
        NoGoArray{k} = NoGoMat;
      
    end
    GoSum = sum(cat(3,GoArray{:}),3);
    GoProb = GoSum(1,:)./GoSum(2,:);
    mouseLickPb(1,j) = GoProb(2);
    mouseLickPbNT(1,j) = GoProb(1);
    
    NoGoSum = sum(cat(3,NoGoArray{:}),3);
    NoGoProb = NoGoSum(1,:)./NoGoSum(2,:);
    mouseLickPb(2,j) = NoGoProb(2);
    mouseLickPbNT(2,j) = NoGoProb(1);
end

    
%% Section 3: Plot results, print .eps files

x = mouseLickPb(2, :);
y = mouseLickPb(1, :); 

xNT = mouseLickPbNT(2, :);
yNT = mouseLickPbNT(1, :); 

figure(01)
hold on
set(gca, 'xlim', [-0.001 1.001])
set(gca, 'ylim', [-0.001 1.001])
% xbounds = xlim;
% set(gca,'XTick',xbounds(1):xbounds(2));

scatter(x,y, 'b')
scatter(xNT, yNT, 'r')

y2 = [0,0.5,1];
x2 = [0,0.5,1];
plot(x2,y2,'k');

hold off 
legend('W/ Touch', 'W/out Touch','NoDescrim Line')

%Print EPS files
% path = PATH;
% CELL_NUMBER = 'All';
% filename = [ARRAY_NAME '_' CELL_NUMBER];
% print(gcf,'-depsc', [path filesep filename])

