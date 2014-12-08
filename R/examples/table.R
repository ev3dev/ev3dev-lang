#   Sample application - TO DO
#   
#   Prerequsities: 
#   -functions and classes from ev3dev.R in memory (e.g. source("ev3dev.R"))
#
#   Copyright (c) 2014 - Bartosz Meglicki
# 
#   This script is intented to work in tandem with table_client.R and should not be called directly
#   The script in table_client.R uploads it to EV3 and sources it and uses the functions remotely through RSclient
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


left=large.motor(ports$OUTPUT_C ) 
right=large.motor(ports$OUTPUT_B ) 

ltouch=touch.sensor(ports$INPUT_2)
rtouch=touch.sensor(ports$INPUT_3)
infrared=infrared.sensor(ports$INPUT_AUTO)
gyro=xg1300l.sensor(ports$INPUT_AUTO)

scary_speach=c("Spadaj", "Zjeżdżaj", "Zabieraj łapy", "Łapska precz", "Won", "Zmykaj", "Zabieraj się", "Zaraz utnę tę łapę")

Sleep=function(time)
{
  Sys.sleep(time)
}

SpeakPL=function(..., sync=TRUE)
{
  text=paste(list(...), collapse="")
  command=paste("espeak -a 200 -v pl --stdout \"", text, "\" | aplay", collapse="")  
  if(!sync) command=paste(command, "&")
  system(command, intern=TRUE, ignore.stderr=TRUE)
}

Scare=function()
{
  SpeakPL(scary_speach[sample(length(scary_speach), 1)], sync=FALSE)
}

SetModeToPosition=function(m)
{
  SetRunMode(m, "position")  
  SetPositionMode(m, "relative")
  SetPosition(m, 0)  
}

InitDriveMotor=function(m)
{
  SetRegulationMode(m, "on")
  SetRampUpSP(m, 1000)
  SetRampDownSP(m, 50)
  SetPulsesPerSecondSP(m, 300)
  SetStopMode(m, "break")
  SetModeToPosition(m)
}

InitDriveMotor(left)
InitDriveMotor(right)

DegreeToHeadPosition=function(deg) {as.integer(deg * 300 / 180)}
PositionToHeadDegree=function(pos){ pos * 180 / 300}
CMToDrivePosition=function(cm) {as.integer(cm*100*5/12)}
DegreeToDrivePosition=function(degree){ as.integer(-degree * 520 / 90) }

DriveStart=function(left_motor, right_motor, cm)
{    
  pos=CMToDrivePosition(cm)
  SetPositionSP(left_motor, pos)
  SetPositionSP(right_motor, pos)
  
  Run(left_motor)
  Run(right_motor)       
}

TestInfrared=function(left, right, infrared, cm)
{
  size=100L
  readings=1L
  inf=integer(size)
  
  SetModeToPosition(left)
  SetModeToPosition(right)
    
  DriveStart(left, right, cm)  
  
  while(Running(left) | Running(right))
  {    
    inf[readings]=Value(infrared)
    readings=readings+1L        
  }    
  inf[1L:(readings-1L)]
}

TestDutyCycle=function(left, right, cm)
{  
  size=100L
  readings=1L
  
  left_states=character(size)
  right_states=character(size)
  ldc=integer(size)
  rdc=integer(size)
  
  DriveStart(left, right, cm)  
  
  while(Running(left) | Running(right))
  {
    left_states[readings]=State(left)
    right_states[readings]=State(right)
    ldc[readings]=DutyCycle(left)
    rdc[readings]=DutyCycle(right)
    readings=readings+1L
    
    #Sys.sleep(0.01)
  }    
    
  span=1L:(readings-1L)
  
  list(left_states = left_states[span], right_states = right_states[span], ldc=ldc[span], rdc=rdc[span] )
}


