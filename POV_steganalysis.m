function [p, S, number_valid_bins] = POV_steganalysis(img, bin_height_min)
% [p, S, number_valid_bins] = POV_steganalysis(img, bin_height_min)
% This function calculates the p-value of the POV based steganalysis of the
% LSB bitplane of an input image.
% The argument "bin_height_min" denotes the minimum height of histogram
% bars used in the calculation of the p-value (default: 5). This is
% required to avoid unnecessary large noises in the results.
% 
% The first two output arguments are the p-value and the chi^2-statistic S,
% respectively.
% The third output argument gives the number of valid bins used for
% calculating the chi^2-statistic S.
%

p = 0;
S = -1;

% Check the validity of input arguments.
if nargin<1
    disp('At least one input argument is needed!');
    return;
end

% Check if the argument 'bin_height_min' exists and is valid.
if (~exist('bin_height_min','var') || ~isnumeric(bin_height_min) || bin_height_min<1)
    bin_height_min = 5;
end

% Get the histogram of the image, which is equivalent to
% h = histc(img(:), 0:255);
h = imhist(img);
% Get the distribution H(2i).
H = (h(1:2:end)+h(2:2:end))/2;
% Get the even-numbered bins of the histogram.
% Note that the bins are 0-indexed but MATLAB elements are 1-indexed.
h_even = h(1:2:end);
% Get the valid bins whose heights are sufficiently large.
valid_indices = find(H>=bin_height_min);
% Note that the number of valid indices may be smaller than numel(H) and
% even be 1 (e.g. if there is just one non-zero bin) or 0 (if the input
% image is too small).
number_valid_bins = numel(valid_indices);
if number_valid_bins<=1
    disp('There are no enough valid bins to perform a chi-squared test!');
    return;
end
% Calculate the chi^2-statistic S.
S = sum((h_even(valid_indices)-H(valid_indices)).^2./H(valid_indices));
% Calculate the p-value from S.
% Note that the degree of freedom is the number of valid bins used minus 1.
p = 1 - chi2cdf(S, number_valid_bins-1);
