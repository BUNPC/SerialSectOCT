
function OCT_IMG = Dat2RR_linear(Dat, numBins, xpix, ypix, intpDk, bavgfrm)

% choose parameter for lamda-k interpolation
if nargin < 5
	intpDk = -0.37;
end
if nargin < 6
	bavgfrm = 0;
end

% substract the reference signal, Subtract mean
[z,x] = size(Dat);

% processing parameters
fftLength = z/numBins;% total num of data/num of bins
OCT_IMG  = zeros([round(fftLength/2), xpix, ypix, numBins]);

if bavgfrm == 1
    Dat = Dat - repmat(mean(Dat(:,:),2),[1 x]);
else
    Dat(:,:) = Dat(:,:) - repmat(mean(Dat(:,:),2),[1 x]);
end
%%%%
nz = round(z/2);
data_k= zeros(z,x,'single');
%% transform from lamda to k, lamda-k interpolation, and ifft
if intpDk ~= 0
    k = linspace(1-intpDk/2, 1+intpDk/2, z);
    lam = 1./fliplr(k);
    %% lamda to k space
    temp = interp1(lam, Dat(:,:), linspace(min(lam),max(lam),length(lam)), 'spline');
    data_k(:,:) = temp;
    % separate data into bins
    % Perform the frequency coumpounding
    for jj = 1:numBins
        tab = (jj-1) * fftLength+1 : jj*fftLength;
        %multipy by the Gaussian window
        GaussianWindow = gausswin(fftLength);
        fringe1 = data_k(tab,:) .* GaussianWindow;

       % do FFT
        Frame = (abs(fft(fringe1,fftLength))).^2;
        Frame_rshd = reshape(Frame(1:fftLength/2,:),fftLength/2,xpix,ypix);
        OCT_IMG(:,:,:,jj) = OCT_IMG(:,:,:,jj) + Frame_rshd;
    end
end


