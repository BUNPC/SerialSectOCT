function [err grad_at_x x]= mm_ggd_tikhonov_func(x,xo,y,D,Dp_l,a,b,e)
N1=size(x,1);
N2 = size(x,2);

indnz = find(x ~=0 & xo ~= 0); % only non-zero voxels are calculated

err = e.*a.*(x(indnz)./xo(indnz)) + (b.*(y(indnz)./x(indnz))).^e;
err = sum(err);
err = err + (x(:)'*Dp_l*D*x(:));

grad_at_x = zeros(size(x(:)));
grad_at_x(indnz) = 1./xo(indnz) - y(indnz)./x(indnz).^2;    
grad_at_x = grad_at_x + 2*Dp_l*(D*x(:));


grad_at_x = reshape(grad_at_x,size(x));

end