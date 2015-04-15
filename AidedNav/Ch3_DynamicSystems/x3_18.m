% This function computes the matrices for Example 3.18 of the book 
% Aided Navigation: GPS and high rate sensors
% Jay A. Farrell, 2008, Mc Graw-Hill
% 
% This software is distibuted without a written or implied warranty. 
% The software is for educational purposes and is not intended for
% use in applications. Adaptation for applications is at the
% users/developers risk.

g = 10;
R = 6e6;
F = [0 1/R 0 0 0
     0 0 g 1 0
     0 1/R 0 0 1
     0 0 0 0 0
     0 0 0 0 0]
 H = [1 0 0 0 0]
 
 O = H;
 for i=2:5
     O = [O;O(i-1,:)*F];
 end
 O
 rank(O)
 
 P = [1 0  0  0 0
      0 1  0  0 0
      0 0  g  1 0
      0 0  0  0 1
      0 0  -1 g 0]
  Pinv = inv(P)
  
  Fs = P*F*Pinv
  Hs = H*Pinv