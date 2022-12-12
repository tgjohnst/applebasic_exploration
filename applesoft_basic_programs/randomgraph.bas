10 REM This program generates a random function and graphs it
20 REM Set up the screen and axes
30 GR
40 HGR2
50 HPLOT 0,0 TO 159,100
60 HPLOT 0,50 TO 159,50
70 HPLOT 80,0 TO 80,100
80 REM Generate the random function
90 FOR X=0 TO 159
100 Y=RND(1)*100
110 HPLOT X,Y TO X+1,Y
120 NEXT X
130 END
