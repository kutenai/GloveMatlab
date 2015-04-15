This diskette contains demonstration programs and source codes in MATLAB for 
algorithms listed in the textbook

"Kalman Filtering: Theory and Practice, Using MATLAB"
 by M. S. Grewal and A. P. Andrews,
 published by John Wiley and Sons, 2000.

LIMITS OF LIABILITY AND DISCLAIMER OF WARRANTY:

These programs are intended for demonstration and instructional purposes only.
The authors and publishers make no warrrenty of any kind, expressed or
implied, that these programs meet any standards of mercantibility for 
commercial purposes.  These programs should not be used as-is for any purpose
or application that may result in loss or injury, and the publishers and
authors shall not be liable in any event for incidental or consequential
damages in connection with, or arising out of, the furnishing, performance,
or use of these programs.

CONTENTS OF THE DISKETTE

The root directory of the diskette contains this file and the file WHATSUP.DOC,
which contains descriptions of any changes to the software since publication.

The other contents are divided among the directories according to
the relative chapters of the book.
(subdirectories)

MATLAB (Matlab script files)

CHAPTER2 - This MATLAB program explains how to find the exponential function of a matrix.
CHAPTER4 
   demo1.m demonstrates the probability conditioning on measurements.
   demo2.m demonstrates the effects of approximations commonly used in converting continuous
       time models to discrete time models, using Example 4.3.
   exam43.m demonstrates the Kalman filter in the estimation of position and velocity
       of a damped harmonic oscillator with constant forcing function, using Example 4.3.
   exam44.m demonstrates the covariance analysis of radar tracking, using Example 4.4.
   RTSvsKF.m demonstrates relative performance of the Kalman filter and Rauch-Tung-Striebel
         smoother on random walk estimation.     
CHAPTER5
   exam53.m demonstrates the extended Kalman filter in the estimation of position,
       velocity, and damping factor of a damped harmonic oscillator with constant forcing
       function using Example 5.3.
   exam53x.m and Exam53y.m descriptions are given in whatsup.doc.
CHAPTER6
   Shootout.m is a demonstration of the efficiency of nine alternative observational
       updates, using the ill-conditioned problem in Example 6.2.)
   Carlson.m - N. A. Carlson's observational update method.
   Utchol.m - upper triangular cholesky decomposition (Matlab's does lower triangular)
   Potter.m - J. E. Potter's observational update method.
   Joseph.m -  P. D. Joseph's observational update method.
   Josephb.m -  P. D. Joseph's observational update method, modified by Bierman.
   Josephdv.m - P. D. Joseph's observational update method, modified by De Vries.
   Bierman.m -  G. J. Bierman's observational update method.
   Thornton.m -  C. L. Thornton's temporal update method.    
CHAPTER7
   kfvsskf.m demonstrates Schmidt-Kalman filter for random walk process with
     correlated sensor noise.
DEMOS
   demo2_01.m demonstrates performance of a fixed gain estimator.
   demo2_02.m demonstrates the relative performance of Weiner filter (fixed gain) and Kalman 
     filter (time-varying gain) on random walk estimation.
   demo2_03.m demonstrates "Type 2 tracker" for random walk process with mean velocity.
   demo2_04.m demonstrates tracking of a harmonic oscillator with drifting characteristics.
   demo2_05.m demonstrates autocorrelations and power spectral densities of different noise types.

READ.ME    A text file explaining the demos.

GENERAL COMMENTS

The executable programs demonstrate Kalman filter implementations on a
problem used throughout the book: estimating the state of the stochastic
system model for damped harmonic resonators and shaping filters.

The source codes are included for the purpose of saving the reader
the effort of transcribing and debugging the listings in the text for
demonstrating how the various implementation methods for the Kalman filter
perform on sample problems.   Derivations of most of these algorithms are
contained in the book.

Any corrections or changes since printing are explained in the file named
WHATSUP.DOC.  The authors would appreciate any corrections or suggestions for
changes to the programs that you may discover in your use of them.  Please
send any correspondence to:

          Angus Andrews
          2037 Rosebay Street
          Westlake Village, California 91361-1822, USA



 

      
