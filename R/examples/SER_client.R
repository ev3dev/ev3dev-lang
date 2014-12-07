ip="192.168.1.10"
#ip="10.1.6.142"

# End of setup

library(RSclient)
source("../ev3_dev_tools.R") #UploadFile

# Connect to Rserve on EV3, upload the srcipt and source it
con=RS.connect(ip) 

UploadFile(con, "SER.R")
RS.eval(con, source("SER.R"))

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

RS.close(con)
