ip="192.168.1.10"
#ip="10.1.6.142"

# End of setup

library(RSclient)

source("../ev3_dev_tools.R") #UploadFile
source("SER_misc.R") 

# Connect to Rserve on EV3, upload the srcipt and source it
con=RS.connect(ip) 

UploadFile(con, "SER.R")
RS.eval(con, source("SER.R"))

#DownloadFile(con, "/var/log/Rserve.log") 
#print( readLines("Rserve.log") )

# Now we are ready for work

## Remote Control

RS.eval(con, RemoteControl())

## Follow Infrared

RS.eval(con, FollowInfrared())

## Duty Cycle

ndc=RS.eval(con, TestDutyCycle(20))
hdc=RS.eval(con, TestDutyCycle(20))

levels=unique(c(levels(ndc$left_states), levels(hdc$left_states), levels(ndc$right_states), levels(hdc$right_states)   ))

par(mfcol=c(1, 2))

plot(ndc$ldc, col=factor(ndc$left_states, levels), ylim=c(0,100),pch=20, cex=2, main="typical DC")
plot(hdc$ldc, col=factor(hdc$left_states, levels), ylim=c(0,100),pch=20,cex=2, main="collision DC")

par(mfcol=c(1, 1))

min.x=-10+min(ndc$ldc[ndc$left_states=="ramp_const"], hdc$ldc[hdc$left_states=="ramp_const"])
max.x=10+max(ndc$ldc[ndc$left_states=="ramp_const"], hdc$ldc[hdc$left_states=="ramp_const"])

plot(density(ndc$ldc[ndc$left_states=="ramp_const"], bw = "SJ"), xlim=c(min.x, max.x), col="green", lwd=10, main="Duty Cycle - typical vs collision")
lines(density(hdc$ldc[hdc$left_states=="ramp_const"], bw = "SJ"), lwd=10, col="red")

ldc_threshold=min(hdc$ldc[hdc$left_states=="ramp_const"])
rdc_threshold=min(hdc$rdc[hdc$right_states=="ramp_const"])

for(i in 1:5)
{
  RS.eval(con, as.call(list(quote(DriveDutyCycle), 20, ldc_threshold, rdc_threshold)), lazy=FALSE)
  RS.eval(con, as.call(list(quote(DriveDutyCycle), -20, ldc_threshold, rdc_threshold)), lazy=FALSE)
}

## SLAM

# Infrared Calibration

inf=RS.eval(con, TestInfrared(30))
plot(inf, col="blue")
hist(inf)
plot(density(inf), col="blue", lwd=5)
inf_min=min(inf)
inf_max=max(inf)

# Rotation Calibration

encs=data.frame(CalibrateRotation(con, go=seq(100, 1000, by=100)))
plot(encs$deg, encs$go, col="green", pch=20)
enc_lm=lm(formula = go ~ deg -1, data=encs)
abline(enc_lm)
summary(enc_lm)

DegToPos=function(degree, model=enc_lm)
{
  as.integer(predict(enc_lm, data.frame(deg=degree)))  
}

Rotate(con, 90 )
Rotate(con, -90 )

# Infrared Scan
RS.eval(con, Command(gyro, "RESET"))
scan=ScanSurroundings(con, inf_max)

# Infrared Distance Model

path=Go(con, control=list(lt=0L, rt=0L, ldc.thr=100L, rdc.thr=100L, pps.sp=50L, get.readings=TRUE))  
Go(con,control=list(lgo=-300L, rgo=-300L, pps.sp=300L))

path$dist=(path$lpos+path$rpos)/2
plot(path$dist, path$inf)
path=path[path$inf>inf_max,]
plot(path$dist, path$inf)
path=path[1:which(path$inf==94)[1],]
plot(path$inf, path$dist)

l1=lm(path$dist ~ path$inf + I(path$inf^2)+I(path$inf^3), data=path)

summary(l1)
lines(path$inf, predict(l1, path), col="blue", lwd=5)  

dist_mod=DistanceFromInfraredModel(con, inf_max+2, 94)

# Feature Extraction

scan=ScanSurroundings(con, inf_max)

ProcessScan=function(data, distance_model, inf_thr=inf_max+2)
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




RS.close(con)