TestAcceleration=function(left, right, gyro, cm)
{
  SetMode(gyro, "ACCEL")
  size=100L
  readings=1L

  left_states=character(size)
  right_states=character(size)
  accx=integer(size)
  accy=integer(size)
  accz=integer(size)
        
  DriveStart(left, right, cm)  
  
  while(Running(left) | Running(right))
  {
    left_states[readings]=State(left)
    right_states[readings]=State(right)
    accx[readings]=Value(gyro,0)
    accy[readings]=Value(gyro,1)
    accz[readings]=Value(gyro,2)
    readings=readings+1L
    
    #Sys.sleep(0.01)
  }    
  
  SetMode(gyro, "ANGLE")
  
  span=1L:(readings-1L)
  
  list(left_states = left_states[span], right_states = right_states[span], accx = accx[span], accy = accy[span], accz = accz[span]    )
}

Drive=function(left_motor, right_motor, cm)
{
  if(cm==0)
    return (0)
  
  DriveStart(left_motor, right_motor, cm)
  
  while( Running(left_motor) | Running(right_motor) )
    Sleep(0.01)
  
  cm
}

Rotate=function(left_motor, right_motor, degree)
{
  if(degree==0L)
    return (0L)
  
  SetRunMode(left, "position")
  SetRunMode(right, "position")
  
  pos=DegreeToDrivePosition(degree)
  SetPosition(left_motor,0L)
  SetPosition(right_motor,0L)  
  SetPositionSP(left_motor, -pos)
  SetPositionSP(right_motor,pos)
  
  Run(left_motor)
  Run(right_motor)
  
  while( Running(left_motor) | Running(right_motor) )
    Sleep(0.1)
  
  degree
}

DriveThreshold=function(left_motor, right_motor, infrared,  cm, threshold_up, threshold_down)
{
  if(cm==0L)
    return (0L)
  
  inf=Value(infrared)
  
  if(inf > threshold_up | inf < threshold_down)
    return (inf)
    
  DriveStart(left_motor, right_motor, cm)
  
  readings=integer(1L)
  i=0L
  
  while( Running(right_motor) | (Running(left_motor) ))
  { 
    i=i+1L
    if( (readings=Value(infrared) ) > threshold_up | readings < threshold_down)
    {
      Stop(left_motor)
      Stop(right_motor)
      SetPosition(left_motor,0L)
      SetPosition(right_motor,0L)
      break
    }
    
    Sleep(0.02)
  }
      
  readings
}

DriveTouch=function(left_motor, right_motor, touch,  cm)
{
  if(Value(touch)==0L | cm==0L)
    return (0L)
          
  DriveStart(left_motor, right_motor, cm)
  
  while( Running(right_motor) | (Running(left_motor) ))
  { 
    if( Value(touch)==0L )
    {
      Stop(left_motor)
      Stop(right_motor)
      SetPosition(left_motor,0L)
      SetPosition(right_motor,0L)      
      return (0L)
    }       
  }
  
  return (1L)
}

InfraredSamples=function(infrared, samples, delay_sec)
{
  inf=integer(samples)
  
  for(i in 1:length(inf))
  {
    inf[i]=Value(infrared)  
    Sleep(delay_sec)
  }
  
  inf
}

StopAll=function(left, right)
{
  Stop(left)
  Stop(right)
  SetPosition(left,0L)
  SetPosition(right,0L)        
}

SpeakReason=function(reason)
{
  if("touch" %in% reason)
    SpeakPL("Przepaść")
  if("infrared_up" %in% reason)
    SpeakPL("Przepaść")
  if("infrared_down" %in% reason)
    SpeakPL("Przeszkoda")
  if("left_dc" %in% reason || "right_dc" %in% reason)
    SpeakPL("Kolizja")
}

