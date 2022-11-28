function [x_out] = gradient_descent_ggd(funfcn, y, x_init, D,Dp_l,a,b,e, options)
% Gradient decent optimization. 
% funfcn - function handle which returns [error grad]
% x_init - Initial estimate of unknown parameters
% options - 
%
% The step size may be decreased aggresively in each iteration. Good (& may be slow) for cost
% functions with low computation cost. See below:  
%     data.step_size = data.step_size * options.step_size_scale_iter;
%% Author: Chitresh Bhushan, Divya Varadarajan

data.step_size = options.step_size;
data.y = y;
data.funcCount = 0;
data.TolX = Inf;
data.X = x_init;
data.X(x_init < 0) = 0; % new

data.fval_current = Inf;
data.fval_old = Inf;
data.TolFun = Inf;
data.timeID_start = tic;

data.exitflag = 0;

if strcmp(options.Display,'iter')
    disp('   Func-Grad-count         f(x)         Step-size        Time Taken');
end

x_out = x_init;
timeID_iter = tic;
[data.fval_current, grad] = feval(funfcn, data.X, x_init, data.y, D,Dp_l,a,b,e);
data.funcCount = data.funcCount+1;
data.X_old = data.X;

%data.X(isnan(grad))= 0;
grad(isnan(grad)) = 0;

data.X = data.X - data.step_size .* grad;
data.X(data.X<0) = data.X_old(data.X<0); % new

if strcmp(options.Display,'iter')
   s=sprintf('     %5.0f       %20.12g   %13.6g            %5.2f', data.funcCount, data.fval_current, NaN, toc(timeID_iter)); disp(s);
end

if(strcmp(options.GradObj,'on'))
   while ~data.exitflag
      timeID_iter = tic;
      
      data.fval_old = data.fval_current;
      [data.fval_current, grad] = feval(funfcn,data.X, x_init, data.y, D,Dp_l,a,b,e);
      data.TolFun = data.fval_old - data.fval_current;
      data.funcCount = data.funcCount+1;

      if data.TolFun>0
         data.step_size = data.step_size * options.step_size_scale_iter;
         x_out = data.X;

         if strcmp(options.Display,'iter')
            s=sprintf('     %5.0f       %20.12g   %13.6g            %5.2f', data.funcCount, data.fval_current, norm(data.X_old-data.X), toc(timeID_iter)); disp(s);
         end
      end
      
      data.X_old = data.X;
      %data.X(isnan(grad))= 0;
      grad(isnan(grad)) = 0;
      data.X = data.X - data.step_size .* grad;
      data.X(data.X<0) = data.X_old(data.X<0); % new
      
      data.TolX = max(abs(data.X_old-data.X));
      
      if data.TolFun<0
         data.exitflag = 1;
      elseif(data.funcCount > options.MaxFunEvals)
         data.exitflag = 2;
      elseif (data.TolX < options.TolX)
         data.exitflag = 3;
      elseif(data.TolFun < options.TolFun)
         data.exitflag = 4;
      end
   end
else
   error('Numerical gradient is not supported, Yet!')
end

if strcmp(options.Display,'iter')
   if data.exitflag == 1,  disp('Cannot find minimum along gradient direction'); end
   if data.exitflag == 2,  disp('Function evaluations exceeded MaxFunEvals'); end
   if data.exitflag == 3,  disp('TolX is smaller than specified TolX'); end
   if data.exitflag == 4,  disp('TolFun is smaller than specified TolFun'); end
   s = sprintf('Total time taken = %10.2f sec.', toc(data.timeID_start)); disp(s);
end


end

