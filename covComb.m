function K = covComb(hyp, x, z, i)

% covariance function, compatible up to GPML version 3.6. For newer GPML versions, construct it simpler with covMask
% 1) factor for linear kernel in intensity
% 2) characteristic lengthscale of SE kernel in frequency
% 3) factor for SE kernel in frequency

if nargin<2, K = '3'; return; end                  % report number of parameters
if nargin<3, z = []; end                                   % make sure, z exists
xeqz = isempty(z); dg = strcmp(z,'diag');                       % determine mode

ampse = exp(hyp(3));             % amplitude of the SE kernel
ell = exp(hyp(2));               % characteristic length scale of SE kernel
slope = exp(hyp(1));             % slope of the linear kernel

if nargin < 4
    if dg        
        K1 = covLINiso(hyp(1), x(:,2),z);
        K2 = covSEiso([hyp(2) hyp(3)], x(:,1),z);
        K = K1 + K2;
    else
        if xeqz
            K1 = covLINiso(hyp(1), x(:,2),z);
            K2 = covSEiso([hyp(2) hyp(3)], x(:,1),z);
            K = K1 + K2;        
    %         K = K + an * eye(size(K));
        else
            K1 = covLINiso(hyp(1), x(:,2),z(:,2));
            K2 = covSEiso([hyp(2) hyp(3)], x(:,1),z(:,1));
            K = K1 + K2;
        end
    end
else
    if i == 1
        if dg        
            K = covLINiso(hyp(1), x(:,2),z,i);
        else
            if xeqz
                K = covLINiso(hyp(1), x(:,2),z,i);       
            else
                K = covLINiso(hyp(1), x(:,2),z(:,2),i);
            end
        end
    else
        j = i-1;
        if dg        
            K = covSEiso([hyp(2) hyp(3)], x(:,1),z,j);
        else
            if xeqz
                K = covSEiso([hyp(2) hyp(3)], x(:,1),z,j);
            else
                K = covSEiso([hyp(2) hyp(3)], x(:,1),z(:,1),j);
            end
        end
    end
end
