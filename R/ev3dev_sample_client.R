#   Sample application for EV3 client.
#   It transfers the necessary files to EV3, starts Rserve on EV3, sources the files
#   With the correctly built EV3 robot this application controls the robot so that:
#   -it looks around with infrared sensor (360 degree on medium motor with polling the infrared)
#   -the result is plotted on PC
#   -the user clicks on plot to guide the robot (roughly)
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
#   This is intented to work in tandem with ev3dev_sample.R 
#   ev3dev_sample.R is not required to be called manually on EV3 (this script does it)
#
#   The intented hardware for EV3 is:
#   -large motor on OUTPUT_B
#   -large motor on OUTPUT_C
#   -(optional) infrared sensor mounted on medium motor with long cable so that it can rotate 360 degrees and back
#
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

# Set working directory to source file location:
# e.g. in RStudio Session->Set Working Directory -> To Source File Location

# End Setup

library(RSclient)
source("ev3_dev_tools.R") #startRemoteRserve, upload, run

scp_path=paste(ip, ":~/R/", sep="")

status=run(ip, "mkdir ~/R") #may warn if directory already exists

startRemoteRserve(ip) 
Sys.sleep(15) # let's wait for the server start
c=RSconnect(ip)
RSeval(c, quote(print("It is ready.")))

upload("ev3dev.R", scp_path)
upload("ev3dev_sample.R", scp_path)
RSeval( c, quote(source("~/R/ev3dev.R") ))
RSeval( c, quote(source("~/R/ev3dev_sample.R") ))

# END Setup

# Send some sample commands

RSeval( c, quote(Drive(left_motor, right_motor, 10)) )
RSeval( c, quote(Look(head_motor, 20)) )
RSeval( c, quote(Look(head_motor, 0)) )
RSeval( c, quote(Sense(infrared)))
RSeval( c, quote(Rotate(left_motor, right_motor, 90)) )

Degree=function(radian)
{
  radian*180/pi
}

Radian=function(degree)
{
  degree*pi/180
}

PlotReadings=function(readings)
{
  plot(0,0, xlim=c(-100,100), ylim=c(-100,100), asp=1, col="red")
  
  x= 100*cos(seq(from=0, to=2*pi, by=0.05))
  y= 100*sin(seq(from=0, to=2*pi, by=0.05))
  lines(x,y, col="red")    
  
  readings=readings[readings[,2]<90,]
  x=-readings[,2]*cos(Radian(90+readings[,1]))
  y= readings[,2]*sin(Radian(90+readings[,1]))

  
  points(x, y, col="blue")    
}

ControlRobot=function()
{
  point=locator(n=1)
  drive=sqrt(point$x^2+point$y^2)*0.7
  
  rotate=90-(Degree(atan2(point$y, point$x)))
  if(rotate>180)
    rotate=rotate-360
  
  list(rotate=round(rotate), drive=round(drive))  
}

X11()

while(1)
{
  readings=RSeval( c, quote(LookAround(head_motor, infrared)))

  PlotReadings(readings)
  command=ControlRobot()
  
  rotation_command=paste("Rotate(left_motor, right_motor,", command$rotate, ")" ,sep="")  
  RSeval( c, rotation_command)
  drive_command=paste("Drive(left_motor, right_motor,", command$drive, ")" ,sep="")  
  RSeval( c, drive_command)
}


RSclose(c)
