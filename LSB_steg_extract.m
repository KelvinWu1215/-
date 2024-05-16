function p = LSB_steg_extract(s, k, p_size, p_class)
% p = LSB_steg_extract(s, k, p_size, p_class)
% This function extracts a plaintext image "p" from the LSB bitplane of a 
% stego-image "s".
% A stego-key "k" is used to select a random path. If not given or [], the
% sequential path will be used.
% The size of the plaintext is given by "p_size" (default: size(s)), which
% is needed since the extracted bits forms a 1-D bit sequence which may not
% match the original format of the plaintext.
% The class of the plaintext is given by "p_class" (default: 'uint8'),
% which is needed if the plaintext has a different type e.g. strings
% ('char').
% 
% In a real-world scenario, the size and type of the plaintext are
% generally unknown so they need to be transmitted to the receiver as part
% of the hidden message as well.
% A common way of doing this is to define a message header which inform the
% receiver about the needed meta-information for the extractor.
% I did not implement this feature in this function to keep it simpler.


% This is needed so that the output is not invalid when the function
% returns earlier.
p = [];

% Check the validity of the first input argument.
if nargin<1
    disp('At least one input argument is needed!');
    return;
end

% Check if the argument 'p_size' exists or has a valid value.
if (~exist('p_size','var') || ~isnumeric(p_size))
    p_size = size(s); % No size is given, then use the image size.
else
    p_size = floor(p_size);
    if numel(p_size)==1
        p_size = [1 p_size];
    end
end
p_number = prod(p_size); % Number of bits of the plaintext.

% Check if the argument 'p_class' exists or has a valid value.
if (~exist('p_class','var') || ~ischar(p_class))
    p_class = 'uint8';
end
switch(p_class)
    case 'logical'
        pb_number = p_number;
    case {'uint8', 'int8', 'char'}
        pb_number = p_number * 8;
    case {'uint16', 'int16'}
        pb_number = p_number * 16;
    case {'uint32', 'int32'}
        pb_number = p_size * 32;
    case {'uint64', 'int64'}
        pb_number = p_number * 64;
    otherwise
        disp('The plaintext must be a sequence of bits, integers or characters!');
        return;
end
if pb_number>numel(s)
    disp('The plaintext size exceeds the maximum capacity of the cover!');
    return;
end

% Check if the argument 'k' exists or has a valid value.
if (~exist('k', 'var') || isempty(k))
    indices = 1:pb_number; % MATLAB sequential path
else
    indices = randpath(numel(s), pb_number, k)';
end

% Note that indices is a 1-D sequence and s is a 2-D or 3-D matrix.
% In this case, the indeices represent the column-row-channel 1-D indices
% of pixels in the image.
pb = bitget(s(indices), 1);
% Change the extracted 1-D bit sequence to a 1-D number sequence.
p_1d = bit2num(pb, pb_number/p_number);
% % Change the extracted 1-D bit sequence to a matrix matching the size of
% the plaintext.
p = reshape(p_1d, p_size);
% If type does not match, change it.
if ~strcmp(class(p),p_class)
    p = cast(p, p_class);
end
