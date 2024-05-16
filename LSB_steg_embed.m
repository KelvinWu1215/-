function s = LSB_steg_embed(c, p, k)
% s = LSB_steg_embed(c, p, k)
% This function hides a plaintext "p" in the LSB bitplane of a cover 
% image "c".
% A stego-key "k" is used to select a random path. If not given or [], the
% sequential path will be used.
% If "k" does not exist or is empty, a sequential path will be used.

% The following assignment is to ensure that the output is not
% invalid when the function returns early.
s = [];

% Check the validity of input arguments.
if nargin<2
    disp('At least two input arguments are required!');
    return;
end

% Pre-process the plaintext to be a bit sequence.
switch(class(p))
    case 'uint8'
        p = num2bit(p, 8);
    case {'int8', 'char'}
        p = num2bit(uint8(p), 8);
    case 'double'
        disp('For double input, we assume they are 8-bit pixel values.');
        p = num2bit(uint8(p), 8);
    case {'uint16', 'int16'}
        p = num2bit(p, 16);
    case {'uint32', 'int32'}
        p = num2bit(p, 32);
    case {'uint64', 'int64'}
        p = num2bit(p, 64);
    case 'logical'
        p = p(:)';
    otherwise
        disp('The plaintext must be a sequence of bits or integers or characters!');
        return;
end
if numel(p)>numel(c)
    disp('The plaintext exceeds the capacity of the cover!');
    return;
end

% Check if the last argument 'k' exists or empty.
if (~exist('k', 'var') || isempty(k))
    indices = 1:numel(p); % MATLAB sequential path
else
    indices = randpath(numel(c), numel(p), k)';
end

% Make a copy of the plaintext so that higher bits are in the stego text.
s = c;
% Note that indices is a 1-D sequence and s is a 2-D or 3-D matrix.
% In this case, the indeices represent the column-row-channel 1-D indices
% of pixels in the image.
s(indices) = bitset(s(indices), 1, p);
