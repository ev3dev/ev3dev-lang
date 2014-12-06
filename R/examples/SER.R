left=large.motor(ports$OUTPUT_C ) 
right=large.motor(ports$OUTPUT_B ) 

ltouch=touch.sensor(ports$INPUT_2)
rtouch=touch.sensor(ports$INPUT_3)
infrared=infrared.sensor(ports$INPUT_AUTO)
gyro=xg1300l.sensor(ports$INPUT_AUTO)

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

RemoteControl=function()
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
    
    SetPulsesPerSecondSP(left, sleft)
    SetPulsesPerSecondSP(right, sright)    
    
    Sys.sleep(0.1)
  }
  StopEngines(left, right)
}

InitDriveMotor(left)
InitDriveMotor(right)

