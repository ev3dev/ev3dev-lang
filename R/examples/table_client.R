#   Sample application for EV3 (client, TO DO)
#
#   It transfers the necessary files to EV3, starts Rserve on EV3, sources the files
#   With the correctly built EV3 robot this application TO DO
#   
#   This script is intended to be run from PC (not EV3)  
#
#   Prerequsities: 
#   -R and Rserve installed on EV3
#   -RSclient package installed on PC
#   -remote connections enabled for Rserve on EV3
#   -ssh client installed on PC and in the system path (e.g. www.openssh.org/ for Windows)
#   -ssh keys for user of PC stored on EV3, same PC/EV3 user (doesn't ask for password)
#   -ssh connected at least once from command line (so machine trusted)
#   -working directory set to location of files (setwd on PC)
#
#   This is intented to work in tandem with table.R 
#   table.R is not required to be called manually on EV3 (this script does it)
#
#   The intented hardware for EV3 is: TO DO
#     
#   Copyright (c) 2014 - Bartosz Meglicki
# 
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#  
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
# 
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# Setup the ip of EV3

ip="192.168.1.10"
ip="10.1.6.142"

# End of setup

library(RSclient)
source("../ev3_dev_tools.R") #UploadFile

# Connect to Rserve on EV3, upload the srcipt and source it
con=RS.connect(ip) 
#UploadFile(con, "../ev3dev.R", "~/R/ev3dev.R")
UploadFile(con, "table.R")
RS.eval(con, source("table.R"))

# Now we are ready for work

RS.eval(con, Connected(ltouch)) 
RS.eval(con, Connected(rtouch)) 
RS.eval(con, Connected(gyro)) 
RS.eval(con, Connected(infrared))

RS.eval(con, Value(infrared)) 
RS.eval(con, Value(ltouch)) 
RS.eval(con, Value(rtouch)) 

RS.eval(con, DriveTouch(left, right, ltouch, 50))
RS.eval(con, DriveTouch(left, right, ltouch, -10))

RS.eval(con,Drive(left, right, 20))
RS.eval(con,Drive(left, right, -20))

RS.eval(con, Rotate(left, right, 30))
RS.eval(con, Rotate(left, right, -40))

inf=RS.eval(con, TestInfrared(left, right, infrared, 20))
plot(inf)
hist(inf)
plot(density(inf))

inf=RS.eval( con, InfraredSamples(infrared, 3, 0.1) )
plot(inf)
hist(inf)
plot(density(inf))
var(inf)

RS.eval(con, SpeakReason(c("test", "sdf")))

dc=RS.eval(con, TestDutyCycle(left, right, 40))
dc

plot(dc$ldc, col=as.factor(dc$left_states))
plot(dc$rdc, col=as.factor(dc$right_states))
plot(density(dc$ldc[dc$left_states=="ramp_const"]))
plot(density(dc$rdc[dc$right_states=="ramp_const"]))

#acceleration

acc=RS.eval(con, TestAcceleration(left, right, gyro, 40))
acc

plot(acc$accx, col=as.factor(acc$left_states))
plot(acc$accy, col=as.factor(acc$right_states))
plot(density(acc$accx[acc$left_states=="ramp_const"]))
plot(density(dc$right_dc[dc$right_states=="ramp_const"]))



thr_left_dc=max(dc$left_dc)+10L
thr_right_dc=max(dc$right_dc)+10L
thr_left_dc
thr_right_dc

for(i in 1:10)
{
  last=RS.eval(con, DriveThresholdTouchDC(left, right, infrared, ltouch, 100L, 60L, 40L, 2L, 53L, 55L))
  
  if(abs(last$infrared - last$mean_infrared)>20)
    next
  
  if( any(c("infrared_up", "touch", "left_dc", "right_dc") %in%  last$stop_reason))
    RS.eval(con,Drive(left, right, -10L))
    
  angle=as.integer(180-runif(1, 0, 90))
  if(sample(2, 1)==1) angle=-angle
  
  t=RS.eval(con, as.call(list(quote(Rotate), quote(left), quote(right), angle)), lazy=FALSE)  
}

DegToPos=function(degree){ as.integer(degree * 520 / 90) }
Radian=function(degree){ degree*pi/180 }

Displacement=function(path)
{
  (path$lpos[[2]]-path$lpos[[1]] + path$rpos[[2]]-path$rpos[[1]])/2
}

Heading=function(path)
{
  Radian(path[1,]$head[[1]]/100)
}

RandomAngle=function()
{
  angle=as.integer(180-runif(1, 0, 90))
  if(sample(2, 1)==1) angle=-angle
  angle  
}
EstimatePosition=function(prev, path)
{
  prev+Displacement(path)*c(sin(Heading(path)), cos(Heading(path)))
}

Go=function(con, control=list(inf.up=70L, inf.down=35L, lt=0L, rt=0L, inf.var.thr=2L, ldc.thr=50L, rdc.thr=50L, pps.sp=300L))
{  
  RS.eval(con, as.call(list(quote(DriveSafely), control)), lazy=FALSE)    
}

Rotate=function(con, degree, control=list(lgo=DegToPos(degree), rgo=-DegToPos(degree), lt=0L, rt=0L, pps.sp=300L))
{  
  RS.eval(con, as.call(list(quote(DriveSafely), control)), lazy=FALSE)    
}

PlotPath=function(prev, curr)
{
  if(prev[1]==curr[1] & prev[2]==curr[2])
    return()
  lines(c(prev[1], curr[1]), c(prev[2], curr[2]))
  arrows(prev[1], prev[2], curr[1], curr[2])  
}

CheckTouch=function(con)
{
  left=RS.eval(con, Value(ltouch) )
  right=RS.eval(con, Value(rtouch) )    
  return (left & right)
}

RS.eval(con, Command(gyro, "RESET"))
RS.eval(con, Value(gyro))

positions=array(NA, dim=c(1000, 2), dimnames=list(c(), c("x", "y")))
positions[1,]=c(0,0)
p=2

X11()
plot(x=positions[1,1], y=positions[1,2], xlim=c(-4000, 4000), ylim=c(-4000,4000), asp=1)

for(i in 1:5)
{
  path=Go(con, control=list(inf.up=60L, inf.down=40L, lt=0L, rt=0L, inf.var.thr=5L, ldc.thr=55L, rdc.thr=55L, pps.sp=300L))
  positions[p,]=EstimatePosition(positions[p-1,],path)
  PlotPath(positions[p-1,], positions[p,])
  p=p+1
  
  if(path$inf$end>60L || path$lt$end==0 || path$rt$end==0)
  {    
    if(CheckTouch(con)==0 & (path$lt$end==0 || path$rt$end==0))
      path=Go(con,control=list(lgo=-300L, rgo=-300L, pps.sp=800L))
    else if(path$inf$end>60L)
      path=Go(con,control=list(lgo=-200L, rgo=-200L, pps.sp=300L))
    
    positions[p,]=EstimatePosition(positions[p-1,],path)
    PlotPath(positions[p-1,], positions[p,])
    p=p+1    
  }
    
  Rotate(con, RandomAngle())  
}

plot(x=positions[1,1], y=positions[1,2], xlim=c(-4000, 4000), ylim=c(-4000,4000), asp=1)

RS.close(con)
