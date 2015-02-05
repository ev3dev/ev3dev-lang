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
#ip="10.1.6.142"

# End of setup

library(RSclient)
source("../ev3_dev_tools.R") #UploadFile

# Connect to Rserve on EV3, upload the srcipt and source it
con=RS.connect(ip) 
#UploadFile(con, "../ev3dev.R", "~/R/ev3dev.R")
UploadFile(con, "table.R")
RS.eval(con, source("table.R"))

#RS.eval(con, rm(list=ls(all=TRUE)))
#RS.eval(con, source("~/R/ev3dev.R"))

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
inf2=RS.eval(con, TestInfrared(left, right, infrared, 80))
inf=c(inf, inf2)
par(mfrow=c(1,1))
plot(inf)
plot(inf2)
hist(inf)
plot(density(inf))

inf=RS.eval( con, InfraredSamples(infrared, 3, 0.1) )
plot(inf)
hist(inf)
plot(density(inf))
var(inf)


dc=RS.eval(con, TestDutyCycle(left, right, 40))
dc

plot(dc$ldc, col=as.factor(dc$left_states))
plot(dc$rdc, col=as.factor(dc$right_states))
plot(density(dc$ldc[dc$left_states=="ramp_const"]))
plot(density(dc$rdc[dc$right_states=="ramp_const"]))

CalibrateRotationOnce=function(con, go=1000)
{  
  RS.eval(con, Command(gyro, "RESET"))
  Sys.sleep(1)
  print(RS.eval(con, Value(gyro)))
  
  control=list(lgo=go, rgo=-go, lt=0L, rt=0L, pps.sp=300L)
  
  r=data.frame(RS.eval(con, as.call(list(quote(DriveSafely2), control)), lazy=FALSE))
  
  deg=(r$head[2]-r$head[1])/100
  if(deg<0)
    deg=180+(180+deg)
  
  enc=((r$lpos[2]-r$lpos[1])-(r$rpos[2]-r$rpos[1]))/2
  enc_per_deg=enc/deg
  c(enc_per_deg, deg, go)
}

CalibrateRotation=function(con, go=1000)
{
  encs_per_deg=matrix(data = 0, nrow = length(go),ncol = 3, dimnames = list(c(), c("encs_per_deg", "deg", "go")))

  times=length(go)
  
  for(i in 1:times)  
   encs_per_deg[i,]=CalibrateRotationOnce(con, go[i])    
  encs_per_deg
}

encs=data.frame(CalibrateRotation(con, go=seq(100, 1500, by=100)))
plot(encs$deg, encs$go)
enc_lm=lm(formula = go ~ deg -1, data=encs)
abline(enc_lm)
summary(enc_lm)

DegToPos=function(degree, model=enc_lm)
{
  as.integer(predict(enc_lm, data.frame(deg=degree)))  
}
Radian=function(degree){ degree*pi/180 }
Degree=function(radian){ radian*180/pi }

Displacement=function(path)
{
  (path$lpos[2]-path$lpos[1] + path$rpos[2]-path$rpos[1])/2
  (path$lpos[2]-path$lpos[1] + path$rpos[2]-path$rpos[1])/2
}

Heading=function(path)
{
  Radian(path$head[1]/100)
}

RandomAngle=function()
{
  angle=as.integer(180-runif(1, 0, 90))
  if(sample(2, 1)==1) angle=-angle
  angle  
}

RandomCWAngle=function()
{
  angle=rnorm(1,25,0)  
  angle  
}

EstimatePosition=function(prev, path)
{
  prev+Displacement(path)*c(sin(Heading(path)), cos(Heading(path)))
}

Go=function(con, control=list(inf.up=70L, inf.down=35L, lt=0L, rt=0L, inf.var.thr=2L, ldc.thr=50L, rdc.thr=50L, pps.sp=300L, get.readings=FALSE))
{  
  data.frame(RS.eval(con, as.call(list(quote(DriveSafely2), control)), lazy=FALSE))
}

Rotate=function(con, degree, control=list(lgo=DegToPos(degree), rgo=-DegToPos(degree), lt=0L, rt=0L, pps.sp=300L, get.readings=FALSE))
{  
  data.frame(RS.eval(con, as.call(list(quote(DriveSafely2), control)), lazy=FALSE))
}

PlotPath=function(prev, curr)
{
  if(prev[1]==curr[1] & prev[2]==curr[2])
    return()
  lines(c(prev[1], curr[1]), c(prev[2], curr[2]))
  arrows(prev[1], prev[2], curr[1], curr[2], length=0.1)  
}

CheckTouch=function(con)
{
  left=RS.eval(con, Value(ltouch) )
  right=RS.eval(con, Value(rtouch) )    
  return (left & right)
}

CalibrateInfraredDistance=function(con, inf_cut=38, inf_cut_up=98)
{
  path=Go(con, control=list(lt=0L, rt=0L, ldc.thr=100L, rdc.thr=100L, pps.sp=50L, get.readings=TRUE))  
  path$dist=(path$lpos+path$rpos)/2
  plot(path$dist, path$inf)
  path=path[path$inf>inf_cut,]
  plot(path$dist, path$inf)
  path=path[1:which(path$inf==inf_cut_up)[1],]
  plot(path$inf, path$dist)
  
  l1=lm(path$dist ~ path$inf + I(path$inf^2)+I(path$inf^3), data=path)
  
  summary(l1)
  lines(path$inf, predict(l1, path))  
}

