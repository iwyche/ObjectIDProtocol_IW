function [xnodes,ynodes]=derivegalvo(type, xshift, yshift)

if nargin<3
    xshift=0;
    yshift=0;
end;
% some basic galvo params:

slope=1/2.8; % 1V change in galvo give 5 mm change in position
% positive Vx-> anterior x displacement
% positive Vy-> lateral y displacement

x0=-2.5;
y0=0;

Lx=1;% 1.5 mm square, centered on x0,y0
Ly=1; 

% we want:
% x1, y1: 

switch type
    case 'grid'% add 4 more nodes
        %         xnodes=[x0; x0+slope*Lx/2; x0+slope*Lx/2; x0-slope*Lx/2; x0-slope*Lx/2];
        %         ynodes=[y0; y0-slope*Ly/2; y0+slope*Ly/2; y0-slope*Ly/2; y0+slope*Ly/2];
        xnodes=[x0; x0+slope*Lx/4; x0+slope*Lx/2; x0-slope*Lx/4; x0-slope*Lx/2];
        ynodes=[y0; y0; y0; y0; y0];
    case 'shift'
        [xshift yshift]
        xnodes=x0+xshift*slope;
        ynodes=y0+yshift*slope;
        
    case 'grid_and_s1'
        xnodes=[x0; x0+slope*Lx/2; x0+slope*Lx/2; x0-slope*Lx/2; x0-slope*Lx/2; x0+xshift*slope];
        ynodes=[y0; y0-slope*Ly/2; y0+slope*Ly/2; y0-slope*Ly/2; y0+slope*Ly/2; y0+yshift*slope];
    case 'shiftgrid'
        x0=x0+xshift*slope;
        y0=y0+yshift*slope;
        xnodes=[x0; x0+slope*Lx/4; x0+slope*Lx/2; x0-slope*Lx/4; x0-slope*Lx/2];
        ynodes=[y0; y0; y0; y0; y0];

    case 'depblock'

        [xshift yshift]
        xnodes=x0+xshift*slope;
        ynodes=y0+yshift*slope;

    case 'collision'

        [xshift yshift]
        xnodes=x0+xshift*slope;
        ynodes=y0+yshift*slope;
        
    otherwise
        error('not the right type')
end