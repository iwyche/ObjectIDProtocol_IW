function [pos, pos2] = gui_position(varargin)

persistent itemwidth;
persistent itemheight;

DEFAULT_WIDTH = 200;
DEFAULT_HEIGHT = 20;

if isempty(itemwidth),  itemwidth = DEFAULT_WIDTH; end;
if isempty(itemheight), itemheight = DEFAULT_HEIGHT; end;

if nargin==0, error('Need at least one arg'); end;
if isstr(varargin{1}),
    switch varargin{1},
        case 'set_width',  itemwidth = varargin{2};
        case 'reset_width', itemwidth = DEFAULT_WIDTH;
        case 'reset_height', itemwidth = DEFAULT_HEIGHT;
        case 'set_height', itemheight = varargin{2};
        case 'get_default_width', pos = DEFAULT_WIDTH;
        case 'get_default_height', pos = DEFAULT_HEIGHT;            
        case 'addrows',
            pos = varargin{3}; pos2 = varargin{4} + varargin{2}*itemheight;
        case 'addcols',
            pos = varargin{3}+varargin{2}*(itemwidth*1.03); pos2 = varargin{4};
        otherwise,
            error(['Don''t know how to deal with ' varargin{1}]);
    end;
    return;
end;

if nargin > 1
    x = varargin{1}; y = varargin{2};

    pos = [x y itemwidth itemheight];

end;

return;
