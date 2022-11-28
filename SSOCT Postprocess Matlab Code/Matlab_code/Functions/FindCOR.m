% input: GG, 2D array, [nVox, nTau]
function RotCtr = FindCOR(GG)

	a = real(GG);
	b = imag(GG);

	A1 = std(a,1,2).^2;
	A2 = mean( (a - repmat(mean(a,2),[1  size(a,2) 1])) .* b ,2);
	A3 = mean( (b - repmat(mean(b,2),[1 size(b,2) 1])) .* a ,2);
	A4 = std(b,1,2).^2;
	
	B1 = 1/2 * ( mean(a.^3,2) - mean(a,2).*mean(a.^2,2) + mean( (a - repmat(mean(a,2),[1 size(a,2) 1])) .* b.^2 ,2) );
	B2 = 1/2 * ( mean(b.^3,2) - mean(b,2).*mean(b.^2,2) + mean( (b - repmat(mean(b,2),[1 size(b,2) 1])) .* a.^2 ,2) );

	RotCtr = ( (A4.*B1 - A2.*B2) + 1i*(A1.*B2 - A3.*B1) ) ./ (A1.*A4 - A2.*A3);
    