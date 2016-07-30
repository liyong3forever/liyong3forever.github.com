%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: 
%       Yong Li
%Email:
%       yong.li@nlpr.ia.ac.cn
%Department:
%       National Laboratory of Pattern Recognition, Institute of Automation, Chinese Academy of Sciences
%
%Description:
    %To learn low-rank representations with classwise block-diagonal structure for robust face recognition.
%Reference:
    %Y. Li, J. Liu, Z. Li, Y. Zhang, H. Lu, and S. Ma, ¡°Learning low-rank representations with classwise block-diagonal structure for robust face recognition,¡± 
    %in AAAI Conference on Artificial Intelligence, 2014, pp.2810¨C2816.
    
% CBDS Copyright 2014, Yong Li (yong.li@nlpr.ia.ac.cn)
% CBDS is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% You should have received a copy of the GNU General Public License
% along with CBDS.  If not, see <http://www.gnu.org/licenses/>.
function [Z, E] = CBDS(X, X_bar,lambda, alpha, clsNum, basePerCls)
%inputs:
%--------X: feature matrix of the whole database
%--------X_bar: feature matrix the training images
%--------lambda: controlling the sparsity of the noise matrix E
%--------alpha: controlling the contribution of structural regularization
%--------clsNum: number of image classes.
%--------basePerCls: number of bases per class, equal to the number of training images per class 
% outputs:
%--------Z: representation of the whole database
%--------E: sparse noise term of the whole database

[d,n] = size(X);
tol = 1e-6;
maxIter = 1e4;
rho = 1.1;
mu= 1e-5;
max_mu= 1e8;
Z=zeros( m,n );
E= zeros( size(X) );
Q=zeros(m,n);
J= zeros(m,n);
Y1 = zeros( size(X) );
Y2 = zeros(m,n);
m = clsNum*basePerCls;
clsImgNum = ones(1, clsNum)*basePerCls;
%% Start main loop
iter = 0;
while iter<maxIter
    iter = iter + 1;
    temp = Z + Y2/mu;
    [U,sigma,V] = svd(temp,'econ');
    sigma = diag(sigma);
    %udpate J 
	svp = length(find(sigma>1/mu));
    if svp>=1
        sigma = sigma(1:svp)-1/mu;
    else
        svp = 1;
        sigma = 0;
    end
    J = U(:,1:svp)*diag(sigma)*V(:,1:svp)';
    
    %udpate Z 
    Z_left = X_bar'*X_bar+( alpha/mu+1 )*eye(m);
    Z = Z_left \ ( X_bar'*(X-E)+J +( X_bar'*Y1-Y2 +alpha*Q )/mu );
    
    %update E
    temp = X-X_bar*Z+Y1/mu;
    E = solve_l1_norm(temp,lambda/mu);
    Z_block = cell(numel(clsImgNum),1);
    for k = 1:numel(clsImgNum)
        Z_block{k} = Z ( (k-1)*basePerCls+1: k*basePerCls,...
            sum(clsImgNum(1:k-1))+1:sum( clsImgNum(1:k) ) );
    end
    Q = [blkdiag( Z_block{:} ), zeros(m, size(X,2)- m )];
    leq1 = X-X_bar*Z-E;
    leq2 = Z-J;
    stopC = max(max(max(abs(leq1))),max(max(abs(leq2))));
         
    if stopC<tol 
        break;
    else
        Y1 = Y1 + mu*leq1;
        Y2 = Y2 + mu*leq2;
        mu = min(max_mu,mu*rho);
    end
    
end

end
function [E] = solve_l1_norm(x,varepsilon)
     E = max(x- varepsilon, 0);
     E = E+min( x+ varepsilon, 0);   
end