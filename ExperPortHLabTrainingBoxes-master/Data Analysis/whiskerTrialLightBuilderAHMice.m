%% Whisker Trial Light Builder example

d           = 'Z:\Data\Video\AHHD_005\AH0097\150402';  % Directory where .measurements files are stored
mouseName   = 'AH0097';                  
sessionName = '2015_04_02';
%% Include Files creation

cd(d)
filelist=dir([d '*.measurements'])

dirTrialNums=[];
trialNums=[2:372];  % enter which trial nums to process 
includef=cell(length(trialNums),1);

% Assign the trial numbers to existing .measurements files in the directory
% NOTE : This assumes that the .measurements files have a four digit number
% with leading zeros corresponding to trial number in string positions 29:32
% of the file name.  These index numbers may need to be changed to match up 
% to the numerical code of the trial number. 

for i=1:length(filelist);
    dirTrialNums(i)=str2num(filelist(i).name(29:32)); % extract out the trial number from each measurements file present in directory
end


% Create a cell array of filenames that correspond to the trial nums

for i=[1:length(trialNums)];
    includef{i}=filelist(find(dirTrialNums==trialNums(i))).name(1:end-13);
end
%%  Extraction of the whisker tracking data

%   DESCRIPTION:
%
%   Calls WhiskerTrial constructor on all .whiskers files in directory d, or all those specified
%   by argument 'include_list' if given,
%   excluding those in ignore_files. Saves WhiskerTrial objects, one per
%   .mat file, with same name as .whiskers file but with '_WT' appended
%   to name.  Existing files with the same names will be overwritten.% 
%  
%           'include_files': Optional cell array of strings giving file name prefixes
%                           of files in directory 'd' to process. Files will be processed
%                           in the order they are given within this cell array. *NOTE*: If
%                           this argument is not given, *all* .whiskers files in directory
%                           'd' will be processed.
%
%           'ignore_files': Optional cell array of strings giving file name prefixes
%                           (i.e., file names without the '.whiskers' extension) to ignore.
%                           Trumps 'include_files' argument.
%
%           'trial_nums': A vector of trial numbers to associate with each file, one element
%                         per trial, in the same order as elements of 'include_files'. This argument
%                         should be used only very carefully if this
%                         function is called without 'include_files' in order to process each
%                         .whiskers file in directory 'd', because the order the files are processed
%                         may or may not match the order of elements in 'trial_nums'.
%
%           'barRadius': The radius of the pole in pixel units. Default is 17.
%
%           'barPosOffset': Displacement from the center of the large pole to the 'contact point'
%                        (either on the edge of the large pole or small pole). Units of pixels.
%                         Default is [0 0] (no offset).
%
%           'faceSideInImage': One of: 'right','left','top','bottom'. Default is 'top'.
%
%           'protractionDirection':  One of: 'downward','upward','rightward','leftward'. Default is 'rightward'.
%
%           'imagePixelDimsXY': An 1x2 vector, e.g. [150 200].
%
%           'pxPerMm': The number of pixels per mm. Default is 22.68.
%
%           'framePeriodInSec': 0.002 for 500 Hz, 0.001 for 1000 Hz. Default is 0.002.
%
%           'mask': 2xN matrix giving x-values (in first row) and y-values (in second row)
%                   to fit a mask to for purposes of defining the arc-length origin. If a mask
%                   is given, arc-length zero occurs at the intersection of the mask and the whisker.
%                   If no mask is given, arc-length zero is the first tracked point on the whisker.
%                   Default is no mask.
%
%           'mouseName': Arbitrary string.
%
%           'sessionName': Arbitrary string.
%
%


Whisker.makeAllDirectory_WhiskerTrial(d,0,'mask', [75 100;250 75],...
    'trial_nums',trialNums,'include_files',includef,... 
    'barRadius',8,'faceSideInImage', 'left', 'framePeriodInSec',.001,...
    'imagePixelDimsXY',[360 440],'pxPerMm',32,'mouseName',mouseName,'sessionName',sessionName,'protractionDirection','downward')

