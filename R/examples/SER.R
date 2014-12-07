left=large.motor(ports$OUTPUT_C ) 
right=large.motor(ports$OUTPUT_B ) 

ltouch=touch.sensor(ports$INPUT_2)
rtouch=touch.sensor(ports$INPUT_3)
infrared=infrared.sensor(ports$INPUT_AUTO)
gyro=xg1300l.sensor(ports$INPUT_AUTO)

SpeakPL=function(..., sync=TRUE)
{
  text=paste(list(...), collapse="")
  command=paste("espeak -a 200 -v pl --stdout \"", text, "\" | aplay", collapse="")  
  if(!sync) command=paste(command, "&")
  system(command, intern=TRUE, ignore.stderr=TRUE)
}

InitDriveMotor=function(m)
{
  SetRegulationMode(m, "on")
  SetRampUpSP(m, 1000)
  SetRampDownSP(m, 1000)
  SetPulsesPerSecondSP(m, 300)
  SetStopMode(m, "coast")
  SetModeToPosition(m)
}
SetModeToPosition=function(m)
{
  SetRunMode(m, "position")  
  SetPositionMode(m, "relative")
  SetPosition(m, 0)  
}

StopEngines=function(left, right)
{
  Stop(left)
  Stop(right)
}

FollowInfrared=function()
{
  forward_thr=3L
  max_speed=600L
  SetMode(infrared, "IR-SEEK")
  SetRunMode(left, "forever")  
  SetRunMode(right, "forever")  
    
  SetPulsesPerSecondSP(left, 0)
  SetPulsesPerSecondSP(right, 0)
  
  Run(left)
  Run(right)
  
  while(Value(infrared, 1L)!=-128L)
  {
    heading=Value(infrared)
        
    if(abs(heading)>forward_thr)
    {
      target_speed=(heading-sign(heading)*forward_thr) / (25L-forward_thr) * max_speed      
      SetPulsesPerSecondSP(left, target_speed)
      SetPulsesPerSecondSP(right, -target_speed)      
    }
    else
    {
      SetPulsesPerSecondSP(left, 0)
      SetPulsesPerSecondSP(right,0)                            
    }    
    Sys.sleep(0.1)
  }  
  StopEngines(left, right)
}

RemoteControl=function(inf_thr=40)
{
  SetMode(infrared, "IR-REMOTE")
  SetRunMode(left, "forever")  
  SetRunMode(right, "forever")  
  
  SetPulsesPerSecondSP(left, 0L)
  SetPulsesPerSecondSP(right, 0L)
  
  Run(left)
  Run(right)
  
  button=integer(1)
  
  while( ( button <- Value(infrared) ) != 9 ) # Beacon
  {
    sleft=switch(button+1, 0L,  300L, -300L, 0L, 0L, 300L, 300L, -300L, -300L, 0L, 0L, 0L)
    sright=switch(button+1, 0L,  0L, 0L, 300L, -300L, 300L, -300L, 300L, -300L, 0L, 0L, 0L)
 
    if((Value(ltouch)==0L || Value(rtouch)==0L) && (sleft>0 || sright>0) )
      sleft=sright=0L
        
    SetPulsesPerSecondSP(left, sleft)
    SetPulsesPerSecondSP(right, sright)    
      
  }
  StopEngines(left, right)
}

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


TestDutyCycle=function(cm)
{  
  size=100L
  readings=1L
  
  left_states=character(size)
  right_states=character(size)
  ldc=integer(size)
  rdc=integer(size)
  
  SetModeToPosition(left)
  SetModeToPosition(right)
  
  DriveStart(left, right, cm)  
  
  while(Running(left) || Running(right))
  {
    left_states[readings]=State(left)
    right_states[readings]=State(right)
    ldc[readings]=DutyCycle(left)
    rdc[readings]=DutyCycle(right)
    readings=readings+1L
    
    #Sys.sleep(0.01)
  }    
  
  span=1L:(readings-1L)
  
  data.frame(left_states = left_states[span], right_states = right_states[span], ldc=ldc[span], rdc=rdc[span] )
}

DriveDutyCycle=function(cm, ldc.thr, rdc.thr)
{
  pos=CMToDrivePosition(cm)
  control=list(lgo=pos, rgo=pos, pps.sp=300L, ldc.thr=ldc.thr, rdc.thr=rdc.thr)
  
  DriveSafely2(control)
}

MotorFactor=function(m)
{
  factor(State(m), c("idle", "ramp_const", "ramp_down", "ramp_up", "position_ramp_down"))
}


GetReadings2=function(left, right, gyro, infrared, ltouch, rtouch)
{
  c(Value(infrared), Value(gyro), Value(ltouch), Value(rtouch), DutyCycle(left), DutyCycle(right), MotorFactor(left), MotorFactor(right), Position(left), Position(right) )
}


CheckConditions2=function(readings, control)
{  
  r=readings
  c=control
    
#c(Value(infrared), Value(gyro), Value(ltouch), Value(rtouch), DutyCycle(left), DutyCycle(right), MotorFactor(left), MotorFactor(right), Position(left), Position(right) )
  list(cliff=r[1] > c$inf.up, obstacle=r[1] < c$inf.down,
       ltouch = (r[3] == c$lt), rtouch = (r[4] == c$rt),  
       ldc = r[7] == 2 && abs(r[5]) > c$ldc.thr,
       rdc = r[8] == 2 && abs(r[6]) > c$rdc.thr)
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
  
  SpeakWhy(CheckConditions2(gdata[r-1,], control))
  
  gdata[r,]=GetReadings2(left, right, gyro, infrared, ltouch, rtouch)
  
  
  #  CheckInfraredVariance(infrared, control)
  if(control$get.readings)
    return (gdata[1:r,])
  else
    return (gdata[c(1,r),])
}

gdata=matrix(0L, nrow=1000L, ncol=10, dimnames=list(c(), c("inf", "head", "lt", "rt", "ldc", "rdc", "lst", "rst", "lpos", "rpos")))

InitDriveMotor(left)
InitDriveMotor(right)


