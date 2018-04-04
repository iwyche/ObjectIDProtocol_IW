function z = FakeZaberAMCB2(a)
%
%
% Class constructor for Zaber AMCB2 motor controller emulator class.
% DHO, 4/07.
% Revised by AS, 6/5/14 for ZaberAMCB2
%

if nargin==0
    z.unit = 0;
    
    
    %--------------------------------------------------
    % Global variable to hold data normally kept globally by serial port
    % object and by Zaber AMCB2 motor controller.  These fields are not
    % in @ZaberAMCB2, and are used for emulation:
    %
%     global fake_serial_port_obj;
%     fake_serial_port_obj.status = 'closed'; % Or, 'open'.
    
    z.position = [0 0]; % Used to remember positions that normally are obtained by queries to motor controllers.
    %
    %--------------------------------------------------
    
    
    z = class(z,'FakeZaberAMCB2');
    
elseif isa(a,'FakeZaberAMCB2')
    z = a;
end