DistanceFromInfraredModel=function(con, inf_cut=38, inf_cut_up=98)
{
  path=Go(con, control=list(lt=0L, rt=0L, inf.var.thr=5L, ldc.thr=100L, rdc.thr=100L, pps.sp=50L, get.readings=TRUE))  
  path$dist=(path$lpos+path$rpos)/2
  path=path[path$inf>inf_cut,]
  path=path[1:which(path$inf==inf_cut_up)[1],]
  
  l1=lm(path$dist ~ path$inf + I(path$inf^2)+I(path$inf^3), data=path)
  l1  
}


ScanSurroundings=function(con, radius=38)
{
  read=data.frame(Rotate(con, degree=370, control=list(lgo=DegToPos(360), rgo=-DegToPos(360), lt=0L, rt=0L, pps.sp=150L, get.readings=TRUE)))
  read$radian=Radian(read$head/100)
  plot(0,0, xlim=c(-100,100), ylim=c(-100,100), asp=1, col="red")
  
  x= radius*sin(seq(from=0, to=2*pi, by=0.05))
  y= radius*cos(seq(from=0, to=2*pi, by=0.05))
  lines(x,y, col="red")    

  x= read$inf*sin(read$radian)
  y= read$inf*cos(read$radian)  
  points(x, y, col="blue")      
  read
}

ProcessScan=function(data, distance_model, inf_thr=38)
{
  data$deg=data$head/100
  middle=mean(data[data$inf==max(data$inf),]$deg)

  data=data[data$inf>inf_thr,]
  data$diff=middle-data$deg
  data$diff_rad=Radian(data$diff)
  data$cos=abs(cos(data$diff_rad))
      
  middle_inf=mean(data[data$inf==max(data$inf),]$inf)  
    
  coefs=distance_model$coef

  inf=middle_inf^c(0, 1,2,3)
  
  dist=sum(inf*coefs)
  
  data$dist=dist/data$cos
  
  plot(0,0, xlim=c(-2000,2000), ylim=c(-2000,2000), asp=1, col="red")
    
  x= data$dist*sin(data$radian)
  y= data$dist*cos(data$radian)  
  points(x, y, col="blue")      
  data.frame(x,y)
}

dist_mod=DistanceFromInfraredModel(con, inf_cut=38, inf_cut_up=98)

X11()
RS.eval(con, Command(gyro, "RESET"))
RS.eval(con, Value(gyro))

positions=array(NA, dim=c(1000, 2), dimnames=list(c(), c("x", "y")))
positions[1,]=c(0,0)
p=2

plot(x=positions[1,1], y=positions[1,2], xlim=c(-4000, 4000), ylim=c(-4000,4000), asp=1)

up=39L
down=24L

for(i in 1:5)
{
  path=Go(con, control=list(inf.up=up, inf.down=down, lt=0L, rt=0L, inf.var.thr=5L, ldc.thr=55L, rdc.thr=55L, pps.sp=300L, get.readings=FALSE))
  positions[p,]=EstimatePosition(positions[p-1,],path)
  PlotPath(positions[p-1,], positions[p,])
  p=p+1    
    
  if(path$inf[2]>up || path$lt[2]==0 || path$rt[2]==0)
  {    
    if(CheckTouch(con)==0 & (path$lt[2]==0 || path$rt[2]==0))
      path=Go(con,control=list(lgo=-300L, rgo=-300L, pps.sp=300L))
    else if(path$inf[2]>up)
      path=Go(con,control=list(lgo=-300L, rgo=-300L, pps.sp=300L, get.readings=FALSE))
    
    positions[p,]=EstimatePosition(positions[p-1,],path)
    PlotPath(positions[p-1,], positions[p,])
    p=p+1    
  }
      
  Rotate(con, RandomCWAngle())  
}

RS.eval(con, Command(gyro, "RESET"))
read=ScanSurroundings(con)
line=ProcessScan(read, dist_mod, 39)


control=list(inf.up=up, inf.down=down, lt=0L, rt=0L, inf.var.thr=5L, ldc.thr=55L, rdc.thr=55L, pps.sp=300L, get.readings=FALSE)
x=RS.eval(con, as.call(list(quote(DriveSafely2), control)), lazy=FALSE)    

control=list(lt=0L, rt=0L, inf.var.thr=5L, ldc.thr=55L, rdc.thr=55L, pps.sp=300L, get.readings=TRUE)
RS.eval(con, as.call(list(quote(DriveSafely2), control)), lazy=FALSE)    

RS.eval(con, SpeakWhy(CheckConditions2(GetReadings2(left, right, gyro, infrared, ltouch, rtouch), list(inf.up=NA, inf.down=NA, lt=0L, rt=0L, ldc.thr=NA, rdc.thr=NA) )))     

RS.close(con)