#returns list(touch=, infrared=)
DriveThresholdTouchDC=function(left, right, infrared, touch, cm, thr_up, thr_down, inf_var_thr, ldc_thr, rdc_thr)
{
  inf=Value(infrared)
  tou=Value(touch)
  lstate=State(left)
  rstate=State(right)
  ldc=DutyCycle(left)
  rdc=DutyCycle(right)
  samples=integer()
  reason=character(0)
  
  if(tou==0L | inf > thr_up | inf < thr_down | cm==0L)
    return (list(stop_reason=reason, touch=tou, infrared=inf, mean_infrared=inf, left_dc=ldc, right_dc=rdc, left_state=lstate, right_state=rstate) )
    
  DriveStart(left, right, cm)
  
  while(length(reason)==0 && (Running(right) || (Running(left) ) ) )
  { 
    if( (tou=Value(touch)) ==0L )
    {
      StopAll(left, right)
      reason=c(reason, "touch")
    }    
    if( (inf=Value(infrared)) > thr_up)
    {
      StopAll(left, right)
      reason=c(reason, "infrared_up")
    }
    if( inf < thr_down)
    {
      StopAll(left, right)
      reason=c(reason, "infrared_down")
    }
    if( (lstate=State(left)) =="ramp_const" & (ldc=DutyCycle(left))>ldc_thr )
    {
      StopAll(left, right)
      reason=c(reason, "left_dc")
    }
    if( (rstate=State(right)) == "ramp_const" & (rdc=DutyCycle(right))>rdc_thr )
    {
      StopAll(left, right)
      reason=c(reason, "right_dc")
    }
    
    Sleep(0.01)
  }
  
  while(abs(PulsesPerSecond(left)) > 0L | abs(PulsesPerSecond(right)) > 0L)
    Sleep(0.02)
     
  while( var( (samples=InfraredSamples(infrared, 3, 0.1)) )  > inf_var_thr)    
    Scare()
  
  SpeakReason(reason)
      
  list(stop_reason=reason, touch=tou, infrared=inf, mean_infrared=mean(samples), left_dc=ldc, right_dc=rdc, left_state=lstate, right_state=rstate) 
}

MotorFactor=function(m)
{
  factor(State(m), c("idle", "ramp_const", "ramp_down", "ramp_up"))
}

GetReadings=function(left, right, gyro, infrared, ltouch, rtouch)
{
  list(inf=Value(infrared), lt=Value(ltouch), rt=Value(rtouch), ldc=DutyCycle(left), rdc=DutyCycle(right), lst=State(left), rst=State(right), lpos=Position(left), rpos=Position(right),  head=Value(gyro))
}
GetReadings2=function(left, right, gyro, infrared, ltouch, rtouch)
{
  c(Value(infrared), Value(gyro), Value(ltouch), Value(rtouch), DutyCycle(left), DutyCycle(right), MotorFactor(left), MotorFactor(right), Position(left), Position(right) )
}

CheckConditions=function(readings, control)
{
  r=readings
  c=control
  list(cliff=r$inf > c$inf.up, obstacle=r$inf < c$inf.down,
       ltouch=r$lt==c$lt, rtouch=r$rt==c$rt,  
      ldc=r$lst=="ramp_const" & r$ldc>c$ldc.thr,
      rdc=r$rst=="ramp_const" & r$rdc>c$rdc.thr)
}

CheckConditions2=function(readings, control)
{  
  r=readings
  c=control
    
  list(cliff=r[1] > c$inf.up, obstacle=r[1] < c$inf.down,
       ltouch = (r[3] == c$lt), rtouch = (r[4] == c$rt),  
       ldc = r[7] == 2 && r[5] > c$ldc.thr,
       rdc = r[8] == 2 && r[6] > c$rdc.thr)
}


PrepareEngines=function(left, right, control)
{
  if(!is.null(control$pps.sp))
  {
    SetPulsesPerSecondSP(left, control$pps.sp)
    SetPulsesPerSecondSP(right, control$pps.sp)
  }  
  
  SetPosition(left, 0)
  SetPosition(right, 0)
  SetStopMode(left, "break")  
  SetStopMode(right, "break")
}

StopEngines=function(left, right)
{
  Stop(left)
  Stop(right)
}

CheckInfraredVariance=function(infrared, control)
{
  if(is.null(control$inf.var.thr))
    return (NULL)
    
  while( var( InfraredSamples(infrared, 3, 0.1) )  > control$inf.var.thr)    
    Scare()  
}


