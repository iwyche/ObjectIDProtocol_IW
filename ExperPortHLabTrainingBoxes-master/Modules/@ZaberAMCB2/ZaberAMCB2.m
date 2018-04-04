function z = ZaberAMCB2(a)
%
% Arguments:
%
% -NONE: Zaber is intialized on serial port COM1.
% -Can be string giving serial port ID, eg, 'COM3'.
% 
%
% ZaberAMCB2 motor controller class constructor
% SAH AS, 06/14
%
% disp('function ZaberAMCB2 is called');%%%

if nargin==0
    z.sobj = serial('COM6','BaudRate',9600,'DataBits',8,'Parity','none','StopBits',1,...
        'InputBufferSize',64,'OutputBufferSize',64); % Input and output codes are all 6 bytes each
    set(z.sobj,'BytesAvailableFcnCount',6,'BytesAvailableFcnMode','byte')
    z.unit = 0;
    z = class(z,'ZaberAMCB2');
    
%     disp('ARG1 function ZaberAMCB2 is called');%%%

elseif isa(a,'char') %%%InputBufferSize and OutputBufferSize changed from 6 to 64 -AS 6/16/14
    z.sobj = serial(a,'BaudRate',9600,'DataBits',8,'Parity','none','StopBits',1,...
        'InputBufferSize',64,'OutputBufferSize',64); % Input and output codes are all 6 bytes each
    set(z.sobj,'BytesAvailableFcnCount',6,'BytesAvailableFcnMode','byte')
    z.unit = 0;
    z = class(z,'ZaberAMCB2');
    
%     disp(a);%%%
%     disp(z);%%%
%     disp(z.sobj);%%%
%     disp('ARG2 function ZaberAMCB2 is called');%%%

elseif isa(a,'ZaberAMCB2')
    z = a;    
    
%     disp('ARG3 function ZaberAMCB2 is called');%%%
end
% disp('object z.sobj created');%%%
%fprintf(z.sobj,'/01 1 move abs 140000');