%
%   DESCRIPTION:
%
%   Requires WhiskerTrial objects to be saved, as .mat files, in the
%   directory specified by argument 'd'.  These files are read in one at a time and
%   converted to WhiskerSignalTrial objects, which are then saved to disk in the same directory
%   as .mat files with a '_WST.mat' suffix/extension.
%
%   Processes all trajectory IDs within each WhiskerTrial.
%   
%   Whisker.makeAllDirectory_WhiskerSignalTrial description
% 
%   d: Directory path name as string.
%
%
%   Optional parameter/value pair arguments:
%
%           'include_files': Optional cell array of strings giving file name prefixes
%                           of files in directory 'd' to process. Files will be processed
%                           in the order they are given within this cell array. *NOTE*: If
%                           this argument is not given, *all* '_WT.mat' files in directory
%                           'd' will be processed.
%
%           'ignore_files': Optional cell array of strings giving file name prefixes
%                           (i.e., file names without the '_WT.mat' suffix/extension) to ignore.
%                           Trumps 'include_files' argument.
%
%           'polyRoiInPix':
%               Sets arc-length limits (in pixels) on which to perform secondary curve fitting.
%               This argument can be given in two forms:
%               (1) an 1x2 vector that gives the ROI for *all* whiskers; or
%               (2) a cell array where first element is a vector of trajectory IDs
%                   (of length N) and subsequent elements comprise N 1x2 vectors
%                   giving ROIs for the trajectory IDs specified in the first
%                   element (respectively).
%               Limits are inclusive.
%
%               PICK A CENTER POINT 2/3 of way to pole.  Width should be
%               about 1mm on each side of center point
%         
%
%           'barPosOffset': [xOffset yOffset].
%
%           'follicleExtrapDistInPix': Distance to extrapolate past the end of the tracked whisker
%                              in order to estimate follicle coordinates. If this argument is
%                              given, follicle position will be estimated. Default is not to estimate.
%                              Presently can only give one value, which will be used for all TIDs. Need to
%                              improve this.
%
%           'polyFitsMask': [xpoints; ypoints]. See Whisker.WhiskerSignalTrial polyFitsMask property.
%
%


Whisker.makeAllDirectory_WhiskerSignalTrial(d,'include_files',includef,'polyRoiInPix',[160-48 160+48],'follicleExtrapDistInPix',32); 


% 
%   DESCRIPTION:
%
%   Requires WhiskerSignalTrial objects to be saved, as .mat files, in the
%   directory specified by argument 'd'.  These files are read in one at a time and
%   converted to WhiskerTrialLite objects, which are then saved to disk in the same directory
%   as .mat files with a '_WL.mat' suffix/extension.
%
%   Processes all trajectory IDs within each WhiskerSignalTrial.   
%   
%   d: Directory path name as string.
%
%
%   Optional parameter/value pair arguments:
%
%           'include_files': Optional cell array of strings giving file name prefixes
%                           of files in directory 'd' to process. Files will be processed
%                           in the order they are given within this cell array. *NOTE*: If
%                           this argument is not given, *all* '_WST.mat' files in directory
%                           'd' will be processed.
%
%           'ignore_files': Optional cell array of strings giving file name prefixes
%                           (i.e., file names without the '_WST.mat' suffix/extension) to ignore.
%                           Trumps 'include_files' argument.
%
%           'r_in_mm': The arc-length along whisker at which to measure kappa. Units of mm. Defaults to 1 mm.
%
%           'calc_forces': Either true or false. Requires the pole position
%                   to be tracked (i.e., barPos property of WhiskerSignalTrial must
%                   not be empty). Default is false. If true, will calculate the following timeseries:
%                       -M0:  Moment at the follicle. In Newton-meters.
%                       -Faxial: Axial force into follice. In Newtons.
%                       -deltaKappa: Change from baseline curvature, at point specified by r_point. In 1/mm.
%                       -Fnorm: The force on the whisker normal to the contacted object. In Newtons.
%                       -thetaAtBase: The whisker angle nearest the follicle. In degrees.
%                       -thetaAtContact: The whisker angle nearest the point of contact. I.e., nearest the center of the pole. In degrees.
%                       -distanceToPoleCenter: The closest distance between the whisker and the center of the pole. In mm.
%                       -meanKappa: The mean of kappa over the entire secondary polynomial fitted ROI. In 1/mm.
%
%   The following optional parameter/value pair arguments are ignored if 'calc_forces'
%   is not true:
%
%           'whisker_radius_at_base': Given in microns. Defaults is 33.5 microns.
%
%           'whisker_length': Given in mm. Default is 16 mm.
%
%           'youngs_modulus': In Pa. Default is 5e9 Pa.
%
%           'baseline_time_or_kappa_value': Either (1) a 1x2 vector giving starting and stopping times (inclusive) for measuring baseline whisker curvature, in sec;
%                                            or (2) a scaler giving a baseline kappa value (measured by the user separately) to directly subtract from kappa
%                                             timeseries, in 1/mm. Default is [0 0.1].
% NOTES:
%   Still need make these arguments settable on a whisker-by-whisker (trajectory ID by trajectory ID) basis.
%
%


Whisker.makeAllDirectory_WhiskerTrialLiteI(d,'r_in_mm',5,'calc_forces',true,'whisker_radius_at_base', 36.5,'whisker_length', 18.43,'baseline_time_or_kappa_value',0.037);

% build the whisker trial lite arry from all WTL objects in the directory
% 'd'

wl = Whisker.WhiskerTrialLiteArray(d);

save([d mouseName sessionName '-WTLIA.mat'],'wl');

tid = 0; % Set trajectory ID to view
Whisker.view_WhiskerTrialLiteArray(wl,tid)  % Open the viewer