DriveStartControl=function(left, right, control)
{    
  if(is.null(control$lgo) | is.null(control$rgo))
  {
    SetRunMode(left, "forever")
    SetRunMode(right, "forever")
  }
  else
  {
    SetRunMode(left, "position")
    SetRunMode(right, "position")
    SetPositionMode(left, "relative")
    SetPositionMode(right, "relative")        
    SetPositionSP(left, control$lgo)
    SetPositionSP(right, control$rgo)    
    SetPosition(left, 0)
    SetPosition(right, 0)        
  }  
  
  Run(left)
  Run(right)       
}

SpeakWhy=function(check)
{      
  if(!is.na(check$ltouch) && check$ltouch==1 || !is.na(check$rtouch) && check$rtouch==1)
    SpeakPL("Brak kontaktu")    
  if(!is.na(check$cliff) && check$cliff)
    SpeakPL("Przepaść")  
  if(!is.na(check$obstacle) && check$obstacle)
    SpeakPL("Przeszkoda")
  if(!is.na(check$ldc) && check$ldc==1 || !is.na(check$rdc) && check$rdc==1)
    SpeakPL("Kolizja")
}

gdata=matrix(0L, nrow=1000L, ncol=10, dimnames=list(c(), c("inf", "head", "lt", "rt", "ldc", "rdc", "lst", "rst", "lpos", "rpos")))

PrepareControl=function(control)
{
  if(is.null(control$inf.up)) control$inf.up=NA
  if(is.null(control$inf.down)) control$inf.down=NA
  if(is.null(control$lt)) control$lt=NA
  if(is.null(control$rt)) control$rt=NA
  if(is.null(control$inf.var.thr)) control$inf.var.thr=NA
  if(is.null(control$ldc.thr)) control$ldc.thr=100
  if(is.null(control$rdc.thr)) control$rdc.thr=100  
  if(is.null(control$pps.sp)) control$pps.sp=300      
  if(is.null(control$get.readings)) control$get.readings=FALSE
  control
}

DriveSafely2=function(control)
{  
  control=PrepareControl(control)
  PrepareEngines(left, right, control)
  gdata[1,]=GetReadings2(left, right, gyro, infrared, ltouch, rtouch)
  if(any( unlist(CheckConditions2(gdata[1,], control)), na.rm=TRUE))
    return (gdata[c(1,1),])
  
  r=2
  DriveStartControl(left, right, control)
  
  while(Running(right) || (Running(left) ))
  {
    gdata[r,]=GetReadings2(left, right, gyro, infrared, ltouch, rtouch)
    if(any( unlist(CheckConditions2(gdata[r,], control)), na.rm=TRUE))
      StopEngines(left, right)
    r=r+1
  }
  
  gdata[r,]=GetReadings2(left, right, gyro, infrared, ltouch, rtouch)
  
  SpeakWhy(CheckConditions2(gdata[r], control))
#  CheckInfraredVariance(infrared, control)
  if(control$get.readings)
    return (gdata[1:r,])
  else
    return (gdata[c(1,r),])
}

DriveSafely=function(control)
{
  PrepareEngines(left, right, control)
  start=GetReadings(left, right, gyro, infrared, ltouch, rtouch)
  if(any( unlist(CheckConditions(start, control)), na.rm=TRUE))
    return (data.frame(rbind(start, end=start)))
  
  DriveStartControl(left, right, control)
  
  while(Running(right) || (Running(left) ))
  {
    end=GetReadings(left, right, gyro, infrared, ltouch, rtouch)
    if(any( unlist(CheckConditions(end, control)), na.rm=TRUE))
      StopEngines(left, right)
  }
  
  end=GetReadings(left, right, gyro, infrared, ltouch, rtouch)
  
  SpeakWhy(CheckConditions(end, control))
  CheckInfraredVariance(infrared, control)
    
  data.frame(rbind(start, end))
}