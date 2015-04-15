#Next line clears the graphics terminal
clear
# "pound" starts a comment line
# Next two lines select the postscript terminal type and assign output  
# to go to the file 'blank1010.eps'
set terminal postscript eps
set output "blank1010.eps"
# The next line turns off the display of the border around the graph
set noborder
# The next line turns off display of the "legend" for the graph
set nokey
# The next two lines remove the 'x' and 'y' labels from the axis
set xlabel ""
set ylabel ""
# The next line sets the size of the graph
set size 0.72,0.8
# The next two lines place the 'x' and 'y' labels
set label "x" at 9,-2
set label "y" at -1,10
# The next line inhibits drawing of the coordinate axis
set nozeroaxis
# Next two lines place tic marks on the respective axis
set xtics axis (-8,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8)
set ytics axis (-8,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8)
# Next two lines draw arrows
set arrow from -10,0 to 10,0 
set arrow from 0,-10 to 0,10
# Next line plots the x-axis
# Without the 'plot' command no graph is outputted
# Since we want an 'empty' coordinate system, we draw the x-axis
# on top of the horizontal 'arrow' drawn above.
# the "0" before 'with point size' tells gnuplot to draw the
# curve 'y=0', which is the x-axis
# The style for the line is chosen to be points and the zero 
# indicates a particular point size
plot [-10:10][-10:10] 0 with points ps 0
set output

