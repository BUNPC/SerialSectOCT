% Convert raw spectrum data to Reflectivity



function OCT_IMG = Dat2RR(Dat, numBins, intpDk, bavgfrm)


% choose parameter for lamda-k interpolation
if nargin < 3
	intpDk = -0.37;
end
if nargin < 4
	bavgfrm = 0;
end


% substract the reference signal, Subtract mean
[z,x,y] = size(Dat);
% processing parameter
fftLength = z/numBins;% total num of data/num of bins
OCT_IMG  = zeros([round(fftLength/2),x,y,numBins]);

if bavgfrm == 1
    Dat = Dat - repmat(mean(Dat(:,:),2),[1 x y]);
else
    for ifr=1:y
        Dat(:,:,ifr) = Dat(:,:,ifr) - repmat(mean(Dat(:,:,ifr),2),[1 x]);
    end
end
%%%%
nz = round(z/2);
data_k= zeros(z,x,y,'single');
%% transform from lamda to k, lamda-k interpolation, and ifft
if intpDk ~= 0
    k = linspace(1-intpDk/2, 1+intpDk/2, z);
    lam = 1./fliplr(k);
    for ifr=1:y
        ifr
        %% lamda to k space
        temp = interp1(lam, Dat(:,:,ifr), linspace(min(lam),max(lam),length(lam)), 'spline');
        data_k(:,:,ifr)=temp;
        % separate data into bins
        % Perform the frequency coumpounding
        for jj = 1:numBins
            tab = (jj-1) * fftLength+1 : jj*fftLength;
            %multipy by the Gaussian window
            GaussianWindow = 1;%gausswin(fftLength);
            fringe1 = data_k(tab,:,ifr) .* GaussianWindow;

           % do FFT
            Frame = (abs(fft(fringe1,fftLength))).^2;
            Frame_rsh = reshape(Frame(1:fftLength/2,:),fftLength/2,x,1);
            OCT_IMG(:,:,:,jj) = OCT_IMG(:,:,:,jj) + Frame_rsh;
        end
        
        %% ifft
%         RRy = ifft(data_k(:,:,ifr));
%         RR(:,:,ifr) = RRy(1:nz,:);  
%         if (mod(ifr,ceil(nf/5)) == 0)  
%             disp(['... Raw to RR ' num2str(ifr) '/' num2str(nf) '  ' datestr(now,'HH:MM')]);  
%         end
    end	
end


